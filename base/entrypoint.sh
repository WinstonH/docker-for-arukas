#!/bin/sh

# generate host keys if not present
sudo ssh-keygen -A
#prepare xauth
sudo touch /root/.Xauthority
sudo nginx
sudo /usr/bin/supervisord -c /etc/supervisord.conf
exec "$@"
