# ========== Install the forum and plugins
FROM webdevops/php-nginx:7.3 as builder
ARG EXTIVERSE_TOKEN

WORKDIR /app
RUN composer create-project flarum/flarum . --stability=beta
COPY composer.json composer.lock ./

RUN composer config --global --auth bearer.extiverse.com $EXTIVERSE_TOKEN
RUN composer install


# ========== Setup webserver
FROM webdevops/php-nginx:7.3 as production

ENV WEB_DOCUMENT_ROOT=/app/public
ENV PHP_DISMOD='amqp,apcu,bcmath,bz2,calendar,exif,gettext,imagick,imap,intl,ioncube,\
    ldap,memcached,mongodb,mysqli,pcntl,pdo_pgsql,pgsql,redis,shmop,soap,sockets,\
    sodium,sysvmsg,sysvsem,sysvshm,vips,xmlrpc,xsl'

COPY --from=builder /app /app

RUN mkdir -p /etc/cron.script
COPY forum_config/cronscripts/flarum_schedule.sh /etc/cron.script
RUN docker-cronjob '23 0 * * * application /etc/cron.script/flarum_schedule.sh'

VOLUME /app/public/assets/avatars
VOLUME /app/public/assets/extensions
VOLUME /app/public/assets/files
VOLUME /app/public/assets/images

# COPY entrypoint script
COPY forum_config/forum_setup.sh /opt/docker/provision/entrypoint.d/50-forum_setup.sh

# Custom php config
COPY webserver_config/php.ini /opt/docker/etc/php/php.ini

# Configure for websockets
COPY webserver_config/vhost.conf /opt/docker/etc/nginx/vhost.conf
COPY webserver_config/50-websocket.conf /opt/docker/etc/nginx/vhost.common.d/50-websocket.conf
COPY webserver_config/10-location-root.conf /opt/docker/etc/nginx/vhost.common.d/10-location-root.conf
COPY forum_config/websocket_supervisor.conf /opt/docker/etc/supervisor.d/websocket.conf
COPY forum_config/websocket_server.sh /opt/docker/bin/service.d/websocket.sh

RUN usermod -s /sbin/nologin application

WORKDIR /app

FROM production as dev

RUN usermod -s /bin/bash application
