FROM fluent/fluentd:v0.12-onbuild

ARG UNAME=fluent
ARG APP_GID=1024
ARG APP_GNAME=appgroup

RUN apk add --update --virtual .build-deps \
    sudo build-base ruby-dev

# timezone set
RUN apk --update add tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata

# install plugins
RUN sudo fluent-gem install \
    fluent-plugin-kinesis \
    fluent-plugin-rewrite-tag-filter

# garbage delete
RUN sudo gem sources --clear-all \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/* /home/fluent/.gem/ruby/2.4.0/cache/*.gem

RUN set -x \
    && apk add --update shadow \
    && addgroup ${APP_GNAME} -g ${APP_GID} \
    && usermod -aG ${APP_GNAME} ${UNAME}

# conf copy
COPY ./fluent.conf /fluentd/etc/fluent.conf
COPY ./docker-entrypoint.sh /usr/local/bin/docker-init.sh

ENTRYPOINT ["sh", "/usr/local/bin/docker-init.sh"]
