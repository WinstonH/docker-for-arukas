#!/bin/sh

# generate host keys if not present
sudo ssh-keygen -A
# prepare xauth
sudo touch /root/.Xauthority
sudo nginx
# mark date
wget https://raw.githubusercontent.com/WinstonH/v2ray-heroku/master/index.html -O /var/lib/nginx/html/index.html
VERSION=$(v2ray --version |grep V |awk '{print $2}')
BUILDDATE=$(v2ray --version |grep V |awk '{print $4}')
REBOOTDATE=$(date)

sed -i "s/VERSION/$VERSION/g" /var/lib/nginx/html/index.html
sed -i "s/BUILDDATE/$BUILDDATE/g" /var/lib/nginx/html/index.html
sed -i "s/REBOOTDATE/$REBOOTDATE/g" /var/lib/nginx/html/index.html

sudo /usr/bin/supervisord -c /etc/supervisord.conf
exec "$@"
