FROM postgres:18-trixie
MAINTAINER Open Room Inc. <tech@openrm.co.jp>

RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates gnupg curl

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && apt-get update -y && apt-get install google-cloud-sdk -y

WORKDIR /openrm

RUN mkdir /backups
ADD script.sh /openrm/script.sh

VOLUME /backups

ENTRYPOINT ["/openrm/script.sh"]
