#!/bin/bash

# capture jenkins home directory and jobs directory with config.xml
plugins='/var/lib/jenkins/plugins'
builds='/var/lib/jenkins/jobs/*/builds/*/*'
workspace='/var/lib/jenkins/jobs/*/workspace/*'
ssh_keys='/var/lib/jenkins/ssh-keys'
tools='/var/lib/jenkins/tools'
cache='/var/lib/jenkins/cache'
config_history='var/lib/jenkins/config-history'
monitoring='var/lib/jenkins/monitoring'

echo "This script will generate the config files for jenkins home and a plugins list \
- both required to migrate or set up a configured Jenkins environment"

sudo tar --exclude=$plugins --exclude=$builds --exclude=$workspace --exclude=$ssh_keys \
	--exclude=$tools --exclude=$cache --exclude=$monitoring \
	-cvf jenkins_home.tar /var/lib/jenkins

# TODO: rotate archive name when adding more archives
sudo tar -tvf jenkins_home.tar
sudo du -sh jenkins_home.tar

# DATE = `date +%Y-%m-%d_%H:%M:%S`
ls /var/lib/jenkins/plugins/ | grep -v ".*.hpi\|.*.jpi" > ./jenkins_plugin_list # ./jenkins_plugin_list_$DATE

echo "created the following:"
ls -l ./jenkins_home.tar
ls -l ./jenkins_plugin_list
