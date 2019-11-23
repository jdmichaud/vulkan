#!/usr/bin/env bash

set -e

USER_AGENT='Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:68.0) Gecko/20100101 Firefox/68.0'
VULKAN_VERSION=1.1.121.1

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

function compilePackage() {
  package=$1
  nbjobs=$2 || `nproc`

  prefix=`pwd`/.env
  pushd .
  cd .env/$package
  ./configure --prefix=$prefix --with-python=$prefix --enable-autotools --enable-llvm
  make -j $nbjobs
  make install
  popd
}

function installCPackage() {
  url=$1
  package=$2
  nbjobs=$3

  downloadFile $url
  untarFile .download/`basename ${url}`
  compilePackage $package $nbjobs
}

#
# Script starts here
#
PREFIX=`pwd`/.env/
export PATH=$PATH:${PREFIX}bin
export CPPFLAGS="-I${PREFIX}include"
export PKG_CONFIG_PATH=${PREFIX}lib/pkgconfig

# All these are dependencies for vulkansdk and glfw
installCPackage https://www.x.org/archive/individual/proto/xproto-7.0.31.tar.gz xproto-7.0.31
installCPackage https://www.x.org/archive/individual/proto/xextproto-7.3.0.tar.gz xextproto-7.3.0
installCPackage https://www.x.org/releases/individual/lib/xtrans-1.4.0.tar.gz xtrans-1.4.0
cp .env/xtrans-1.4.0/xtrans.pc .env/lib/pkgconfig/
installCPackage http://xmlsoft.org/sources/libxml2-2.9.9.tar.gz libxml2-2.9.9
installCPackage http://xmlsoft.org/sources/libxslt-1.1.33.tar.gz libxslt-1.1.33
installCPackage https://xcb.freedesktop.org/dist/libpthread-stubs-0.4.tar.gz libpthread-stubs-0.4
installCPackage https://www.x.org/releases/individual/lib/libXau-1.0.9.tar.gz libXau-1.0.9
installCPackage https://xcb.freedesktop.org/dist/xcb-proto-1.13.tar.gz xcb-proto-1.13
installCPackage https://xcb.freedesktop.org/dist/libxcb-1.13.tar.gz libxcb-1.13
installCPackage https://www.x.org/archive/individual/proto/kbproto-1.0.7.tar.gz kbproto-1.0.7
installCPackage https://www.x.org/archive/individual/proto/inputproto-2.3.tar.gz inputproto-2.3
installCPackage https://www.x.org/releases/individual/lib/libX11-1.6.8.tar.gz libX11-1.6.8
installCPackage https://www.x.org/releases/individual/lib/libXext-1.3.4.tar.gz libXext-1.3.4
installCPackage https://www.x.org/archive/individual/proto/renderproto-0.11.tar.gz renderproto-0.11
installCPackage https://www.x.org/archive/individual/proto/randrproto-1.5.0.tar.gz randrproto-1.5.0
installCPackage https://www.x.org/releases/individual/lib/libXrender-0.9.10.tar.gz libXrender-0.9.10
installCPackage https://www.x.org/releases/individual/lib/libXrandr-1.5.2.tar.gz libXrandr-1.5.2
installCPackage https://www.x.org/archive/individual/proto/xineramaproto-1.2.tar.gz xineramaproto-1.2
installCPackage https://www.x.org/archive//individual/lib/libXinerama-1.1.tar.gz libXinerama-1.1
installCPackage https://www.x.org/archive/individual/proto/fixesproto-5.0.tar.gz fixesproto-5.0
installCPackage https://www.x.org/archive//individual/lib/libXfixes-5.0.tar.gz libXfixes-5.0
installCPackage https://www.x.org/archive//individual/lib/libXcursor-1.2.0.tar.gz libXcursor-1.2.0
# For mesa
installCPackage https://www.x.org/archive/individual/proto/inputproto-2.3.tar.gz inputproto-2.3
installCPackage https://www.x.org/archive//individual/lib/libXi-1.7.tar.gz libXi-1.7
installCPackage https://www.x.org/archive/individual/proto/glproto-1.4.17.tar.gz glproto-1.4.17
installCPackage https://www.x.org/releases/individual/lib/libpciaccess-0.16.tar.gz libpciaccess-0.16
installCPackage https://dri.freedesktop.org/libdrm/libdrm-2.4.99.tar.gz libdrm-2.4.99
installCPackage https://www.x.org/releases/individual/proto/dri2proto-2.8.tar.gz dri2proto-2.8
installCPackage https://www.x.org/archive/individual/proto/damageproto-1.2.1.tar.gz damageproto-1.2.1
installCPackage https://www.x.org/releases/individual/lib/libXdamage-1.1.tar.gz libXdamage-1.1
installCPackage https://www.x.org/archive/individual/proto/xf86vidmodeproto-2.3.tar.gz xf86vidmodeproto-2.3
installCPackage https://www.x.org/releases/individual/lib/libXxf86vm-1.1.4.tar.gz libXxf86vm-1.1.4
installCPackage https://www.x.org/releases/individual/lib/libxshmfence-1.3.tar.gz libxshmfence-1.3

