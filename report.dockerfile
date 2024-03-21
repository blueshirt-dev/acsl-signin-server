FROM crystallang/crystal:latest
WORKDIR /app
COPY . .
ADD crontab /etc/cron.d/hello-cron
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get install -y sqlite3 libsqlite3-dev cron
RUN shards install
RUN chmod 0644 /etc/cron.d/hello-cron
RUN touch /var/log/cron.log
EXPOSE 3000
CMD ["cron","-f", "-l", "2"]