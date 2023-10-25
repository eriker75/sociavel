FROM php:8.1-apache

ARG USER_ID
RUN useradd -u ${USER_ID} www

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

RUN docker-php-ext-install zip

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN a2enmod rewrite

RUN composer install --no-dev --optimize-autoloader

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

USER www

EXPOSE 80

CMD ["apache2-foreground"]