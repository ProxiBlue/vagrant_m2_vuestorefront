#!/bin/bash

export DEV_DOMAIN=$1

echo "==================== CUSTOM BOOTSTRAP ==========================="

#example - copy in an alternative nginx config file
#cp -xav /vagrant/custom/magento /etc/nginx/sites-available/magento
envsubst '${DEV_DOMAIN}' < /etc/nginx/sites-available/magento > /etc/nginx/sites-enabled/magento
service nginx stop
service nginx start

## to start a debug session for CLI
# export XDEBUG_CONFIG="remote_enable=1 remote_mode=req remote_port=9000 remote_host=172.17.0.1 remote_connect_back=0"



