#!/bin/bash

sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

sudo apt-get install docker-ce -y

sudo gpasswd -a ${USER} docker

sudo newgrp docker

sudo mkdir -p /data/docker

sed -i -r 's/^(ExecStart=\/usr\/bin\/dockerd)(.*?)/\1\2 \-g \/data\/docker/' /lib/systemd/system/docker.service

sudo systemctl restart docker

sudo systemctl enable docker

#https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce-1
