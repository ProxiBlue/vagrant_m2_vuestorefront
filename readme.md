# Magento 2 Vagrant + Docker [ Vue Store Front ] development environment

## A Work in Progress 

This is a local development environment, to make working with magento 2 and vueStorefront a bit easier to get up and running, in a repeatable, self contained environment.

## Requirements

* Vagrant 2.2.5 or greater
* Docker 18.09.7 or greater
* vagrant plugin: https://github.com/devopsgroup-io/vagrant-hostmanager

## Layout / Structure

The environment starts up multiple Docker instances, for magento 2 and vueStorefront, with known fixed ips

* magento : 172.20.0.200 
* redis : 172.20.0.201 
* elasticsearchm2 : 172.20.0.202
* rabbitmq : 172.20.0.203
* mysql : 172.20.0.300
* elasticsearch : 172.20.0.204
* kibana : 172.20.0.205
* vueapi : 172.20.0.206
* vuestorefront : 172.20.0.207 

## Quick Start

* clone this repo ```git clone https://github.com/ProxiBlue/vagrant_m2_vuestorefront.git```
* set a local dev domain: ```export DEV_DOMAIN=<DOMAIN YOU WANT TO USE>```
* set var that is mysql root password: ```export MYSQL_ROOT_PASSWORD=<MYSQL PASSWORD YOU WANT TO USE>```
* cd into the cloned repo: ```cd vagrant_m2_vuestorefront```
* create folder: ```mkdir sites```
* cd into: ```cd sites```
* clone: ```git clone https://github.com/DivanteLtd/vue-storefront.git vue-storefront```
* clone: ```git clone https://github.com/DivanteLtd/vue-storefront-api.git vue-storefront-api```
* create folder: ```mkdir magento2```




Only the magento instance is SSH capable, and is the primary instance
running ```vagrant ssh``` will enter the magento instance

The magento source code is expected to reside in the ```[base folder of this environment]\sites\magento2``` folder 
[ HOST ] and inside the Docker instance will be available as /vagrant/sites/magento2

## Fetch environment

* Clone this repo to your local machine
* run on host : ```sudo echo "172.20.0.200 magento.enjo.test >> /etc/hosts"```

All other commands are expected to be run from within this cloned folder

## Start environment

* run on host : ```vagrant up```

you can now enter the environment using : ```vagrant ssh``` (this will be the magento docker instance)

## Halt entire environment

* run on host : ```vagrant halt```

## Halt specific Docker instance

* run on host : ```vagrant halt [magento|redis|elasticsearch|rabbitmq]```

## Start specific Docker instance

* run on host : ```vagrant start [magento|redis|elasticsearch|rabbitmq]```

## Update docker image of specific Docker instance

* run on host : ```vagrant stop [magento|redis|elasticsearch|rabbitmq]```
* run in host : ```vagrant destroy [magento|redis|elasticsearch|rabbitmq]```
* run on host : ```docker rmi $(docker images |grep [magento|redis|elasticsearch|rabbitmq] | awk '{print $3}')```
* run on host : ```vagrant up [magento|redis|elasticsearch|rabbitmq]```

## Migrate old dev environment over:

* copy the entire folder from ```[old environment]/sites/m2``` to ```[new environment]\sites\magento2```

example being inside new environment folder: ```cp -xav ~/workspace/vagrant/sites/m2 ./sites/magento```

## OMG, docker hub is offline!

Don't fear, you can initiate a local build of your environment. 
It can take a while (about 20 minutes), but only needs to build once

Edit the Vagrant file.
Find this line: ```d.image = "enjo/magento2:latest"``` and has it out
The next line: ```#d.build_dir = "./Docker/magento"``` unhash

Now you can run all the same commands, but the initial up will build the docker image locally

## Some environment details

### SSH

You HOST user .ssh folder is mounted within the magento Docker box under /home/vagrant/.ssh (vagrant is your default 
user inside the Docker environment)
This allow you to ssh from within the vagrant environment to any external resources, as all yoru keys are available, 
including your hosts config file.

### GUI applications

Your HOST x11-org SOCKET is also mounted within the magento Docker box.
This will allow you to run any gui application from within teh Docker box, but the GUI will appear in the HOST, as if 
the application runs on teh HOST

try for example:

* export DISPLAY=:0 && google-chrome --no-sandbox

### Composer auth / config

Your HOST ~/.composer/ folder is mounted within the magento Docker box. Thsi allows you to place coposer auth.json 
in your usual home folder on the HOST, and that authentication file will be used with composer in the Docker environment

### ngrok (expose dev instance to external)

ngrok makes it possible to test the site from a mobile, or to allow someone to view the code/functionality on your 
dev machine, prior to deployment to any server, or code commit to repo
Mostly it is used for mobile testing
You will need a free authtoken form https://dashboard.ngrok.com


* ssh into vagrant
* run ```ngrok http https://<SITE URL>```

You can access ngrok admin port on 172.20.0.200:4040

## Debugging startup

If you find that one of the docker instacnes is not persisting, it is likely there is a startup issue with the packages
within that docker instance.

Do:

* ```docker ps -a``` to get the instacne id of the problematic instance
* ```docker logs <INSTANCE ID>``` to get the output of that instance startup console, which can help debug the issue



