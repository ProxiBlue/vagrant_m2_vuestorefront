#!/bin/bash

DEV_DOMAIN=$1
echo "==================== BOOTSTRAP ==========================="
echo "WE HAVE ${DEV_DOMAIN}"

export DEV_DOMAIN=$DEV_DOMAIN

#cp -xa /vagrant/auth.json /home/vagrant/.composer/auth.json
chown vagrant:vagrant /home/vagrant/.composer -R
# ref: https://www.scalix.com/wiki/index.php?title=Configuring_Sendmail_with_smarthost_Ubuntu_Gutsy
cp -xa /vagrant/sendmail/* /etc/mail/
echo "127.0.0.1 magento " >>/etc/hosts
echo "172.20.0.201 redis " >>/etc/hosts
echo "172.20.0.202  elasticsearch" >>/etc/hosts
echo "172.20.0.203  rabbitmq" >>/etc/hosts

envsubst '${DEV_DOMAIN}' < /etc/nginx/sites-available/magento > /etc/nginx/sites-enabled/magento
service nginx stop
service nginx start



