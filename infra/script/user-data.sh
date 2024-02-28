#!/bin/bash

sudo apt update -y
sudo apt install curl wget apt-transport-https -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose -y
#sudo newgrp docker
sudo usermod -aG docker vmadmin
sudo systemctl start docker
sudo systemctl enable docker
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x ./kubectl
sudo mv kubectl /usr/local/bin/
sudo su -c 'minikube start --profile=minikube --listen-address='0.0.0.0'' -s /bin/bash vmadmin
sudo su -c 'minikube addons enable ingress' -s /bin/bash vmadmin
sudo su -c 'minikube addons enable ingress-dns' -s /bin/bash vmadmin
sleep 30