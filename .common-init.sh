# enable export of any declared variables from now on
set -a # disable auto exporting variables #set +a
# to abort the script if any command returns a failure (nonzero) status
set -e
# script will exit with error when variable not set
set -u # or set -o nounset

CURRENT_DIR=$(realpath $0 | xargs dirname)

PARENTPATH=`dirname $CURRENT_DIR`

CURRENT_DIR_NAME=`basename $CURRENT_DIR`

# add docker container prefix
CONTAINER_PREFIX="ds"

CONTAINER="${CONTAINER_PREFIX}-${CURRENT_DIR_NAME}"

source $PARENTPATH/.common-functions.sh

# define file paths
VAR_FILE=$CURRENT_DIR/$(create_conf_filename var)
VAR_OVERRIDE_FILE=$CURRENT_DIR/$(create_conf_override_filename var)

# load file with variables if exist
[ -e $VAR_FILE ] && source $VAR_FILE
[ -e $VAR_OVERRIDE_FILE ] && source $VAR_OVERRIDE_FILE

[ ! -e $VAR_FILE ] && [ ! -e $VAR_OVERRIDE_FILE ] && echo -e "Var files don't exist (quitting): ${VAR_FILE##*/} | ${VAR_OVERRIDE_FILE##*/}" && exit 1

ENV_FILE=$CURRENT_DIR/$(create_conf_filename env)
ENV_OVERRIDE_FILE=$CURRENT_DIR/$(create_conf_override_filename env)

LABEL_FILE=$CURRENT_DIR/$(create_conf_filename label)
LABEL_OVERRIDE_FILE=$CURRENT_DIR/$(create_conf_override_filename label)

OPTION_FILE=$CURRENT_DIR/$(create_conf_filename option)
OPTION_OVERRIDE_FILE=$CURRENT_DIR/$(create_conf_override_filename option)

PORT_FILE=$CURRENT_DIR/$(create_conf_filename port)
PORT_OVERRIDE_FILE=$CURRENT_DIR/$(create_conf_override_filename port)

NET_CREATE_FILE=$CURRENT_DIR/$(create_conf_filename network.create)
NET_CREATE_OVERRIDE_FILE=$CURRENT_DIR/$(create_conf_override_filename network.create)

NET_JOIN_FILE=$CURRENT_DIR/$(create_conf_filename network.join)
NET_JOIN_OVERRIDE_FILE=$CURRENT_DIR/$(create_conf_override_filename network.join)

LINK_FILE=$CURRENT_DIR/$(create_conf_filename link)
LINK_OVERRIDE_FILE=$CURRENT_DIR/$(create_conf_override_filename link)

VOLUME_FILE=$CURRENT_DIR/$(create_conf_filename volume)
VOLUME_OVERRIDE_FILE=$CURRENT_DIR/$(create_conf_override_filename volume)

COMMAND_FILE=$CURRENT_DIR/$(create_conf_filename command)
COMMAND_OVERRIDE_FILE=$CURRENT_DIR/$(create_conf_override_filename command)

DNS_FILE=$CURRENT_DIR/$(create_conf_filename dns)
DNS_OVERRIDE_FILE=$CURRENT_DIR/$(create_conf_override_filename dns)
