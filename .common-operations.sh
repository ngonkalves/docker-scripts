

case "${1-}" in
create|build)
    docker_create $CONTAINER
    ;;
start)
    docker_start $CONTAINER
    ;;
stop)
    docker_stop $CONTAINER
    ;;
restart)
    docker_restart $CONTAINER
    ;;
remove)
    docker_remove $CONTAINER
    ;;
pull)
    docker_pull $IMAGE
    ;;
cp)
    docker_cp $CONTAINER $2 $3
    ;;
recreate|rebuild)
    docker_recreate $CONTAINER
    ;;
create-network)
    docker_create_network $NETWORK
    ;;
remove-network)
    docker_remove_network $NETWORK
    ;;
remove-config)
    remove_config $CONTAINER
    ;;
create-folder-structure)
    create_folder_structure
    ;;
terminal|console)
    docker_exec_terminal $CONTAINER
    ;;
uname)
    docker_exec_uname $CONTAINER
    ;;
log)
    docker_log $CONTAINER
    ;;
logf)
    docker_logf $CONTAINER
    ;;
inspect)
    docker_inspect $CONTAINER
    ;;
status)
    docker_ps $CONTAINER
    ;;
*)
    echo -e "
    Usage: $0
                             start | stop | restart | status
                             remove
                             create | recreate
                             create-network | remove-network
                             remove-config
                             terminal | console
                             pull
                             cp [source_path] [target_path]
                             uname
                             log
                             logf
                             inspect
                             status"
    ;;
esac;
