# ========== webserver overrides
FROM webdevops/php-nginx:7.4 as webserverconfig

# Flarum Scheduler for
# Draft, Sitemap
COPY forum_config/cronscripts/flarum_schedule.sh /etc/cron.script/flarum_schedule.sh
RUN docker-cronjob '*/15 * * * * application /etc/cron.script/flarum_schedule.sh'

COPY forum_config/sql_scripts/*.sql /etc/cron.script/sql/
RUN docker-cronjob '0 0 * * * application for sql in /etc/cron.script/sql/*.sql; do \
 mysql --host=db --user="$MYSQL_USER" --password="$MYSQL_PASSWORD" "$MYSQL_DATABASE" \
 < "$sql"; done'

# Custom php config
COPY webserver_config/php.ini                      /opt/docker/etc/php/php.ini
# Get real ip
COPY webserver_config/20-realip.conf               /opt/docker/etc/nginx/conf.d/20-realip.conf
# Configure for websockets
COPY webserver_config/vhost.conf                   /opt/docker/etc/nginx/vhost.conf
COPY webserver_config/50-websocket.conf            /opt/docker/etc/nginx/vhost.common.d/50-websocket.conf
COPY webserver_config/10-location-root.conf        /opt/docker/etc/nginx/vhost.common.d/10-location-root.conf
COPY supervisor/websocket_supervisor.conf          /opt/docker/etc/supervisor.d/websocket.conf
COPY supervisor/websocket_server.sh                /opt/docker/bin/service.d/websocket.sh
# Custom Footer with Image version
RUN docker-cronjob '@reboot application /etc/cron.script/set_forum_version.sh'
COPY forum_config/cronscripts/set_forum_version.sh /etc/cron.script/set_forum_version.sh
# Entrypoint
COPY forum_config/forum-setup.sh                   /opt/docker/provision/entrypoint.d/50-forum-setup.sh


# # ========== Install the forum and plugins from scratch
# # ========== Only uncomment when in use (or using BuildKit)
# FROM webdevops/php-nginx:7.4 as dev_builder
# ENV COMPOSER_VERSION=2
# ARG EXTIVERSE_TOKEN
#
# RUN apt-get update && apt-get install --no-install-recommends -y jq && rm -rf rm /var/lib/apt/lists/*
#
# USER application
# WORKDIR /app
#
# RUN composer create-project flarum/flarum . --stability=beta
#
# RUN if [ -n "$EXTIVERSE_TOKEN" ]; then \
#       composer config --global --auth bearer.extiverse.com "$EXTIVERSE_TOKEN"; \
#       jq '. += {"repositories": [{"type": "composer", "url": "https://extiverse.com/composer/"}]}' composer.json > .composer.json.tmp; \
#       mv .composer.json.tmp composer.json; \
#     fi
#
# COPY .null composer*.json /composer/conf/
# RUN composer require -W $(jq '.require | keys' /composer/conf/composer.json | grep -v '"flarum/' | grep -o '".*"' | tr -d '"' | tr '\n' ' ')
#
#
# ========== Install the forum and plugins
FROM webdevops/php-nginx:7.4 as production_builder
ENV COMPOSER_VERSION=2
ARG EXTIVERSE_TOKEN

USER application
WORKDIR /app

RUN composer create-project flarum/flarum . --stability=beta

COPY .null composer.* ./
RUN if [ -n "$EXTIVERSE_TOKEN" ]; then composer config --global --auth bearer.extiverse.com "$EXTIVERSE_TOKEN"; fi
RUN composer install


# ========== Setup webserver
FROM webdevops/php-nginx:7.4 as production

ENV WEB_DOCUMENT_ROOT=/app/public
ENV PHP_DISMOD='amqp,apcu,bcmath,bz2,calendar,gettext,imagick,imap,intl,ioncube,\
    ldap,memcached,mongodb,mysqli,pcntl,pdo_pgsql,pgsql,redis,shmop,soap,sockets,\
    sodium,sysvmsg,sysvsem,sysvshm,vips,xmlrpc,xsl'

RUN apt-get update && apt-get install --no-install-recommends -y default-mysql-client && rm -rf rm /var/lib/apt/lists/*

VOLUME /app/public/assets

COPY --from=webserverconfig     /opt /opt
COPY --from=webserverconfig     /etc /etc
COPY --from=production_builder  /app /app

RUN usermod -s /sbin/nologin application

WORKDIR /app


# ========== Setup development mode
FROM production as dev

RUN usermod -s /bin/bash application

ARG EXTIVERSE_TOKEN
RUN if [ -n "$EXTIVERSE_TOKEN" ]; then composer config --global --auth bearer.extiverse.com "$EXTIVERSE_TOKEN"; fi
