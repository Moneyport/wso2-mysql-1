#!/bin/bash

while getopts h:u:p:d:i: option
do
    case "${option}" in
        h) DBHOST=${OPTARG};;
        u) DBUSER=${OPTARG};;
        p) DBPASS=${OPTARG};;
        d) DFSPID=${OPTARG};;
    esac
done

#CMD sh ./startup.sh -e ${ENVIRONMENT} -h ${DBHOST} -u${DBUSER} -p${DBPASS}

if [ -z $DBHOST ] || [ -z $DBUSER ] || [ -z $DBPASS ] 
then
    echo " "
    echo "Missing arguments"
    echo "usage: ./add-whitelist.sh -h DBHOST -u DBUSER -p DBPASS [-d DFSPID]"
    echo " "
    exit
fi

export MYSQL_PWD=$DBPASS

echo ""
echo ""

echo "PRINTING WHITELIST FROM DATABASE"
if [ -z $DFSPID ]
then
    mysql -h $DBHOST -u $DBUSER -e "USE wso2_addons; SELECT * FROM whitelist ORDER BY dfsp_id;"
else
    mysql -h $DBHOST -u $DBUSER -e "USE wso2_addons; SELECT * FROM whitelist WHERE dfsp_id = '${DFSPID}' ORDER BY dfsp_id;"
fi
# echo $sqlresponse

echo " "
echo " "