#!/bin/bash
sudo apt-get install software-properties-common
sudo apt-add-repository universe
sudo apt-get update
sudo apt-get install python3-pip -y
sudo pip install -U pip 
sudo -H pip install ansible 
