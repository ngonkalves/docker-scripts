#!/usr/bin/env bash
#################################################################################
# Sources:
# https://stackoverflow.com/a/26339869/5774036
# https://stackoverflow.com/a/23778599/5774036
# https://github.com/discordianfish/docker-backup
#################################################################################
#
# This script allows you to backup a single volume from a container
# Data in given volume is saved in the current directory in a tar archive.
CONTAINER_NAME=$1
VOLUME_NAME=$2

usage() {
  echo "Usage: $0 [container name] [volume name]"
  exit 1
}

if [ -z $CONTAINER_NAME ]
then
  echo "Error: missing container name parameter."
  usage
fi

if [ -z $VOLUME_NAME ]
then
  echo "Error: missing volume name parameter."
  usage
fi

sudo docker run --rm --volumes-from $CONTAINER_NAME -v $(pwd):/backup busybox tar cvf /backup/backup-${CONTAINER_NAME}.tar $VOLUME_NAME
