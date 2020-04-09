#!/bin/bash

while getopts h:u:p:w:x:d: option
do
    case "${option}" in
        h) DBHOST=${OPTARG};;
        u) DBUSER=${OPTARG};;
        p) DBPASS=${OPTARG};;
        w) WHITELISTUSER=${OPTARG};;
        x) WHITELISTPASS=${OPTARG};;
        d) DROPDBIFEXISTS=${OPTARG};;
    esac
done

#CMD sh ./startup.sh -e ${ENVIRONMENT} -h ${DBHOST} -u${DBUSER} -p${DBPASS}

if [ -z $DBHOST ] || [ -z $DBUSER ] || [ -z $DBPASS ] || [ -z $WHITELISTUSER ] || [ -r $WHITELISTPASS ]
then
    echo " "
    echo "Missing arguments"
    echo "usage: ./init-wso2-addons.sh -h DBHOST -u DBUSER -p DBPASS -w WHITELISTUSER -x WHITELISTPASS -d DROPDBIFEXISTS <y | n>"
    echo " "
    exit
fi

export MYSQL_PWD=$DBPASS

echo ""
echo ""

echo "VERIFYING USER ACCOUNTS"
count=$(mysql -h ${DBHOST} -u ${DBUSER} -e "select count(1) from mysql.user where user = '${WHITELISTUSER}' and host = 'localhost';" -N -B)
if [ $count -eq 0 ]
then    
    echo " - creating user [${WHITELISTUSER}@localhost]"
    mysql -h $DBHOST -u $DBUSER -e "create user if not exists '${WHITELISTUSER}'@'localhost' IDENTIFIED BY '${WHITELISTPASS}';"
else
    echo "   user [${WHITELISTUSER}@localhost] exists"
fi
count=$(mysql -h ${DBHOST} -u ${DBUSER} -e "select count(1) from mysql.user where user = '${WHITELISTUSER}' and host = '%';" -N -B)
if [ $count -eq 0 ]
then    
    echo " - creating user [${WHITELISTUSER}@%]"
    mysql -h $DBHOST -u $DBUSER -e "create user if not exists '${WHITELISTUSER}'@'%' IDENTIFIED BY '${WHITELISTPASS}';"
else
    echo "   user [${WHITELISTUSER}@%] exists"
fi

echo ""
echo ""
if [ "$DROPDBIFEXISTS" = "y" ]; then
    echo "DELETING DATABASE"
    echo " - deleting wso2_addons"
    count=$(mysql -h ${DBHOST} -u ${DBUSER} -e "select count(*) from information_schema.SCHEMATA where schema_name in ('wso2_addons');" -N -B)
    if [ $count -eq 0 ]
    then
        echo "   database does not exist"
    else    
        echo "   database exists, continuing to delete"
        mysql -h $DBHOST -u $DBUSER -e "DROP DATABASE IF EXISTS wso2_addons;"
        count=$(mysql -h ${DBHOST} -u ${DBUSER} -e "select count(*) from information_schema.SCHEMATA where schema_name in ('wso2_addons');" -N -B)
        if [ $count -eq 0 ]
        then
            echo "   database delete"
        else
            echo "   database not deleted"
        fi
    fi
fi

echo ""
echo ""
echo "CREATING DATABASE"
count=$(mysql -h ${DBHOST} -u ${DBUSER} -e "select count(*) from information_schema.SCHEMATA where schema_name in ('wso2am_addons');" -N -B)
if [ $count -eq 0 ]
then
    echo " - creating database wso2_addons"
    mysql -h $DBHOST -u $DBUSER -e "create database wso2_addons;"    

    echo " - creating table [whitelist]"
    mysql -h $DBHOST -u $DBUSER -e "USE wso2_addons; CREATE TABLE whitelist (dfsp_id varchar(50) NOT NULL, ip_address varchar(50) NOT NULL, PRIMARY KEY (ip_address,dfsp_id)) ENGINE=InnoDB DEFAULT CHARSET=latin1;"

    echo " - granting privileges"
    mysql -h $DBHOST -u $DBUSER -e "GRANT ALL PRIVILEGES ON wso2_addons.* TO '${WHITELISTUSER}'@'localhost';"
    mysql -h $DBHOST -u $DBUSER -e "GRANT ALL PRIVILEGES ON wso2_addons.* TO '${WHITELISTUSER}'@'%';"
    mysql -h $DBHOST -u $DBUSER -e "FLUSH PRIVILEGES;"
    echo " "
    echo " "
fi