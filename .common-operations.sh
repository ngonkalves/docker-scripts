

case "${1-}" in
c|create|build)
    docker_create $CONTAINER
    ;;
s|start)
    docker_start $CONTAINER
    ;;
ss|stop)
    docker_stop $CONTAINER
    ;;
rs|restart)
    docker_restart $CONTAINER
    ;;
rm|remove)
    docker_remove $CONTAINER
    ;;
p|pull)
    docker_pull $IMAGE
    ;;
cp|copy)
    docker_cp $CONTAINER $2 $3
    ;;
re|recreate|rebuild)
    docker_recreate $CONTAINER
    ;;
cn|create-network)
    docker_create_network
    ;;
rmn|remove-network)
    docker_remove_network
    ;;
rmc|remove-config)
    remove_config $CONTAINER
    ;;
create-folder-structure)
    create_folder_structure
    ;;
rmec|remove-empty-config)
    remove-empty-config "$CURRENT_DIR"
    ;;
t|terminal|console)
    docker_exec_terminal $CONTAINER
    ;;
u|uname)
    docker_exec_uname $CONTAINER
    ;;
l|log)
    docker_log $CONTAINER
    ;;
lf|logf)
    docker_logf $CONTAINER
    ;;
i|inspect)
    docker_inspect $CONTAINER
    ;;
s|status)
    docker_ps $CONTAINER
    ;;
*)
    echo -e "
    Usage: $0
                             start | stop | restart | status
                             remove
                             create | recreate
                             create-network | remove-network
                             remove-config | remove-empty-config
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
