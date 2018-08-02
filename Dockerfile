FROM alpine:3.8

RUN apk add speedtest-cli=2.0.2-r0

# Add crontab file in the cron directory
ADD crontab /etc/cron.d/hello-cron

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/hello-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Apply cron job
RUN crontab /etc/cron.d/hello-cron

COPY ./speed-monitor-run.sh /root/

# Run cron on foreground
CMD ["/usr/sbin/crond", "-f"]
