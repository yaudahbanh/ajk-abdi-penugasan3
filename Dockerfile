FROM php:8.2-fpm-alpine as php

RUN apk --no-cache add \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    nodejs \
    npm \
    gnupg \
    && apk add --no-cache --virtual .build-deps \
    autoconf \
    g++ \
    make \
    && docker-php-ext-install pdo_mysql gd xml \
    && apk del .build-deps

WORKDIR /var/www/html

RUN curl -sS https://dl.yarnpkg.com/rpm/pubkey.gpg | gpg --import - \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk --no-cache add yarn

COPY . /var/www/html/

RUN chmod 775 -R . \
    && chown -R www-data:www-data .

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer install

RUN php artisan key:generate \
    && php artisan config:clear \
    && php artisan config:cache \
    && yarn \
    && php artisan storage:link \
    && yarn build

EXPOSE 9000

CMD ["php-fpm"]
