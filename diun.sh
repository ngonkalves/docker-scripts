#!/usr/bin/env bash

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

# include init
source $SCRIPTPATH/.common-init.sh

# to abort the script if any command returns a failure (nonzero) status
set -e
# script will exit with error when variable not set
set -u # or set -o nounset

# due to set -u we need to define a default value of empty when no arguments are passed
# https://stackoverflow.com/questions/43707685/set-u-nounset-vs-checking-whether-i-have-arguments
case "${1-}" in
create|build)
        echo -e "---------------------------------\n"
        echo -e "Creating container $CONTAINER\n"
        echo -e "---------------------------------\n"

        network_option=$( [[ ! $NETWORK == "" ]] && echo "--net $NETWORK" || echo "")

        docker create \
            --name="$CONTAINER" \
            --restart="$RESTART_MODE" \
            $network_option \
            $ENVS_STR \
            $LABELS_STR \
			-v "/var/run/docker.sock:/var/run/docker.sock:ro" \
            -v $VOL_DATA:/data \
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
