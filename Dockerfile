FROM postgres:10.23-bullseye
MAINTAINER Open Room Inc. <tech@openrm.co.jp>

RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates gnupg curl

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y

WORKDIR /openrm

RUN mkdir /backups
ADD script.sh /openrm/script.sh

VOLUME /backups

ENTRYPOINT ["/openrm/script.sh"]
