# Vagrant vueStoreFront + Magento 2 (using Docker) development environment
 
This is a local development environment, to make working with magento 2 and vueStorefront a bit easier to get up and running, in a repeatable, self contained environment.

* NOTE: This was done on Linux, using Debian based distro, and uses Docker as the VM engine. 
* Some parts *may* be Linux specific (like linking in the home user .ssh folder for ssh-keys)
* example startup: https://asciinema.org/a/AG8w9J4gCcqMmyTws3GX5qQyx

## Requirements

* Vagrant 2.2.5 or greater (important, will not work with older vagrant versions)
* Docker 18.09.7 or greater
* vagrant plugin: https://github.com/devopsgroup-io/vagrant-hostmanager
* vagrant plugin: ```vagrant plugin install docker-api```
* vagrant plugin: https://github.com/ProxiBlue/vagrant-communicator-docker

## Layout / Structure

The environment starts up multiple Docker instances, for magento 2 and vueStorefront, with known fixed ips

* magento : 172.20.0.200 
* redis : 172.20.0.201 
* elasticsearchm2 : 172.20.0.202 (for use in m2)
* rabbitmq : 172.20.0.203 (for use in m2)
* database : 172.20.0.208 (for use in m2)
* elasticsearch : 172.20.0.204
* kibana : 172.20.0.205
* vueapi : 172.20.0.206
* vuestorefront : 172.20.0.207 
* reverseproxy : 172.20.0.210 (conditional, see section about Reverse Proxy) 

## Quick(ish) Start

* clone this repo ```git clone https://github.com/ProxiBlue/vagrant_m2_vuestorefront.git```
* set a local dev domain: ```export DEV_DOMAIN=<DOMAIN YOU WANT TO USE>```
* set path to persistent storage (path must exist): ```export PERSISTENT_STORAGE=<ABSOLUTE PATH>```
    * Persistent storage is currently used for:
        * Mysql Database storage
        * Elasticsearch storage (both vueSF + Magento 2)
* cd into the cloned repo: ```cd vagrant_m2_vuestorefront```
* create folder: ```mkdir sites```
* cd into: ```cd sites```
* clone: ```git clone https://github.com/DivanteLtd/vue-storefront.git vue-storefront```
* clone: ```git clone https://github.com/DivanteLtd/vue-storefront-api.git vue-storefront-api```
* create folder: ```mkdir magento2```
* bring up the database instance: ```vagrant up database```
* bring up the magento instance: ```vagrant up magento``` (ignore error: The SSH command responded with a non-zero exit status)
* ssh into instance ```vagrant ssh```, and install magento files (any way you like) example: ```composer create-project --repository=https://repo.magento.com/ magento/project-community-edition ./``` 
* then ```mysqladmin -u root -h database -p  create magento```
* browse to ```https://magento.<THE DEV DOMAIN YOU USE>``` and install magento 2. The database server will be ```database.<YOUR DOMAIN>```
    * you might want to install sample data: https://devdocs.magento.com/guides/v2.3/install-gde/install/cli/install-cli-sample-data.html
* copy the vue config files to the overlay folder: (these actions are run on the HOST)
    * ```mkdir -p ./vuestorefront-config-overlay/vue-storefront-api/config/```
    * ```cp -xav ./sites/vue-storefront-api/config/default.json ././vuestorefront-config-overlay/vue-storefront-api/config/local.json```
    * ```mkdir -p ./vuestorefront-config-overlay/vue-storefront/config/```
    * ```cp -xav ./sites/vue-storefront/config/default.json ././vuestorefront-config-overlay/vue-storefront/config/local.json```    
* Follow this guide, and setup magento OAuth keys: https://docs.vuestorefront.io/guide/installation/magento.html (remember, you will edit the OVERLAY CONFIGS)
    * you want to stop here: ```yarn mage2vs import``` - you only want to do the OAuth keys, not the import, that is the next step!
* Install https://github.com/DivanteLtd/magento2-vsbridge-indexer
    * ```vagrant ssh```
    * ```composer require divante/magento2-vsbridge-indexer```
    * ```composer require divante/magento2-vsbridge-indexer-msi:0.1.0```    
    * configure as per their guide, and re-index.
