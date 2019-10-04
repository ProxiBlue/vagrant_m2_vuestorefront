# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'fileutils'

# Generate a random port number
# fixes issue where two boxes try and map port 22, if you run multiple vagrant environments in one host
r = Random.new
ssh_port = r.rand(1000...5000)
vagrant_root = File.dirname(__FILE__)
dev_domain = ENV['DEV_DOMAIN'] || 'enjo.test'
mode = ENV['VAGRANT_MODE'] || 'dev'

puts "========================================================"
puts "base domain : #{dev_domain}"
puts "folder : #{vagrant_root}"
puts "========================================================"

Vagrant.configure('2') do |config|
    config.vm.boot_timeout = 1800
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
    config.vm.define "magento", primary: true do |magento|
        magento.hostmanager.aliases = [ "magento."+dev_domain ]
        magento.vm.provision "shell" do |s|
            s.path = "bootstrap.sh"
        end
        magento.ssh.username = "vagrant"
        magento.ssh.password = "vagrant"
        magento.ssh.keys_only = false
        magento.vm.network "forwarded_port", guest: 22, host: "#{ssh_port}", id: 'ssh', auto_correct: true
        magento.vm.network :private_network, ip: "172.20.0.200", subnet: "172.20.0.0/16"
        magento.vm.hostname = "magento"
        magento.vm.provider 'docker' do |d|
            d.image = "enjo/magento2:latest"
            #d.build_dir = "./Docker/magento"
            d.has_ssh = true
            d.name = "magento"
            d.create_args = ["--cap-add=NET_ADMIN"]
            d.remains_running = true
            d.volumes = ["/tmp/.X11-unix:/tmp/.X11-unix", ENV['HOME']+"/.ssh/:/home/vagrant/.ssh", ENV['HOME']+"/.composer:/home/vagrant/.composer"]
            d.env = { "DEV_DOMAIN" => "#{dev_domain}" }
        end
    end

    config.vm.define "redis", primary: false do |redis|
        redis.hostmanager.aliases = [ "redis."+dev_domain ]
        redis.vm.network "forwarded_port", guest: 6379, host: 6379, protocol: "tcp"
        redis.vm.network :private_network, ip: "172.20.0.201", subnet: "172.20.0.0/16"
        redis.vm.hostname = "redis"
        redis.vm.provider 'docker' do |d|
            d.image = "redis:latest"
            d.has_ssh = false
            d.name = "redis"
            d.remains_running = true
        end
    end

    config.vm.define "elasticsearchm2", primary: false do |elasticsearchm2|
        elasticsearchm2.hostmanager.aliases = [ "elasticsearchm2."+dev_domain ]
        elasticsearchm2.vm.network :private_network, ip: "172.20.0.202", subnet: "172.20.0.0/16"
        elasticsearchm2.vm.hostname = "elasticsearchm2"
        elasticsearchm2.vm.provider 'docker' do |d|
            d.image = "docker.elastic.co/elasticsearch/elasticsearch:6.8.3"
            d.has_ssh = false
            d.name = "elasticsearchm2"
            d.remains_running = true
        end
    end

    config.vm.define "rabbitmq", primary: false do |rabbitmq|
        rabbitmq.hostmanager.aliases = [ "rabbitmq."+dev_domain ]
        rabbitmq.vm.network :private_network, ip: "172.20.0.203", subnet: "172.20.0.0/16"
        rabbitmq.vm.hostname = "rabbitmq"
        rabbitmq.vm.provider 'docker' do |d|
            d.image = "rabbitmq:latest"
            d.has_ssh = false
            d.name = "rabbitmq"
            d.remains_running = true
        end
    end

    config.vm.define "elasticsearch", primary: false do |elasticsearch|
        elasticsearch.hostmanager.aliases = [ "elasticsearch."+dev_domain ]
        vue_elastic_config="#{vagrant_root}/sites/vue-storefront-api/docker/elasticsearch/config/elasticsearch.yml"
        elasticsearch.trigger.before :up do |trigger|
            trigger.name = "overlay config"
            # Check if overlay config for elastic search exists.
            if File.exist?("#{vagrant_root}/vuestorefront-config-overlay/elasticsearch/config/elasticsearch.yml")
                vue_elastic_config="#{vagrant_root}/vuestorefront-config-overlay/elasticsearch/config/elasticsearch.yml"
                trigger.info = "Found overlay config: #{vue_elastic_config}"
            end
        end
        elasticsearch.vm.network :private_network, ip: "172.20.0.204", subnet: "172.20.0.0/16"
        elasticsearch.vm.hostname = "elasticsearch"
        elasticsearch.vm.provider 'docker' do |d|
            d.build_dir = "#{vagrant_root}/sites/vue-storefront-api/docker/elasticsearch"
            d.dockerfile = "Dockerfile"
            d.has_ssh = false
            d.name = "elasticsearch"
            d.remains_running = true
            d.volumes = [
                "#{vue_elastic_config}:/usr/share/elasticsearch/config/elasticsearch.yml:ro",
                "#{vagrant_root}/sites/vue-storefront-api/docker/elasticsearch/data:/usr/share/elasticsearch/data"
                ]
            d.env =  { "ES_JAVA_OPTS" => "-Xmx512m -Xms512m" }
        end
    end

    config.vm.define "kibana", primary: false do |kibana|
        kibana.hostmanager.aliases =  [ "kibana."+dev_domain ]
        vue_kibana_config="#{vagrant_root}/sites/vue-storefront-api/docker/kibana/config/"
        kibana.trigger.before :up do |trigger|
            trigger.name = "overlay config"
            # Check if overlay config for kibana exists.
            if File.exist?("#{vagrant_root}/vuestorefront-config-overlay/kibana/config/kibana.yml")
                vue_kibana_config="#{vagrant_root}/vuestorefront-config-overlay/kibana/config/"
                trigger.info = "Found overlay config: #{vue_kibana_config}"
            end
        end
        kibana.vm.network :private_network, ip: "172.20.0.205", subnet: "172.20.0.0/16"
        kibana.vm.hostname = "kibana"
        kibana.vm.provider 'docker' do |d|
            d.build_dir = "#{vagrant_root}/sites/vue-storefront-api/docker/kibana"
            d.dockerfile = "Dockerfile"
            d.has_ssh = false
            d.name = "kibana"
            d.remains_running = true
            d.volumes = [
                "#{vue_kibana_config}:/usr/share/kibana/config:ro"
                ]
        end
    end

    config.vm.define "vueapi", primary: false do |vueapi|
        vueapi.hostmanager.aliases = [ "vueapi."+dev_domain ]
        vueapi.trigger.before :up do |trigger|
            trigger.name = "overlay config"
            # Check if vue local.json config exists, and copy it to the vue config folder
            # any edits must be made in teh overlay file. Edits in teh destination file will be overwritten
            if File.exist?("#{vagrant_root}/vuestorefront-config-overlay/vue-storefront-api/config/local.json")
                FileUtils.copy_file("#{vagrant_root}/vuestorefront-config-overlay/vue-storefront-api/config/local.json",
                "#{vagrant_root}/sites/vue-storefront-api/config/local.json")
                trigger.info = "Found overlay local.json. It was copied to the base vue config folder."
            end
            # check that the /tmp/vueapi folder exists (which is used to simulated teh tmpfs setup as per vue composer files
            if File.directory?("/tmp/vueapi")
                FileUtils.rm_rf("/tmp/vueapi")
                FileUtils.mkdir_p("/tmp/vueapi")
                trigger.info = "Temp folder /tmp/vueapi created."
            end

        end
        vueapi.vm.network :private_network, ip: "172.20.0.206", subnet: "172.20.0.0/16"
        vueapi.vm.hostname = "vueapi"
        vueapi.vm.provider 'docker' do |d|
            d.build_dir = "#{vagrant_root}/sites/vue-storefront-api/"
            d.dockerfile = "docker/vue-storefront-api/Dockerfile"
            d.has_ssh = false
            d.name = "vuepai"
            d.remains_running = true
            d.volumes = [
                "#{vagrant_root}/sites/vue-storefront-api/config:/var/www/config",
                "#{vagrant_root}/sites/vue-storefront-api/ecosystem.json:/var/www/ecosystem.json",
                "#{vagrant_root}/sites/vue-storefront-api/migrations:/var/www/migrations",
                "#{vagrant_root}/sites/vue-storefront-api/package.json:/var/www/package.json",
                "#{vagrant_root}/sites/vue-storefront-api/babel.config.js:/var/www/babel.config.js",
                "#{vagrant_root}/sites/vue-storefront-api/tsconfig.json:/var/www/tsconfig.json",
                "#{vagrant_root}/sites/vue-storefront-api/nodemon.json:/var/www/nodemon.json",
                "#{vagrant_root}/sites/vue-storefront-api/scripts:/var/www/scripts",
                "#{vagrant_root}/sites/vue-storefront-api/src:/var/www/src",
                "#{vagrant_root}/sites/vue-storefront-api/var:/var/www/var",
                "/tmp/vueapi:/var/www/dist"
                ]
            d.env = { "BIND_HOST" => "0.0.0.0",
                      "ELASTICSEARCH_HOST" => "elasticsearch",
                      "ELASTICSEARCH_PORT" => "9200",
                      "REDIS_HOST" => "redis",
                      "VS_ENV" => "#{mode}",
                      "PM2_ARGS" => "--no-daemon"
                    }
        end
    end

    config.vm.define "vuestorefront", primary: false do |vuestorefront|
        vuestorefront.hostmanager.aliases =  [ "vuestorefront."+dev_domain ]
        vuestorefront.trigger.before :up do |trigger|
            trigger.name = "overlay config"
            # Check if vue local.json config exists, and copy it to the vue config folder
            # any edits must be made in teh overlay file. Edits in teh destination file will be overwritten
            if File.exist?("#{vagrant_root}/vuestorefront-config-overlay/vue-storefront/config/local.json")
                FileUtils.copy_file("#{vagrant_root}/vuestorefront-config-overlay/vue-storefront/config/local.json",
                "#{vagrant_root}/sites/vue-storefront/config/local.json")
                trigger.info = "Found overlay local.json. It was copied to the base vue config folder."
            end
            # check that the /tmp/vuestorefront folder exists (which is used to simulated teh tmpfs setup as per vue composer files
            if File.directory?("/tmp/vuestorefront")
                FileUtils.rm_rf("/tmp/vuestorefront")
                FileUtils.mkdir_p("/tmp/vuestorefront")
                trigger.info = "Temp folder /tmp/vuestorefront created."
            end

        end
        vuestorefront.vm.network :private_network, ip: "172.20.0.206", subnet: "172.20.0.0/16"
        vuestorefront.vm.hostname = "vuestorefront"
        vuestorefront.vm.provider 'docker' do |d|
            d.build_dir = "#{vagrant_root}/sites/vue-storefront/docker/vue-storefront/"
            d.dockerfile = "Dockerfile"
            d.has_ssh = false
            d.name = "vuestorefront"
            d.remains_running = true
            d.volumes = [
                "#{vagrant_root}/sites/vue-storefront/babel.config.js:/var/www/babel.config.js",
                "#{vagrant_root}/sites/vue-storefront/config:/var/www/config",
                "#{vagrant_root}/sites/vue-storefront/core:/var/www/core",
                "#{vagrant_root}/sites/vue-storefront/ecosystem.json:/var/www/ecosystem.json",
                "#{vagrant_root}/sites/vue-storefront/.eslintignore:/var/www/.eslintignore",
                "#{vagrant_root}/sites/vue-storefront/.eslintrc.js:/var/www/.eslintrc.js",
                "#{vagrant_root}/sites/vue-storefront/lerna.json:/var/www/lerna.json",
                "#{vagrant_root}/sites/vue-storefront/tsconfig.json:/var/www/tsconfig.json",
                "#{vagrant_root}/sites/vue-storefront/tsconfig-build.json:/var/www/tsconfig-build.json",
                "#{vagrant_root}/sites/vue-storefront/shims.d.ts:/var/www/shims.d.ts",
                "#{vagrant_root}/sites/vue-storefront/package.json:/var/www/package.json",
                "#{vagrant_root}/sites/vue-storefront/src:/var/www/src",
                "/tmp/vuestorefront:/var/www/dist"
                ]
            d.env = { "BIND_HOST" => "0.0.0.0",
                      "NODE_CONFIG_ENV" => "docker",
                      "BIND_HOST" => "0.0.0.0",
                      "VS_ENV" => "#{mode}",
                      "PM2_ARGS" => "--no-daemon"
                    }
        end
    end
end
