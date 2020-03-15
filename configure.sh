#!/bin/sh -e

if test -f "build.ninja"; then
 echo 'Already Configured'
 exit 0
fi

# Dependencies
MUSL_version=musl-1.2.0
LINUX_version=linux-5.4.24
LLVM_version=llvm-10
TOYBOX_version=toybox-HEAD
CMAKE_version=cmake-3.16.5
AWK_version=awk-HEAD
SBASE_version=sbase-HEAD
VIM_version=vim-8.2.0347
BEARSSL_version=bearssl-HEAD
CURL_version=curl-7.69.0
BYACC_version=byacc-20191125
CURSES_version=netbsd-curses-HEAD
ZLIB_version=zlib-1.2.11
SAMURAI_version=samurai-HEAD
GETTEXT_version=gettext-tiny-HEAD
ZSH_version=zsh-5.8
GIT_version=git-2.25.1
LESS_version=less-551
DASH_version=dash-0.5.10
PYTHON_version=Python-3.8.2
NVI_version=nvi-1.79

# GPL Dependencies
GNUMAKE_version=make-3.81
RSYNC_version=rsync-2.6.9

check()
{
  if ! type "$1" > /dev/null; then
    echo "ERROR: $1 not found in path!"
    exit 1
  fi
}

check curl
check git
check find
check cmp

check clang
check clang++
check ar
check ranlib
check lld

check nproc

projects='$sysroot/tmp musl clang awk sbase toybox curl cacert samurai git zsh less nvi'

if ! type "ccache" > /dev/null; then
  HOST_CC=clang
  HOST_CXX=clang++
  LLVM_CCACHE_BUILD=OFF
else
  HOST_CC='ccache clang'
  HOST_CXX='ccache clang++'
  LLVM_CCACHE_BUILD=ON
fi

CURL_headers=$PWD/target-$CURL_version/include
CURL_lib=$PWD/target-$CURL_version/lib
CURSES_headers=$PWD/target-$CURSES_version/include
CURSES_lib=$PWD/target-$CURSES_version/lib
BEARSSL_headers=$PWD/$BEARSSL_version/inc
BEARSSL_lib=$PWD/target-$BEARSSL_version
ZLIB_headers=$PWD/target-$ZLIB_version/include
ZLIB_lib=$PWD/target-$ZLIB_version/lib
LINUX_headers=$PWD/$LINUX_version/usr/include
SYSROOT=$PWD/sysroot
HOSTROOT=$PWD/build-host-$LLVM_version
MARCH=broadwell
NPROC=$(nproc)
LLVM_TBLGEN=$PWD/build-host-$llvm/bin/llvm-tblgen
CLANG_TBLGEN=$PWD/build-host-$llvm/bin/clang-tblgen
CFLAGS="-Os -pipe -march=$MARCH -mtune=$MARCH"
CXXFLAGS="-Os -pipe -march=$MARCH -mtune=$MARCH"
LDFLAGS="-w -s"

# Test for LIBC++
tmp_out=$(mktemp /tmp/test-XXXXXX)
clang++ -x c++ -o $tmp_out - << EOF
#include <iostream>
int main(int argc, char* argv[]) {
  #ifdef _LIBCPP_VERSION
    std::cout << _LIBCPP_VERSION << std::endl;
  #endif
  return 0;
}
EOF

LIBCPP_VERSION=$($tmp_out)
rm $tmp_out

echo LIBCPP_VERSION=$LIBCPP_VERSION

if [ -z "$LIBCPP_VERSION" ]; then
  LLVM_SYSROOT=$SYSROOT
else
  LLVM_SYSROOT='/'
fi

echo "Creating build.ninja"
cat << EOF > build.ninja
# Autogenerated Configuration
#============================
musl=$MUSL_version
linux=$LINUX_version
llvm=$LLVM_version
toybox=$TOYBOX_version
cmake=$CMAKE_version
host-cmake=$PWD/$CMAKE_version/bin/cmake
awk=$AWK_version
sbase=$SBASE_version
vim=$VIM_version
bearssl=$BEARSSL_version
bearssl-headers=$BEARSSL_headers
bearssl-lib=$BEARSSL_lib
curl=$CURL_version
curl-headers=$CURL_headers
curl-lib=$CURL_lib
byacc=$BYACC_version
host-yacc=$PWD/host-$BYACC_version/bin/yacc
curses=$CURSES_version
curses-headers=$CURSES_headers
curses-lib=$CURSES_lib
zlib=$ZLIB_version
zlib-headers=$ZLIB_headers
zlib-lib=$ZLIB_lib
gettext=$GETTEXT_version
host-msgfmt=$PWD/host-$GETTEXT_version/bin/msgfmt
zsh=$ZSH_version
git=$GIT_version
less=$LESS_version
samurai=$SAMURAI_version
dash=$DASH_version
python=$PYTHON_version
nvi=$NVI_version
host-python=$PWD/host-$PYTHON_version/bin/python3
gnumake=$GNUMAKE_version
host-make=$PWD/host-$GNUMAKE_version/bin/make
rsync=$RSYNC_version
sysroot=$SYSROOT
llvm-sysroot=$LLVM_SYSROOT
march=$MARCH
nproc=$NPROC
llvm_ccache_build=$LLVM_CCACHE_BUILD
host_cc=$HOST_CC
host_cxx=$HOST_CXX
cc=$SYSROOT/bin/clang
cxx=$SYSROOT/bin/clang++
llvm-tblgen=$HOSTROOT/bin/llvm-tblgen
clang-tblgen=$HOSTROOT/bin/clang-tblgen
linux-headers=$LINUX_headers
cflags=$CFLAGS
cxxflags=$CXXFLAGS
ldflags=$LDFLAGS

# Default build rules
#####################
include rules.ninja

EOF

find -name build.ninja | sed '/^.\/build.ninja.*$/d' | cut -c3- | xargs -n1 echo subninja >> build.ninja

cat << EOF >> build.ninja

# Default clean tasks
#####################
build clean: rm
  rm = src-* build-* target-* host-* sysroot *.tgz *.log

build distclean: rm
  rm = src-* build-* target-* host-* sysroot *.tgz *.log build.ninja $
    \$musl \$linux \$byacc \$clang \$llvm \$cmake \$awk \$sbase \$toybox \$less \$curses $
    \$bearssl \$curl \$zlib \$samurai \$gettext \$git \$zsh \$python \$nvi \$gnumake

# Default builds
################
build \$sysroot/tmp: mkdir

build sysroot.tgz: package | $projects
  builddir = \$sysroot

default sysroot.tgz
EOF
