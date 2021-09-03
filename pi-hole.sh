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

# include init
source $SCRIPTPATH/.common-init.sh

# to abort the script if any command returns a failure (nonzero) status
set -e
# script will exit with error when variable not set
set -u # or set -o nounset

# due to set -u we need to define a default value of empty when no arguments are passed
# https://stackoverflow.com/questions/43707685/set-u-nounset-vs-checking-whether-i-have-arguments
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
		# When containter network is the same as the host, there's no need to map ports
		WEB_PORT_STR=$([[ ! $WEB_PORT = "" ]] && echo "-p $WEB_PORT:80" || echo "" )
		DNS_PORT_STR=$([[ ! $DNS_PORT = "" ]] && echo "-p $DNS_PORT:53" || echo "" )
		
        docker create \
            --name="$CONTAINER" \
            --net=host \
            --dns="$ServerIP" \
            --dns="$DNS1" \
            --cap-add=NET_ADMIN \
            --restart="$RESTART_MODE" \
            -v $VOL_ETC_PIHOLE:/etc/pihole \
            -v $VOL_ETC_DNSMASQ:/etc/dnsmasq.d \
			$WEB_PORT_STR \
			$DNS_PORT_STR \
            "$IMAGE"
        exit $?
        ;;
chpasswd)
        echo -e "Changing admin password for $CONTAINER\n"
        docker exec -it $CONTAINER pihole -a -p
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
