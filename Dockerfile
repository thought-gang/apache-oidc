FROM debian:buster-slim

LABEL maintainer Felix Hoßfeld <felix.hossfeld@thoughtgang.de>
LABEL version="0.1"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y apache2 libapache2-mod-auth-openidc ca-certificates --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY auth_openidc.conf /etc/apache2/mods-available/

# https://httpd.apache.org/docs/2.4/stopping.html#gracefulstop
STOPSIGNAL SIGWINCH

ENV LANG=C
ENV APACHE_PID_FILE=/var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR=/var/run/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_LOG_DIR=/var/log/apache2

ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data

RUN install  -d -m 0700 -o  ${APACHE_RUN_USER} -g ${APACHE_RUN_USER} ${APACHE_RUN_DIR} && \
    a2disconf other-vhosts-access-log && \
    rm /etc/apache2/sites-enabled/000-default.conf && \
    sed -i 's/^ErrorLog .*$/ErrorLog \/dev\/stderr/' /etc/apache2/apache2.conf

#USER ${APACHE_RUN_USER}:${APACHE_RUN_USER}

ENV OIDC_SCOPE=openid

EXPOSE 80

ENTRYPOINT ["/usr/sbin/apache2", "-DFOREGROUND"]