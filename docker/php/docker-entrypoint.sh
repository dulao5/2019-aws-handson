set -x \
    && whoami \
    && mkdir -p /var/log/php \
    && chmod 775 /var/log/php \
    && chmod g+s /var/log/php \
    && chown www:appgroup /var/log/php \
    && mkfifo /var/log/php/error.log /var/log/php/access.log \
    && chown www:appgroup /var/log/php/error.log /var/log/php/access.log \
    && chmod g+r /var/log/php/error.log /var/log/php/access.log

# fix /proc/self/fd/2 in php-fpm.d/docker.conf
set -x \
    && sed -i -e 's:error_log =.*:error_log = /var/log/php/error.log:' /usr/local/etc/php-fpm.d/docker.conf \
    && sed -i -e 's:access\.log =.*:access\.log = /var/log/php/access.log:' /usr/local/etc/php-fpm.d/docker.conf \
    && cat /usr/local/etc/php-fpm.d/docker.conf

exec gosu www php-fpm
