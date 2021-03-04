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
VOLUME /app/storage

# COPY forum_config/entrypoint.sh /entrypoint.sh
COPY forum_config/forum_directories.sh /opt/docker/provision/entrypoint.d/50-forum_directories.sh
WORKDIR /app


## ========== Install dev tools
#FROM production as dev
#
#RUN apt-get update \
# && apt-get install -y \
#      nano \
#      zip  \
# && rm -r /var/lib/apt/lists
