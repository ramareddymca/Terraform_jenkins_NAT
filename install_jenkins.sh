#! /bin/bash

sudo yum update -y
echo "installing the Java  ..."
sudo yum install -y java-1.8.0-openjdk-devel
sleep 10
echo "downloading Jenkins..."
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sleep 10
echo "installing the Jenkins ..."
sudo yum install -y jenkins
sleep 10
echo "start the Jenkins ..."
sudo systemctl start jenkins