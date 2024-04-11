FROM crystallang/crystal:latest
WORKDIR /app
COPY . .
RUN apt-get -y update && apt-get -y upgrade && apt-get install -y sqlite3 libsqlite3-dev && rm -rf /var/lib/apt/lists/*
RUN shards install
EXPOSE 3000
CMD [ "crystal", "run", "SigninServer.cr" ]