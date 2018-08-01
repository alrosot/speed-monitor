FROM ubuntu:latest

RUN apt-get update && apt-get -y install cron && apt-get -y install python-pip && pip install speedtest-cli

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
CMD cron && tail -f /var/log/cron.log
