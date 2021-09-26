#!/bin/bash
sudo apt-get -y update
#sudo apt-get -y install openjdk-8-jdk
#wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
#sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
#sudo apt-get -y update
#sudo apt-get -y install jenkins
#sudo systemctl start jenkins

###### Ansible ###################
sudo apt-get install python3-pip -y
sudo pip install -U pip
sudo -H pip install ansible
