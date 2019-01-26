#!/bin/bash

while test $# -gt 0; do
  case "$1" in
    --only)
      shift
      ONLY=$1
      shift
      ;;
    *)
      BACKUP_FILE=$1
      shift
      ;;
  esac
done


if [ -z "${BACKUP_FILE}" ]; then
  echo "ERROR: No backup file provided!"
  echo "USAGE: run_restore.sh  [--only <service_name>] <backup_file>"
  exit
fi


TMP_RESTORE_FOLDER=/tmp/restore

rm -rf ${TMP_RESTORE_FOLDER}
mkdir -p ${TMP_RESTORE_FOLDER}

tar -xzf ${BACKUP_FILE} -C ${TMP_RESTORE_FOLDER}/

for service_backup in ${TMP_RESTORE_FOLDER}/*; do
  backup_file=${service_backup##*/}
  service_name=${backup_file%.*}
  if [ -z "$ONLY" ] || [ "$ONLY" == "$service_name" ]  ; then
    /usr/local/bin/restore_service_backup.sh ${service_name} ${service_backup}
  fi
done
