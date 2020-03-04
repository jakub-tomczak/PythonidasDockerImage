# PythonidasDockerImage

## Launch container using script

This repository helps with setting up development environment for Pythonidas project.
To launch docker container with the development environment type:
```
./init_framsticks.sh # if framsticks SDK and pythonidas are not initialized yet
sudo ./run_pythonidas_env.sh # to run container with dev environment
```

which will initialize `framsticksSDK`, `pythonidas` and will mount `framsticks` directory and add required parameters to `docker run` command.
It is not required to have FramsticksSDK nor Pythonidas before launching container. `init_framsticks.sh` checks whether FramsticksSDK is located in the `framsticks` directory. If not found then, using subversion, [FramsticksSDK]('https://www.framsticks.com/svn/framsticks/') is being cloned to the `framsticks` directory. Then,  [Pythonias repository]('https://bitbucket.org/mack0/pythonidas/src/master/') is being cloned. If both repositories exist then, by using `run_pythonidas_env.sh`, docker image is being run. If the image has not been built from `Dockerfile` locally then docker tries to pull it from [DockerHub]('https://hub.docker.com/r/jakubtomczak/pythonidas_dev_image').

If pythonidas docker image has been already launched and there exists a **running** container with `pythonidas_dev` name then docker runs it and doesn't run another instance of the pythonidas docker image.

### Building Framsticks SDK and pythonidas inside container.

Container should start in `/framsticks` directory. Enter `/framsticks/cpp` directory and build `framsticksSDK` by typing command (may change in the newer versions of `framsticksSDK`):
```
make -f frams/Makefile-SDK lib
```
then enter `/framsticks/cpp/pythonidas` directory and follow build instructions from `README.md` to build `pythonidas`.

## Launch container manually

Of course container for `pythonidas` development may be created using just the `docker run` command:
```
docker run -it --rm --tty \
    -e DISPLAY=${DISPLAY} \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ${FRAMSTICKS_SDK_ROOT}:/${FRAMSTICKS_SDK_ROOT_DOCKER} \
    --name ${CONTAINER_NAME} \
    ${IMAGE_NAME}
```

where $FRAMSTICKS_SDK_ROOT indicates directory with `framsticksSDK` repository (that contains `pythonidas` inside `cpp` directory), $CONTAINER_NAME is the name that will be assigned to this newly created container and $IMAGE_NAME is the name of the image. If the image was build locally then one should assign to IMAGE_NAME the name of the image defined when building the image (see [Building Dockerfile locally](#building-dockerfile-locally) section). Otherwise, $IMAGE_NAME should be defined as `jakubtomczak/pythonidas_dev_image` so the image will be pulled from [DockerHub]('https://hub.docker.com/r/jakubtomczak/pythonidas_dev_image').

## Building Dockerfile locally

To build `Dockerfile` type:
```
IMAGE_NAME=pythonidas_dev_image
docker build -t ${IMAGE_NAME} .
```

Then set `IMAGE_NAME` to value of $IMAGE_NAME variable in the `run_pythonidas_env.sh`.

## Dockerfile remarks

### boost-python

Dockerfile contains all required dependencies for building `FrmasticksSDK` and `pythonidas`. The main dependency is `boost-python` which
should be compiled against python3. The simplest way to get `boost-python` is to install `libboost-python-dev` which was compiled with older boost version (currently boost 1.65.1 but this is enough for the current `pythonidas`). In order to install `libboost-python-dev` this line (1) in the Dockerfile
```
RUN apt-get install -y libboost-python-dev
```
should be uncommented and those lines (2)
```
RUN wget --max-redirect 3 https://netix.dl.sourceforge.net/project/boost/boost/${BOOST_VERSION}/boost_${BOOST_VERSION_}.tar.gz
RUN mkdir -p ${BOOST_ROOT} && tar zxf boost_${BOOST_VERSION_}.tar.gz -C ${BOOST_ROOT} --strip-components=1
RUN rm boost_${BOOST_VERSION_}.tar.gz
RUN echo "Boost downloaded and extracted to: ${BOOST_ROOT}"

# build boost.python
WORKDIR ${BOOST_ROOT}
RUN ./bootstrap.sh --with-python=/usr/bin/python${PYTHON_VERSION}
RUN ./b2 --with-python3
```
should be commented.
The other way to get `boost-python` is to download boost sources and build `boost-python` as well as other `boost` components. To make it happen just comment line (1) and uncomment lines (2).

### python dependencies

In the process of building docker image from `Dockerfile` all python's requirements for [Pythonias]('https://bitbucket.org/mack0/pythonidas/src/master/') are being installed using `pip`. It is not required but it doesn't require the user to install them each time when entering newly created container. For this purpose, during build process of `Dockerfile`, [Pythonias]('https://bitbucket.org/mack0/pythonidas/src/master/') repository is being cloned and all python's packages from `requirements.txt` are being installed. If that file doesn't exist the building process continues without failing. If `requirements.txt` changes its location or name, the `pythonidas_python_dependencies_file` variable should be adjusted properly. After installing python's dependencies `pythonidas` repository is removed - it should be mounted when starting container along with `framsticksSDK`.

### default user

In order to simplify the process of displaying GUI, during build process of the `Dockerfile`, a user called `developer` is being created.
There are some hacks to run use Xserver when logged as root but creating additional user doesn't require those hacks to be applied.
Apart from that, when launching built image it is required to pass `DISPLAY` env variable as well as mount `/tmp/.X11-unix` directory.