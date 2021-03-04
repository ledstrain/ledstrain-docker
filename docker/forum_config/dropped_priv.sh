#!/usr/bin/env bash

if [ -f config.php ]; then
  while [ "$(php flarum 2>&1 | grep -q 'Uncaught PDOException'; echo $?)" -eq 0 ]; do
    sleep 2
  done
  echo "Database up, attempting to migrate and cache assets"
  php flarum migrate
  # Requires Cache Assets
  # https://discuss.flarum.org/d/23321-cache-assets-by-bokt
  php flarum cache:assets --js --css --locales || true
  php flarum cache:clear

  # Remove old views on load
  # https://discuss.flarum.org/d/25436-beta-14-call-to-undefined-function-array-get/51
  rm -r storage/views/*
else
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
  while [ "$(curl --silent db:3306 &> /dev/null; echo $?)" -ne 56 ]; do sleep 2; done
  echo "Database up, attempting to install"

  php flarum install --file install.yml
fi

