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
    echo "usage: ./add-whitelist.sh -h DBHOST -u DBUSER -p DBPASS -d DFSPID -i IPADDRESS_CIDR"
    echo " "
    exit
fi

export MYSQL_PWD=$DBPASS

echo ""
echo ""

echo "DELETE WHITELIST FROM DATABASE"
mysql -h $DBHOST -u $DBUSER -e "USE wso2_addons; DELETE FROM whitelist WHERE dfsp_id = '${DFSPID}' AND ip_address = '${IPADDRESS}';"

mysql -h $DBHOST -u $DBUSER -e "USE wso2_addons; SELECT * FROM whitelist WHERE dfsp_id = '${DFSPID}'"
# echo $sqlresponse

echo " "
echo " "