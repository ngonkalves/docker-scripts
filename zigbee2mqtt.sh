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
            --privileged=true \
            $network_option \
            --device $DEVICE:$DEVICE \
            -e TZ="$TIMEZONE" \
            $ENVS_STR \
            -v /run/udev:/run/udev:ro \
            -v $VOL_DATA:/app/data \
            --restart="$CONTAINER_RESTART_MODE" \
            "$IMAGE"
        exit $?
        ;;
check-permission)
        echo "---------------------------------"
        echo "Check write permissions: $DEVICE "
        echo "---------------------------------"
        test -w $DEVICE && echo "OK: user/group has write permissions" || echo "FAILED: user/group doesn't have write permissions"
        exit 0
        ;;
set-defaults|force-defaults)
        echo -e "---------------------------------\n"
        echo -e "Setting defaults for $CONTAINER\n"
        echo -e "---------------------------------\n"

        $0 create-folder-structure

        file_path="$VOL_DATA/configuration.yaml"
        [[ -e "$file_path" && "$1" == "set-defaults" ]] || echo "overwriting: $file_path" && \
        cat << EOF > $file_path
homeassistant: false
permit_join: true
mqtt:
  base_topic: zigbee2mqtt
  server: 'mqtt://${CONTAINER_PREFIX}-mosquitto'
  user: user
  password: password
  version: 5
serial:
  port: $DEVICE
advanced:
  rtscts: false
  log_level: info
  pan_id: 6755
device_options: {}
external_converters: []
EOF
#############################################################
        ;;
*)
        # include common operations
        source $SCRIPTPATH/.common-operations.sh
        echo -e "\t\t\t\t----------------------------------------
                                 check-permission
                                 set-defaults | force-defaults
                                 "

        exit 2
        ;;
esac
exit 0
