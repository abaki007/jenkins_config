#!/bin/bash

# get Location so I can point to scripts later if I cd
script_location=$(pwd)

# install jenkins
sudo ./aws_jenkins_install.sh


# install nginx & configure reverse proxy for jenkins
sudo ./nginx_jenkins_rp.sh

# configure jenkins with saved jenkins home dir
sudo service jenkins stop
sleep 5s
sudo ./jenkins_configure.sh

# install plugins
sudo service jenkins stop
sudo ./jenkins_plugin_install.sh jenkins_plugin_list
sudo service jenkins start

sleep 5s

curl -L localhost:80 --insecure
