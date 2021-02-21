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

        docker create \
            --name="$CONTAINER" \
            --user "$PUID:$PGID" \
            -e TZ="$TIMEZONE" \
            -v $VOL_DATA:/mosquitto/data \
            -v $VOL_CONFIG:/mosquitto/config \
            -v $VOL_LOG:/mosquitto/log \
            -v /etc/localtime:/etc/localtime:ro \
            --restart="$CONTAINER_RESTART_MODE" \
            -p $PORT1:1883 \
            -p $PORT2:8883 \
            -p $PORT3:9001 \
            "$IMAGE"
        exit $?
        ;;
create-user)
         echo -e "---------------------------------\n"
         echo -e "Enter username: "

         read USERNAME

         if [[ ! "$USERNAME" == "" ]]; then
             container_exist $CONTAINER
             EXISTS=$(container_exist $CONTAINER)
             if [[ ! $EXISTS = "true" ]]; then
                 $0 recreate
             fi
             docker run -it $CONTAINER mosquitto_passwd -c test $USERNAME
         else
             echo -e "\nMust provide a non empty username"
             exit 2
         fi
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
