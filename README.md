# Bootstrap
A Bootstrap/Scratch cross compilation environment which does not depend upon
gcc, libgcc, libstdc++ or GNU Binutils. It is a complete linux toolchain built
using LLVM, LLVM Clang, LLVM LibUnwind, LLVM Compiler-RT and LLVM LibC++. It's
primary purpose is to bootstrap esplinux base packages but it can be used to 
build pretty much anything.

## Toybox and SBase
Uses Toybox and SBase to complete a basic set of coreutils. Toybox versions
are preferred over those from SBase when possible.

## ZSH Workaround
Currently contains a symlink chain from bash to sh and from sh to zsh. This
enables zsh to emulate bash and build toybox. This will be replaced with
toybox sh once it is complete.

## GNU Make
Contains a single GNU dependency GNU Make. I'm using the last GPLv2 version
of GNU Make statically linked and found in /opt/gnu/bin/make.
