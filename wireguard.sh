#!/usr/bin/env bash
#################################################################################
# Sources:
# https://github.com/linuxserver/docker-wireguard
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
            --cap-add=NET_ADMIN \
            --cap-add=SYS_MODULE \
            -e TZ="$TIMEZONE" \
            -e PUID=$PUID \
            -e PGID=$PGID \
            -e SERVERURL=$SERVERURL \
            -e SERVERPORT=$SERVERPORT \
            -e PEERS=$PEERS \
            -e PEERDNS=$PEERDNS \
            -e INTERNAL_SUBNET=$INTERNAL_SUBNET \
            -e ALLOWEDIPS=$ALLOWEDIPS \
            -v $VOL_CONFIG:/config \
            -v $VOL_MODULES:/lib/modules \
            -v $VOL_USR_SRC:/usr/src \
            --restart="$CONTAINER_RESTART_MODE" \
            --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
            -p $SERVERPORT:51820/udp \
            "$CONTAINER_IMAGE"
        exit $?
        ;;
users)
        echo -e "---------------------------------\n"
        echo -e "Execute command for container $CONTAINER\n"
        echo -e "---------------------------------\n"
        docker exec -it $CONTAINER /app/show-peer ${PEERS/,/ }
        exit $?
        ;;
user)
        echo -e "---------------------------------\n"
        echo -e "Execute command for container $CONTAINER\n"
        echo -e "---------------------------------\n"
        docker exec -it $CONTAINER /app/show-peer ${2-}
        exit $?
        ;;
*)
        # include common operations
        source $SCRIPTPATH/.common-operations.sh
        echo -e "\t\t\t\t----------------------------------------
                                 users
                                 user [username]"
        exit 2
        ;;
esac
exit 0
