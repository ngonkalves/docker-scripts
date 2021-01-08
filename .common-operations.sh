

case "${1-}" in
start)
        echo -e "---------------------------------\n"
        echo -e "Starting container $CONTAINER\n"
        echo -e "---------------------------------\n"
        docker start $CONTAINER
        printf '\nStarting up %s container\n\n' "$CONTAINER"
        $0 logf
        exit $?
        ;;
stop)
        echo -e "---------------------------------\n"
        echo -e "Stopping container $CONTAINER\n"
        echo -e "---------------------------------\n"
        docker stop $CONTAINER
        exit $?
        ;;
restart)
        echo -e "---------------------------------\n"
        echo -e "Restarting container $CONTAINER\n"
        echo -e "---------------------------------\n"
        docker restart $CONTAINER
        exit $?
        ;;
remove)
        echo -e "---------------------------------\n"
        echo -e "Remove container $CONTAINER\n"
        echo -e "---------------------------------\n"
        $0 stop
        docker container rm $CONTAINER
        exit $?
        ;;
pull)
        echo -e "---------------------------------\n"
        echo -e "Pulling container image $IMAGE\n"
        echo -e "---------------------------------\n"
        docker pull $IMAGE
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
        $0 start
        echo -e "---------------------------------\n"
        echo -e "---------------------------------\n"
        docker container ls -a -f name=$CONTAINER
        exit $?
        ;;
terminal|console)
        echo -e "---------------------------------\n"
        echo -e "Accessing terminal $CONTAINER\n"
        echo -e "---------------------------------\n"
        docker exec -it $CONTAINER /bin/sh
        exit $?
        ;;
uname)
        echo -e "---------------------------------\n"
        echo -e "Execute command for container $CONTAINER\n"
        echo -e "---------------------------------\n"
        docker exec -it $CONTAINER uname -a
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
                                 start | stop | restart
                                 remove
                                 pull
                                 create | recreate
                                 terminal | console
                                 uname
                                 log
                                 logf
                                 status"
        ;;
esac;
