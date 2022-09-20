# ========== webserver overrides
FROM webdevops/php-nginx:8.1 as webserverconfig

# Flarum Scheduler for
# Draft, Sitemap
COPY forum_config/cronscripts/flarum_schedule.sh /etc/cron.script/flarum_schedule.sh
RUN docker-cronjob '*/15 * * * * application /etc/cron.script/flarum_schedule.sh'

COPY forum_config/sql_scripts/*.sql /etc/cron.script/sql/
RUN docker-cronjob '0 */6 * * * application for sql in /etc/cron.script/sql/*.sql; do \
 nice -n 10 mysql --host=db --user="$MYSQL_USER" --password="$MYSQL_PASSWORD" "$MYSQL_DATABASE" \
 < "$sql"; done'

# Custom php config
COPY webserver_config/php.ini                      /opt/docker/etc/php/php.ini
# Get real ip
COPY webserver_config/20-realip.conf               /opt/docker/etc/nginx/conf.d/20-realip.conf
# Configure for realtime plugin
COPY webserver_config/50-websocket.conf            /opt/docker/etc/nginx/vhost.common.d/5-realtime.conf
COPY webserver_config/100-flarum.conf              /opt/docker/etc/nginx/vhost.common.d/10-location-root.conf
COPY supervisor/websocket_supervisor.conf          /opt/docker/etc/supervisor.d/websocket.conf
COPY supervisor/websocket_server.sh                /opt/docker/bin/service.d/websocket.sh
# Redis queues
COPY supervisor/redis_queue_supervisor.conf        /opt/docker/etc/supervisor.d/redis_queue_supervisor.conf
COPY supervisor/redis_queue.sh                     /opt/docker/bin/service.d/redis_queue.sh
# Niceness for processes run by application user
COPY webserver_config/limits.conf                  /etc/security/limits.conf
# Custom Footer with Image version
RUN docker-cronjob '@reboot application nice -n 10 /etc/cron.script/set_forum_version.sh'
COPY forum_config/cronscripts/set_forum_version.sh /etc/cron.script/set_forum_version.sh
# Entrypoint
COPY forum_config/forum-setup.sh                   /opt/docker/provision/entrypoint.d/50-forum-setup.sh


# # ========== Install the forum and plugins from scratch
# ========== Only uncomment when in use (or using BuildKit)
# FROM webdevops/php-nginx:8.1 as dev_builder
# ENV COMPOSER_VERSION=2
# ARG EXTIVERSE_TOKEN
#
# RUN apt-get update && apt-get install --no-install-recommends -y jq && rm -rf rm /var/lib/apt/lists/*
#
# USER application
# WORKDIR /app
# 
# RUN composer create-project flarum/flarum .
# 
# RUN if [ -n "$EXTIVERSE_TOKEN" ]; then \
#       composer config --global --auth bearer.extiverse.com "$EXTIVERSE_TOKEN"; \
#       jq '. += {"repositories": [{"type": "composer", "url": "https://extiverse.com/composer/"}]}' composer.json > .composer.json.tmp; \
#       mv .composer.json.tmp composer.json; \
#     fi
# 
# COPY .null composer*.json /composer/conf/
# RUN plugins=$(jq '.require | keys' /composer/conf/composer.json | sed -nr 's/"(.*)?",?/\1:*/p' | grep -v 'flarum/' | tr -s '\n' ' ') \
#  && echo $plugins | tr ' ' '\n' \
#  && composer require -W $plugins
# 
# ========== Install the forum and plugins
FROM webdevops/php-nginx:8.1 as production_builder
ENV COMPOSER_VERSION=2
ARG EXTIVERSE_TOKEN

WORKDIR /app

RUN composer create-project flarum/flarum .

COPY .null composer.* ./
RUN if [ -n "$EXTIVERSE_TOKEN" ]; then composer config --global --auth bearer.extiverse.com "$EXTIVERSE_TOKEN"; fi
RUN composer install


# ========== Setup webserver
FROM webdevops/php-nginx:8.1 as production

ENV WEB_DOCUMENT_ROOT=/app/public
ENV PHP_DISMOD='amqp,apcu,bcmath,bz2,calendar,gettext,imagick,imap,ioncube,\
    ldap,memcached,mongodb,mysqli,pcntl,pdo_pgsql,pgsql,redis,shmop,soap,sockets,\
    sodium,sysvmsg,sysvsem,sysvshm,vips,xmlrpc,xsl'

RUN apt-get update && apt-get install --no-install-recommends -y default-mysql-client \
                                                                 libncurses5          \
 && rm -rf rm /var/lib/apt/lists/*

VOLUME /app/public/assets

COPY --from=webserverconfig    /opt /opt
COPY --from=webserverconfig    /etc /etc
COPY --from=production_builder /app /app
# COPY --from=dev_builder /app /app

# Redis queues
COPY forum_config/extend.php                       /app/extend.php

RUN usermod -s /sbin/nologin application

ARG GIT_COMMIT
ENV BUILD_COMMIT=$GIT_COMMIT
WORKDIR /app


# ========== Setup development mode
FROM production as dev

RUN usermod -s /bin/bash application

ARG EXTIVERSE_TOKEN
RUN if [ -n "$EXTIVERSE_TOKEN" ]; then composer config --global --auth bearer.extiverse.com "$EXTIVERSE_TOKEN"; fi
