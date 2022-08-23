#!/bin/bash

# Install docker and docker compose
export PRIVATE_IP=$(hostname -I)
sudo -- sh -c -e "echo '$PRIVATE_IP   $HOSTNAME' >> /etc/hosts"
sudo -- sh -c -e "echo '127.0.0.1    localhost' >> /etc/hosts"
sudo systemctl disable systemd-resolved.service
sudo service systemd-resolved stop
cat << EOF > resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
sudo mv resolv.conf /etc/
sudo service systemd-networkd restart
sudo apt-get update
sudo apt-get install -y apt-transport-https jq software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt install docker.io -y
sudo usermod -a -G docker ubuntu
sudo systemctl enable docker
sudo systemctl start docker
sudo apt-get install curl -y
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt-get install kubeadm kubelet kubectl -y
sudo usermod -G docker -a ubuntu
sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo apt install -y python3-pip
sudo apt install -y ansible
sudo apt install -y git 
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install node

sudo docker-compose -f /home/ubuntu/docker-compose.yaml up