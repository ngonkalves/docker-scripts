#!/usr/bin/env bash
#################################################################################
#################################################################################

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
            -e PUID=$PUID \
            -e PGID=$PGID \
            -e SERVERURL=$SERVERURL \
            -v $VOL_DATA:/data \
            --restart="$CONTAINER_RESTART_MODE" \
            -p $PORT:9000 \
            "$IMAGE"
        exit $?
        ;;
*)
        # include common operations
        source $SCRIPTPATH/.common-operations.sh
        exit 2
        ;;
esac
exit 0
