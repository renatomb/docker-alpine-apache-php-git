FROM alpine
LABEL version="1.0.0"
LABEL author="Renato Monteiro Batista - https://github.com/renatomb"
VOLUME ["/data"]
RUN apk add --no-cache bash php-apache2 curl php-cli php-json php-phar php-openssl php-mysqli php7-session php-curl php-pdo php-simplexml php-gd git openssh-client openssh-keygen
COPY scripts/. /usr/local/bin/
RUN chmod -R 755 /usr/local/bin/*
WORKDIR /data/localhost/htdocs
EXPOSE 80
CMD ["httpd-foreground"]
