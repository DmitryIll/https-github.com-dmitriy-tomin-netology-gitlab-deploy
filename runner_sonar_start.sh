#!/bin/bash

sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo systemctl restart docker

 # pull some images in advance
dsudo ocker pull gitlab/gitlab-runner:latest
sudo docker pull sonarsource/sonar-scanner-cli:latest
sudo docker pull golang:1.17
sudo docker pull docker:latest
sudo docker pull gitlab/gitlab-runner:latest

sudo sysctl -w vm.max_map_count=262144

git clone https://github.com/dmitriy-tomin/netology-gitlab-deploy.git
cd ~/netology-gitlab-deploy
sudo docker-compose up -d