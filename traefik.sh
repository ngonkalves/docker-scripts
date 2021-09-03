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

        docker create \
            --name="$CONTAINER" \
            --security-opt="no-new-privileges:true" \
            --restart="$RESTART_MODE" \
            $network_option \
            $ENVS_STR \
            $LABELS_STR \
            -p $PORT_UNSECURE:80 \
            -p $PORT_SECURE:443 \
            -v /etc/localtime:/etc/localtime:ro \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            -v $VOL_DYNAMIC_CONFIG:/etc/traefik/dynamic_conf/config.yml:rw \
            -v $VOL_CERTS:/tools/certs:rw \
            "$IMAGE"
            --api.insecure=true \
            --entrypoints.web.address=:80 \
            --entrypoints.websecure.address=:443 \
            --providers.docker=true \
            --providers.file.filename=/etc/traefik/dynamic_conf/config.yml \
            --providers.file.watch=true
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
