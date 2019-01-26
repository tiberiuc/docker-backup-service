FROM alpine:edge
MAINTAINER Tiberiu Craciun <tibi@happysoft.ro>

RUN apk add --no-cache python3 curl  bash tzdata unzip tar gzip \
    && python3 -m ensurepip \
    && pip3 install rotate-backups \
    && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing man-db \
    && mkdir -p /var/cache/man/local \
    && curl https://rclone.org/install.sh | /bin/bash \
    && rm -rf /var/cache/apk/* /tmp/*



COPY ./scripts/*.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/*.sh


ENTRYPOINT ["/usr/local/bin/backup_entrypoint.sh"]
