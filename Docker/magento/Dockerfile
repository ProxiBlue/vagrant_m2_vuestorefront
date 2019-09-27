FROM ubuntu:18.04
LABEL maintainer="Lucas van Staden lucas.vanstaden@enjo.com.au"

ENV DEBIAN_FRONTEND noninteractive

RUN useradd -G www-data --create-home --shell /bin/bash vagrant && \
    echo root:vagrant | chpasswd && \
    echo vagrant:vagrant | chpasswd && \
    mkdir /home/vagrant/.composer && \
    echo "cd /vagrant/sites/magento2" >> /home/vagrant/.bashrc && \
    chown -R vagrant:vagrant /home/vagrant/.composer && \
    apt-get update && \
    apt-get -y install software-properties-common tzdata curl sudo && \
    DEBIAN_FRONTEND=noninteractive && \
    echo "Australia/Perth" tee /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get update && apt -y upgrade && sudo apt remove cmdtest && \
    apt-get -y --allow-unauthenticated --no-install-recommends install \
        bzip2 \
        ca-certificates \
        openjdk-8-jre-headless \
        unzip \
        wget \
        curl \
        vim \
        joe \
        net-tools \
        mcrypt \
        build-essential \
        git \
        mc \
        nginx \
        php7.2-fpm \
        php7.2-cli \
        php7.2-mysql \
        php7.2-curl \
        php7.2-gd \
        php7.2-redis \
        php7.2-xml \
        php7.2-soap \
        php7.2-mbstring \
        php7.2-zip \
        php7.2-common \
        php7.2-intl \
        php7.2-xsl \
        php7.2-bcmath \
        php7.2-iconv \
        php7.2-intl \
        php-xdebug \
        redis-server \
        ruby-dev \
        composer \
        nano \
        pv \
        mc \
        screen \
        xvfb \
        inetutils-ping \
        rsync \
        s3fs \
        sendmail \
        mailtools \
        automake \
        checkinstall \
        openssh-server \
        supervisor \
        dos2unix \
        python-pip \
        gcc \
        python-dev \
        yarn \
        apt-transport-https \
        imagemagick \
        gettext-base && \
    phpenmod xdebug && \
    echo 'kernel.unprivileged_userns_clone=1' > /etc/sysctl.d/00-local-userns.conf && \
    service procps restart && \
    useradd -G www-data --create-home --shell /bin/bash seluser && echo 'seluser:secret' | chpasswd && \
    mkdir -p /opt/selenium && \
    sudo chown seluser:seluser /opt/selenium && \
    wget --no-verbose https://selenium-release.storage.googleapis.com/3.12/selenium-server-standalone-3.12.0.jar \
        -O /opt/selenium/selenium-server-standalone.jar && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
      && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
      && apt-get update -qqy \
      && apt-get -qqy install \
        google-chrome-stable \
      && rm /etc/apt/sources.list.d/google-chrome.list \
      && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

ADD https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub /home/vagrant/.ssh/authorized_keys
ADD common/wrap_chrome_binary /tmp/
RUN bash /tmp/wrap_chrome_binary && \
export CD_VERSION=$(wget -qO- https://chromedriver.storage.googleapis.com/LATEST_RELEASE) \
  && echo "Using chromedriver version: "$CD_VERSION \
  && wget -q --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CD_VERSION/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CD_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CD_VERSION \
  && sudo ln -fs /opt/selenium/chromedriver-$CD_VERSION /usr/bin/chromedriver

ADD common/generate_config /tmp/
RUN bash /tmp/generate_config > /opt/selenium/config.json && \
/usr/bin/wget -q --no-verbose --no-check-certificate https://files.magerun.net/n98-magerun.phar && \
 /bin/chmod +x ./n98-magerun.phar && \
 mv ./n98-magerun.phar /usr/local/bin/n98-magerun && \
  /usr/bin/php -r "readfile('https://getcomposer.org/installer');" | /usr/bin/php && \
   /bin/chmod a+rwx composer.phar && mv composer.phar /usr/local/bin/composer

RUN wget https://phar.phpunit.de/phpunit.phar && /bin/chmod a+rwx phpunit.phar && \
mv phpunit.phar /usr/local/bin/phpunit.phar && \
echo "client_max_body_size 20M;" >>/etc/nginx/conf.d/client_max_body_size.conf && \
echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/01_vagrant
ADD common/php-fpm/* /etc/php/7.2/fpm/pool.d/
RUN rm -rf /etc/php/7.2/fpm/pool.d/www.conf && mkdir /run/php && rm /etc/nginx/sites-enabled/default
ADD common/.inputrc /home/vagrant/
ADD common/nginx/* /etc/nginx/snippets/
ADD common/nginx/ssl/certs/* /etc/ssl/certs/
ADD common/nginx/ssl/private/* /etc/ssl/private/
ADD common/nginx/magento /etc/nginx/sites-available/
ADD common/xdebug.ini /etc/php/7.2/mods-available/xdebug.ini
ADD common/supervisord* /etc/supervisor/conf.d/

ADD https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip /tmp/ngrok-stable-linux-amd64.zip
RUN cd /tmp && unzip /tmp/ngrok-stable-linux-amd64.zip
RUN mv /tmp/ngrok /usr/bin/


RUN chmod 0400 /etc/sudoers.d/01_vagrant && \
 echo "source ~/git-completion.bash" >>/home/vagrant/.bashrc && \
 su vagrant -c "git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=1 && echo 'export GIT_PROMPT_ONLY_IN_REPO=1' >> ~/.bashrc && echo 'export GIT_PROMPT_FETCH_REMOTE_STATUS=0' >> ~/.bashrc && echo 'source ~/.bash-git-prompt/gitprompt.sh' >> ~/.bashrc" && \
mkdir /root/.ssh && \
chmod 700 /root/.ssh && \
ssh-keyscan -t rsa,dsa bitbucket.com >> /root/.ssh/known_hosts && \
ssh-keyscan -t rsa,dsa github.com >> /root/.ssh/known_hosts && \
chmod 644 /root/.ssh/known_hosts && \
su vagrant -c "composer global require hirak/prestissimo" && \
mkdir /var/run/sshd
EXPOSE 22 80 443 9000 4040
CMD ["/usr/bin/supervisord", "-n"]
RUN apt-get autoremove -y && apt-get clean
