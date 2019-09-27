#!/bin/bash

DEV_DOMAIN=$1
echo "==================== BOOTSTRAP ==========================="
export DEV_DOMAIN=$DEV_DOMAIN

#cp -xa /vagrant/auth.json /home/vagrant/.composer/auth.json
chown vagrant:vagrant /home/vagrant/.composer -R
# ref: https://www.scalix.com/wiki/index.php?title=Configuring_Sendmail_with_smarthost_Ubuntu_Gutsy
cp -xa /vagrant/sendmail/* /etc/mail/
echo "172.20.0.200 magento" >>/etc/hosts
echo "172.20.0.201 redis " >>/etc/hosts
echo "172.20.0.202  elasticsearch" >>/etc/hosts
echo "172.20.0.203  rabbitmq" >>/etc/hosts

export GIT_VESRION=$(git --version |awk '{print $3}')
wget -q https://raw.githubusercontent.com/git/git/v${GIT_VESRION}/contrib/completion/git-completion.bash
mv ./git-completion.bash /home/vagrant
source /home/vagrant/git-completion.bash

envsubst '${DEV_DOMAIN}' < /etc/nginx/sites-available/magento > /etc/nginx/sites-enabled/magento
service nginx stop
service nginx start



