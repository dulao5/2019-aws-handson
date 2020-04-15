FROM nginx:1.15-alpine

ARG UNAME=nginx
ARG APP_GID=1024
ARG APP_GNAME=appgroup

RUN set -x \
    && apk add --update shadow \
    && addgroup ${APP_GNAME} -g ${APP_GID} \
    && usermod -aG ${APP_GNAME} ${UNAME}

COPY public /var/www/html/public
COPY docker/nginx/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY docker/nginx/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENV PHP_HOST=127.0.0.1

EXPOSE 80

ENTRYPOINT ["sh", "/usr/local/bin/docker-entrypoint.sh"]
