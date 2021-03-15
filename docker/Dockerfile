# ========== webserver overrides
FROM webdevops/php-nginx:7.4 as webserverconfig

# Draft plugin
COPY forum_config/cronscripts/flarum_schedule.sh /etc/cron.script/flarum_schedule.sh
RUN docker-cronjob '23 0 * * * application /etc/cron.script/flarum_schedule.sh'

# Custom php config
COPY webserver_config/php.ini               /opt/docker/etc/php/php.ini
# Get real ip
COPY webserver_config/20-realip.conf        /opt/docker/etc/nginx/conf.d/20-realip.conf
# Configure for websockets
COPY webserver_config/vhost.conf            /opt/docker/etc/nginx/vhost.conf
COPY webserver_config/50-websocket.conf     /opt/docker/etc/nginx/vhost.common.d/50-websocket.conf
COPY webserver_config/10-location-root.conf /opt/docker/etc/nginx/vhost.common.d/10-location-root.conf
COPY forum_config/websocket_supervisor.conf /opt/docker/etc/supervisor.d/websocket.conf
COPY forum_config/websocket_server.sh       /opt/docker/bin/service.d/websocket.sh
# Entrypoint
COPY forum_config/forum_setup.sh            /opt/docker/provision/entrypoint.d/50-forum_setup.sh


# ========== Install the forum and plugins
FROM webdevops/php-nginx:7.4 as builder
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

VOLUME /app/public/assets

COPY --from=webserverconfig /opt /opt
COPY --from=webserverconfig /etc /etc
COPY --from=builder         /app /app

RUN usermod -s /sbin/nologin application

WORKDIR /app


# ========== Setup development mode
FROM production as dev

RUN usermod -s /bin/bash application

ARG EXTIVERSE_TOKEN
RUN if [ -n "$EXTIVERSE_TOKEN" ]; then composer config --global --auth bearer.extiverse.com "$EXTIVERSE_TOKEN"; fi
