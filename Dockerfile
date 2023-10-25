FROM php:8.1-apache

ARG USER_ID
RUN useradd -u ${USER_ID} www

USER root
RUN a2enmod rewrite

WORKDIR /var/www/html

COPY ./src .

RUN chown -R www:www /var/www/html

RUN apt-get update && apt-get install -y \
    git \
    nano \
    zlib1g-dev \
    zip \
    unzip \
    libzip-dev

RUN docker-php-ext-install zip pdo_mysql

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p /home/www/.composer
RUN chown -R www:www /home/www/.composer;

RUN composer install
#--no-dev --optimize-autoloader

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

USER www

EXPOSE 80

CMD ["apache2-foreground"]