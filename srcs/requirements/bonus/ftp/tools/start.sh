#!/bin/sh
set -e

if ! id ftpuser >/dev/null 2>&1; then
    useradd -d /var/www/html -s /usr/sbin/nologin ftpuser
    usermod -aG www-data ftpuser
    chmod -R g+rwX /var/www/html
    find /var/www/html -type d -exec chmod g+s {} +
fi
FTP_PASSWORD=$(cat /run/secrets/ftp_password)

if [ -z "$FTP_PASSWORD" ]; then
    echo "Error: FTP password is empty" >&2
    exit 1
fi

echo "ftpuser:$FTP_PASSWORD" | chpasswd

exec /usr/sbin/vsftpd /etc/vsftpd.conf