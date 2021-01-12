CURRENT_DIR=$SCRIPTPATH

CURRENT_FILE=$SCRIPT

FILE_VARS="${CURRENT_FILE%%.*}.vars"

# load file with variables if exists
[[ -e $FILE_VARS ]] && source $FILE_VARS

[[ ! -e $FILE_VARS ]] && echo -e "Variables file doesn't exist: $FILE_VARS\n\nRename the $FILE_VARS.template to $FILE_VARS as starting point.\n" && exit 1

# add docker container prefix
CONTAINER_PREFIX="ds"
CONTAINER="${CONTAINER_PREFIX}-${CONTAINER}"
