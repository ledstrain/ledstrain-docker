#!/usr/bin/env bash
set -e
cd "$APPLICATION_PATH"

mkdir -p \
 /app/assets         \
 /app/public/assets  \
 /app/storage

if [ -f /conf/config.php ]; then
  ln -fs /conf/config.php ./config.php
  php flarum migrate
  # Requires Cache Assets
  # https://discuss.flarum.org/d/23321-cache-assets-by-bokt
  php flarum cache:clear
  php flarum cache:assets --js --css --locales || true

elif [ "$INSTALL" == "true" ]; then
  cat > install.yml <<EOF
debug: true
baseUrl: ${HOSTNAME}
databaseConfiguration:
  driver: mysql
  host: db
  port: 3306
  database: ${MYSQL_DATABASE}
  username: ${MYSQL_USER}
  password: ${MYSQL_PASSWORD}
  prefix:
adminUser:
  username: admin
  password: password
  email: admin@example.com
settings:
EOF
  php flarum install --file install.yml
  cp config.php /conf/config.php
  chown application /conf/config.php
fi

chown application:application -R \
  /app/assets        \
  /app/public/assets \
  /app/storage
