# enable export of any declared variables from now on
set -a
# disable auto exporting variables
#set +a

CURRENT_DIR=$SCRIPTPATH

CURRENT_FILE=$SCRIPT

CURRENT_DIR_NAME=`basename $CURRENT_DIR`
#echo "CURRENT_DIR_NAME: $CURRENT_DIR_NAME"

# add docker container prefix
CONTAINER_PREFIX="ds"
CONTAINER="${CONTAINER_PREFIX}-${CURRENT_DIR_NAME}"

source $PARENTPATH/.common-functions.sh

VAR_FILE=$(create_conf_filename var)
VAR_OVERRIDE_FILE=$(create_conf_override_filename $VAR_FILE)

# load file with variables if exists
[ -e $VAR_FILE ] && source $VAR_FILE
[ -e $VAR_OVERRIDE_FILE ] && source $VAR_OVERRIDE_FILE

[ ! -e $VAR_FILE ] && [ ! -e $VAR_OVERRIDE_FILE ] && echo -e "Files don't exist (quitting): $VAR_FILE | $VAR_OVERRIDE_FILE" && exit 1

ENV_FILE=$(create_conf_filename env)
ENV_OVERRIDE_FILE=$(create_conf_override_filename $ENV_FILE)

LABEL_FILE=$(create_conf_filename label)
LABEL_OVERRIDE_FILE=$(create_conf_override_filename $LABEL_FILE)

OPTION_FILE=$(create_conf_filename option)
OPTION_OVERRIDE_FILE=$(create_conf_override_filename $OPTION_FILE)

PORT_FILE=$(create_conf_filename port)
PORT_OVERRIDE_FILE=$(create_conf_override_filename $PORT_FILE)

NETWORK_FILE=$(create_conf_filename network)
NETWORK_OVERRIDE_FILE=$(create_conf_override_filename $NETWORK_FILE)

LINK_FILE=$(create_conf_filename link)
LINK_OVERRIDE_FILE=$(create_conf_override_filename $LINK_FILE)

VOLUME_FILE=$(create_conf_filename volume)
VOLUME_OVERRIDE_FILE=$(create_conf_override_filename $VOLUME_FILE)

COMMAND_FILE=$(create_conf_filename command)
COMMAND_OVERRIDE_FILE=$(create_conf_override_filename $COMMAND_FILE)
