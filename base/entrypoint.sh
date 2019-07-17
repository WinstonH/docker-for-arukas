#!/bin/sh

# generate host keys if not present
sudo ssh-keygen -A
# prepare xauth
sudo touch /root/.Xauthority
sudo mkdir -p /run/nginx
sudo nginx
sudo php-fpm7
# mark date
VERSION=$(sudo /usr/bin/v2ray/v2ray --version |grep V |awk '{print $2}')
BUILDDATE=$(sudo /usr/bin/v2ray/v2ray --version |grep V |awk '{print $4}')
REBOOTDATE=$(date)

sudo sed -i "s/VERSION/$VERSION/g" /home/alpine/www/index.html
sudo sed -i "s/BUILDDATE/$BUILDDATE/g" /home/alpine/www/index.html
sudo sed -i "s/REBOOTDATE/$REBOOTDATE/g" /home/alpine/www/index.html

sudo /usr/bin/supervisord -c /etc/supervisord.conf
exec "$@"
