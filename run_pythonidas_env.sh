#!/bin/bash

FRAMSTICKS_SDK_SVN="https://www.framsticks.com/svn/framsticks/"
PYTHONIDAS_GIT="https://bitbucket.org/mack0/pythonidas.git"
FRAMSTICKS_SDK_ROOT=framsticks
PYTHONIDAS_SDK_ROOT=${FRAMSTICKS_SDK_ROOT}/cpp/pythonidas
# image name
IMAGE_NAME=pythonidas/develop
# container name
CONTAINER_NAME=pythonidas_dev


PYTHONIDAS_DOCKER_CONTAINER_ID=$(sudo docker ps -aqf "name=${CONTAINER_NAME}")

if [ ! -z "$PYTHONIDAS_DOCKER_CONTAINER_ID" ];then
    # launch existing container
    echo "Opening existing container [$PYTHONIDAS_DOCKER_CONTAINER_ID]"
    sudo docker exec -it $PYTHONIDAS_DOCKER_CONTAINER_ID /bin/bash
    exit 0
fi

clone_framsticksSDK () {
    echo "Cloning Framsticks SDK from ${FRAMSTICKS_SDK_SVN}"
    if [ ! $`svn co ${FRAMSTICKS_SDK_SVN} --quiet` ]; then
        echo "Failed to clone Framsticks SDK" && exit -1
    fi
    echo "Cloned Framsticks SDK"
}

clone_pythonidas () {
    echo "Cloning Pythonidas from ${PYTHONIDAS_GIT}"

    if [ ! -d ${FRAMSTICKS_SDK_ROOT} ]; then
        echo "Failed to clone pythonidas, FramsticksSDK not found in directory '${FRAMSTICKS_SDK_ROOT}'" \
            && exit -1
    fi

    # create directory for pythonidas in the framsticksSDK cpp directory
    if [ ! -d ${PYTHONIDAS_SDK_ROOT} ];then
        if [ ! $`mkdir ${PYTHONIDAS_SDK_ROOT}` ];then
            echo "Failed to create directory for Pythonidas" && exit -1
        fi
    fi

    pushd ${PYTHONIDAS_SDK_ROOT} &>/dev/null
    if [ ! $`git clone ${PYTHONIDAS_GIT} .` ];then
        echo "Failed to clone Framsticks SDK" && exit -1
    fi

    popd &>/dev/null
    echo "Cloned Framsticks SDK"
}

if [ ! -d ${FRAMSTICKS_SDK_ROOT} ];then
    echo "Directory with FramsticksSDK (${FRAMSTICKS_SDK_ROOT}) doesn't exist."
    echo "Trying to clone FramsticksSDK"

    clone_framsticksSDK
fi

if [ ! -d ${PYTHONIDAS_SDK_ROOT} ];then
    echo "Directory with Pythonidas (${PYTHONIDAS_SDK_ROOT}) doesn't exist."
    echo "Trying to clone Pythonidas"

    clone_pythonidas
fi

# check whether pythonidas repository is correct
pushd ${PYTHONIDAS_SDK_ROOT} &>/dev/null
if [ ! $`git status &>/dev/null` ];then
        echo "Failed to get pythonidas repository status." \
             && echo "Check files in ${PYTHONIDAS_SDK_ROOT}" && exit -1
fi
popd &>/dev/null

echo "Launching pythonidas dev image with name ${CONTAINER_NAME}."
# # run image
docker run -it --rm \
    -v ${FRAMSTICKS_SDK_ROOT}:/${FRAMSTICKS_SDK_ROOT} \
    --name ${CONTAINER_NAME} \
    ${IMAGE_NAME}
