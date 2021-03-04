# ========== Setup webserver
FROM php:7.3-apache as production

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
ENV DEBIAN_FRONTEND=noninteractive

RUN a2enmod rewrite
RUN a2dissite default-ssl

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
 && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod uga+x /usr/local/bin/install-php-extensions && sync \
    && docker-php-ext-install \
        mysqli \
        pdo \
        pdo_mysql \
    && install-php-extensions \
        gd \
        curl \
        dom \
        json \
        mbstring \
        openssl \
        tokenizer \
        zip

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"


EXPOSE 8080
VOLUME /var/www/html/assets
VOLUME /var/www/html/public/assets
VOLUME /var/www/html/storage

COPY web_config/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY web_config/ports.conf /etc/apache2/ports.conf

COPY forum_config/entrypoint.sh /entrypoint.sh
COPY forum_config/dropped_priv.sh /dropped_priv.sh

CMD ["/entrypoint.sh"]


# ========== Install the forum and plugins
FROM php:7.3-apache as builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
                                            git \
                                            zip \
 && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html
RUN composer create-project flarum/flarum . --stability=beta
COPY forum_config/composer.json forum_config/composer.lock ./

RUN composer install


# ========== Run forum
FROM production

COPY --from=builder /var/www/html /var/www/html

# ========== Install dev tools
FROM production as dev

RUN apt-get update \
 && apt-get install -y \
      nano \
      zip  \
 && rm -r /var/lib/apt/lists
COPY --from=builder /usr/local/bin/composer /usr/local/bin/composer
