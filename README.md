# docker-backup-service
Docker container for creating backups by connecting to multiple [backup-agent](https://github.com/tiberiuc/docker-backup-agent) and store it in the cloud

* Based on  [Alpine Linux](https://alpinelinux.org/)
* Bacukp rotating is done with [rotate-backups](https://github.com/xolox/python-rotate-backups)
* Offsite backups storage is done with [rclone](https://rclone.org/l). Check their documentaion for different remote types.
* Backups interval are cron based

## Quick start

Requires that [Docker be installed](https://docs.docker.com/engine/installation/) on the host machine.

```
# Create some directory where your local backup data will be stored.
$ mkdir /home/youruser/backup

$ docker run --name backup-service -d \
   --env 'RCLONE_CONFIG_BACKUP_TYPE=s3' \
   --env 'RCLONE_CONFIG_BACKUP_PROVIDER=aws'
   --env 'RCLONE_CONFIG_BACKUP_ACCESS_KEY_ID=<yourkey>'
   --env 'RCLONE_CONFIG_BACKUP_SECRET_ACCESS_KEY=<youraccesskey>'
   --env 'RCLONE_CONFIG_BACKUP_REGION=us-east-1' \
   --env 'RCLONE_CONFIG_BACKUP_ACL=bucket-owner-full-control' \
   --env 'ROTATE_BACKUPS="-hourly=240 --daily=60 --weekly=16 --yearl=always"' \
   --env 'REMOTE_BACKUP_PATH=/backup-bucket/backups' \
   --env 'BACKUP_INTERVAL="0 * * * *"' \
   --env 'SERVICES_BACKUP_LIST="webapp=http://webapp:9191/  database=http://database:9191" \
   -v /home/data/backup:/backup
   tiberiuc/backup-service

$ docker logs -f backup-service
[ ... ]
```


## Configuration

Configuration is done by sending environmental variables to the container

| name | default | example |
| ---- | ------- | --- |
|RCLONE_CONFIG_BACKUP_rclone-config |  | see [rclone](https://rclone.org/l) !IMPORTANT!  the name of the remote should be BACKUP|
|ROTATE_BACKUPS| | "-hourly=24 --daily=60 --weekly=16 --yearl=always" see [rotate-backups](https://github.com/xolox/python-rotate-backups)|
|REMOTE_BACKUP_PATH| |/backup-bucket/backup |
|BACKUP_INTERVAL | | "0 \* \* \* \*" |
|SERVICES_BACKUP_LIST| | Space separated list of values in format <backup_name>=<backup_agent_url> ex: `"webapp=http://webapp:9191  database=http://database:9191"` |


## Manual backup

```
docker exec backup-service /usr/local/bin/run_backup.sh
```

## Restore from backup

Restoring from backup is made only manual. Local backups can be found in /backup folder local on container. That folder can be on host machine and mount with --volume
For other backups files you need to copy first on the running container
```
docker exec backup-service /usr/local/bin/run_restore.sh <backup_file.tgz>
```

For restoration on only one service ( for example database service ). Service must be defined on `SERVICES_BACKUP_LIST` env variable
```
docker exec backup-service /usr/local/bin/run_restore.sh --only database <backup_file.tgz>
```

