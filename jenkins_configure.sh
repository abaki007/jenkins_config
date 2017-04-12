#!/bin/bash


sudo service jenkins stop
jenkins_config_location=$(pwd)

cd /
sudo tar xvf ${jenkins_config_location}/jenkins_home.tar
sudo cp -R ${jenkins_config_location}/ssh-keys /var/lib/jenkins/
sudo chown -R jenkins:jenkins /var/lib/jenkins

sudo service jenkins start

curl -L localhost:80 --insecure
