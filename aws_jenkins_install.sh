#!/bin/bash

java_location=$(type -p java)

if [ ! "$java_location" ] || [ -z "$java_location" ]; then
  yum install -y java-1.8.0-openjdk
fi

if [ ! -e /var/lib/jenkins/config.xml ]; then
  sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
  sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key

  sudo yum install jenkins -y #| tee /tmp/yum-jenkins.log

  usermod -a -G jenkins ec2-user

  sudo service jenkins start
  sleep 5s

  sudo sed -i 's@JENKINS_LISTEN_ADDRESS=\"\"@JENKINS_LISTEN_ADDRESS=\"127.0.0.1\"@' /etc/sysconfig/jenkins
  sudo service jenkins restart


fi

#curl -L localhost:8080

set -x
ip_address=$(hostname -I | tr -d '[:space:]')
curl -L ${ip_address}:8080 --insecure
curl -L ${ip_address}:80 --insecure

