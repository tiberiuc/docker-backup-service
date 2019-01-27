#!/bin/bash

# must have a env variable called SERVICES_BACKUP_LIST containing a space separated list of values in format <backup_name>=<backup_agent_url>


LOCAL_BACKUP_FOLDER=/backup
TMP_BACKUP_FOLDER=/tmp/backup

rm -rf $TMP_BACKUP_FOLDER
mkdir -p $TMP_BACKUP_FOLDER

backups=`echo $SERVICES_BACKUP_LIST | tr ' ', ' ' | grep '\S'`

echo $backups
for backup in $backups; do
  echo "run backup for $backup"
  /usr/local/bin/create_service_backup.sh $backup $TMP_BACKUP_FOLDER
done

BACKUP_DATE=`date +%Y_%m_%d_%H_%M`

BACKUP_FILE_NAME="backup_${BACKUP_DATE}.tgz"
# create backup file
mkdir -p ${LOCAL_BACKUP_FOLDER}
cd ${TMP_BACKUP_FOLDER}
tar -czf $BACKUP_FILE_NAME --exclude=${BACKUP_FILE_NAME} ./

# send backup in the backup folder
mv ${TMP_BACKUP_FOLDER}/${BACKUP_FILE_NAME} ${LOCAL_BACKUP_FOLDER}/
cd ${LOCAL_BACKUP_FOLDER}

# rotate backups
if [ ! -z "$ROTATE_BACKUPS" ]; then
  echo "Rotate backups"
  rotate-backups --hourly=240 --daily=60 --weekly=16 --yearl=always -v ${LOCAL_BACKUP_FOLDER}
else
  echo "Rotate backups disabled! ROTATE_BACKUPS env variable is not set."
fi

#sync backup
if [ ! -z "$REMOTE_BACKUP_PATH" ]; then
  cd ${LOCAL_BACKUP_FOLDER}
  rclone sync -v ./ backup:${REMOTE_BACKUP_PATH}/
else
  echo "Syncronisation failed as env variable REMOTE_BACKUP_PATH is empty"
fi



