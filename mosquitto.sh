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

        network_option=$( [[ ! ${NETWORK-} == "" ]] && echo "--net $NETWORK" || echo "")

        PORT_STR=$([[ ! $PORT = "" ]] && echo "-p $PORT:1883" || echo "" )

        docker create \
            --name="$CONTAINER" \
            --user "$PUID:$PGID" \
            --restart="$RESTART_MODE" \
            $network_option \
            $ENVS_STR \
            $LABELS_STR \
            -v /etc/localtime:/etc/localtime:ro \
            -v $VOL_DATA:/mosquitto/data \
            -v $VOL_CONFIG:/mosquitto/config \
            -v $VOL_LOG:/mosquitto/log \
            $PORT_STR \
            "$IMAGE"
        exit $?
        ;;
set-defaults|force-defaults)
        echo -e "---------------------------------\n"
        echo -e "Setting defaults for $CONTAINER\n"
        echo -e "---------------------------------\n"

        $0 create-folder-structure

        file_path="$VOL_CONFIG/mosquitto.conf"
        [[ -e "$file_path" && "$1" == "set-defaults" ]] || echo "overwriting: $file_path" && \
        cat << EOF > $file_path
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
        file_path="$VOL_CONFIG/mosquitto_passwd"
        [[ -e "$file_path" && "$1" == "set-defaults" ]] || echo "overwriting: $file_path" && \
        cat << EOF > $file_path
EOF
#############################################################
        file_path="$VOL_CONFIG/conf.d/passwd.conf"
        [[ -e "$file_path" && "$1" == "set-defaults" ]] || echo "overwriting: $file_path" && \
        cat << EOF > $file_path
password_file /mosquitto/config/mosquitto_passwd
EOF
#############################################################
        file_path="$VOL_CONFIG/conf.d/anonymous.conf"
        [[ -e "$file_path" && "$1" == "set-defaults" ]] || echo "overwriting: $file_path" && \
        cat << EOF > $file_path
allow_anonymous false
EOF
#############################################################
        file_path="$VOL_CONFIG/conf.d/port.conf"
        [[ -e "$file_path" && "$1" == "set-defaults" ]] || echo "overwriting: $file_path" && \
        cat << EOF > $file_path
listener 1883
EOF
#############################################################
        file_path="$VOL_CONFIG/conf.d/README"
        [[ -e "$file_path" && "$1" == "set-defaults" ]] || echo "overwriting: $file_path" && \
        cat << EOF > $file_path
Any files placed in this directory that have a .conf ending will be loaded as
config files by the broker. Use this to make your local config.
EOF
#############################################################
        file_path="$VOL_LOG/mosquitto.log"
        [[ -e "$file_path" && "$1" == "set-defaults" ]] || echo "overwriting: $file_path" && \
        cat << EOF > $file_path
EOF
        ;;
create-user)
         echo -e "---------------------------------\n"
         echo -e "Enter username: "

         read USERNAME

         if [[ ! "$USERNAME" == "" ]]; then
             EXISTS=$(container_exists $CONTAINER)
             if [[ ! $EXISTS == "true" ]]; then
                 $0 recreate
             fi
             RUNNING=$(container_running $CONTAINER)
             if [[ ! $RUNNING == "true" ]]; then
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
