#!/bin/bash
yum install nginx -y
rm -f /etc/nginx/conf.d/default.conf
cp jumpserver.conf /etc/nginx/conf.d/
service nginx start


