

case "${1-}" in
start)
        echo -e "---------------------------------\n"
        echo -e "Starting container $CONTAINER\n"
        echo -e "---------------------------------\n"
        $0 create-network
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
cp)
        echo -e "---------------------------------\n"
        echo -e "Copying from container $CONTAINER\n"
        echo -e "---------------------------------\n"
        [ -z ${2+x} ] && echo "source path not defined" && exit 1
        [ -z ${3+x} ] && echo "target path not defined" && exit 1
        docker cp "$CONTAINER":"$2" "$3"
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
        echo -e "---------------------------------\n"
        echo -e "---------------------------------\n"
        $0 start
        exit $?
        ;;
create-network)
        if [[ ! ${NETWORK-} == "" ]]; then
            echo -e "---------------------------------\n"
            echo -e "Creating network $NETWORK\n"
            echo -e "---------------------------------\n"
            create_network_if_not_exists "$NETWORK"
            exit $?
        fi
        exit 0
        ;;
remove-network)
        #if [[ ! ${NETWORK-} == "" ]]; then
            # TODO: remove network if not in use
        #fi
        ;;
remove-config)
        read -r -p "Do you really want to remove all configuration files? [y/N] " option
        case ${option-} in
            [yY][eE][sS]|[yY])
                $0 stop || true
                read -r -p "Are you really sure you want to remove $CURRENT_DIR/volumes/$CONTAINER_SIMPLE_NAME? [y/N] " option2
                case ${option2-} in
                    [yY][eE][sS]|[yY])
                        rm -rvf $CURRENT_DIR/volumes/$CONTAINER_SIMPLE_NAME
                    ;;
                    *)
                        echo "Nothing was done!"
                        exit 0
                    ;;
                esac;
                ;;
            *)
                echo "Nothing was done!"
                exit 0
            ;;
        esac;
        exit 0
        ;;
create-folder-structure)
         folders=(${FOLDERS-})
         for folder in ${folders[@]}; do
             echo "processing folder: $folder"
             if [[ ! -x "$folder" ]]; then
                 mkdir -p "$folder"
             fi
             echo "change permissions: $folder"
             chown "${PUID=`id -u`}":"${PGID=`id -g`}" "$folder"
             chmod 770 "$folder"
         done;
         files=(${FILES-})
         for file in ${files[@]}; do
             echo "processing file: $file"
             if [[ ! -e "$file" ]]; then
                 touch "$file"
             fi
             echo "change permissions: $file"
             chown "${PUID=`id -u`}":"${PGID=`id -g`}" "$file"
             chmod 660 "$file"
         done;
         exit 0
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
inspect)
        echo -e "---------------------------------\n"
        echo -e "     Inspecting: $CONTAINER\n  "
        echo -e "---------------------------------\n"
        docker inspect $CONTAINER
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
