# Jenkins Installation:
Installing Jenkins is detailed below, the following example installs Nginx first, so then we can secure Jenkins behind a reverse proxy that will only accept
https requests.

## Install Nginx
- full end to end (open terminal, etc)
- explain the reason for the components
- commit to git and share with Callum - will need Jenkins jobs in repo too

### Ubuntu
`sudo apt-get update`
`sudo apt-get install nginx`

### RHEL
`sudo touch /etc/yum.repos.d/nginx.rep`

`sudo cat <<EOF > /etc/yum.repos.d/nginx.rep
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/rhel/$releasever/$basearch/
gpgcheck=0
enabled=1
EOF`

If you have any permission problems with the above command:
`sudo su`
Then run the previously failed commands and exit from the root user:
`exit`

`sudo yum install -y nginx`

### Configure the reverse proxy
copy the following into a file called jenkins_nginx_rp:
`server {
    listen 80;
    return 301 https://$host$request_uri;
}

server {

    listen 443;
    server_name localhost;

    #update the cert.crt and cert.key names to the location of where you stored the nginx SSL keys & certs
    ssl_certificate           /etc/nginx/cert.crt;
    ssl_certificate_key       /etc/nginx/cert.key;

    ssl on;
    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;

    access_log            /var/log/nginx/jenkins.access.log;

    location / {

      proxy_set_header        Host $host;
      proxy_set_header        X-Real-IP $remote_addr;
      proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header        X-Forwarded-Proto $scheme;

      # Fix the “It appears that your reverse proxy set up is broken" error.
      proxy_pass          http://localhost:8080;
      proxy_read_timeout  90;

      proxy_redirect      http://localhost:8080 https://localhost;
    }
  }
`


`export LOCATION=$(pwd)`
`export IP_ADDR=$(hostname -I)`

`cd /etc/nginx`

Please update:
- localhosting in `O=localtesting`
- testing in  `OU=testing`
To an appropriate value for your environment
```
sudo openssl req -x509 -nodes -days 999 -newkey rsa:2048 \
    -subj "/C=GB/ST=London/L=London/O=localtesting/OU=testing/CN=$IP_ADDR" \
    -keyout /etc/nginx/cert.key -out /etc/nginx/cert.crt
```

`cd $LOCATION`
`sudo cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.orig`
`sudo cp $location/jenkins_nginx_rp  /etc/nginx/conf.d/default.conf`
`sudo sed -i 's@root\ \ \ \ \ \ \ \ \ \/usr\/share\/nginx\/html@return\ 301\ https:\/\/$host$request_uri@' /etc/nginx/nginx.conf`

`sudo service nginx restart`



## Base Install

### Ubuntu
`wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -`
`sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'`
`sudo apt-get update`
`sudo apt-get install jenkins`

### RHEL
`sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo`
`sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key`
`sudo yum install jenkins -y`
`sudo service jenkins start`

For RHEL, you'll need to update `/etc/sysconfig/jenkins`:
`sudo sed -i 's@JENKINS_LISTEN_ADDRESS=\"\"@JENKINS_LISTEN_ADDRESS=\"127.0.0.1\"@' /etc/sysconfig/jenkins`
`sudo service jenkins restart`

### Verify Jenkins is running
Open a browser and go to the following URLs:
- `https://localhost`
This will take you to Jenkins via Nginx. If you receive a page not found, it may be be due to the following reasons:
- Jenkins is not running:
  - `sudo service jenkins status`
  - if you receive `Jenkins Continuous Integration Server is not running` try to run:
    - `sudo service jenkins start`
    - `sudo service jenkins status` hopefully you will receive `Jenkins Continuous Integration Server is running`
    - if Jenkins still fails to start, see what is reported in `/var/log/jenkins/jenkins.log`
- Nginx is not running:
  - `sudo service nginx status`
  - if you receive `nginx is not running`, start nginx `sudo service nginx start` and check the Nginx status
  - if you still receive `nginx is not running`, check the Nginx logs: `/var/log/nginx/`, start with `/var/log/nginx/error.log`


## Migrate Jenkins Configurations
To migrate the Jenkins environment you will need:
- An archived Jenkins Home directory (detailed how to archive Jenkins Home below)
OR
- A set of Jenkins Jobs from the previous Jenkins environment

### Migrating Jenkins Jobs only
If you are migrating Jenkins jobs, complete the following:

#### Initial Jenkins Configuration
- Open a browser and go to:
`http://localhost:8080`
- Provide a Jenkins master password as per requested
- Once logged in, set up the Jenkins security:
  - Go to the following page containing the official Jenkins security documentation https://wiki.jenkins-ci.org/display/JENKINS/Standard+Security+Setup
  - Complete the following sections:
    - Jenkins' Own User Database
    - Matrix-based Security
    *NOTE* Do not grant Anonymous user any access privileges.

#### Migrating Jenkins Jobs
- Open and navigate to the Jenkins home directory
- Click on the 'New Item' icon on the left side menu
- Create a Freestyle Jenkins job with the same name as the original Jenkins job (see job directory name if unsure)
- Without making any changes, save the Jenkins Job.
- Copy the content of the original Jenkins job directory to the Job recently created
(this will include the `config.xml` file and potentially other files/directories like the `builds` directory)
- Open the Jenkins job and check the files were made successfully, if so you will now see a populated/configured Jenkins job.
- For any secrets and credentials:
  - If credentials/secrets specific to Jenkins job:
    - Locate the secrets or credentials field in the Jenkins job and once again add the current password.
    It is required to do this because the cypher used to hash passwords and secrets are unique to each Jenkins instance.
  - If credentials/secrets are globally available:
    -



### Migrating Jenkins Home
Prerequisites:
- tar file of previous Jenkins home directory called `jenkins_home.tar`

`sudo service jenkins stop
jenkins_config_location=$(pwd)

cd /
sudo tar xvf ${jenkins_config_location}/jenkins_home.tar
sudo chown -R jenkins:jenkins /var/lib/jenkins

sudo service jenkins start

curl -L localhost:80 --insecure`


#### Backing up an existing Jenkins Home directory
```
sudo cat <<EOF > ./archive_jenkins_home.sh
#!/bin/bash

# capture jenkins home directory and jobs directory with config.xml
plugins='/var/lib/jenkins/plugins'
builds='/var/lib/jenkins/jobs/*/builds/*/*'
workspace='/var/lib/jenkins/jobs/*/workspace/*'
tools='/var/lib/jenkins/tools'
cache='/var/lib/jenkins/cache'


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
EOF
```
`chmod 700 archive_jenkins_home.sh`
`./archive_jenkins_home.sh`

running archive_jenkins_home.sh will generate jenkins_home.tar archive and jenkins_plugin_list file


## Generating Generic Jenkins Jobs & Isolating Dependancies
### Global configuration
### Job parameterisation
