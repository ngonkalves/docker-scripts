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

# due to set -u we need to define a default value of empty when no arguments are passed
# https://stackoverflow.com/questions/43707685/set-u-nounset-vs-checking-whether-i-have-arguments
case "${1-}" in
create|build)
        echo -e "---------------------------------\n"
        echo -e "Creating container $CONTAINER\n"
        echo -e "---------------------------------\n"

        network_option=$( [[ ! $NETWORK == "" ]] && echo "--net $NETWORK" || echo "")
        
		SERVERPORT_STR=$([[ ! $SERVERPORT = "" ]] && echo "-p $SERVERPORT:51820/udp" || echo "" )

        docker create \
            --name="$CONTAINER" \
            --cap-add=NET_ADMIN \
            --cap-add=SYS_MODULE \
            --restart="$RESTART_MODE" \
            --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
			$network_option \
            $ENVS_STR \
            $LABELS_STR \
            -v $VOL_CONFIG:/config \
            -v $VOL_MODULES:/lib/modules \
            -v $VOL_USR_SRC:/usr/src \
            $SERVERPORT_STR \
            "$IMAGE"
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
