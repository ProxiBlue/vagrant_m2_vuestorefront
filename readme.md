# Vagrant vueStoreFront + Magento 2 (using Docker) development environment
 
This is a local development environment, to make working with magento 2 and vueStorefront a bit easier to get up and running, in a repeatable, self contained environment.

* NOTE: This was done on Linux, using Debian based distro, and uses Docker as the VM engine. 
* Some parts *may* be Linux specific (like linking in the home user .ssh folder for ssh-keys)

## Requirements

* Vagrant 2.2.5 or greater (important, will not work with older vagrant versions)
* Docker 18.09.7 or greater
* vagrant plugin: https://github.com/devopsgroup-io/vagrant-hostmanager
* vagrant plugin: ```vagrant plugin install docker-api```
* vagrant plugin: https://github.com/ProxiBlue/vagrant-communicator-docker

## Layout / Structure

The environment starts up multiple Docker instances, for magento 2 and vueStorefront, with known fixed ips
You can set the base IP range in teh Vagrant file. example: ip_range = "172.20.0"

* magento : 172.20.0.200 
* redis : 172.20.0.201 
* elasticsearch : 172.20.0.202
* database : 172.20.0.208 
* kibana : 172.20.0.205
* vueapi : 172.20.0.206
* vuestorefront : 172.20.0.207 
* reverseproxy : 172.20.0.210 (conditional, see section about Reverse Proxy) 

## Quick(ish) Start

* clone this repo ```git clone https://github.com/ProxiBlue/vagrant_m2_vuestorefront.git```
* set a local dev domain: ```export DEV_DOMAIN=<DOMAIN YOU WANT TO USE>```
* cd into the cloned repo: ```cd vagrant_m2_vuestorefront```
* create folder: ```mkdir sites```
* cd into: ```cd sites```
* clone: ```git clone https://github.com/DivanteLtd/vue-storefront.git vue-storefront```
* clone: ```git clone https://github.com/DivanteLtd/vue-storefront-api.git vue-storefront-api```
* create folder: ```mkdir magento2```
* bring up the database instance: ```vagrant up database```
* bring up the magento instance: ```vagrant up magento``` (ignore error: The SSH command responded with a non-zero exit status)
* ssh into instance ```vagrant ssh```, and install magento files (any way you like) example: ```composer create-project --repository=https://repo.magento.com/ magento/project-community-edition ./``` 
* then ```mysqladmin -u root -h database.<YOUR DOMAIN> -p  create magento``` (password = root)
* then ```exit``` to exit vagrant, and reload ```vagrant reload magento``` (will now start without error)
* browse to ```https://magento.<THE DEV DOMAIN YOU USE>``` and install magento 2. The database server will be ```database.<YOUR DOMAIN>```
    * you might want to install sample data: https://devdocs.magento.com/guides/v2.3/install-gde/install/cli/install-cli-sample-data.html
    * if you find you get Gateway Error, ssh into vagrant, and start php fpm (```sudo service php7.3-fpm start```)
* Follow this guide, and setup magento OAuth keys: https://docs.vuestorefront.io/guide/installation/magento.html 
    * you want to stop here: ```yarn mage2vs import``` - you only want to do the OAuth keys, not the import, that is the next step!
* Install https://github.com/DivanteLtd/magento2-vsbridge-indexer
    * ```vagrant ssh```
    * ```composer require divante/magento2-vsbridge-indexer```
    * ```composer require divante/magento2-vsbridge-indexer-msi:0.1.0```   
    
    NOTE: Magent 2.3.5 /  Elasticsearch 7: ```divante/magento2-vsbridge-indexer``` should be substituted with ```"divante/magento2-vsbridge-indexer": "2.x-dev"```
    NOTE: Remember to set the elastic version use din the config here: https://github.com/DivanteLtd/vue-storefront-api/blob/master/config/default.json#L42 (naturally,edit your config file, not the default one)
     
    * configure as per their guide, and re-index.
    
