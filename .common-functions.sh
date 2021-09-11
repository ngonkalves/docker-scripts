function docker_create() {
    local container="$1"
    echo -e "---------------------------------\n"
    echo -e "Creating container $container\n"
    echo -e "---------------------------------\n"

    # call pre function
    [ $(type -t pre_docker_create)"" = "function" ] && pre_docker_create $container

    load_all

    docker create \
        --name="$container" \
        $OPTION_STR \
        $NET_JOIN_STR \
        $ENV_STR \
        $LABEL_STR \
        $VOLUME_STR \
        $PORT_STR \
        $SECRET_STR \
        $DNS_STR \
        $IMAGE \
        $COMMAND_STR
}

function docker_start() {
    local container="$1"
    echo -e "---------------------------------\n"
    echo -e "Starting container $container\n"
    echo -e "---------------------------------\n"
    docker_create_network
    docker start $container
    printf '\nStarting up %s container\n\n' "$container"

    # call post  function
    [ $(type -t post_docker_start)"" = "function" ] && post_docker_start $container

    docker_logf $container
}

function docker_stop() {
    local container="$1"
    echo -e "---------------------------------\n"
    echo -e "Stopping container $container\n"
    echo -e "---------------------------------\n"
    docker stop $container &> /dev/null || echo "Container doesn't exist"
}

function docker_restart() {
    local container="$1"
    echo -e "---------------------------------\n"
    echo -e "Restarting container $container\n"
    echo -e "---------------------------------\n"
    docker restart $container
}

function docker_remove() {
    local container="$1"
    echo -e "---------------------------------\n"
    echo -e "Remove container $container\n"
    echo -e "---------------------------------\n"
    docker_stop $container
    docker container rm $container || true
}

function docker_pull() {
    local image="$1"
    echo -e "---------------------------------\n"
    echo -e "Pulling container image $IMAGE\n"
    echo -e "---------------------------------\n"
    docker pull $IMAGE
}

function docker_recreate() {
    local container="$1"
    echo -e "---------------------------------\n"
    echo -e "Rebuilding container $container\n"
    echo -e "---------------------------------\n"
    docker_stop $container
    docker_remove $container
    docker_pull $container
    docker_create $container
    echo -e "---------------------------------\n"
    echo -e "---------------------------------\n"
    docker container ls -a -f name=$container
    echo -e "---------------------------------\n"
    echo -e "---------------------------------\n"
    docker_start $container
}

function docker_cp() {
    local container="$1"
    echo -e "---------------------------------\n"
    echo -e "Copying from container $container\n"
    echo -e "---------------------------------\n"
    [ -z ${2+x} ] && echo "source path not defined" && exit 1
    [ -z ${3+x} ] && echo "target path not defined" && exit 1
    docker cp "$container":"$2" "$3"
}