* Edit the rest of vueStorefront configs, and set according to YOUR needs
    * Note that you can set the following, in accordance to this environment: 
        * redis host: ```redis```
        * elasticsearch host: ```elasticsearch```
        * vueStorefront api host: ```vueapi```
        * magento host: ```magento.<YOUR DOMAIN>``` (you must use the FQDN for magento, else magento will redirect)
        * vueStorefront : ```vuestorefront```
    * You can also use the FQDN with your set dev domain for any of the above    
    * If you have activated the reverse proxy, you can use api.<YOUR DEV DOMAIN> for all hosts, as they will go via teh proxy.
       
* bring the entire environment down, then back up: ```exit``` && ```vagrant halt``` && ```vagrant up```
* wait a moment for vuestorefront to start. you can follow the progress using : ```docker logs -f vuestorefront``` (NOTE: this is also the best way to debug, as you will get pointed errors noted inthe console. Example, connection errors)

Done, you should be able to browse to vueStorefront using: http://vuestorefront:3000

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

### Fetch environment

* Clone this repo to your local machine

All other commands are expected to be run from within this cloned folder

### Start environment

#### set required environment variables:

* DEV_DOMAIN : The domain that vagrant instances will use
* MYSQL_ROOT_PASSWORD :  password to use as root for database (optional - defaults to: root)
* PERSISTENT_STORAGE : Path on your HOST where data will save for persistence. example mysql, elaticsearch

Suggest you place these into your user profile startup. (```~/bashrc```)

* run on host : ```vagrant up```

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

#### The config overlay folder

Since you require custom config for vueStoreFront, you can place the appropriate local.json config files in the folder ```vuestorefront-config-overlay```, ensuring the path matches that of the parent config.

Example:

To configure a local.json for vue-storefront-api, which has its config located now in ```sites/vue-storefront-api/config/default.json``` place your local.json file in ```vuestorefront-config-overlay/vue-storefront-api/config/local.json```

Basically, and files placed in the overlay folder, matching the `parent` config folder structure, will be used instead of the `parent`
The files here are excluded from this GIT repo.
It is advised that you create a git sub-module here, so you can commit yor custom configs, and not loose them!

#### Custom bootstrap.sh

Lets say there is something you would like to adjust in the main startup of the magento docker instance.
Example, this could be a modified nginx config file, or you would like to install some package that you use.
So, rather than having to build your own docker image, you can place a custom bootstrap.sh file located in ```provision``` folder.
If that exists, it will be run, as root, on the magento docker instance (only)
Handy for developers who want to tweak a thing or two.

### Editing vueStoreFront Configs

```vagrant halt vueapi && vagrant halt vuestorefront && vagrant up vueapi && vagrant up vuestorefront```

The vueStoreront parts build the exact same Docker images, as supplied by them. The initial startup will thus be slightly slower, giving those once to build.
reUsing their docker builds shoudl produced greater ongoing compatibility, with ongoing features implemented to those.

REMEMBER: If you edit the local.json configs, for either service, you need to restart instances!

### a Reverse Proxy

Imagine you have a multistore setup. YEs, you can access the multipe stores via http://vuestorefront:3000/<STORE>, but that is hardly ideal.
You would want to access each store via a proper URL. Example store.example.com, store2.example.com etc

For this, you can create an nginx config file that you place in the reverseproxy folder. If that nginz.conf exists, an nginx instance on ip 172.20.0.210 will be brought up, and run that given nginx file
The domain ```api.<YOUR DEV DOMAIN``` will be placed into all guest machines, and your host. You can use the api.<dev_domain> address to set all connections to inthe local.json files

Example: 

```
"elasticsearch": {
    "host": "https://api.dev.proxiblue.com.au/api/catalog",
    "index": "vue_storefront_magento_default"
},

```

#### SSL certificate

* I found this tool to allow creation of self-signed, but 'trusted' self certs: https://github.com/FiloSottile/mkcert
* Install this tool, and generate a new self signed cert for your dev domain

The run:

* ```mkcert -install```
* ```mkcert <YOUR DEV DOMAIN>```

You will be given 2 x .pem file, one for the cert, the other for the key. Copy them into the ```reverseproxy``` folder.


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

### Docker instances are not getting assigned the new private ip ranges

You have started everything up, but there is no networking between the HOST and the docker instances, or the docker instances cannot communicate.

If you check IP allocation to the magento docker : ```vagrant ssh``` then ```ifconfig``` shows no ip range of 172.20.x.x was assigned to the instances

* You need to update vagrant!


