#! /bin/bash
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -aG docker $USER
mkdir -p /home/ec2-user/prometheus/config                  
sudo systemctl enable docker
sudo curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose 
sudo chmod +x /usr/local/bin/docker-compose 
sudo cp /usr/local/bin/docker-compose /usr/bin/
sudo docker-compose up -d
sudo docker cp prometheus_1:/etc/prometheus/prometheus.yml /home/ec2-user/prometheus/config