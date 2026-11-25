FROM debian:12

RUN apt-get update && apt-get install -y vsftpd
RUN sed -i '/pam_shells.so/d' /etc/pam.d/vsftpd
RUN mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]