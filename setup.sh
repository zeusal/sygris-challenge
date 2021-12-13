#!/bin/bash

if [[ $1 && $2 && $3 && $4 && $5 && $6]]
then
    echo "Creating SSH Key for SSH connection"
    echo -e "\n"|ssh-keygen -t rsa -f ./$1 -b 2048  -N ""
    echo "priv_key = \"$(cat $1 |base64 -w 0)"\" >> input.tfvars
    echo "pub_key = \"$(cat $1.pub)"\" >> input.tfvars
    echo "management_access_key  = \"$2\"" >> input.tfvars
    echo "management_secret_key  = \"$3\"" >> input.tfvars
    echo "operational_access_key = \"$4\"" >> input.tfvars
    echo "operational_secret_key = \"$5\"" >> input.tfvars
    echo "Generating custom certificate for Hosted Zone"
    openssl genrsa -out ./$6.key 2048
    echo -e "[req]\ndistinguished_name=req\n[SAN]\nsubjectAltName=DNS:$6" > ./$6.conf
    echo "Generating key of custom certificate for Hosted Zone"
    openssl req -new -x509 -key ./$6.key -out 256490151058.sygris.net.cert -days 3650 -subj /CN=$6 -extensions SAN -config "$6.conf"
    echo "hosted_zone_cert = \"$(cat ./$6.cert |base64 -w 0)"\" >> input.tfvars
    echo "hosted_zone_key = \"$(cat ./$6.key|base64 -w 0)"\" >> input.tfvars
    echo "File input.tfvars has been generated" 
else
    echo 'Usage: ./setup.sh filename-for-key operational-access-key operational-secret-key management-access-key management-secret-key name-of-dns';
    echo 'Example: ./setup.sh id_rsa OPT_ACCESS_KEY OPT_SECRET_KEY MNGT_ACCESS_KEY MNGT_SECRET_KEY test.sygris.net'
fi
