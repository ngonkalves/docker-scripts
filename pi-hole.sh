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

CONTAINER="pihole"
CONTAINER_IMAGE="pihole/pihole:latest"
CONTAINER_RESTART_MODE="unless-stopped"
SERVER_IPV4="192.168.1.10"
SERVER_IPV6="2001:818:e303:ac00:81:a5ff:fea6:88a1"
IPV6="true"
DNS_SERVER="1.1.1.1"
DNS_SERVER1="1.1.1.1"
DNS_SERVER2="1.0.0.1"
ADMIN_EMAIL="email@domain.com"
TIMEZONE="Europe/Lisbon"
WEBPASSWORD="YourPasswordHere"

case "$1" in
start)
        echo -e "Starting container $CONTAINER\n"
        docker start $CONTAINER
        printf 'Starting up pihole container '
        for i in $(seq 1 30); do
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

            if [ $i -eq 20 ] ; then
                echo -e "\nTimed out waiting for Pi-hole start, consult check your container logs for more info (\`$0 log\`)"
                exit 1
            fi
        done;
        exit $?
        ;;
stop)
        echo -e "Stopping container $CONTAINER\n"
        docker stop $CONTAINER
        exit $?
        ;;
pull)
        echo -e "Pulling container image $CONTAINER_IMAGE\n"
        docker pull $CONTAINER_IMAGE
        exit $?
        ;;
restart)
        echo -e "Restarting container $CONTAINER\n"
        docker restart $CONTAINER
        # $0 stop
        # $0 start
        exit $?
        ;;
remove)
        echo -e "Remove container $CONTAINER\n"
        docker container rm $CONTAINER
        exit $?
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
            -v pihole:/etc/pihole \
            -v pihole-dnsmasq:/etc/dnsmasq.d \
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
recreate|rebuild)
        echo -e "Rebuilding container $CONTAINER\n"
        $0 stop &> /dev/null || echo "Container doesn't exist"
        $0 remove &> /dev/null || echo "Container doesn't exist"
        $0 pull
        $0 create
        $0 start
        exit $?
        ;;
chpasswd)
        echo -e "Changing admin password for $CONTAINER\n"
        docker exec -it $CONTAINER pihole -a -p
        exit $?
        ;;
terminal|console)
        echo -e "Accessing terminal $CONTAINER\n"
        docker exec -it $CONTAINER /bin/bash
        exit $?
        ;;
log)
        echo -e "Accessing logs $CONTAINER\n"
        docker logs $CONTAINER
        exit $?
        ;;
logf)
        echo -e "Accessing logs $CONTAINER\n"
        docker logs -f $CONTAINER
        exit $?
        ;;
status)
        docker ps -a -f name=$CONTAINER
        exit $?
        ;;
*)
        echo -e "Usage: $0 {start|stop|pull|restart|remove|create|recreate|chpasswd|terminal|log|logf|status}\n"
        exit 2
        ;;
esac
exit 0
