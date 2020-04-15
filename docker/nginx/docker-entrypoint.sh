set -x \
    && mkdir -p /var/log/nginx \
    && chown nginx:appgroup /var/log/nginx \
    && chmod g+s /var/log/nginx

set -x \
    && sed "s/\${PHP_HOST}/${PHP_HOST}/" /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf \
    && exec nginx -g "daemon off;"

