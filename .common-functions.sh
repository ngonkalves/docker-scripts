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
        $OPTION_ARG \
        $WORK_DIR_ARG \
        $USER_ARG \
        $NET_JOIN_ARG \
        $ENV_ARG \
        $LABEL_ARG \
        $VOLUME_ARG \
        $PORT_ARG \
        $SECRET_ARG \
        $DNS_ARG \
        $IMAGE \
        $COMMAND_ARG
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
                network=$(echo $network | envsubst "$DEFINED_VARS")
                create_network_if_not_exists "$network"
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
                network=$(echo $network | envsubst "$DEFINED_VARS")
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
    elif [[ $filename =~ ^user\. ]]; then
        result=$(read_file "--user" $conf_path)
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

function read_conf_variables() {
    local file_path="$1"
    local append_vars="${@:2}"
    if [ -e "$file_path" ]; then
        readarray -t lines < "$file_path";
        for line in "${lines[@]}"; do
            [[ "$line" =~ ^([[:space:]]*|[[:space:]]*#.*)$ ]] && continue;
            local varname="${line%%=*}"
            if [ -n "${varname}" ]; then
                printf '${%s} ' "${varname}";
            fi
        done;
    fi
    for var in "${@:2}"; do
        if [ -n "${var}" ]; then
            printf '${%s} ' "${var}";
        fi
    done;
}

function remove-empty-config() {
    local path="$1"
    for file in $(find $path -maxdepth 1 -type f -name '*.conf'); do
        if [ $(grep -v -E '^([ ]*#|[ ]*$)' $file | wc -l) = "0" ]; then
            \rm -i $file
        fi
    done;
}

# creates the option to pass a file to docker
function get_conf_file_arg() {
    local prefix="$1"
    local conf_path="$2"
    local override_conf_path="$3"
    #local conf_path_gen="${conf_path%/*}/.${conf_path##*/}.generated"
    #local override_conf_path_gen="${override_conf_path%/*}/.${override_conf_path##*/}.generated"
    local conf_path_gen="${conf_path}.generated"
    local override_conf_path_gen="${override_conf_path}.generated"
    local result=""
    # do variable substitution on file
    [ -e $conf_path ] && \grep "\\$" $conf_path > /dev/null 2>&1 && envsubst "$DEFINED_VARS" < $conf_path > $conf_path_gen && conf_path=$conf_path_gen

    [ -e $override_conf_path ] && \grep "\\$" $override_conf_path > /dev/null 2>&1 && envsubst "$DEFINED_VARS" < $override_conf_path > $override_conf_path_gen && override_conf_path=$override_conf_path_gen

    # defining result depending on existing files
    [ -e $conf_path ] && result="$prefix $conf_path"

    [ -e $override_conf_path ] && result="$result $prefix $override_conf_path"

    echo "$result"
}

# load params
function load_defined_vars() {
    # define which variable will be available for replace with envsubst command
    DEFINED_VARS="\${PARENTPATH} \${CONTAINER} \${CONTAINER_SIMPLE_NAME} \${CONTAINER_PREFIX} \${CURRENT_DIR} \${CURRENT_DIR_NAME} \${USER_ID} \${GROUP_ID}"
    [ -e $VAR_FILE ] && DEFINED_VARS="$DEFINED_VARS $(read_conf_variables $VAR_FILE)"
    [ -e $VAR_OVERRIDE_FILE ] && DEFINED_VARS="$DEFINED_VARS $(read_conf_variables $VAR_OVERRIDE_FILE)"
    # remove duplicates
    DEFINED_VARS=$(echo "$DEFINED_VARS" | tr ' ' '\n' | sort | uniq | tr '\n' ' ')
    echo "DEFINED_VARS: $DEFINED_VARS"
}

function load_option() {
    OPTION_ARG=$(read_conf $OPTION_FILE $OPTION_OVERRIDE_FILE)
    OPTION_ARG=$(echo $OPTION_ARG | envsubst "$DEFINED_VARS")
    echo "OPTION_ARG: $OPTION_ARG"
}

function load_workdir() {
    WORK_DIR_ARG=""
    if [ -n "${WORK_DIR-}" ]; then
        WORK_DIR_ARG="--workdir ${WORK_DIR}"
    fi
    echo "WORK_DIR_ARG: $WORK_DIR_ARG"
}

function load_user() {
    USER_ARG=$(read_conf $USER_FILE $USER_OVERRIDE_FILE)
    USER_ARG=$(echo $USER_ARG | envsubst "$DEFINED_VARS")
    echo "USER_ARG: $USER_ARG"
}

function load_port() {
    PORT_ARG=$(read_conf $PORT_FILE $PORT_OVERRIDE_FILE)
    PORT_ARG=$(echo $PORT_ARG | envsubst "$DEFINED_VARS")
    echo "PORT_ARG: $PORT_ARG"
}

function load_net_create() {
    NET_CREATE_ARG=$(read_conf $NET_CREATE_FILE $NET_CREATE_OVERRIDE_FILE)
    NET_CREATE_ARG=$(echo $NET_CREATE_ARG | envsubst "$DEFINED_VARS")
    echo "NET_CREATE_ARG: $NET_CREATE_ARG"
}

function load_net_join() {
    NET_JOIN_ARG=$(read_conf $NET_JOIN_FILE $NET_JOIN_OVERRIDE_FILE)
    NET_JOIN_ARG=$(echo $NET_JOIN_ARG | envsubst "$DEFINED_VARS")
    echo "NET_JOIN_ARG: $NET_JOIN_ARG"
}

function load_link() {
    LINK_ARG=$(read_conf $LINK_FILE $LINK_OVERRIDE_FILE)
    LINK_ARG=$(echo $LINK_ARG | envsubst "$DEFINED_VARS")
    echo "LINK_ARG: $LINK_ARG"
}

function load_volume() {
    VOLUME_ARG=$(read_conf $VOLUME_FILE $VOLUME_OVERRIDE_FILE)
    VOLUME_ARG=$(echo $VOLUME_ARG | envsubst "$DEFINED_VARS")
    echo "VOLUME_ARG: $VOLUME_ARG"
}

function load_command() {
    COMMAND_ARG=$(read_conf $COMMAND_FILE $COMMAND_OVERRIDE_FILE)
    COMMAND_ARG=$(echo $COMMAND_ARG | envsubst "$DEFINED_VARS")
    echo "COMMAND_ARG: $COMMAND_ARG"
}

function load_dns() {
    DNS_ARG=$(read_conf $DNS_FILE $DNS_OVERRIDE_FILE)
    DNS_ARG=$(echo $DNS_ARG | envsubst "$DEFINED_VARS")
    echo "DNS_ARG: $DNS_ARG"
}

function load_env() {
    ENV_ARG=$(get_conf_file_arg "--env-file" "$ENV_FILE" "$ENV_OVERRIDE_FILE")
    echo "ENV_ARG: $ENV_ARG"
}

function load_label() {
    LABEL_ARG=$(get_conf_file_arg "--label-file" "$LABEL_FILE" "$LABEL_OVERRIDE_FILE")
    echo "LABEL_ARG: $LABEL_ARG"
}

function load_secret() {
    SECRET_ARG=""
    for file in $(find $CURRENT_DIR -maxdepth 1 -type f -name 'secret_*'); do
        secret_name=${file##*/}
        secret_name=${secret_name/secret_/}
        SECRET_ARG="$SECRET_ARG--volume ${file}:/run/secrets/$secret_name "
    done
    echo "SECRET_ARG: $SECRET_ARG"
}

function load_all() {
    load_defined_vars
    load_option
    load_workdir
    load_user
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