* Edit the rest of vueStorefront configs, and set according to YOUR needs
    * Note that you can set the following, in accordance to this environment: 
        * redis host: ```redis```
        * elasticsearch host: ```elasticsearch```
        * vueStorefront api host: ```vueapi```
        * magento host: ```magento.<YOUR DOMAIN>``` (you must use the FQDN for magento, else magento will redirect)
        * vueStorefront : ```vuestorefront```
        * magento 2 vue image assetPath: ```"assetPath": "/vagrant/sites/magento2/pub/media"``` (https://github.com/DivanteLtd/vue-storefront/blob/master/docs/guide/basics/recipes.md#running-vue-storefront-api-on-a-different-machine-than-magento--images-not-working)
    * You can also use the FQDN with your set dev domain for any of the above    
    * If you have activated the reverse proxy, you can use api.<YOUR DEV DOMAIN> for all hosts, as they will go via the proxy.
 
 It is advised to use the proxy, as it allows you to completely hide the actual vueSF and API urls from the client.
 Example: 
 
     * http://vueapi:8080/api/ext/braintree can become https://api.enjo.test/api/ext/braintree which is the url rendered in the client browser, and the proxy will translate it to the internal url
     
       
* bring the entire environment down, then back up: ```exit``` && ```vagrant halt``` && ```vagrant up --no-parallel```
* wait a moment for vuestorefront to start. you can follow the progress using : ```docker logs -f vuestorefront``` (NOTE: this is also the best way to debug, as you will get pointed errors noted inthe console. Example, connection errors)

Done, you should be able to browse to vueStorefront using: http://vuestorefront:3000

I have found the best startup command is: ```vagrant up --no-parallel && vagrant hostmanager --provider docker``` which also re-jigs the hostmanager host file entries, as I had found that some randomly fail to get the entries created during startup.
Very likely an issue with the docker-communicator plugin, which I will need to look into solving at some point.

I place this an an alias on my linux host


## Additional things to do

### setup Kibana

* access using: http://kibana:5601

In the 'Configure-index-pattern' insert the index pattern as what was configured in magento2-vsbridge-indexer module

example: ```vue*``` will give you all the vue indexed data

It is a good idea to go do this, and confirm your data has been indexed.


Only the magento instance is SSH capable, and is the primary instance
running ```vagrant ssh``` will enter the magento instance

The magento source code is expected to reside in the ```[base folder of this environment]\sites\magento2``` folder 
[ HOST ] and inside the Docker instance will be available as /vagrant/sites/magento2


### reverse Proxy

Although you can access the vueSF store via the http://vuestorefront:3000 url, this is not always ideal. 

You can place a reverse proxy ```nginx.conf``` file into the folder ```reverseproxy```

If that file exists, an additional docker nginx instance will be brought up, and the supplied config file will be used.
You can ref the self signed cert, or place your own cert files withing the vagrant folder, to use SSL

There is an example ```nginx.conf.dist``` file that shows reverse proxy for 2 sites

You need to place the domains in your HOST machine host file, using teh IP 172.20.0.210. 

Example: ```172.20.0.210 site1.dev.proxiblue.com.au site2.dev.proxiblue.com.au```

## Other stuff

### Required environment variables:

* DEV_DOMAIN : The domain that vagrant instances will use
* MYSQL_ROOT_PASSWORD :  password to use as root for database (optional - defaults to: root)
* PERSISTENT_STORAGE : Path on your HOST where data will save for persistence. example mysql, elaticsearch

Suggest you place these into your user profile startup. (```~/bashrc```)

### Start entire environment

* run on host : ```vagrant up --no-parallel && vagrant hostmanager --provider docker```

you can now enter the environment using : ```vagrant ssh``` (this will be the magento docker instance)

### Halt entire environment

* run on host : ```vagrant halt```

### Halt specific Docker instance

* run on host : ```vagrant halt [magento|redis|elasticsearchm2|rabbitmq|elasticsearch|vueapi|vuestorefront|reverseproxy]```

### Start specific Docker instance

* run on host : ```vagrant start [magento|redis|elasticsearchm2|rabbitmq|elasticsearch|vueapi|vuestorefront|reverseproxy]```

### Update docker image of specific Docker instance

* run on host : ```vagrant stop [magento|redis|elasticsearchm2|rabbitmq|elasticsearch|vueapi|vuestorefront|reverseproxy]```
* run in host : ```vagrant destroy [magento|redis|elasticsearchm2|rabbitmq|elasticsearch|vueapi|vuestorefront|reverseproxy]```
* run on host : ```docker rmi $(docker images |grep [magento|redis|elasticsearchm2|rabbitmq|elasticsearch|vueapi|vuestorefront|reverseproxy] | awk '{print $3}')```
* run on host : ```vagrant up [magento|redis|elasticsearchm2|rabbitmq|elasticsearch|vueapi|vuestorefront|reverseproxy]```

### Migrate old dev environment over:

* copy the entire folder from ```[old environment]/sites/m2``` to ```[new environment]/sites/magento2```

example being inside new environment folder: ```cp -xav ~/workspace/vagrant/sites/m2 ./sites/magento```

### OMG, docker hub is offline!

Don't fear, you can initiate a local build of your environment. 
It can take a while (about 20 minutes), but only needs to build once

Edit the Vagrant file.
Find this line: ```d.image = "enjo/magento2:latest"``` and has it out
The next line: ```#d.build_dir = "./Docker/magento"``` unhash

Now you can run all the same commands, but the initial up will build the docker image locally

### Some environment details

#### SSH

You HOST user .ssh folder is mounted within the magento Docker box under /home/vagrant/.ssh (vagrant is your default 
user inside the Docker environment)
This allow you to ssh from within the vagrant environment to any external resources, as all your keys are available, 
including your hosts config file.

Although none of the other docker instances has SSH, you can easily drop into a shell to do stuff inside the containers:

```docker exec -it vueapi /bin/sh```

will give you a shell session inside the vueapi docker instance


#### GUI applications

Your HOST x11-org SOCKET is also mounted within the magento Docker box.
This will allow you to run any gui application from within the Docker box, but the GUI will appear in the HOST, as if 
the application runs on the HOST

try for example:

* export DISPLAY=:0 && google-chrome --no-sandbox

#### Composer auth / config

Your HOST ~/.composer/ folder is mounted within the magento Docker box. This allows you to place composer auth.json 
in your usual home folder on the HOST, and that authentication file will be used with composer in the Docker environment

#### ngrok (expose dev instance to external)

ngrok makes it possible to test the site from a mobile, or to allow someone to view the code/functionality on your 
dev machine, prior to deployment to any server, or code commit to repo
Mostly it is used for mobile testing
You will need a free authtoken form https://dashboard.ngrok.com


* ssh into vagrant
* run ```ngrok http https://<SITE URL>```

You can access ngrok admin port on 172.20.0.200:4040

#### Access database

* ssh into magento vagrant box
* mysql -u root -p -h database
* OR use a GUI client form your HOST, and access database via port 3306

#### The config overlay

Since you require custom config for vueStoreFront, you can place the appropriate local.json config files in the vuesf config folder, named ```local.json.dev```

Example:

#### Custom bootstrap.sh

Let's say there is something you would like to adjust in the main startup of the magento docker instance.
Example, this could be a modified nginx config file, or you would like to install some package you use.
So, rather than having to build your own docker image, you can place a custom bootstrap.sh file located in ```provision``` folder.
If that exists, it will be run, as root, on the magento docker instance (only)
Handy for developers who want to tweak a thing or two.

### Editing vueStoreFront Configs

```vagrant halt vueapi && vagrant halt vuestorefront && vagrant up vueapi && vagrant up vuestorefront```

The vueStoreront parts build the exact same Docker images, as supplied by them. The initial startup will thus be slightly slower, giving those once to build.
reUsing their docker builds shoudl produced greater ongoing compatibility, with ongoing features implemented to those.

REMEMBER: If you edit the local.json configs, for either service, you need to restart instances!

### Custom commands after docker startup

You can place a file called ```boot.sh```, located inside both folders on the overlay, and if it exists, the commands within will be run after a docker box comes up
example: vuestorefront-config-overlay/vue-storefront-api/boot.sh will run as soon as the instance is up

### a Reverse Proxy

Imagine you have a multistore setup. YEs, you can access the multipe stores via http://vuestorefront:3000/<STORE>, but that is hardly ideal.
You would want to access each store via a proper URL. Example store.example.com, store2.example.com etc

For this, you can create an nginx config file that you place in the reverseproxy folder. If that nginx.conf exists, an nginx instance on ip 172.20.0.210 will be brought up, and run that given nginx file

Example conf file for multipel stores:

https://gist.github.com/ProxiBlue/77589a96abdd1e9bd6b5942ab0916711


The domain ```api.<YOUR DEV DOMAIN``` will be placed into all guest machines, and your host. You can use the api.<dev_domain> address to set all connections to the local.json files

Example: 

```
"elasticsearch": {
    "host": "https://api.dev.proxiblue.com.au/api/catalog",
    "index": "vue_storefront_magento_default"
},

```

#### NOTE: 

If you use a proxy, you need to adjust the local.json configs for vuestorefront, and vue api.
The API urls need to be adjusted to be that of the PROXY, which will then hit the proxy, and be translated.

#### SSL certificate

* I found this tool to allow creation of self-signed, but 'trusted' self certs: https://github.com/FiloSottile/mkcert
* Install this tool, and generate a new self signed cert for your dev domain

The run:

* ```mkcert -install```
* ```mkcert <YOUR DEV DOMAIN>```

You will be given 2 x .pem file, one for the cert, the other for the key. Copy them into the ```reverseproxy``` folder.

### Ability to connect a debugger (example from PHPStorm)

1. VueStoreFront

You need to make two edits to the vueSF files. 

Edit ```sites/vue-storefront/pacakge.json```, and find the entry for ```dev:inspect``` and in that line, replace ```node --inspect``` with ```node --inspect=0.0.0.0:9229```
This will tell the debugger listener to listen on all interfaces. Default is localhost only, and since this is in a docker, you will not be able to export that to external.
** You may also need to edit the ending part and change ```server``` to ```server.ts``` ** 

Edit ```sites/vue-storefront/docker/vue-storefront/vue-storefront.sh``` and replace ```yarn dev``` with ```yarn dev:inspect```

Now issue a reload of vuestorefront: ```vagrant reload vuestorefront```

Next setup your debugger connection to listen to the IP of vuestorefront (172.20.0.207)

2. Vue API

You need to make two edits to the api files. 

Edit ```sites/vue-storefront-api/pacakge.json```, and find the entry for ```dev:inspect``` and in that line, replace ```node --inspect``` with ```node --inspect=0.0.0.0:9229```
This will tell the debugger listener to listen on all interfaces. Default is localhost only, and since this is in a docker, you will not be able to export that to external.

Edit ```sites/vue-storefront-api/docker/vue-storefront-api/vue-storefront-api.sh``` and replace ```yarn dev``` with ```yarn dev:inspect```

Now issue a reload of vuestorefrontapi: ```vagrant reload vueapi```

Next setup your debugger connection to listen to the IP of vueapi (172.20.0.206)


### Debugging startup

If you find that one of the docker instacnes is not persisting, it is likely there is a startup issue with the packages
within that docker instance.

Do:

* ```docker logs -f [vuestorefront|vueapi]``` to get the output of that instance startup console, which can help debug the issue

Example:

* Accessing the storefront on url: http://vuestorefront:3000/ I get 500 internal server error (something went wrong)
* To figure out, I tail the log on vuestorefront using ```docker logs -f vuestorefront```

In that tail, I see:

```
Error: request to http://localhost:8080/api/catalog/vue_storefront_magento_default/product/_search?_source_exclude=%2A.msrp_display_actual_price_type%2Crequired_options%2Cupdated_at%2Ccreated_at%2Cattribute_set_id%2Coptions_container%2Cmsrp_display_actual_price_type%2Chas_options%2Cstock.manage_stock%2Cstock.use_config_min_qty%2Cstock.use_config_notify_stock_qty%2Cstock.stock_id%2Cstock.use_config_backorders%2Cstock.use_config_enable_qty_inc%2Cstock.enable_qty_increments%2Cstock.use_config_manage_stock%2Cstock.use_config_min_sale_qty%2Cstock.notify_stock_qty%2Cstock.use_config_max_sale_qty%2Cstock.use_config_max_sale_qty%2Cstock.qty_increments%2Csmall_image%2Csgn%2C%2A.sgn&from=0&request=%7B%22query%22%3A%7B%22bool%22%3A%7B%22filter%22%3A%7B%22bool%22%3A%7B%22must%22%3A%5B%7B%22terms%22%3A%7B%22category.name.keyword%22%3A%5B%22Tees%22%5D%7D%7D%2C%7B%22terms%22%3A%7B%22visibility%22%3A%5B2%2C3%2C4%5D%7D%7D%2C%7B%22terms%22%3A%7B%22status%22%3A%5B0%2C1%5D%7D%7D%5D%7D%7D%7D%7D%7D&size=8&sort=created_at%3Adesc failed, reason: connect ECONNREFUSED 127.0.0.1:8080

```

which clearly points to having incorrectly configured the connection to the API in vuestorefront local.json

```
    "api": {
      "url": "http://localhost:8080"
    },
```

should be

```
    "api": {
      "url": "http://vueapi:8080"
    },
```

and then I run 

```vagrant halt vueapi && vagrant halt vuestorefront && vagrant up vueapi && vagrant up vuestorefront```

to get that change reloaded

### rebuild all hostfile entries

force having all host entries re-done

```vagrant hostmanager --provider docker```

output:

```
[vagrant-hostmanager:guest] Updating hosts file on the virtual machine magento...
[vagrant-hostmanager:guest] Updating hosts file on the virtual machine database...
[vagrant-hostmanager:guest] Updating hosts file on the virtual machine redis...
[vagrant-hostmanager:guest] Updating hosts file on the virtual machine elasticsearchm2...
[vagrant-hostmanager:guest] Updating hosts file on the virtual machine rabbitmq...
[vagrant-hostmanager:guest] Updating hosts file on the virtual machine elasticsearch...
[vagrant-hostmanager:guest] Updating hosts file on the virtual machine kibana...
[vagrant-hostmanager:guest] Updating hosts file on the virtual machine vueapi...
[vagrant-hostmanager:guest] Updating hosts file on the virtual machine vuestorefront...
[vagrant-hostmanager:guest] Updating hosts file on the virtual machine reverseproxy...
[vagrant-hostmanager:host] Updating hosts file on your workstation (password may be required)...
```

example error in vue: ```failed, reason: getaddrinfo ENOTFOUND```

### elasticsearchm2

* vagrant status showed this machine failed to start.
* docker logs elasticsearchm2 showed "Error: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]"
* Ran sysctl -w vm.max_map_count=262144 on host machine to fix

### Docker instances are not getting assigned the new private ip ranges

You have started everything up, but there is no networking between the HOST and the docker instances, or the docker instances cannot communicate.

If you check IP allocation to the magento docker : ```vagrant ssh``` then ```ifconfig``` shows no ip range of 172.20.x.x was assigned to the instances

* You need to update vagrant!



