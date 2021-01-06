#!/usr/bin/env bash
#################################################################################
# Sources:
# https://github.com/TheMardy/docker-openvpn
# https://github.com/kylemanna/docker-openvpn
#################################################################################

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

# include common functions
source $SCRIPTPATH/.common-functions

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
        $0 log
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
            -v $OVPN_DATA:/etc/openvpn \
            --privileged \
            --restart="$CONTAINER_RESTART_MODE" \
            --sysctl net.ipv6.conf.all.disable_ipv6=1 \
            -p $OVPN_PORT:1194 \
            -e DEBUG=$DEBUG \
            "$CONTAINER_IMAGE"
        exit $?
        ;;
init)
        echo -e "---------------------------------\n"
        echo -e "Init container $CONTAINER\n"
        echo -e "---------------------------------\n"
        # TODO: create docker volume if necessary
        echo -e "Initialize $CONTAINER configuration\n"
        docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm $CONTAINER_IMAGE ovpn_genconfig -u udp://$OVPN_DOMAIN -n $OVPN_DNS_SERVER1 -n $OVPN_DNS_SERVER2 -n $OVPN_DNS_SERVER3
        docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it $CONTAINER_IMAGE ovpn_initpki
        exit $?
        ;;
uname)
        echo -e "---------------------------------\n"
        echo -e "Execute command for container $CONTAINER\n"
        echo -e "---------------------------------\n"
        docker exec -it $CONTAINER uname -a
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
                docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it $CONTAINER_IMAGE easyrsa build-client-full $CLIENTNAME nopass
            else
                docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it $CONTAINER_IMAGE easyrsa build-client-full $CLIENTNAME
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
                docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it $CONTAINER_IMAGE ovpn_revokeclient $CLIENTNAME remove
            else
                docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it $CONTAINER_IMAGE ovpn_revokeclient $CLIENTNAME
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
            docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm -it $CONTAINER_IMAGE ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn
        else
            echo -e "\nMust provide a non empty username"
        fi
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
                                 start | stop
                                 pull
                                 restart
                                 remove
                                 create | recreate
                                 generate-client | generate-client-nopass
                                 revoke-client | revoke-client-remove
                                 retrieve-client-config
                                 fix-permissions
                                 terminal
                                 log
                                 logf
                                 status"
        exit 2
        ;;
esac
exit 0
