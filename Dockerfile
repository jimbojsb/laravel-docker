FROM ubuntu:20.04 AS base

ENV LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

COPY bin/ /usr/local/bin/

RUN install_clean \
        git \
        nginx \
        mysql-client \
        gpg-agent \
        nodejs \
        curl \
        software-properties-common

RUN add-apt-repository ppa:ondrej/php \
    && install_clean \
        php7.4-cli \
        php7.4-common \
        php7.4-fpm \
        php7.4-zip \
        php7.4-mbstring \
        php7.4-mysql \
        php7.4-imagick \
        php7.4-gd \
        php7.4-curl \
        php7.4-pgsql \
        php7.4-xml \
        php7.4-sqlite \
        php7.4-pgsql \
        php7.4-bcmath \
        php7.4-soap \
        php7.4-intl \
        php7.4-redis

# PHP Extensions: Patched Xdebug
FROM base AS phpext
RUN install_clean \
        pkg-config \
        build-essential \
        php7.4-dev
WORKDIR /root
RUN git clone https://github.com/jimbojsb/xdebug.git
WORKDIR /root/xdebug
RUN phpize && ./configure && make -j6

FROM base

ENV PATH $PATH:/app/vendor/bin:/app:/app/node_modules/.bin
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV APP_ENV production
ENV APP_NAME laravel
ENV FPM_MEMORY_LIMIT 128M
ENV FPM_UPLOAD_MAX_FILESIZE 10M
ENV FPM_POST_MAX_SIZE 10M

VOLUME /app/storage/framework
VOLUME /app/storage/debugbar

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["/usr/local/bin/web"]

COPY etc/ /etc/
COPY root/ /root/

COPY --from=phpext /root/xdebug/modules/xdebug.so /usr/lib/php/20190902/xdebug.so

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN phpdismod xdebug

WORKDIR /app

ONBUILD ARG SKIP=0
ONBUILD COPY composer* package* /app/
ONBUILD RUN maybe composer install --no-scripts --no-plugins --no-autoloader --no-progress --no-dev && composer clear-cache
ONBUILD RUN maybe npm install
ONBUILD COPY . /app
ONBUILD RUN maybe composer -o dump-autoload
ONBUILD RUN maybe npm run production