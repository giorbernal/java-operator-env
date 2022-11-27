#!/bin/bash

sudo mkdir -p /etc/nginx/conf.d/ /etc/nginx/certs

sudo cat <<EOF > /etc/nginx/conf.d/minikube.conf 
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;
    auth_basic "Administrator’s Area";
    auth_basic_user_file /etc/nginx/.htpasswd;    
    
    location / {   
        proxy_pass https://192.168.59.100:8443;
        proxy_ssl_certificate /etc/nginx/certs/minikube-client.crt;
        proxy_ssl_certificate_key /etc/nginx/certs/minikube-client.key;
    }
}
EOF

sudo apt update -y && sudo apt-get install apache2-utils -y
sudo htpasswd -c /etc/nginx/.htpasswd minikube

sudo docker run -d \
--name nginxk8s \
-p 8080:80 \
-v /home/bernal/.minikube/profiles/minikube/client.key:/etc/nginx/certs/minikube-client.key \
-v /home/bernal/.minikube/profiles/minikube/client.crt:/etc/nginx/certs/minikube-client.crt \
-v /etc/nginx/conf.d/:/etc/nginx/conf.d \
-v /etc/nginx/.htpasswd:/etc/nginx/.htpasswd \
nginx
