#!/bin/bash

################################################################################
# Based on start.sh from C:\Program Files\Docker Toolbox
################################################################################

trap '[ "$?" -eq 0 ] || read -p "Error in step ´$STEP´. Press any key."' EXIT

################################################################################
# Confirm our Docker Machine and VirtualBox dependencies.
################################################################################

VM="${DOCKER_MACHINE_NAME-default}"
DOCKER_MACHINE="${DOCKER_TOOLBOX_INSTALL_PATH}/docker-machine.exe"

################################################################################
# Configure the environment for our specific machine.
################################################################################

STEP="Setting env"
eval "$("${DOCKER_MACHINE}" env --shell=bash ${VM})"

################################################################################
# Run our command.
################################################################################

STEP="Finalize"
clear

BLUE='\033[1;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}docker${NC} is configured to use the ${GREEN}${VM}${NC} machine with IP ${GREEN}$("${DOCKER_MACHINE}" ip ${VM})${NC}"
echo "For help getting started, check out the docs at https://docs.docker.com"
echo
cd

docker () {
  MSYS_NO_PATHCONV=1 "${DOCKER_TOOLBOX_INSTALL_PATH}/docker.exe" "$@"
}
export -f docker

exec "$BASH" --login -i
