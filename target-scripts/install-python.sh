#!/bin/bash

source ./config.sh

ENABLE_DOWNLOAD=${ENABLE_DOWNLOAD:-false}

if [ ! -e files ]; then
    mkdir -p files
fi

FILES_DIR=./files
if $ENABLE_DOWNLOAD; then
    FILES_DIR=./tmp/files
    mkdir -p $FILES_DIR
fi

# download files, if not found
download() {
    url=$1
    dir=$2

    filename=$(basename $1)
    mkdir -p ${FILES_DIR}/$dir

    if [ ! -e ${FILES_DIR}/$dir/$filename ]; then
        echo "==> download $url"
        (cd ${FILES_DIR}/$dir && curl -SLO $1)
    fi
}

if $ENABLE_DOWNLOAD; then
    download https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
else
    FILES_DIR=./files
fi

# Install python
echo "==> Install python"
tar xvf "${FILES_DIR}/Python-${PYTHON_VERSION}.tgz" -C /tmp
cd /tmp/Python-${PYTHON_VERSION} || exit 1
./configure --enable-optimizations
make -j "$(nproc)"
sudo make altinstall
