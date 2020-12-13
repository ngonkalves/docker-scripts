#!/usr/bin/env bash
#################################################################################
# Sources:
# https://github.com/linuxserver/docker-wireguard
#################################################################################

# to abort the script if any command returns a failure (nonzero) status
set -e
# script will exit with error when variable not set
set -u # or set -o nounset

CURRENT_DIR=`pwd`
CURRENT_FILE=`basename "${0}"`
FILE_VARS="${CURRENT_FILE%%.*}.vars"

[[ -e $FILE_VARS ]] && source $FILE_VARS && [[ $DEBUG == 1 ]] && echo "Variables loaded from: $FILE_VARS"
[[ ! -e $FILE_VARS ]] && echo -e "Variables file doesn't exist: $FILE_VARS\n\nRename the $FILE_VARS.template to $FILE_VARS as starting point.\n" && exit 1

# due to set -u we need to define a default value of empty when no arguments are passed
# https://stackoverflow.com/questions/43707685/set-u-nounset-vs-checking-whether-i-have-arguments
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
        echo -e "Pulling container image $IMAGE\n"
        echo -e "---------------------------------\n"
        docker pull $IMAGE
        exit $?
        ;;
restart)
        echo -e "---------------------------------\n"
        echo -e "Restarting container $CONTAINER\n"
        echo -e "---------------------------------\n"
        docker restart $CONTAINER
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
            -e "TZ=$TZ" \
            -e "LOG_LEVEL=$LOG_LEVEL" \
            -e "LOG_JSON=$LOG_JSON" \
            -e "DIUN_WATCH_WORKERS=$WATCH_WORKERS" \
            -e "DIUN_WATCH_SCHEDULE=$WATCH_SCHEDULE" \
            -e "DIUN_PROVIDERS_DOCKER=$PROVIDERS_DOCKER" \
            -e "DIUN_PROVIDERS_DOCKER_WATCHSTOPPED=$PROVIDERS_DOCKER_WATCHSTOPPED" \
            -v $DIR_DATA:/data \
            -v "/var/run/docker.sock:/var/run/docker.sock" \
            -l "diun.enable=$ENABLE" \
            -l "diun.watch_repo=$WATCH_REPO" \
            --restart="$RESTART_MODE" \
            "$IMAGE"
        exit $?
        ;;
uname)
        echo -e "---------------------------------\n"
        echo -e "Execute command for container $CONTAINER\n"
        echo -e "---------------------------------\n"
        docker exec -it $CONTAINER uname -a
        exit $?
        ;;
recreate|rebuild)
        echo -e "---------------------------------\n"
        echo -e "Rebuilding container $CONTAINER\n"
        echo -e "---------------------------------\n"
        $0 stop &> /dev/null || echo "Container doesn't exist"
        $0 remove &> /dev/null || echo "Container doesn't exist"
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
        docker exec -it $CONTAINER /bin/sh
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
