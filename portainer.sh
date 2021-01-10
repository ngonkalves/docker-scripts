#!/usr/bin/env bash
#################################################################################
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

        HTPASSWD_IMAGE="httpd:alpine"

        docker pull "$HTPASSWD_IMAGE"

        PASSWORD_HASH=$(docker run --rm "$HTPASSWD_IMAGE" htpasswd -nbB admin "$PASSWORD" | cut -d ":" -f 2)

        docker rmi -f $(docker images --format '{{.ID}}' --filter 'reference=$HTPASSWD_IMAGE')

        docker create \
            --name="$CONTAINER" \
            -e TZ="$TIMEZONE" \
            -e PUID=$PUID \
            -e PGID=$PGID \
            -v /etc/localtime:/etc/localtime:ro \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            -v $VOL_DATA:/data \
            --restart="$CONTAINER_RESTART_MODE" \
            -p $PORT:9000 \
            "$IMAGE" \
            -H unix:///var/run/docker.sock \
            --admin-password="$PASSWORD_HASH"
        exit $?
        ;;
*)
        # include common operations
        source $SCRIPTPATH/.common-operations.sh
        exit 2
        ;;
esac
exit 0
