FROM php:7.1-fpm

RUN pecl install redis-3.1.4 \
    && pecl install xdebug \
    && docker-php-ext-enable redis xdebug

RUN docker-php-ext-install mysqli pdo_mysql

COPY ./docker/php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
