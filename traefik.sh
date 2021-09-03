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

        network_option=$( [[ ! $NETWORK == "" ]] && echo "--net $NETWORK")

		WEB_PORT_UNSECURE_STR=$([[ ! $WEB_PORT_UNSECURE = "" ]] && echo "-p $WEB_PORT_UNSECURE:80" || echo "" )
		WEB_PORT_SECURE_STR=$([[ ! $WEB_PORT_SECURE = "" ]] && echo "-p $WEB_PORT_SECURE:443" || echo "" )

        docker create \
            --name="$CONTAINER" \
            --security-opt="no-new-privileges:true" \
            --restart="$RESTART_MODE" \
            $network_option \
            $ENVS_STR \
            $LABELS_STR \
            $WEB_PORT_UNSECURE_STR \
            $WEB_PORT_SECURE_STR \
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
