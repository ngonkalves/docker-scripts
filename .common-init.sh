CURRENT_DIR=$SCRIPTPATH

CURRENT_FILE=$SCRIPT

FILE_NO_EXTENSION="${CURRENT_FILE%%.*}"

FILE_VARS="${FILE_NO_EXTENSION}.conf"

OVERRIDE_FILE_VARS="${FILE_NO_EXTENSION}.override.conf"

# load file with variables if exists
[[ -e $FILE_VARS ]] && source $FILE_VARS

[[ ! -e $FILE_VARS ]] && echo -e "Variables file doesn't exist: $FILE_VARS" && exit 1

[[ -e $OVERRIDE_FILE_VARS ]] && echo "Loading override file: $OVERRIDE_FILE_VARS" && source $OVERRIDE_FILE_VARS

# add docker container prefix
CONTAINER_PREFIX="ds"
CONTAINER_SIMPLE_NAME="$CONTAINER"
CONTAINER="${CONTAINER_PREFIX}-${CONTAINER}"
CONTAINER_NAME="${CONTAINER_PREFIX}-${CONTAINER}"

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
    local network="$1"
    local num_created_networks=$(docker network create $network | wc -l)
    [[ $num_created_networks == "1" ]] && echo "true" || echo "false"
}

function remove_network() {
    local network="$1"
    local num_removed_networks=$(docker network rm $network | wc -l)
    [[ $num_removed_networks == "1" ]] && echo "true" || echo "false"
}

function create_network_if_not_exists() {
    local network="$1"
    local exists=$(network_exists $network)
    if [[ ! $exists == "true" ]]; then
        echo "Network $network doesn't exist, creating..."
        local created=$(create_network $network)
        if [[ $created == "true" ]]; then
            echo "Network $network created successfully"
        else
            echo "Network $network creation failed"
        fi
    fi
}
