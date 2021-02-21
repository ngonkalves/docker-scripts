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
            --user $PUID:$PGID \
            -e TZ="$TIMEZONE" \
            -e NODE_RED_CREDENTIAL_SECRET=$CREDENTIAL_SECRET \
            -v $VOL_DATA:/data \
            -v /etc/timezone:/etc/timezone:ro \
            --restart="$CONTAINER_RESTART_MODE" \
            -p $WEB_PORT:1880 \
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
