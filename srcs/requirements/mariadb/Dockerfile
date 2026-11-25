FROM debian:12

RUN apt-get update && apt-get install -y mariadb-server

COPY tools/start.sh /usr/local/bin/start.sh

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN chmod +x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]