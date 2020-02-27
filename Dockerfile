FROM ubuntu:bionic

ENV DEBIAN_FRONTEND noninteractive

# boost variables
ENV BOOST_VERSION=1.72.0
ENV BOOST_VERSION_=1_72_0
ENV BOOST_ROOT=/usr/include/boost


# framsticksSDK and pythonidas variables
ENV FRAMSTICKS_SDK_SVN="https://www.framsticks.com/svn/framsticks/"
ENV PYTHONIDAS_GIT="https://bitbucket.org/mack0/pythonidas.git"
ENV FRAMSTICKS_SDK_ROOT=/framsticks
ENV PYTHONIDAS_SDK_ROOT=${FRAMSTICKS_SDK_ROOT}/cpp/pythonidas

# other variables
ENV PYTHON_VERSION=3.7

RUN apt-get -qq update && apt-get install -q -y software-properties-common
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y
RUN apt-get -qq update && apt-get install -qy g++ gcc git wget python${PYTHON_VERSION} python3-pip libpython${PYTHON_VERSION}-dev
# install subversion to clone framsticksSDK
RUN apt-get -y install subversion

# download BOOST library
RUN wget --max-redirect 3 https://dl.bintray.com/boostorg/release/${BOOST_VERSION}/source/boost_${BOOST_VERSION_}.tar.gz
RUN mkdir -p ${BOOST_ROOT} && tar zxf boost_${BOOST_VERSION_}.tar.gz -C ${BOOST_ROOT} --strip-components=1
RUN rm boost_${BOOST_VERSION_}.tar.gz
RUN echo "Boost downloaded and extracted to: ${BOOST_ROOT}"

# build boost.python
WORKDIR ${BOOST_ROOT}
RUN ./bootstrap.sh --with-python=/usr/bin/python3.7
RUN ./b2 --with-python

# download framsticks SDK
WORKDIR ${FRAMSTICKS_SDK_ROOT}
# workaround for the error:
#svn: E170013: Unable to connect to a repository at URL 'https://www.framsticks.com/svn/framsticks'
#svn: E230001: Server SSL certificate verification failed: certificate issued for a different hostname, issuer is not trusted
COPY ./svn.ssl.server/5ba3fcf72231bb7c699abee57eac3bab /root/.subversion/auth/svn.ssl.server/
RUN svn co ${FRAMSTICKS_SDK_SVN} --non-interactive --quiet .

RUN apt-get install -y cmake make
WORKDIR "${FRAMSTICKS_SDK_ROOT}/cpp"
RUN make -f frams/Makefile-SDK lib

# download pythonidas to appropritate location
WORKDIR ${PYTHONIDAS_SDK_ROOT}
RUN git clone ${PYTHONIDAS_GIT} .

ENTRYPOINT /bin/bash