FROM debian:12

RUN apt-get update && apt-get install -y php-fpm php-cli php-mysql php-redis curl ca-certificates

RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

RUN curl -fSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

COPY tools/start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]