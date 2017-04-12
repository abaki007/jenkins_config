#!/bin/bash

#set -x

if [ $# -eq 0 ]; then
  echo "USAGE: $0 plugin_list "
  exit 1
fi

plugin_dir=/var/lib/jenkins/plugins
file_owner=jenkins.jenkins

sudo mkdir -p /var/lib/jenkins/plugins


plugins_list="$1"
missing_plugins=""

if ! type zip; then
  sudo yum install zip -y
  sudo yum install unzip -y
fi



installPlugin() {
  if [ -f ${plugin_dir}/$1.jpi ] || [ -f ${plugin_dir}/$1.hpi ]; then
    echo "Skipped: $1 (already installed)"
    return 0
  else
    echo "Installing: $1"
    curl -L --silent --output ${plugin_dir}/${1}.hpi  https://updates.jenkins-ci.org/latest/${1}.hpi
    return 0
  fi
}

while IFS='' read -r line || [[ -n "$line" ]]; do
    #echo "$line"
    installPlugin "$line"
done < "$plugins_list"

for plugin in ${plugin_dir}/*.hpi; do
  deps=$( unzip -p ${plugin_dir}/${line}.hpi META-INF/MANIFEST.MF | tr -d '\r' | sed -e ':a;N;$!ba;s/\n //g' | grep -e "^Plugin-Dependencies: " | awk '{ print $2 }' | tr ',' '\n' | awk -F ':' '{ print $1 }' | tr '\n' ' ' )
      for plugin in $deps; do
          installPlugin "$plugin" 1 #&& changed=1
      done
done

for plugin in {plugin_dir}/*.jpi; do
  deps2=$( unzip -p ${plugin_dir}/${line}.jpi META-INF/MANIFEST.MF | tr -d '\r' | sed -e ':a;N;$!ba;s/\n //g' | grep -e "^Plugin-Dependencies: " | awk '{ print $2 }' | tr ',' '\n' | awk -F ':' '{ print $1 }' | tr '\n' ' ' )
      for plugin in $deps2; do
          installPlugin "$plugin" 1 #&& changed=1
      done
done
