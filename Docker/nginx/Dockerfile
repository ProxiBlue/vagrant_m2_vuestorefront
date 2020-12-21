FROM nginx:latest

ENV NOTVISIBLE "in users profile"

RUN set -x &&\
apt-get update && \
apt-get install -y openssh-server sudo && \
mkdir /var/run/sshd && \
adduser --disabled-password --gecos '' vagrant && \
echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/01_vagrant && \
chmod 0400 /etc/sudoers.d/01_vagrant && \
chown -R vagrant /home/vagrant && \
echo vagrant:vagrant | chpasswd  && \
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22 80 443
CMD ["/usr/sbin/sshd", "-D"]
