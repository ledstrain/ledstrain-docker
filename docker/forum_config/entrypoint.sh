#!/usr/bin/env bash

usermod --non-unique --home /var/www/html --shell /bin/bash --uid "${PUID_ID}" www-data
chown -R www-data:www-data \
  /var/www/html/assets \
  /var/www/html/public/assets \
  /var/www/html/storage

su --preserve-environment www-data -c /dropped_priv.sh

/usr/sbin/apache2ctl -D FOREGROUND
