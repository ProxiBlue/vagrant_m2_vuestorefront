#!/bin/bash

export DEV_DOMAIN=$1

echo "==================== BOOTSTRAP ==========================="
chown vagrant:vagrant /home/vagrant/.composer -R
export GIT_VESRION=$(git --version |awk '{print $3}')
wget -q https://raw.githubusercontent.com/git/git/v${GIT_VESRION}/contrib/completion/git-completion.bash
source /home/vagrant/git-completion.bash

envsubst '${DEV_DOMAIN}' < /etc/nginx/sites-available/magento > /etc/nginx/sites-enabled/magento
service nginx stop
service nginx start

## to start a debug session for CLI
# export XDEBUG_CONFIG="remote_enable=1 remote_mode=req remote_port=9000 remote_host=172.17.0.1 remote_connect_back=0"



