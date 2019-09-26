#!/bin/bash

source /home/vagrant/myvars.sh

for file in /vagrant/nginx/*
do
    echo "PLACING NGINX CONFIG: ${file}"
    FILENAME=`basename ${file}`
     envsubst '${DEV_DOMAIN}' < ${file} > /etc/nginx/sites-enabled/${FILENAME}
done