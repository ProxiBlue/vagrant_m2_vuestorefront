scp -i ~/.ssh/enjo_aws_private_key.pem ubuntu@magento.656ea.com:/var/www/html/current/app/etc/config.php ./sites/magento2/app/etc/config.php 
scp -i ~/.ssh/enjo_aws_private_key.pem ubuntu@magento.656ea.com:/var/www/html/current/app/etc/env.php ./sites/magento2/app/etc/env.php.live 
scp -i ~/.ssh/enjo_aws_private_key.pem ubuntu@www.656ea.com:/var/www/storefront/config/local.json ./sites/vue-storefront/config/local.json.live 
scp -i ~/.ssh/enjo_aws_private_key.pem ubuntu@www.656ea.com:/var/www/api/config/local.json ./sites/vue-storefront-api/config/local.json.live 
