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
set-defaults|force-defaults)
        echo -e "---------------------------------\n"
        echo -e "Setting defaults for $CONTAINER\n"
        echo -e "---------------------------------\n"
        #[[ -x "$VOL_CONFIG/conf.d" ]] || mkdir -p $VOL_CONFIG/conf.d

        FOLDERS=(
            "$VOL_CONFIG"
            "$VOL_CONFIG/conf.d"
            "$VOL_LOG"
        )

        FILES=(
            "$VOL_CONFIG/mosquitto.conf"
            "$VOL_CONFIG/mosquitto_passwd"
            "$VOL_CONFIG/conf.d/passwd.conf"
            "$VOL_CONFIG/conf.d/anonymous.conf"
            "$VOL_CONFIG/conf.d/port.conf"
            "$VOL_LOG/mosquitto.log"
        )

        for FOLDER in ${FOLDERS[@]}; do
            echo "processing folder: $FOLDER"
            if [[ ! -x "$FOLDER" ]]; then
                mkdir -p "$FOLDER"
            fi
            echo "change permissions: $FOLDER"
            chown "$PUID":"$PGID" "$FOLDER"
            chmod 770 "$FOLDER"
        done;

        for FILE in ${FILES[@]}; do
            echo "processing file: $FILE"
            if [[ ! -e "$FILE" ]]; then
                touch "$FILE"
            fi
            echo "change permissions: $FILE"
            chown "$PUID":"$PGID" "$FILE"
            chmod 660 "$FILE"
        done;

        [[ -e "$VOL_CONFIG/mosquitto.conf" && "$1" == "set-defaults" ]] || echo "overwriting: $VOL_CONFIG/mosquitto.conf" && \
        cat << EOF > $VOL_CONFIG/mosquitto.conf
# Place your local configuration in /etc/mosquitto/conf.d/
#
# A full description of the configuration file is at
# /usr/share/doc/mosquitto/examples/mosquitto.conf.example

###############################################################################
# https://mosquitto.org/documentation/migrating-to-2-0/
# https://github.com/eclipse/mosquitto/issues/1950#issuecomment-774030111
###############################################################################
#pid_file /var/run/mosquitto.pid

persistence true
persistence_location /mosquitto/data/

log_type all

log_dest file /mosquitto/log/mosquitto.log

include_dir /mosquitto/config/conf.d
EOF
#############################################################
        [[ -e "$VOL_CONFIG/mosquitto_passwd" && "$1" == "set-defaults" ]] || echo "overwriting: $VOL_CONFIG/mosquitto_passwd" && \
        cat << EOF > $VOL_CONFIG/mosquitto_passwd
EOF
#        [[ -e "$VOL_CONFIG/mosquitto_passwd" ]] && chmod 666 "$VOL_CONFIG/mosquitto_passwd"
#############################################################
        [[ -e "$VOL_CONFIG/conf.d/passwd.conf" && "$1" == "set-defaults" ]] || echo "overwriting: $VOL_CONFIG/conf.d/passwd.conf" && \
        cat << EOF > $VOL_CONFIG/conf.d/passwd.conf
password_file /mosquitto/config/mosquitto_passwd
EOF
#############################################################
        [[ -e "$VOL_CONFIG/conf.d/anonymous.conf" && "$1" == "set-defaults" ]] || echo "overwriting: $VOL_CONFIG/conf.d/anonymous.conf" && \
        cat << EOF > $VOL_CONFIG/conf.d/anonymous.conf
allow_anonymous false
EOF
#############################################################
        [[ -e "$VOL_CONFIG/conf.d/port.conf" && "$1" == "set-defaults" ]] || echo "overwriting: $VOL_CONFIG/conf.d/port.conf" && \
        cat << EOF > $VOL_CONFIG/conf.d/port.conf
listener 1883
EOF
#############################################################
        [[ -e "$VOL_CONFIG/config.d/README" && "$1" == "set-defaults" ]] || echo "overwriting: $VOL_CONFIG/conf.d/README" && \
        cat << EOF > $VOL_CONFIG/conf.d/README
Any files placed in this directory that have a .conf ending will be loaded as
config files by the broker. Use this to make your local config.
EOF
#############################################################
        [[ -e "$VOL_LOG/mosquitto.log" && "$1" == "set-defaults" ]] || echo "overwriting: $VOL_LOG/mosquitto.log" && \
        cat << EOF > $VOL_LOG/mosquitto.log
EOF
#        [[ -e "$VOL_LOG/mosquitto.log" ]] && chmod 666 "$VOL_LOG/mosquitto.log"
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
             RUNNING=$(container_running $CONTAINER)
             if [[ ! $RUNNING = "true" ]]; then
                 docker start $CONTAINER
             fi
             #docker run -it $CONTAINER mosquitto_passwd -c test $USERNAME
             docker exec -it $CONTAINER mosquitto_passwd -c /mosquitto/config/mosquitto_passwd $USERNAME
         else
             echo -e "\nMust provide a non empty username"
             exit 2
         fi
         exit $?
         ;;
*)
        # include common operations
        source $SCRIPTPATH/.common-operations.sh
        echo -e "\t\t\t\t----------------------------------------
                                  set-defaults | force-defaults
                                  create-user
                                  "

        exit 2
        ;;
esac
exit 0
