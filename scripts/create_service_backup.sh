#!/bin/bash

BACKUP=$1
BACKUP_FOLDER=$2

arr=(`echo $BACKUP | tr  '=' "\n"`)
name=${arr[0]}
url=${arr[1]}

BACKUP_FILE_NAME=$BACKUP_FOLDER/$name.tgz

echo "Getting backup $name -> $url into $BACKUP_FILE_NAME"

curl $url/backup -o $BACKUP_FILE_NAME

