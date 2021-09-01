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
    if [[ $exists == "true" ]]; then
        echo "Network $network already exist, skipping..."
    else
        echo "Network $network doesn't exist, creating..."
        local created=$(create_network $network)
        if [[ $created == "true" ]]; then
            echo "Network $network created successfully"
        else
            echo "Network $network creation failed"
        fi
    fi
}
