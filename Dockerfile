FROM ubuntu:bionic

ENV DEBIAN_FRONTEND noninteractive

# boost variables
ENV BOOST_VERSION=1.72.0
ENV BOOST_VERSION_=1_72_0
ENV BOOST_ROOT=/usr/include/boost


# framsticksSDK and pythonidas variables
ENV FRAMSTICKS_SDK_ROOT=/framsticks

# other variables
ENV PYTHON_VERSION=3.7

RUN apt-get -qq update && apt-get install -q -y software-properties-common
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y
RUN apt-get -qq update && apt-get install -qy g++ \
    gcc git wget subversion \
    python${PYTHON_VERSION} python3-pip libpython${PYTHON_VERSION}-dev \
    cmake make

# download BOOST library
RUN wget --max-redirect 3 https://dl.bintray.com/boostorg/release/${BOOST_VERSION}/source/boost_${BOOST_VERSION_}.tar.gz
RUN mkdir -p ${BOOST_ROOT} && tar zxf boost_${BOOST_VERSION_}.tar.gz -C ${BOOST_ROOT} --strip-components=1
RUN rm boost_${BOOST_VERSION_}.tar.gz
RUN echo "Boost downloaded and extracted to: ${BOOST_ROOT}"

# build boost.python
WORKDIR ${BOOST_ROOT}
RUN ./bootstrap.sh --with-python=/usr/bin/python3.7
RUN ./b2 --with-python

# set current dir to FRAMSTICKS_SDK_ROOT framsticks SDK
# container should be launched with framsticksSDK (and pythonidas in it)
# mounted from host
WORKDIR ${FRAMSTICKS_SDK_ROOT}

ENTRYPOINT /bin/bash