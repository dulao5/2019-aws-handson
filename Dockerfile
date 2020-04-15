FROM php:7.2-fpm-alpine

ARG UID=991
ARG UNAME=www
ARG GID=991
ARG GNAME=www
ARG APP_GID=1024
ARG APP_GNAME=appgroup

ENV WORKDIR=/var/www/html
WORKDIR $WORKDIR

ENV DD_TRACE_VERSION=0.15.1
ENV DD_TRACE_APK=https://github.com/DataDog/dd-trace-php/releases/download/${DD_TRACE_VERSION}/datadog-php-tracer_${DD_TRACE_VERSION}_noarch.apk

COPY ./docker/php/php.ini /usr/local/etc/php
COPY composer.json composer.lock ${WORKDIR}/

RUN set -x \
    && apk add --no-cache git php7-zlib zlib-dev \
    && docker-php-ext-install pdo_mysql zip \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && curl -L -o /tmp/datadog-php-tracer.apk ${DD_TRACE_APK} \
    && apk add /tmp/datadog-php-tracer.apk --allow-untrusted \
    && rm /tmp/datadog-php-tracer.apk \
    && composer install --no-autoloader --no-progress --no-dev

COPY . .

RUN set -x \
    && apk add --update shadow \
    && composer install --no-progress --no-dev \
    && php artisan config:clear \
    && addgroup ${GNAME} -g ${GID} \
    && adduser -D -G ${GNAME} -u ${UID} ${UNAME} \
    && addgroup ${APP_GNAME} -g ${APP_GID} \
    && usermod -aG ${APP_GNAME} ${UNAME} \
    && chown -R ${UNAME}:${GNAME} ${WORKDIR} \
    && mv /root/.composer /home/${UNAME}/ \
    && chown -R ${UNAME}:${GNAME} /home/${UNAME}

RUN set -x \
    && mkdir -p /var/log/php \
    && chown ${UNAME}:${APP_GNAME} /var/log/php \
    && chmod g+s /var/log/php

ENV GOSU_VERSION 1.11
RUN set -eux; \
	\
	apk add --no-cache --virtual .gosu-deps \
		wget \
		dpkg \
		gnupg \
	; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
# for flaky keyservers, consider https://github.com/tianon/pgp-happy-eyeballs, ala https://github.com/docker-library/php/pull/666
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	command -v gpgconf && gpgconf --kill all || :; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
# clean up fetch dependencies
	apk del --no-network .gosu-deps; \
	\
	chmod +x /usr/local/bin/gosu; \
# verify that the binary works
	gosu --version; \
	gosu nobody true

COPY ./docker/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["sh", "/usr/local/bin/docker-entrypoint.sh"]

# USER ${UNAME}
