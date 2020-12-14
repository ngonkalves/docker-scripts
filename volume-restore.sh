#!/usr/bin/env bash
#################################################################################
# Sources:
# https://stackoverflow.com/a/26339869/5774036
# https://stackoverflow.com/a/23778599/5774036
# https://github.com/discordianfish/docker-backup
#################################################################################
#
# This script allows you to restore a single volume from a container
# Data in restored in volume with same backupped path
NEW_CONTAINER_NAME=$1

usage() {
  echo "Usage: $0 [container name]"
  exit 1
}

if [ -z $CONTAINER_NAME ]
then
  echo "Error: missing container name parameter."
  usage
fi

sudo docker run --rm --volumes-from $CONTAINER_NAME -v $(pwd):/backup busybox tar xvf /backup/backup-${CONTAINER_NAME}.tar
