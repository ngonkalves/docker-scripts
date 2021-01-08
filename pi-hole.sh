#!/usr/bin/env bash
#################################################################################
# Sources:
# https://howchoo.com/pi/pi-hole-setup
# https://github.com/pi-hole/docker-pi-hole/blob/master/docker_run.sh
# https://codeopolis.com/posts/running-pi-hole-in-docker-is-remarkably-easy/
#
# Vodafone:
# https://hugo-ma-alves.github.io/2019-03-22-pihole-vodafone/
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
        echo -e "Starting container $CONTAINER\n"
        docker start $CONTAINER
        printf 'Starting up pihole container '
        for i in $(seq 1 60); do
            if [ "$(docker inspect -f "{{.State.Health.Status}}" $CONTAINER)" == "healthy" ] ; then
                printf ' OK'
                if docker logs $CONTAINER 2> /dev/null | grep 'password:'; then
                    echo -e "\n$(docker logs pihole 2> /dev/null | grep 'password:') for your pi-hole: https://${SERVER_IPV4}/admin/"
                else
                    echo -e "\nAdmin webpage: https://${SERVER_IPV4}/admin/"
                fi
                exit 0
            else
                sleep 3
                printf '.'
            fi
        done;
        echo -e "\nTimed out waiting for Pi-hole start, check your container logs for more info (\`$0 log\`)"
        exit 1
        ;;
create|build)
        echo -e "Creating container $CONTAINER\n"

        docker create \
            --name="$CONTAINER" \
            -e TZ="$TIMEZONE" \
            -e WEBPASSWORD="$WEBPASSWORD" \
            -e ServerIP="$SERVER_IPV4" \
            -e ServerIPv6="$SERVER_IPV6" \
            -e DNS1="$DNS_SERVER1" \
            -e DNS2="$DNS_SERVER2" \
            -e ADMIN_EMAIL="$ADMIN_EMAIL" \
            -e IPv6="$IPV6" \
            -v $VOL_ETC_PIHOLE:/etc/pihole \
            -v $VOL_ETC_DNSMASQ:/etc/dnsmasq.d \
            --net=host \
            --dns="$SERVER_IPV4" \
            --dns="$DNS_SERVER" \
            --cap-add=NET_ADMIN \
            --restart="$CONTAINER_RESTART_MODE" \
            "$CONTAINER_IMAGE"
            # Containter network is the same as the host, there's no need to map ports
            #-p 80:80 \
            #-p 53:53/tcp \
            #-p 53:53/udp \
        exit $?
        ;;
chpasswd)
        echo -e "Changing admin password for $CONTAINER\n"
        docker exec -it $CONTAINER pihole -a -p
        exit $?
        ;;
*)
        # include common operations
        source $SCRIPTPATH/.common-operations
        echo -e "Usage: $0 {start|stop|pull|restart|remove|create|recreate|chpasswd|terminal|log|logf|status}\n"
        exit 2
        ;;
esac
exit 0
