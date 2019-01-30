FROM nvidia/cuda:9.0-base-ubuntu16.04

LABEL maintainer="jgilewski@jagin.pl"

WORKDIR /root

# No interactive frontend during docker build
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

# Update package list and set default locale to en_US.UTF-8
RUN apt-get update && apt-get install -y \
    locales && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure --frontend=noninteractive locales
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en

# Install packages
RUN apt-get install -qqy \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    vim \
    zip \
    unzip \
    ca-certificates \
    libjpeg-dev \
    libpng-dev

# Install Miniconda
RUN curl -so miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x miniconda.sh && \
    ./miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    /opt/conda/bin/conda install -qy conda-build
ENV PATH=/opt/conda/bin:$PATH
ENV CONDA_AUTO_UPDATE_CONDA=false

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create fastai environment
COPY environment.yaml environment.yaml
RUN conda env create -q -f environment.yaml
ENV CONDA_DEFAULT_ENV=fastai
ENV CONDA_PREFIX=/opt/conda/envs/$CONDA_DEFAULT_ENV
ENV PATH=$CONDA_PREFIX/bin:$PATH
ENV TORCH_MODEL_ZOO=/workspace/fastai/models

# Copy fastai settings
COPY .fastai .fastai

# Copy Jupyter settings
COPY .jupyter .jupyter

EXPOSE 8888