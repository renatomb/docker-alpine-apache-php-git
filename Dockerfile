FROM alpine
LABEL version="1.0.0"
LABEL author="Renato Monteiro Batista - https://github.com/renatomb"
RUN apk add --no-cache bash php-apache2 curl php-cli php-json php-phar php-openssl php-mysqli php7-session php-curl php-pdo php-simplexml php-gd git openssh-client openssh-keygen
COPY scripts/. /usr/local/bin/
RUN mkdir -p /data/ssh; \
mv /etc/apache2 /data/etc; \
mv /var/log/apache2 /data/log; \
mv /var/www/localhost /data; \
ln -s /data/etc /etc/apache2; \
ln -s /data/log /var/log/apache2; \
ln -s /data/ssh /var/www/.ssh; \
ln -s /data/localhost /var/www/localhost
RUN sed -i 's#AllowOverride none#AllowOverride All#' /etc/apache2/httpd.conf; \
sed -i 's#/var/www/#/data/#' /etc/apache2/httpd.conf
RUN chmod -R 755 /usr/local/bin/*
WORKDIR /data/localhost/htdocs
EXPOSE 80
CMD ["httpd-foreground"]
