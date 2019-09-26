# -*- mode: ruby -*-
# vi: set ft=ruby :
# Run with: vagrant up --provider=docker
# to get a dns entry for the docker machines use DNSGUARD
# Generate a random port number
# fixes issue where two boxes try and map port 22.
r = Random.new
ssh_port = r.rand(1000...5000)
dev_domain = ENV['DEV_DOMAIN'] || 'enjo.test'
puts "========================================================"
puts "using #{dev_domain}"
puts "========================================================"

Vagrant.configure('2') do |config|
    config.vm.boot_timeout = 1800

    config.vm.define "magento", primary: true do |magento|
        magento.vm.provision "shell" do |s|
            s.path = "bootstrap.sh"
            s.args = "#{dev_domain}"
        end
        magento.ssh.username = "vagrant"
        magento.ssh.password = "vagrant"
        magento.ssh.keys_only = false
        magento.vm.network "forwarded_port", guest: 22, host: "#{ssh_port}", id: 'ssh', auto_correct: true
        magento.vm.network :private_network, ip: "172.20.0.200", subnet: "172.20.0.0/16"
        magento.vm.hostname = "magento"
        magento.vm.provider 'docker' do |d|
            #d.image = "enjo/ubuntu-devbox:latest"
            d.build_dir = "./Docker/magento"
            d.has_ssh = true
            d.name = "magento"
            d.create_args = ["--cap-add=NET_ADMIN"]
            d.remains_running = true
            d.volumes = ["/tmp/.X11-unix:/tmp/.X11-unix", ENV['HOME']+"/.ssh/:/home/vagrant/.ssh", ENV['HOME']+"/.composer:/home/vagrant/.composer"]
        end
    end

    config.vm.define "redis", primary: false do |redis|
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

    config.vm.define "elasticsearch", primary: false do |elasticsearch|
        elasticsearch.vm.network "forwarded_port", guest: 9200, host: 9200, protocol: "tcp"
        elasticsearch.vm.network :private_network, ip: "172.20.0.202", subnet: "172.20.0.0/16"
        elasticsearch.vm.hostname = "elasticsearch"
        elasticsearch.vm.provider 'docker' do |d|
            d.image = "elasticsearch:2.3"
            d.has_ssh = false
            d.name = "elasticsearch"
            d.remains_running = true
        end
    end

    config.vm.define "rabbitmq", primary: false do |rabbitmq|
        rabbitmq.vm.network :private_network, ip: "172.20.0.203", subnet: "172.20.0.0/16"
        rabbitmq.vm.hostname = "rabbitmq"
        rabbitmq.vm.provider 'docker' do |d|
            d.image = "rabbitmq:latest"
            d.has_ssh = false
            d.name = "rabbitmq"
            d.remains_running = true
        end
    end



end
