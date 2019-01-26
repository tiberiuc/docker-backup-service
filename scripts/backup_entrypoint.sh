#!/bin/bash


# for rcloud to work this env variable must be set
# RCLONE_CONFIG_BACKUP_TYPE=s3
#
# also must have env variable set as REMOTE_BACKUP_PATH


CRONTAB_FILE=/root/crontab
LOCAL_BACKUP_FOLDER=/backup

if [ ! -z "${BACKUP_INTERVAL}" ]; then
  tee -a >${CRONTAB_FILE} <<EOF
${BACKUP_INTERVAL} /usr/local/bin/run_backup.sh
EOF

  crontab ${CRONTAB_FILE}
else
  echo "BACKUP_INTERVAL env variable not set. Cron backups will not run."
fi

#sync backup
if [ ! -z "$REMOTE_BACKUP_PATH" ]; then
  mkdir -p ${LOCAL_BACKUP_FOLDER}
  cd ${LOCAL_BACKUP_FOLDER}
  rclone sync -v backup:${REMOTE_BACKUP_PATH}/ ./
else
  echo "Syncronisation failed as env variable REMOTE_BACKUP_PATH is empty"
fi

if [ $# -eq 0 ]; then
  exec /usr/sbin/crond -f -l 8
else
  exec "$@"
fi


