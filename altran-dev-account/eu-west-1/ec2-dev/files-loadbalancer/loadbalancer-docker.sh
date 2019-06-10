#!/bin/sh
sudo yum -y update
sudo yum -y install docker
sudo service docker start
sudo usermod -a -G docker ec2-user

cd /tmp
sudo docker run --name mynginx1 -p 443:443 -v /data/www:/usr/share/nginx/html:ro -v /tmp/nginx.conf:/etc/nginx/nginx.conf:ro -v /tmp:/etc/ssl:ro -d nginx
