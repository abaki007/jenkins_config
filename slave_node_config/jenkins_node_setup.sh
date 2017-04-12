#!/bin/bash

jenkins_pub= #public jenkins master file content

echo $jenkins_pub >> /home/ec2-user/.ssh/authorized_keys

sudo mkdir -p /var/jenkins
sudo chown -R ec2-user:ec2-user /var/jenkins
ls -l /var/jenkins

