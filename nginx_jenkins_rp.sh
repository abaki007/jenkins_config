#!/bin/bash
#set -xe

nginx_install_location=$(type -p nginx)

if [ `which apt` ]; then
  sudo apt-get update
  install_cmd=`sudo apt-get install nginx`

elif [ `which yum` ]; then
  install_cmd=`yum install -y nginx`

else
  echo "unsupported os"
  exit 2
fi


if [ ! "$nginx_install_location" ] || [ -z "$nginx_install_location" ]; then
  install_cmd
fi

location=$(pwd)
ip_addr=$(hostname -I)
cd /etc/nginx

sudo openssl req -x509 -nodes -days 999 -newkey rsa:2048 \
    -subj "/C=GB/ST=London/L=London/O=localtesting/OU=testing/CN=$ip_addr" \
    -keyout /etc/nginx/cert.key -out /etc/nginx/cert.crt

cd $location
sudo cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.orig
sudo cp $location/jenkins_nginx_rp  /etc/nginx/conf.d/default.conf
sudo sed -i 's@root\ \ \ \ \ \ \ \ \ \/usr\/share\/nginx\/html@return\ 301\ https:\/\/$host$request_uri@' /etc/nginx/nginx.conf

sudo service nginx restart

curl -L localhost --insecure
