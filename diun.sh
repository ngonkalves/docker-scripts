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

        docker create \
            --name="$CONTAINER" \
            -e "TZ=$TIMEZONE" \
            -e "LOG_LEVEL=$LOG_LEVEL" \
            -e "LOG_JSON=$LOG_JSON" \
            -e "DIUN_WATCH_WORKERS=$WATCH_WORKERS" \
            -e "DIUN_WATCH_SCHEDULE=$WATCH_SCHEDULE" \
            -e "DIUN_PROVIDERS_DOCKER=$PROVIDERS_DOCKER" \
            -e "DIUN_PROVIDERS_DOCKER_WATCHSTOPPED=$PROVIDERS_DOCKER_WATCHSTOPPED" \
            -e "DIUN_PROVIDERS_DOCKER_WATCHBYDEFAULT=$PROVIDERS_DOCKER_WATCHBYDEFAULT" \
            -e "DIUN_NOTIF_TELEGRAM_TOKEN=$TELEGRAM_TOKEN" \
            -e "DIUN_NOTIF_TELEGRAM_CHATIDS=$TELEGRAM_CHATIDS" \
            -v $VOL_DATA:/data \
            -v "/var/run/docker.sock:/var/run/docker.sock:ro" \
            -l "diun.enable=$ENABLE" \
            -l "diun.watch_repo=$WATCH_REPO" \
            --restart="$RESTART_MODE" \
            "$IMAGE"
        exit $?
        ;;
*)
        # include common operations
        source $SCRIPTPATH/.common-operations.sh
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
