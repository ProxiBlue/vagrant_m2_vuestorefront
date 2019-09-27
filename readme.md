# Magento 2 Vagrant + Docker [ Vue Store Front - WIP ] development environment

## Requirements

* Vagrant 2.2.5 or greater
* Docker 18.09.7 or greater

## Layout / Structure

The environment starts up 4 Docker instances, each being a self contained part of the needed environment required to run magento 2
Each is assigned a fixed IP

* magento : 172.20.0.200 : exposes ports 80, 443, 9000
* redis : 172.20.0.201 : exposes ports 6379
* elasticsearch : 172.20.0.202 : exposes ports 9200
* rabbitmq : 172.20.0.203

Only the magento instance is SSH capable, nad is the primary instance
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

