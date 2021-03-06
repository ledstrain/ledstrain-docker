# ========== Install the forum and plugins
FROM webdevops/php-nginx:7.3 as builder

WORKDIR /app
RUN composer create-project flarum/flarum . --stability=beta
COPY composer.json composer.lock ./

RUN composer install


# ========== Setup webserver
FROM webdevops/php-nginx:7.3 as production

ENV WEB_DOCUMENT_ROOT=/app/public

COPY --from=builder /app /app

RUN mkdir -p /etc/cron.script
COPY forum_config/cronscripts/flarum_schedule.sh /etc/cron.script
RUN docker-cronjob '23 0 * * * application /etc/cron.script/flarum_schedule.sh'

VOLUME /app/assets
VOLUME /app/public/assets

# COPY forum_config/entrypoint.sh /entrypoint.sh
COPY forum_config/forum_setup.sh /opt/docker/provision/entrypoint.d/50-forum_setup.sh
WORKDIR /app
