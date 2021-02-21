#!/usr/bin/env bash

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

# include init
source $SCRIPTPATH/.common-init.sh

# to abort the script if any command returns a failure (nonzero) status
set -e
# script will exit with error when variable not set
set -u # or set -o nounset

case "${1-}" in
create|build)
        echo -e "---------------------------------\n"
        echo -e "Creating container $CONTAINER\n"
        echo -e "---------------------------------\n"

        docker create \
            --name="$CONTAINER" \
            -e TZ="$TIMEZONE" \
            -e RUN_CROND=$RUN_CROND \
            -e BACKUP_INTERVAL=$BACKUP_INTERVAL \
            -e BACKUP_RETENTION=$BACKUP_RETENTION \
            -v $VOL_DATA:/data \
            --restart="$CONTAINER_RESTART_MODE" \
            -p $WEB_PORT:3000 \
            -p $SSH_PORT:22 \
            "$IMAGE"
        exit $?
        ;;
*)
        # include common operations
        source $SCRIPTPATH/.common-operations.sh
        echo -e "\t\t\t\t----------------------------------------"
        exit 2
        ;;
esac
exit 0
