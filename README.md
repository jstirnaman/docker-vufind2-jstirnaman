# Commands for VuFind Docker image#
## Build a new image from Dockerfile (if you've changed your Dockerfile)
docker build -t "jstirnaman/vufind2" /Users/jstirnaman/dev/docker-vufind2-jstirnaman

## Create the data volume container if it doesn't exist
` docker run -v /usr/local/vufind --name vufind-data jstirnaman/vufind-data /bin/true`

## Startup Vufind Container from Image ##
Mapping data volume container and ports
` docker create --volumes-from vufind-data --name="vufind-container" -p 10000:80 -p 10080:8080 -p 10306:3306 jstirnaman/vufind2:latest`

## Create a vufind-tools container for working with files and data
` docker run -it --volumes-from vufind-data -v /Users/jstirnaman/dev/vufind:/home/vufind --name vufind-tools ubuntu:trusty /bin/bash `

## Copy data into the data volume from vufind-tools
` cp -r /home/vufind/* /usr/local/vufind
chown -R vufind:www-data /usr/local/vufind
ln -s /usr/local/vufind /usr/local/vufind2 `

docker exec vufind-container ln -s /usr/local/vufind/local/httpd-vufind.conf /etc/apache2/sites-enabled/httpd-vufind2.conf

## Create a new MySQL database in vufind-container
`docker exec vufind-container mysqladmin -hlocalhost -P3306 -uroot -p create vf2`

## Create a database user interactively
` docker exec -it vufind-container mysql -hlocalhost -P3306
  use vf2;
  source /usr/local/vufind/module/VuFind/sql/mysql.sql
  create user vf2;
  set password for 'vf2'@'localhost' = PASSWORD('vf2password');
  grant all privileges on vf2.* to 'vf2'@'%' with grant option;
  \q `
  
## Start VuFind
` docker exec vufind-container /bin/su vufind /usr/local/vufind/vufind.sh restart `

## Index MARC records (if you need more)
` docker exec vufind-container /usr/local/vufind/import-marc.sh /opt/local/data/vufindready.voyout.mrc.20140331.mrc `

## To restart Apache on Ubuntu in vufind-container
`  docker exec vufind-container apache2ctl -e debug -DFOREGROUND >> /var/log/apache.log 2>&1` 
# About Port Forwarding on OS X
## Accessing Docker from OS X when Cisco AnyConnect VPN gets in the way
Be sure to set matching VirtualBox rules for OS X host so that boot2docker port 10000 is in turned mapped to OS X host, e.g. 
` for i in {10000..10999}; do
VBoxManage modifyvm "boot2docker-vm" --natpf1 "tcp-port$i,tcp,,$i,,$i";
VBoxManage modifyvm "boot2docker-vm" --natpf1 "udp-port$i,udp,,$i,,$i";
done `

Start boot2docker:
`boot2docker up`

Set default DOCKER environment variables:
`$(boot2docker shellinit)`

Override the DOCKER_HOST variable to point to 127.0.0.1:
`export DOCKER_HOST=tcp://127.0.0.1:2376`

Now you should be able to run docker commands:
`docker version`