CURRENT_DIR=$SCRIPTPATH

CURRENT_FILE=$SCRIPT

FILE_NO_EXTENSION="${CURRENT_FILE%%.*}"

source $CURRENT_DIR/.common-functions.sh

FILE_VARS="${FILE_NO_EXTENSION}.conf"
OVERRIDE_FILE_VARS="${FILE_NO_EXTENSION}.override.conf"

ENV_FILE="${FILE_NO_EXTENSION}.env.conf"
ENV_OVERRIDE_FILE="${FILE_NO_EXTENSION}.env.override.conf"

LABEL_FILE="${FILE_NO_EXTENSION}.label.conf"
LABEL_OVERRIDE_FILE="${FILE_NO_EXTENSION}.label.override.conf"

# load file with variables if exists
[[ -e $FILE_VARS ]] && source $FILE_VARS

[[ ! -e $FILE_VARS ]] && echo -e "Variables file doesn't exist: $FILE_VARS" && exit 1

[[ -e $OVERRIDE_FILE_VARS ]] && echo "Loading override file: $OVERRIDE_FILE_VARS" && source $OVERRIDE_FILE_VARS


# add docker container prefix
CONTAINER_PREFIX="ds"
CONTAINER_SIMPLE_NAME="$CONTAINER"
CONTAINER="${CONTAINER_PREFIX}-${CONTAINER}"
CONTAINER_NAME="${CONTAINER_PREFIX}-${CONTAINER}"


ENVS_STR=""
[[ -e $ENV_FILE ]] && echo "Loading: $ENV_FILE" && ENVS_STR="--env-file $ENV_FILE" && source $ENV_FILE
[[ -e $ENV_OVERRIDE_FILE ]] && echo "Loading: $ENV_OVERRIDE_FILE" && ENVS_STR=" ${ENVS_STR} --env-file $ENV_OVERRIDE_FILE" && source $ENV_OVERRIDE_FILE

LABELS_STR=""
[[ -e $LABEL_FILE ]] && echo "Loading: $LABEL_FILE" && LABELS_STR="--label-file $LABEL_FILE"
[[ -e $LABEL_OVERRIDE_FILE ]] && echo "Loading: $LABEL_OVERRIDE_FILE" && LABELS_STR="${LABELS_STR} --label-file $LABEL_OVERRIDE_FILE"
