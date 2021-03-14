CURRENT_DIR=$SCRIPTPATH

CURRENT_FILE=$SCRIPT

FILE_NO_EXTENSION="${CURRENT_FILE%%.*}"

FILE_VARS="${FILE_NO_EXTENSION}.conf"

OVERRIDE_FILE_VARS="${FILE_NO_EXTENSION}.override.conf"

ENV_FILE="${FILE_NO_EXTENSION}.env.conf"

source $CURRENT_DIR/.common-functions.sh

# load file with variables if exists
[[ -e $FILE_VARS ]] && source $FILE_VARS

[[ ! -e $FILE_VARS ]] && echo -e "Variables file doesn't exist: $FILE_VARS" && exit 1

[[ -e $OVERRIDE_FILE_VARS ]] && echo "Loading override file: $OVERRIDE_FILE_VARS" && source $OVERRIDE_FILE_VARS

# add docker container prefix
CONTAINER_PREFIX="ds"
CONTAINER_SIMPLE_NAME="$CONTAINER"
CONTAINER="${CONTAINER_PREFIX}-${CONTAINER}"
CONTAINER_NAME="${CONTAINER_PREFIX}-${CONTAINER}"
ENVS_STR=$(load_environment_variables $ENV_FILE)
if [[ ! $ENVS_STR = "" ]]; then
    echo ":::::::::::::env variables::::::::::::::::"
    echo "$ENVS_STR"
    echo "::::::::::::::::::::::::::::::::::::::::::"
fi
