
#!/bin/bash -e

if (( $(ps -ef | grep -v grep | grep jenkins | wc -l) > 0 )); then
  echo " jenkins is still running \
  ** Stop jenkins before running this script **"
  exit 1
fi

# register slave node with jenkins master
if [ $# -lt 3 ]; then
  echo "USAGE: $0 slave_node_name node_label ip_address "
  exit 1
fi

if [ -z $3 ]; then
  echo "missing ip address"
  echo "USAGE: $0 slave_node_name node_label ip_address "
  exit 1
else
  ip_addr="$3"
fi

if [ -z $2 ]; then
  node_label="linux_slave_nodes"
else
  node_label="$2"
fi

node_name="$1"

echo "/var/lib/jenkins/nodes/${node_name}"
echo "node label: $node_label"
#location=$(pwd)
location=/var/lib/jenkins/nodes

mkdir -p ${location}/${node_name}
cp node_config.xml ${location}/${node_name}/config.xml

sed -i "s/name_update/$node_name/g" ${location}/${node_name}/config.xml
sed -i "s/ip_update/$ip_addr/g" ${location}/${node_name}/config.xml
sed -i "s/label_update/$node_label/g" ${location}/${node_name}/config.xml

cat ${location}/${node_name}/config.xml

sudo chown -R jenkins:jenkins ${location}

ls -l ${location}/${node_name}

sleep 5s
sudo service jenkins start

sleep 10
sudo service jenkins status
