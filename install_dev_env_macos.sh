#!/usr/bin/env bash

USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:68.0) Gecko/20100101 Firefox/68.0'
SDK_VERSION=1.1.114.0

function downloadFile() {
  which curl > /dev/null
  if [ $? -ne 0 ]; then
    echo "You need the curl binary installed and accessible to this shell."
    exit 1
  fi

  url=$1
  destination=.download/`basename $url`

  mkdir -p .download
  if test -f $destination; then
    echo "$destination already downloaded"
    return
  fi

  echo "downloading $destination"
  curl --progress-bar --show-error --location --user-agent '${USER_AGENT}' $url --output $destination
  if [ $? -ne 0 ]; then
    echo "fail downloading from $url"
    exit 1
  fi
}

function untarFile() {
  file=$1

  mkdir -p .env
  echo "untaring $file"
  tar -x -f $file -C .env
  if [ $? -ne 0 ]; then
    echo "fail untaring file $file"
    exit 2
  fi
}

function unzipFile() {
  file=$1

  mkdir -p .env
  echo "unzipping $file"
  unzip $file -d .env
  if [ $? -ne 0 ]; then
    echo "fail unzipping file $file"
    exit 2
  fi
}

#
# Script starts here
#

downloadFile https://github.com/Kitware/CMake/releases/download/v3.15.2/cmake-3.15.2-Darwin-x86_64.tar.gz
untarFile .download/cmake-3.15.2-Darwin-x86_64.tar.gz
CMAKE=$PWD/.env/cmake-3.15.2-Darwin-x86_64/CMake.app/Contents/bin/cmake

downloadFile https://sdk.lunarg.com/sdk/download/${SDK_VERSION}/mac/vulkansdk-macos-${SDK_VERSION}.tar.gz?u=
untarFile .download/vulkansdk-macos-${SDK_VERSION}.tar.gz?u=

downloadFile https://github.com/glfw/glfw/releases/download/3.3/glfw-3.3.zip
unzipFile .download/glfw-3.3.zip
(${CMAKE} -B.env/glfw-3.3/build -H.env/glfw-3.3/ && cd .env/glfw-3.3/build && make -j `sysctl -n hw.ncpu` || exit 3)

downloadFile https://github.com/g-truc/glm/archive/0.9.9.5.tar.gz
untarFile .download/0.9.9.5.tar.gz

