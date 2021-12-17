#!/bin/bash

if [[ $1 && $2 && $3 && $4 && $5 && $6 ]]
then
    echo "Creating a folder: resources"
    mkdir -p ./resources
    echo "management_access_key  = \"$2\"" >> ./resources/input.tfvars
    echo "management_secret_key  = \"$3\"" >> ./resources/input.tfvars
    echo "operational_access_key = \"$4\"" >> ./resources/input.tfvars
    echo "operational_secret_key = \"$5\"" >> ./resources/input.tfvars
    echo "Creating SSH Key for SSH connection"
    echo -e "\n"|ssh-keygen -t rsa -f ./resources/$1 -b 2048  -N ""
    echo "priv_key = \"$(cat ./resources/$1 |base64 -w 0)"\" >> ./resources/input.tfvars
    echo "pub_key = \"$(cat ./resources/$1.pub)"\" >> ./resources/input.tfvars
    echo "Generating custom certificate for Hosted Zone"
    openssl genrsa -out ./resources/$6.key 2048
    echo -e "[req]\ndistinguished_name=req\n[SAN]\nsubjectAltName=DNS:$6" > ./resources/$6.conf
    echo "Generating key of custom certificate for Hosted Zone"
    openssl req -new -x509 -key ./resources/$6.key -out ./resources/$6.cert -days 3650 -subj /CN=$6 -extensions SAN -config "./resources/$6.conf"
    echo "hosted_zone_cert = \"$(cat ./resources/$6.cert |base64 -w 0)"\" >> ./resources/input.tfvars
    echo "hosted_zone_key = \"$(cat ./resources/$6.key|base64 -w 0)"\" >> ./resources/input.tfvars
    echo "File input.tfvars has been generated" 
else
    echo 'Usage: ./setup.sh filename-for-key management-access-key management-secret-key operational-access-key operational-secret-key name-of-dns';
    echo 'Example: ./setup.sh id_rsa MNGT_ACCESS_KEY MNGT_SECRET_KEY OPT_ACCESS_KEY OPT_SECRET_KEY test.sygris.net'
fi
