FROM debian:12

RUN apt-get update && apt-get install -y redis-server

COPY tools/start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]