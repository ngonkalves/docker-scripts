#!/usr/bin/env bash
#################################################################################
# Sources:
# https://github.com/linuxserver/docker-wireguard
#################################################################################

# include common functions
source .common-functions

# to abort the script if any command returns a failure (nonzero) status
set -e
# script will exit with error when variable not set
set -u # or set -o nounset

case "${1-}" in
start)
        echo -e "---------------------------------\n"
        echo -e "Starting container $CONTAINER\n"
        echo -e "---------------------------------\n"
        docker start $CONTAINER
        printf '\nStarting up %s container\n\n' "$CONTAINER"
        $0 logf
        exit $?
        ;;
stop)
        echo -e "---------------------------------\n"
        echo -e "Stopping container $CONTAINER\n"
        echo -e "---------------------------------\n"
        docker stop $CONTAINER
        exit $?
        ;;
pull)
        echo -e "---------------------------------\n"
        echo -e "Pulling container image $CONTAINER_IMAGE\n"
        echo -e "---------------------------------\n"
        docker pull $CONTAINER_IMAGE
        exit $?
        ;;
restart)
        echo -e "---------------------------------\n"
        echo -e "Restarting container $CONTAINER\n"
        echo -e "---------------------------------\n"
        docker restart $CONTAINER
        # $0 stop
        # $0 start
        exit $?
        ;;
remove)
        echo -e "---------------------------------\n"
        echo -e "Remove container $CONTAINER\n"
        echo -e "---------------------------------\n"
        docker container rm $CONTAINER
        exit $?
        ;;
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
            -v $DIR_CONFIG:/config \
            -v $DIR_MODULES:/lib/modules \
            -v $DIR_USR_SRC:/usr/src \
            --restart="$CONTAINER_RESTART_MODE" \
            --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
            -p $SERVERPORT:51820/udp \
            "$CONTAINER_IMAGE"
        exit $?
        ;;
uname)
        echo -e "---------------------------------\n"
        echo -e "Execute command for container $CONTAINER\n"
        echo -e "---------------------------------\n"
        docker exec -it $CONTAINER uname -a
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
recreate|rebuild)
        echo -e "---------------------------------\n"
        echo -e "Rebuilding container $CONTAINER\n"
        echo -e "---------------------------------\n"
        $0 stop &> /dev/null || echo "Container $CONTAINER doesn't exist"
        $0 remove &> /dev/null || echo "Container $CONTAINER doesn't exist"
        $0 pull
        $0 create
        echo -e "---------------------------------\n"
        echo -e "---------------------------------\n"
        docker container ls -a -f name=$CONTAINER
        exit $?
        ;;
terminal|console)
        echo -e "---------------------------------\n"
        echo -e "Accessing terminal $CONTAINER\n"
        echo -e "---------------------------------\n"
        docker exec -it $CONTAINER /bin/bash
        exit $?
        ;;
log)
        echo -e "---------------------------------\n"
        echo -e "     Accessing logs: $CONTAINER\n  "
        echo -e "---------------------------------\n"
        docker logs $CONTAINER
        exit $?
        ;;
logf)
        echo -e "---------------------------------\n"
        echo -e "     Accessing logs: $CONTAINER\n  "
        echo -e "---------------------------------\n"
        docker logs -f $CONTAINER
        exit $?
        ;;
status)
        echo -e "---------------------------------\n"
        echo -e "     Status: $CONTAINER\n  "
        echo -e "---------------------------------\n"
        docker ps -a -f name=$CONTAINER
        exit $?
        ;;
*)
        echo -e "
        Usage: $0
                                 start | stop | restart
                                 pull
                                 remove
                                 create | recreate
                                 terminal | console
                                 log
                                 logf
                                 status"
        exit 2
        ;;
esac
exit 0
