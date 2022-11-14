#!/bin/sh

# Set cron job
RUN echo "$(CRON_SCHEDULE) /backup.sh" > /etc/crontabs/root

# run backup once on container start to ensure it works
/backup.sh

# start crond in foreground
exec crond -f
