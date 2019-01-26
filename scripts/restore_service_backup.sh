#!/bin/bash

SERVICE_NAME=$1
BACKUP_FILE=$2

declare -A SERVICES

backups=`echo $SERVICES_BACKUP_LIST | tr ' ', ' ' | grep '\S'`
for backup in $backups; do
  arr=(`echo $backup | tr  '=' "\n"`)
  name=${arr[0]}
  url=${arr[1]}
  SERVICES[$name]=$url
done

url=${SERVICES[$SERVICE_NAME]}

if [ ! -z $url ]; then
  echo "Restoring ${SERVICE_NAME} from ${BACKUP_FILE}"
  curl -v   ${url}/restore --data-binary @${BACKUP_FILE}
else
  echo "Service '${SERVICE_NAME}' not found. Please check SERVICES_BACKUP_LIST env variable."
fi


