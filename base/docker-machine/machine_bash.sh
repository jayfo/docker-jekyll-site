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

docker () {
  MSYS_NO_PATHCONV=1 "${DOCKER_TOOLBOX_INSTALL_PATH}/docker.exe" "$@"
}
export -f docker

exec "$BASH" -c "$*"
