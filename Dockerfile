FROM php:8.1-apache 

LABEL maintainer="Eribert Marquez"

ENV NODE_VERSION 20

RUN a2enmod rewrite

ARG USER_ID
RUN useradd -u ${USER_ID} www

WORKDIR /var/www/html 

COPY ./src .

RUN chown -R www:www /var/www/html
RUN chmod -R 755 /var/www/html

RUN chown -R www:www /var/www/html/storage
# RUN chmod -R 775 /var/www/html/storage

RUN chown -R www:www /var/www/html/bootstrap/cache
# RUN chmod -R 775 /var/www/html/bootstrap/cache

RUN mkdir -p /home/www/.composer
RUN chown -R www:www /home/www/.composer
RUN chmod -R 755 /home/www/.composer

RUN mkdir -p /home/www/.npm 
RUN chown -R www:www /home/www/.npm
RUN chmod -R 755 /home/www/.npm

RUN apt-get update && apt-get install -y \
    git \
    nano \
    zlib1g-dev \
    zip \
    unzip \
    libzip-dev

RUN docker-php-ext-install zip pdo_mysql pdo bcmath

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer install
#--no-dev --optimize-autoloader

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

RUN apt-get update && apt-get install -y gnupg \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g npm
    # && npm install -g bun \
    # && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarn.gpg >/dev/null \
    # && echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    # && apt-get update \
    # && apt-get install -y yarn

RUN npm i
RUN npm run build

USER www

EXPOSE 80

CMD ["apache2-foreground"]