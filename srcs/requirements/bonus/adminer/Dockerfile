FROM debian:12

RUN apt-get update && apt-get install -y \
    php \
    php-mysql \
    php-cli \
    wget \
    ca-certificates

RUN mkdir -p /var/www/html

RUN wget -O /var/www/html/index.php \
    https://www.adminer.org/latest.php

COPY tools/start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]