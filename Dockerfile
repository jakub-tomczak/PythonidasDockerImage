FROM ubuntu:bionic

ENV DEBIAN_FRONTEND noninteractive

# boost variables
ENV BOOST_VERSION=1.72.0
# this should be the same version as in BOOST_VERSION
# Dockerfile doesn't allow to substitute . with _ in place as it is in bash
# so this explicit substitution below is required
ENV BOOST_VERSION_=1_72_0
ENV BOOST_ROOT=/usr/include/boost


# framsticksSDK and pythonidas variables
ENV PYTHONIDAS_GIT="https://bitbucket.org/mack0/pythonidas.git"
ENV FRAMSTICKS_SDK_ROOT=/framsticks

# other variables
ENV PYTHON_VERSION=3.6

RUN apt-get -qq update && apt-get install -q -y software-properties-common
RUN apt-get -qq update && apt-get install -qy g++ \
    gcc git wget subversion \
    python${PYTHON_VERSION} python3-pip libpython${PYTHON_VERSION}-dev \
    cmake make


# When it is required to use the newest version of the boost, comment lines below ### BOOST PRECOMPILED VERSION OF BOOST_PYTHON ###
# and uncomment section ### BOOST DOWNLOAD AND BUILD ###.
# However if the boost's version delivered with libboost-python-dev is enough, comment lines below ### BOOST DOWNLOAD AND BUILD ###
# and uncomment lines below ### BOOST PRECOMPILED VERSION OF BOOST_PYTHON ###.

### BOOST DOWNLOAD AND BUILD ###
# RUN wget --max-redirect 3 https://netix.dl.sourceforge.net/project/boost/boost/${BOOST_VERSION}/boost_${BOOST_VERSION_}.tar.gz
# RUN mkdir -p ${BOOST_ROOT} && tar zxf boost_${BOOST_VERSION_}.tar.gz -C ${BOOST_ROOT} --strip-components=1
# RUN rm boost_${BOOST_VERSION_}.tar.gz
# RUN echo "Boost downloaded and extracted to: ${BOOST_ROOT}"

# # build boost.python
# WORKDIR ${BOOST_ROOT}
# RUN ./bootstrap.sh --with-python=/usr/bin/python${PYTHON_VERSION}
# RUN ./b2 --with-python3

# instead of building boost try with libboost-python-dev with a little older boost library
### BOOST PRECOMPILED VERSION OF BOOST_PYTHON ###
RUN apt-get install -y libboost-python-dev

# set current dir to FRAMSTICKS_SDK_ROOT framsticks SDK
# container should be launched with framsticksSDK (and pythonidas in it)
# mounted from host
WORKDIR ${FRAMSTICKS_SDK_ROOT}
# link python${PYTHON_VERSION} as the default python command
RUN ln /usr/bin/python${PYTHON_VERSION} /usr/bin/python -f
# assign pip3 as the default pip command
RUN ln /usr/bin/pip3 /usr/bin/pip -f

# install dependencies for pythonidas
ARG pythonidas_tmp_dir=pythonidas
ARG pythonidas_python_dependencies_file=requirements.txt

RUN apt-get install -y python3-tk python-opengl
# clone pythonidas and install its requirements
RUN git clone -b gui ${PYTHONIDAS_GIT} ${pythonidas_tmp_dir}
RUN pip install -r ${pythonidas_tmp_dir}/${pythonidas_python_dependencies_file}  || : # ignore error when file not exist - file with requirements may not exist in the future releases
# remove pythonidas since it is not required anymore
RUN rm -rf ${pythonidas_tmp_dir}

# add custom user - it easier to set up X server when logged as non root user
RUN useradd -ms /bin/bash  developer
USER developer
ENV HOME /home/developer

ENTRYPOINT /bin/bash