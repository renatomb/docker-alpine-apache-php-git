FROM alpine
LABEL version="2.0.0"
LABEL org.opencontainers.image.title="alpine-apache-php-git" \
      org.opencontainers.image.description="Alpine with Apache, PHP, and Git" \
      org.opencontainers.image.url="https://hub.docker.com/r/renatomb/alpine-apache-php-git" \
      org.opencontainers.image.source="https://github.com/renatomb/alpine-apache-php-git" \
      org.opencontainers.image.authors="Renato Monteiro Batista <https://github.com/renatomb>"
VOLUME ["/data"]
RUN apk add --no-cache bash php-apache2 curl php-cli php-json php-phar php-openssl php-mysqli php-session php-curl php-pdo php-simplexml php-gd git openssh-client openssh-keygen
RUN apk add --no-cache php-mbstring php-common php-iconv php-xml php-imap php-cgi fcgi php-pdo_mysql php-soap php-posix php-gettext php-ldap php-ctype php-dom
COPY scripts/. /usr/local/bin/
RUN chmod -R 755 /usr/local/bin/*
WORKDIR /data/localhost/htdocs
EXPOSE 80
CMD ["httpd-foreground"]
