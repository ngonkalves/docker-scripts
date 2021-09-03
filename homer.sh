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

        network_option=$( [[ ! $NETWORK == "" ]] && echo "--net $NETWORK")

        WEB_PORT=$([[ ! $PORT = "" ]] && echo "-p $PORT:8080" || echo "" )

        docker create \
            --name="$CONTAINER" \
            --restart="$CONTAINER_RESTART_MODE" \
            $network_option \
            $ENVS_STR \
            $LABELS_STR \
            -v $VOL_ASSETS:/www/assets \
            $WEB_PORT \
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