#installCPackage http://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.gz m4-1.4.18
# Since glibc 2.28, m4 does not compile. As it is not maintained anymore, use a
# patch from buildroot.
downloadFile http://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.gz
untarFile .download/m4-1.4.18.tar.gz
(
  cd .env/m4-1.4.18
  curl -sOL https://raw.githubusercontent.com/buildroot/buildroot/master/package/m4/0001-fflush-adjust-to-glibc-2.28-libio.h-removal.patch
  patch -p1 < 0001-fflush-adjust-to-glibc-2.28-libio.h-removal.patch
)
compilePackage m4-1.4.18 `nproc`

installCPackage https://sourceware.org/elfutils/ftp/0.177/elfutils-0.177.tar.bz2 elfutils-0.177

downloadFile https://github.com/Kitware/CMake/releases/download/v3.15.3/cmake-3.15.3.tar.gz
untarFile .download/cmake-3.15.3.tar.gz
(
  cd .env/cmake-3.15.3
  ./bootstrap --prefix=$PREFIX --parallel=`nproc`
  make -j `nproc`
  make install
)

# Install LLVM for mesa
downloadFile http://releases.llvm.org/9.0.0/llvm-9.0.0.src.tar.xz
untarFile .download/llvm-9.0.0.src.tar.xz
(
  mkdir -p .env/llvm-9.0.0.src/build
  cd .env/llvm-9.0.0.src/build
  cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=$PREFIX -DLLVM_BUILD_LLVM_DYLIB=ON -DLLVM_ENABLE_RTTI=ON ../
  make -j `nproc`
  make install
)

# To build mesa with meson
installCPackage https://ftp.gnu.org/gnu/bison/bison-3.4.tar.xz bison-3.4 1
installCPackage https://github.com/westes/flex/releases/download/v2.6.3/flex-2.6.3.tar.gz flex-2.6.3 1

# Install mesa homemade build system meson
downloadFile https://github.com/mesonbuild/meson/releases/download/0.51.2/meson-0.51.2.tar.gz
untarFile .download/meson-0.51.2.tar.gz
export PATH=`pwd`/.env/meson-0.51.2/:$PATH

# Instrall ninja needed by meson
downloadFile https://github.com/ninja-build/ninja/archive/v1.9.0.tar.gz
untarFile .download/v1.9.0.tar.gz
(
  cd .env/ninja-1.9.0
  ./configure.py --bootstrap
  cp ninja ../bin/
)

downloadFile https://mesa.freedesktop.org/archive/mesa-19.1.7.tar.xz mesa-19.1.7
untarFile .download/mesa-19.1.7.tar.xz
(
  cd .env/mesa-19.1.7
  mkdir -p build
  cd build
  meson.py -Dplatforms=x11,drm -Dprefix=$PREFIX ../
  ninja -C .
  ninja -C . install
  ninja -C . xmlpool-pot xmlpool-update-po xmlpool-gmo
)

downloadFile https://sdk.lunarg.com/sdk/download/${VULKAN_VERSION}/linux/vulkansdk-linux-x86_64-${VULKAN_VERSION}.tar.gz?u=
untarFile .download/vulkansdk-linux-x86_64-${VULKAN_VERSION}.tar.gz?u=

downloadFile https://github.com/glfw/glfw/releases/download/3.3/glfw-3.3.zip
unzipFile .download/glfw-3.3.zip
(
  cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -B.env/glfw-3.3/build -H.env/glfw-3.3/
  cd .env/glfw-3.3/build
  make -j `nproc`
  make install
)

downloadFile https://github.com/g-truc/glm/archive/0.9.9.5.tar.gz
untarFile .download/0.9.9.5.tar.gz
(
  cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -B.env/glm-0.9.9.5/build -H.env/glm-0.9.9.5/
  cd .env/glm-0.9.9.5/build
  make -j `nproc`
  make install
)

cat > setup_dev_env_linux.sh <<EOF
#!/bin/sh

export VULKAN_SDK_PATH=`pwd`/.env/${VULKAN_VERSION}/x86_64/

# So that vulkan will find icd.d
export XDG_DATA_DIRS=\$XDG_DATA_DIRS:`pwd`/.env/share/:${VULKAN_SDK_PATH}/etc/vulkan/

export PKG_CONFIG_PATH=`pwd`/.env/lib/pkgconfig:${VULKAN_SDK_PATH}/lib/pkgconfig/
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:`pwd`/.env/lib/:${VULKAN_SDK_PATH}/lib
export PATH=\$PATH:`pwd`/.env/bin:${VULKAN_SDK_PATH}/bin
EOF

