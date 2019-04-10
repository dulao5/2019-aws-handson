set -x \
    && mkdir -p /var/log/nginx \
    && mkfifo /var/log/nginx/site_error.log /var/log/nginx/site_access.log \
    && chown -R nginx:appgroup /var/log/nginx \
    && chmod -R g+s /var/log/nginx \
    && chmod g+r /var/log/nginx/site_error.log /var/log/nginx/site_access.log \

set -x \
    && sed "s/\${PHP_HOST}/${PHP_HOST}/" /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf \
    && exec nginx -g "daemon off;"

