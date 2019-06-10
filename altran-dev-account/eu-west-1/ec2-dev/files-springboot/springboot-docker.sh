#!/bin/sh

sudo yum -y update
sudo yum -y install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo yum -y install git

git clone https://github.com/spring-projects/spring-boot.git

sudo docker run --rm -v /home/ec2-user/spring-boot:/app -w /app maven:3-alpine mvn -B -DskipTests clean package -f spring-boot-samples/spring-boot-sample-hateoas
cp /home/ec2-user/spring-boot/spring-boot-samples/spring-boot-sample-hateoas/target/spring-boot-sample-hateoas-2.2.0.BUILD-SNAPSHOT.jar /tmp

cd /tmp
sudo docker build -t hateoas .
sudo docker run -d  -p 9000:8080 hateoas:latest