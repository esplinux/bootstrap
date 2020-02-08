#!/bin/sh -e

LLVM_version=llvm-10
LINUX_version=linux-5.4.18
MUSL_version=musl-1.1.24
TOYBOX_version=toybox-HEAD
DASH_version=dash-0.5.10
BASH_version=bash-5.0
NODE_version=node-v12.15.0

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
check python

check clang
check clang++
check llvm-ar
check llvm-ranlib
check lld

check make
check cmake
check ninja
check bash
check nproc

if ! test -f "versions.ninja"; then
  echo "Creating versions.ninja"
  touch versions.ninja
  echo "# Package Versions" >> versions.ninja
  echo "#=================" >> versions.ninja
  echo "musl=$MUSL_version" >> versions.ninja
  echo "linux=$LINUX_version" >> versions.ninja
  echo "llvm=$LLVM_version" >> versions.ninja
  echo "toybox=$TOYBOX_version" >> versions.ninja
  echo "dash=$DASH_version" >> versions.ninja
  echo "bash=$BASH_version" >> versions.ninja
  echo "node=$NODE_version" >> versions.ninja
fi

if ! test -f "tools.ninja"; then
  NPROC=$(nproc)
  CC=$PWD/out-clang-$LLVM_version/bin/clang
  CXX=$PWD/out-clang-$LLVM_version/bin/clang++
  SYSROOT=$PWD/out-$MUSL_version
  CFLAGS="-Os"
  CXXFLAGS="-Os"
  LDFLAGS="-w -s"

  echo "Creating tools.ninja"
  touch tools.ninja
  echo "# Build Tools" >> tools.ninja
  echo "#============" >> tools.ninja
  echo "nproc=$NPROC" >> tools.ninja
  echo "cc=$CC" >> tools.ninja
  echo "cxx=$CXX" >> tools.ninja
  echo "sysroot=$SYSROOT" >> tools.ninja
  echo "cflags=$CFLAGS" >> tools.ninja
  echo "cxxflags=$CXXFLAGS" >> tools.ninja
  echo "ldflags=$LDFLAGS" >> tools.ninja
fi
