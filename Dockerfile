FROM php:7.2-fpm-alpine

##prep for php install like GD and so on
RUN apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
    docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ && \
    NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
    docker-php-ext-install -j${NPROC} gd

##curl, libs and pdo bits for php to work nicely
RUN apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        curl-dev \
        imagemagick-dev \
        libtool \
        libxml2-dev \
        postgresql-dev \
        sqlite-dev \
    && apk add --no-cache \
        nano \
        curl \
        git \
        imagemagick \
        mysql-client \
        postgresql-libs \
        libintl \
        icu \
        icu-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick
RUN docker-php-ext-install \
        curl \
        iconv \
        mbstring \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        pdo_sqlite \
        pcntl \
        tokenizer \
        xml \
        zip \
        intl

##Redis bits
RUN pecl install -o -f redis \
&&  rm -rf /tmp/pear \
&&  docker-php-ext-enable redis

##MySQLi
RUN docker-php-ext-install mysqli

## theses are the WUP related bits I need.
RUN apk add --update --no-cache bash gzip
RUN apk add --update \
    openssh-client \
    rsync \
    python3 \
    python3-dev \
    py-pip \
    build-base \
  && pip install virtualenv && pip install --upgrade pip


##WKHTMLPDF, not often used but always installed
RUN apk add --update --no-cache \
    libgcc libstdc++ libx11 glib libxrender libxext libintl \
    libcrypto1.0 libssl1.0 \
    ttf-dejavu ttf-droid ttf-freefont ttf-liberation ttf-ubuntu-font-family
COPY wkhtmltopdf /bin
RUN chmod +x /bin/wkhtmltopdf 


##Composer is used alot, not so much for WP
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
RUN apk del -f .build-deps freetype-dev libpng-dev libjpeg-turbo-dev

##normally this would be correct but in WUP sites we work in repo and live
WORKDIR /var/www

