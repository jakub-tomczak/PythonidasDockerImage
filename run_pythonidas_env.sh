#!/bin/bash

# this script assumes that
# Framsticks SDK is located in FRAMSTICKS_SDK_ROOT location
FRAMSTICKS_SDK_ROOT=`pwd`/framsticks
if [ ! -d ${FRAMSTICKS_SDK_ROOT} ]; then
    echo "Framsticks SDK could not be found in '${FRAMSTICKS_SDK_ROOT}'."
    exit 1
fi
# and should be mounted to FRAMSTICKS_SDK_ROOT_DOCKER in container
FRAMSTICKS_SDK_ROOT_DOCKER=framsticks
# and pythonidas is located in PYTHONIDAS_SDK_ROOT
PYTHONIDAS_SDK_ROOT=${FRAMSTICKS_SDK_ROOT}/cpp/pythonidas
if [ ! -d ${PYTHONIDAS_SDK_ROOT} ]; then
    echo "Pythonidas could not be found in '${PYTHONIDAS_SDK_ROOT}'."
    exit 1
fi

# image name
IMAGE_NAME=jakubtomczak/pythonidas_dev_image
# container name
CONTAINER_NAME=pythonidas_dev

PYTHONIDAS_DOCKER_CONTAINER_ID=$(sudo docker ps -qf "name=${CONTAINER_NAME}")

if [ ! -z "$PYTHONIDAS_DOCKER_CONTAINER_ID" ];then
    # launch existing container
    echo "Opening existing and running container [$PYTHONIDAS_DOCKER_CONTAINER_ID]"
    sudo docker exec -it $PYTHONIDAS_DOCKER_CONTAINER_ID /bin/bash
    exit 0
fi

echo "Launching pythonidas dev image with name '${CONTAINER_NAME}'."
echo "Mounting directory '${FRAMSTICKS_SDK_ROOT}' to '${FRAMSTICKS_SDK_ROOT_DOCKER}'."
# # run image
docker run -it --rm --tty \
    -e DISPLAY=${DISPLAY} \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ${FRAMSTICKS_SDK_ROOT}:/${FRAMSTICKS_SDK_ROOT_DOCKER} \
    --name ${CONTAINER_NAME} \
    ${IMAGE_NAME}
