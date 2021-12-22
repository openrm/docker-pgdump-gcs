FROM postgresql:latest
MAINTAINER Open Room Inc. <tech@openrm.co.jp>

WORKDIR /openrm

RUN mkdir /backups
ADD script.sh /openrm/script.sh

VOLUME /backups

ENTRYPOINT ["/openrm/script.sh"]
