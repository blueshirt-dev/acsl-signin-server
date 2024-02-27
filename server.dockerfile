FROM crystallang/crystal:latest
WORKDIR /app
COPY . .
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y sqlite3 libsqlite3-dev
RUN shards install
EXPOSE 3000
CMD [ "crystal", "run", "SigninServer.cr" ]