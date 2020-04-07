#!/bin/bash

while getopts h:u:p:d:i: option
do
    case "${option}" in
        h) DBHOST=${OPTARG};;
        u) DBUSER=${OPTARG};;
        p) DBPASS=${OPTARG};;
        d) DFSPID=${OPTARG};;
        i) IPADDRESS=${OPTARG};;
    esac
done

#CMD sh ./startup.sh -e ${ENVIRONMENT} -h ${DBHOST} -u${DBUSER} -p${DBPASS}

if [ -z $DBHOST ] || [ -z $DBUSER ] || [ -z $DBPASS ] || [ -z $DFSPID ] || [ -r $IPADDRESS ]
then
    echo " "
    echo "Missing arguments"
    echo "usage: ./add-whitelist.sh -h DBHOST -u DBUSER -p DBPASS -d DFSPID -i IPADDRESS"
    echo " "
    exit
fi

export MYSQL_PWD=$DBPASS

echo ""
echo ""

echo "ADDING WHITELIST TO DATABASE"
mysql -h $DBHOST -u $DBUSER -e "USE wso2_addons; INSERT INTO whitelist (dfsp_id, ip_address) VALUES ('${DFSPID}','${IPADDRESS}');"

mysql -h $DBHOST -u $DBUSER -e "USE wso2_addons; SELECT * FROM whitelist WHERE dfsp_id = '${DFSPID}'"
# echo $sqlresponse

echo " "
echo " "