FROM alpine:3.8

RUN apk add speedtest-cli=2.0.2-r0 && apk add curl && apk add openssl

# Add crontab file in the cron directory
ADD crontab /etc/cron.d/hello-cron

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/hello-cron

COPY ./speed-monitor-run.sh /root/

# Apply cron job
RUN crontab /etc/cron.d/hello-cron

# Run cron on foreground
CMD ["/usr/sbin/crond", "-f"]
