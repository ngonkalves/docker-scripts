function load_environment_variables() {
    local envs_str=""
    local file_path="$1"
    if [[ -e $file_path ]]; then
        # declare associative array
        declare -A envs_array

        #echo "Loading env file: $file_path"

        readarray -t lines < "$file_path"

        for line in "${lines[@]}"; do
           key=${line%%=*}
           value=${line#*=}
           envs_array[$key]=$value  ## Or simply envs_array[${line%%=*}]=${line#*=}
        done
        # build environment string
        for key in "${!envs_array[@]}"; do
          # Skip lines starting with sharp
          # or lines containing only space or empty lines
          [[ "$key" =~ ^([[:space:]]*|[[:space:]]*#.*)$ ]] && continue
          #echo "key  : $key"
          #echo "value: ${envs_array[$key]}"
          envs_str=" ${envs_str} --env $key=${envs_array[$key]} "
        done
    fi
    echo $envs_str
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
