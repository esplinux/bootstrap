#!/bin/sh -e

MUSL_version=musl-1.2.0
LINUX_version=linux-5.4.24
LLVM_version=llvm-10
TOYBOX_version=toybox-HEAD
CMAKE_version=cmake-3.16.5
AWK_version=awk-HEAD
SBASE_version=sbase-HEAD
#DASH_version=dash-0.5.10
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
GNUMAKE_version=make-3.81
#GNUBASH_version=bash-3.2.57

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
check rsync
check cmp
check python3

check clang
check clang++
check ar
check ranlib
check lld

check make
check cmake
check bash
check nproc

if ! type "ccache" > /dev/null; then
  HOST_CC=clang
  HOST_CXX=clang++
  LLVM_CCACHE_BUILD=OFF
else
  HOST_CC='ccache clang'
  HOST_CXX='ccache clang++'
  LLVM_CCACHE_BUILD=ON
fi

CURL_headers=$PWD/out-$CURL_version/include
CURL_lib=$PWD/out-$CURL_version/lib
CURSES_headers=$PWD/out-$CURSES_version/include
CURSES_lib=$PWD/out-$CURSES_version/lib
BEARSSL_headers=$PWD/$BEARSSL_version/inc
BEARSSL_lib=$PWD/out-$BEARSSL_version
ZLIB_headers=$PWD/out-$ZLIB_version/include
ZLIB_lib=$PWD/out-$ZLIB_version/lib
LINUX_headers=$PWD/out-$LINUX_version/include
SYSROOT=$PWD/sysroot
HOSTROOT=$PWD/build-host-$LLVM_version
MARCH=broadwell
NPROC=$(nproc)
LLVM_TBLGEN=$PWD/build-host-$llvm/bin/llvm-tblgen
CLANG_TBLGEN=$PWD/build-host-$llvm/bin/clang-tblgen
CFLAGS="-Os -pipe -march=$MARCH -mtune=$MARCH"
CXXFLAGS="-Os -pipe -march=$MARCH -mtune=$MARCH"
LDFLAGS="-w -s"

if ! test -f "config.ninja"; then
  echo "Creating config.ninja"
  touch config.ninja
  echo "# Autogenerated Configuration" >> config.ninja
  echo "#============================" >> config.ninja
  echo "musl=$MUSL_version" >> config.ninja
  echo "linux=$LINUX_version" >> config.ninja
  echo "llvm=$LLVM_version" >> config.ninja
  echo "toybox=$TOYBOX_version" >> config.ninja
  echo "cmake=$CMAKE_version" >> config.ninja
  echo "awk=$AWK_version" >> config.ninja
  echo "sbase=$SBASE_version" >> config.ninja
#  echo "dash=$DASH_version" >> config.ninja
  echo "vim=$VIM_version" >> config.ninja
  echo "bearssl=$BEARSSL_version" >> config.ninja
  echo "bearssl-headers=$BEARSSL_headers" >> config.ninja
  echo "bearssl-lib=$BEARSSL_lib" >> config.ninja
  echo "curl=$CURL_version" >> config.ninja
  echo "curl-headers=$CURL_headers" >> config.ninja
  echo "curl-lib=$CURL_lib" >> config.ninja
  echo "byacc=$BYACC_version" >> config.ninja
  echo "curses=$CURSES_version" >> config.ninja
  echo "curses-headers=$CURSES_headers" >> config.ninja
  echo "curses-lib=$CURSES_lib" >> config.ninja
  echo "zlib=$ZLIB_version" >> config.ninja
  echo "zlib-headers=$ZLIB_headers" >> config.ninja
  echo "zlib-lib=$ZLIB_lib" >> config.ninja
  echo "gettext=$GETTEXT_version" >> config.ninja
  echo "zsh=$ZSH_version" >> config.ninja
  echo "git=$GIT_version" >> config.ninja
  echo "samurai=$SAMURAI_version" >> config.ninja
  echo "gnumake=$GNUMAKE_version" >> config.ninja
#  echo "gnubash=$GNUBASH_version" >> config.ninja
  echo "sysroot=$SYSROOT" >> config.ninja
  echo "march=$MARCH" >> config.ninja
  echo "nproc=$NPROC" >> config.ninja
  echo "make=$SYSROOT/opt/gnu/bin/make" >> config.ninja
  echo "llvm_ccache_build=$LLVM_CCACHE_BUILD" >> config.ninja
  echo "host_cc=$HOST_CC" >> config.ninja
  echo "host_cxx=$HOST_CXX" >> config.ninja
  echo "cc=$SYSROOT/bin/clang" >> config.ninja
  echo "cxx=$SYSROOT/bin/clang++" >> config.ninja
  echo "yacc=$SYSROOT/bin/yacc" >> config.ninja
  echo "llvm-tblgen=$HOSTROOT/bin/llvm-tblgen" >> config.ninja
  echo "clang-tblgen=$HOSTROOT/bin/clang-tblgen" >> config.ninja
  echo "linux-headers=$LINUX_headers" >> config.ninja
  echo "cflags=$CFLAGS" >> config.ninja
  echo "cxxflags=$CXXFLAGS" >> config.ninja
  echo "ldflags=$LDFLAGS" >> config.ninja
fi