function docker_create_network() {
    local filename=""
    if [ -e $NET_CREATE_OVERRIDE_FILE ]; then
        filename="$NET_CREATE_OVERRIDE_FILE"
    elif [ -e $NET_CREATE_FILE ]; then
        filename="$NET_CREATE_FILE"
    fi
    if [ -n "$filename"  ]; then
        readarray -t lines < "$filename"

        for line in "${lines[@]}"; do
            # Skip lines starting with sharp
            # or lines containing only space or empty lines
            [[ "$line" =~ ^([[:space:]]*|[[:space:]]*#.*)$ ]] && continue
            local network="${line##* }"
            if [[ ! ${network-} == "" ]]; then
                create_network_if_not_exists "$line"
            fi
        done
    fi
}

function docker_remove_network() {
    local filename=""
    if [ -e $NET_CREATE_OVERRIDE_FILE ]; then
        filename="$NET_CREATE_OVERRIDE_FILE"
    elif [ -e $NET_CREATE_FILE ]; then
        filename="$NET_CREATE_FILE"
    fi
    if [ -n "$filename"  ]; then
        readarray -t lines < "$filename"

        for line in "${lines[@]}"; do
            # Skip lines starting with sharp
            # or lines containing only space or empty lines
            [[ "$line" =~ ^([[:space:]]*|[[:space:]]*#.*)$ ]] && continue
            local network="${line##* }"
            if [[ ! ${network-} == "" ]]; then
                remove_network_if_exists "$network"
            fi
        done
    fi
}

function docker_exec_terminal() {
    local container="$1"
    echo -e "---------------------------------\n"
    echo -e "Accessing terminal $container\n"
    echo -e "---------------------------------\n"
    docker exec -it $container /bin/sh
}

function docker_exec_uname() {
    local container="$1"
    echo -e "---------------------------------\n"
    echo -e "Execute command for container $container\n"
    echo -e "---------------------------------\n"
    docker exec -it $container uname -a
}

function docker_log() {
    local container="$1"
    echo -e "---------------------------------\n"
    echo -e "     Accessing logs: $container\n  "
    echo -e "---------------------------------\n"
    docker logs $container
}

function docker_logf() {
    local container="$1"
    echo -e "---------------------------------\n"
    echo -e "     Accessing logs: $container\n  "
    echo -e "---------------------------------\n"
    docker logs -f $container
}

function docker_inspect() {
    local container="$1"
    echo -e "---------------------------------\n"
    echo -e "     Inspecting: $container\n  "
    echo -e "---------------------------------\n"
    docker inspect $container
}

function docker_ps() {
    local container="$1"
    echo -e "---------------------------------\n"
    echo -e "     Status: $container\n  "
    echo -e "---------------------------------\n"
    docker ps -a -f name=$container
}

function container_exists() {
     local container="$1"
     local num_containers=$(docker container ls -a -q -f name=$container | wc -l)
     [[ $num_containers == "1" ]] && echo "true" || echo "false"
}

function container_running() {
    local container="$1"
    local num_containers=$(docker container ps -q -f name=$container | wc -l)
    [[ $num_containers == "1" ]] && echo "true" || echo "false"
}

function network_exists() {
    local network="$1"
    local num_networks=$(docker network ls -q -f name=$network | wc -l)
    [[ $num_networks == "1" ]] && echo "true" || echo "false"
}

function create_network() {
    local num_created_networks=$(docker network create $@ | wc -l)
    [[ $num_created_networks == "1" ]] && echo "true" || echo "false"
}

function remove_network() {
    local network="$1"
    local num_removed_networks=$(docker network rm $network | wc -l)
    [[ $num_removed_networks == "1" ]] && echo "true" || echo "false"
}

function create_network_if_not_exists() {
    local network="${1##* }"
    local exists=$(network_exists $network)
    if [[ $exists == "true" ]]; then
        echo "Network $network already exist, skipping..."
    else
        echo -e "---------------------------------\n"
        echo -e "Creating network $network\n"
        echo -e "---------------------------------\n"
        local created=$(create_network $@)
        if [[ $created == "true" ]]; then
            echo "Network $network created successfully"
        else
            echo "Network $network creation failed"
        fi
    fi
}

function remove_network_if_exists() {
    local network="${1}"
    local exists=$(network_exists $network)
    if [[ $exists == "true" ]]; then
        echo -e "---------------------------------\n"
        echo -e "Remove network $network\n"
        echo -e "---------------------------------\n"
        local removed=$(remove_network $@)
        if [[ $removed == "true" ]]; then
            echo "Network $network removed successfully"
        else
            echo "Network $network removal failed"
        fi
    else
        echo "Network $network doesn't exist, skipping..."
    fi
}

function remove_config() {
    local container="$1"
    read -r -p "Do you really want to remove all configuration files? [y/N] " option
    case ${option-} in
        [yY][eE][sS]|[yY])
            docker_stop $container || true
            read -r -p "Are you really sure you want to remove $CURRENT_DIR/volumes/$container? [y/N] " option2
            case ${option2-} in
                [yY][eE][sS]|[yY])
                    rm -rvf $CURRENT_DIR/volumes/$container
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
}


function create_folder_structure() {
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
}


function create_conf_filename() {
    local filename="$1"
    echo "${filename}.conf"
}

function create_conf_override_filename() {
    local filename="$1"
    if [[ "$filename" =~ \.conf$ ]]; then
        echo "${filename/.conf/.override.conf}"
    else
        echo "${filename}.override.conf"
    fi
}

function read_conf() {
    local conf_path="$1"
    local override_conf_path="$2"
    local result=""
    if [ -e $override_conf_path ]; then
        result=$(read_conf_file $override_conf_path)
    elif [ -e $conf_path ]; then
        result=$(read_conf_file $conf_path)
    fi
    echo "$result"
}

function read_conf_file() {
    local result=""
    local conf_path="$1"
    local filename="${conf_path##*/}"
    # test filename only
    if [[ $filename =~ ^port\. ]]; then
        result=$(read_file "--publish" $conf_path)
    elif [[ $filename =~ ^network\.join\. ]]; then
        result=$(read_file "--network" $conf_path)
    elif [[ $filename =~ ^volume\. ]]; then
        result=$(read_file "--volume" $conf_path)
    elif [[ $filename =~ ^link\. ]]; then
        result=$(read_file "--link" $conf_path)
    elif [[ $filename =~ ^dns\. ]]; then
        result=$(read_file "--dns" $conf_path)
    else
        result=$(read_file "" $conf_path)
    fi
    echo "$result"
}

function read_file() {
    local result=""
    local line_prefix="$1"
    local file_path="$2"
    if [[ -e $file_path ]]; then
        readarray -t lines < "$file_path"

        for line in "${lines[@]}"; do
            # Skip lines starting with sharp
            # or lines containing only space or empty lines
            [[ "$line" =~ ^([[:space:]]*|[[:space:]]*#.*)$ ]] && continue
            # test if variable is empty
            if [ -z "$line_prefix" ]; then
                result="${result}$line "
            else
                result="${result}$line_prefix $line "
            fi
        done
    fi
    echo "$result"
}

# creates the option to pass a file to docker
function get_conf_file_arg() {
    local prefix="$1"
    local conf_path="$2"
    local override_conf_path="$3"
    local conf_path_gen="$conf_path.generated"
    local override_conf_path_gen="$override_conf_path.generated"
    local result=""
    # do variable substitution on file
    [ -e $conf_path ] && \grep "\\$" $conf_path > /dev/null 2>&1 && envsubst < $conf_path > $conf_path_gen && conf_path=$conf_path_gen

    [ -e $override_conf_path ] && \grep "\\$" $override_conf_path > /dev/null 2>&1 && envsubst < $override_conf_path > $override_conf_path_gen && override_conf_path=$override_conf_path_gen

    # defining result depending on existing files
    [ -e $conf_path ] && result="$prefix $conf_path"

    [ -e $override_conf_path ] && result="$result $prefix $override_conf_path"

    echo "$result"
}

# load params
function load_option() {
    OPTION_STR=$(read_conf $OPTION_FILE $OPTION_OVERRIDE_FILE)
    OPTION_STR=$(echo $OPTION_STR | envsubst)
    echo "OPTION_STR: $OPTION_STR"
}

function load_port() {
    PORT_STR=$(read_conf $PORT_FILE $PORT_OVERRIDE_FILE)
    PORT_STR=$(echo $PORT_STR | envsubst)
    echo "PORT_STR: $PORT_STR"
}

function load_net_create() {
    NET_CREATE_STR=$(read_conf $NET_CREATE_FILE $NET_CREATE_OVERRIDE_FILE)
    NET_CREATE_STR=$(echo $NET_CREATE_STR | envsubst)
    echo "NET_CREATE_STR: $NET_CREATE_STR"
}

function load_net_join() {
    NET_JOIN_STR=$(read_conf $NET_JOIN_FILE $NET_JOIN_OVERRIDE_FILE)
    NET_JOIN_STR=$(echo $NET_JOIN_STR | envsubst)
    echo "NET_JOIN_STR: $NET_JOIN_STR"
}

function load_link() {
    LINK_STR=$(read_conf $LINK_FILE $LINK_OVERRIDE_FILE)
    LINK_STR=$(echo $LINK_STR | envsubst)
    echo "LINK_STR: $LINK_STR"
}

function load_volume() {
    VOLUME_STR=$(read_conf $VOLUME_FILE $VOLUME_OVERRIDE_FILE)
    VOLUME_STR=$(echo $VOLUME_STR | envsubst)
    echo "VOLUME_STR: $VOLUME_STR"
}

function load_command() {
    COMMAND_STR=$(read_conf $COMMAND_FILE $COMMAND_OVERRIDE_FILE)
    COMMAND_STR=$(echo $COMMAND_STR | envsubst)
    echo "COMMAND_STR: $COMMAND_STR"
}

function load_dns() {
    DNS_STR=$(read_conf $DNS_FILE $DNS_OVERRIDE_FILE)
    DNS_STR=$(echo $DNS_STR | envsubst)
    echo "DNS_STR: $DNS_STR"
}

function load_env() {
    ENV_STR=$(get_conf_file_arg "--env-file" "$ENV_FILE" "$ENV_OVERRIDE_FILE")
    echo "ENV_STR: $ENV_STR"
}

function load_label() {
    LABEL_STR=$(get_conf_file_arg "--label-file" "$LABEL_FILE" "$LABEL_OVERRIDE_FILE")
    echo "LABEL_STR: $LABEL_STR"
}

function load_secret() {
    SECRET_STR=""
    for file in $(find $CURRENT_DIR -maxdepth 1 -type f -name 'secret_*'); do
        secret_name=${file##*/}
        secret_name=${secret_name/secret_/}
        SECRET_STR="$SECRET_STR--volume ${file}:/run/secrets/$secret_name "
    done
    echo "SECRET_STR: $SECRET_STR"
}

function load_all() {
    load_option
    load_port
    load_net_create
    load_net_join
    load_link
    load_volume
    load_command
    load_dns
    load_env
    load_label
    load_secret
}

