#!/bin/bash

export DEV_DOMAIN=$1
export WEB_IP=$2

echo "==================== BOOTSTRAP ==========================="
chown vagrant:vagrant /home/vagrant/.composer -R
export GIT_VESRION=$(git --version |awk '{print $3}')
wget -q https://raw.githubusercontent.com/git/git/v${GIT_VESRION}/contrib/completion/git-completion.bash
source /home/vagrant/git-completion.bash

echo Setting NGINX site config file....
envsubst '${DEV_DOMAIN} ${WEB_IP}' < /tmp/magento > /etc/nginx/sites-enabled/magento

service nginx stop
sleep 5
service nginx start

## to start a debug session for CLI
# export XDEBUG_CONFIG="remote_enable=1 remote_mode=req remote_port=9000 remote_host=172.17.0.1 remote_connect_back=0"



