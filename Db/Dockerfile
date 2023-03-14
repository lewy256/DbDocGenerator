FROM mcr.microsoft.com/mssql/server:2019-latest

USER root

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app

RUN chmod +x /usr/src/app/run-initialization.sh

ENV SA_PASSWORD Passw0rd
ENV ACCEPT_EULA Y

EXPOSE 1433

CMD /bin/bash ./entrypoint.sh