FROM wyrihaximusnet/php:7.3-zts-alpine3.10 AS github-cli

COPY ./etc /opt/app/etc
COPY ./github /opt/app/github
COPY ./composer.json /opt/app/composer.json
COPY ./composer.lock /opt/app/composer.lock

USER root

RUN  chown app:app /opt/app && \
     apk add \
            make \
            git \
            openssh-client \
            bash

# Install composer
COPY .docker/utils/install-composer /usr/local/bin/
RUN install-composer && rm -rf /usr/local/bin/install-composer

USER app

WORKDIR /opt/app

RUN mkdir vendor && \
    composer install --no-dev --no-progress --optimize-autoloader --classmap-authoritative

ENTRYPOINT ["/opt/app/github"]
