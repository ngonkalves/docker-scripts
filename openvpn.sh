#!/usr/bin/env bash
#################################################################################
# Sources:
# https://github.com/TheMardy/docker-openvpn
# https://github.com/kylemanna/docker-openvpn
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

        # if is a folder path, chech if exists
        if [[ "$OVPN_DATA" == *"/"* ]]; then
            echo -e "Container data is a folder: $OVPN_DATA"
            if [[ ! -e "$OVPN_DATA" ]]; then
                mkdir -p "$OVPN_DATA"
                # chgrp $DOCKER_GROUP $OVPN_DATA
            fi
        else
            echo -e "Container data is a docker volume: $OVPN_DATA"
        fi

        docker create \
            --name="$CONTAINER" \
            -e TZ="$TIMEZONE" \
            -v $VOL_ETC_OPENVPN:/etc/openvpn \
            --privileged \
            --restart="$CONTAINER_RESTART_MODE" \
            --sysctl net.ipv6.conf.all.disable_ipv6=1 \
            -p $OVPN_PORT:1194 \
            -e DEBUG=$DEBUG \
            "$IMAGE"
        exit $?
        ;;
init)
        echo -e "---------------------------------\n"
        echo -e "Init container $CONTAINER\n"
        echo -e "---------------------------------\n"
        # TODO: create docker volume if necessary
        echo -e "Initialize $CONTAINER configuration\n"
        docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm $IMAGE ovpn_genconfig -u udp://$OVPN_DOMAIN -n $OVPN_DNS_SERVER1 -n $OVPN_DNS_SERVER2 -n $OVPN_DNS_SERVER3
        docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it $IMAGE ovpn_initpki
        exit $?
        ;;
fix-permissions)
        echo -e "---------------------------------\n"
        echo -e "---------------------------------\n"
        # if is a folder path, chech if exists
        if [[ "$OVPN_DATA" == *"/"* ]]; then
            echo -e "Container data is a folder: $OVPN_DATA"
            if [[ -e "$OVPN_DATA" ]]; then
                sudo chown -R $(whoami) "$OVPN_DATA"
                sudo chgrp -R "$DOCKER_GROUP" "$OVPN_DATA"
            fi
        else
            echo -e "Container data is a docker volume: $OVPN_DATA"
        fi

        ;;
generate-client-nopass|generate-client)
        echo -e "---------------------------------\n"
        if [[ "$1" == *"-nopass" ]]; then
            echo -e "Generate a client certificate without a passphrase"
        else
            echo -e "Generate a client certificate"
        fi
        echo -e "---------------------------------\n"
        echo -e "---------------------------------\n"
        echo -e "Enter client username: "

        read CLIENTNAME

        if [[ ! "$CLIENTNAME" == "" ]]; then
            if [[ "$1" == *"-nopass" ]]; then
                docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it $IMAGE easyrsa build-client-full $CLIENTNAME nopass
            else
                docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it $IMAGE easyrsa build-client-full $CLIENTNAME
            fi
        else
            echo -e "\nMust provide a non empty username"
        fi
        exit $?
        ;;
revoke-client-remove|revoke-client)
        echo -e "---------------------------------\n"
        if [[ "$1" == *"-remove" ]]; then
            echo -e "Revoking a client certificate (REMOVE)"
        else
            echo -e "Revoking a client certificate"
        fi
        echo -e "---------------------------------\n"
        echo -e "---------------------------------\n"
        echo -e "Enter client username: "

        read CLIENTNAME

        if [[ ! "$CLIENTNAME" == "" ]]; then
            if [[ "$1" == *"-remove" ]]; then
                docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it $IMAGE ovpn_revokeclient $CLIENTNAME remove
            else
                docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it $IMAGE ovpn_revokeclient $CLIENTNAME
            fi
        else
            echo -e "\nMust provide a non empty username"
        fi
        exit $?
        ;;
retrieve-client-config)
        echo -e "---------------------------------\n"
        echo -e "Retrieve a client configuration with embedded certificates"
        echo -e "---------------------------------\n"
        echo -e "---------------------------------\n"
        echo -e "Enter client username: "

        read CLIENTNAME

        if [[ ! "$CLIENTNAME" == "" ]]; then
            docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it $IMAGE ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn
        else
            echo -e "\nMust provide a non empty username"
        fi
        exit $?
        ;;
*)
        # include common operations
        source $SCRIPTPATH/.common-operations.sh
        echo -e "\t\t\t\t----------------------------------------
                                 init
                                 fix-permissions
                                 generate-client-nopass | generate-client
                                 revoke-client-remove | revoke-client
                                 retrieve-client-config"
        exit 2
        ;;
esac
exit 0
