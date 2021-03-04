# ========== Install the forum and plugins
FROM webdevops/php-nginx:7.3 as builder

WORKDIR /app
RUN composer create-project flarum/flarum . --stability=beta
COPY forum_config/composer.json forum_config/composer.lock ./

RUN composer install


# ========== Setup webserver
FROM webdevops/php-nginx:7.3 as production

ENV WEB_DOCUMENT_ROOT=/app/public

COPY --from=builder /app /app

VOLUME /app/assets
VOLUME /app/public/assets

# COPY forum_config/entrypoint.sh /entrypoint.sh
COPY forum_config/forum_setup.sh /opt/docker/provision/entrypoint.d/50-forum_setup.sh
WORKDIR /app
