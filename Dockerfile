FROM ubuntu:18.04 as intermediate

###############################################################################################
MAINTAINER Ivan E. Cao-Berg <icaoberg@andrew.cmu.edu>
LABEL Description="Ubuntu 18.04 + MATLAB MCR 2018b + Jupyter NoteBook"
LABEL Vendor="Murphy Lab in the Computational Biology Department at Carnegie Mellon University"
LABEL Web="http://murphylab.cbd.cmu.edu"
LABEL Version="2018b"
###############################################################################################

###############################################################################################
# UPDATE OS AND INSTALL TOOLS
USER root
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y build-essential git \
    unzip \
    xorg xserver-xorg \
    wget \
    curl \
    sudo \
    software-properties-common
RUN add-apt-repository ppa:webupd8team/java && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y openjdk-8-jdk && \
    which java
###############################################################################################

###############################################################################################
# INSTALL MATLAB MCR 2018b
USER root
RUN echo "Downloading Matlab MCR 2018b"
RUN mkdir /mcr-install && \
    mkdir /opt/mcr
RUN cd /mcr-install && \
    wget --quiet -nc http://ssd.mathworks.com/supportfiles/downloads/R2018b/deployment_files/R2018b/installers/glnxa64/MCR_R2018b_glnxa64_installer.zip && \
    cd /mcr-install && \
    echo "Unzipping container" && \
    unzip -q MCR_R2018b_glnxa64_installer.zip && \
    ./install -destinationFolder /opt/mcr -agreeToLicense yes -mode silent && \
    cd / && \
    echo "Removing temporary files" && \
    rm -rvf mcr-install
###############################################################################################

###############################################################################################
FROM jupyter/base-notebook:latest
COPY --from=intermediate /opt/mcr /opt/mcr

# Install Python 3 packages
RUN conda install --quiet --yes \
    'beautifulsoup4=4.8.*' \
    'conda-forge::blas=*=openblas' \
    'bokeh=1.3*' \
    'cython=0.29*' \
    'dill=0.3*' \
    'h5py=2.9*' \
    'hdf5=1.10*' \
    'ipywidgets=7.5*' \
    'matplotlib-base=3.1.*' \
    'numba=0.45*' \
    'numexpr=2.6*' \
    'pandas=0.25*' \
    'patsy=0.5*' \
    'scikit-image=0.15*' \
    'scikit-learn=0.21*' \
    'scipy=1.3*' \
    'seaborn=0.9*' \
    'sqlalchemy=1.3*' \
    'statsmodels=0.10*' \
    'sympy=1.4*' \
    'tabulate' \
    'vincent=0.4.*' \
    'xlrd' \
    && \
    conda clean --all -f -y
###############################################################################################

###############################################################################################
# CONFIGURE ENVIRONMENT VARIABLES FOR MCR
USER root
RUN mv -v /opt/mcr/v95/sys/os/glnxa64/libstdc++.so.6 /opt/mcr/v95/sys/os/glnxa64/libstdc++.so.6.old
RUN mv -v /opt/mcr/v95/bin/glnxa64/libexpat.so.1 /opt/mcr/v95/bin/glnxa64/libexpat.so.1.backup
RUN mv -v /opt/mcr/v95/bin/glnxa64/libexpat.so.1.5.0 /opt/mcr/v95/bin/glnxa64/libexpat.so.1.5.0.backup

ENV LD_LIBRARY_PATH /opt/mcr/v95/runtime/glnxa64:/opt/mcr/v95/bin/glnxa64:/opt/mcr/v95/sys/os/glnxa64
ENV XAPPLRESDIR /opt/mcr/v95/X11/app-defaults
###############################################################################################

USER root
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y build-essential git \
    unzip \
    xorg xserver-xorg \
    wget \
    curl \
    sudo \
    software-properties-common \
    uuid-runtime

RUN add-apt-repository ppa:webupd8team/java && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y openjdk-8-jdk

###############################################################################################
# CONFIGURE ENVIRONMENT
ENV DEBIAN_FRONTEND noninteractive
ENV SHELL /bin/bash
ENV USERNAME murphylab
ENV UID 1001
RUN useradd -m -s /bin/bash -N -u $UID $USERNAME
RUN if [ ! -d /home/$USERNAME/ ]; then mkdir /home/$USERNAME/; fi
###############################################################################################
