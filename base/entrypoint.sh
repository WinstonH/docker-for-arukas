#!/bin/sh

# generate host keys if not present
sudo ssh-keygen -A
# prepare xauth
sudo touch /root/.Xauthority
sudo mkdir -p /run/nginx
sudo nginx
# mark date
sudo wget https://raw.githubusercontent.com/WinstonH/v2ray-heroku/master/index.html -O /var/lib/nginx/html/index.html
VERSION=$(sudo /usr/bin/v2ray/v2ray --version |grep V |awk '{print $2}')
BUILDDATE=$(sudo /usr/bin/v2ray/v2ray --version |grep V |awk '{print $4}')
REBOOTDATE=$(date)

sudo sed -i "s/VERSION/$VERSION/g" /var/lib/nginx/html/index.html
sudo sed -i "s/BUILDDATE/$BUILDDATE/g" /var/lib/nginx/html/index.html
sudo sed -i "s/REBOOTDATE/$REBOOTDATE/g" /var/lib/nginx/html/index.html

sudo /usr/bin/supervisord -c /etc/supervisord.conf
exec "$@"
