#! /bin/bash



sudo yum update -y
sudo yum install docker
sudo service docker start
sudo su - docker

docker run -p 80:3000 rowco/api-frisbee:latest 