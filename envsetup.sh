#!/bin/bash

export SRCROOT=/tool/src
export KS=/ks/ramfs
export BUILDTMP=/tool/tmp
export CROSS=/tool/cross
export LIBPARENT=/tool
export SCRIPTROOT=/home/ruby/git/KSLinux

# set env var
rm -rf {$KS,$BUILDTMP,$CROSS} 2>/dev/null
mkdir -p {$KS,$BUILDTMP,$CROSS} 2>/dev/null

set +h
umask 022
LFS=$KS
LC_ALL=POSIX
LFS_TGT=x86_64-ks-linux-gnu

PATH=$CROSS/bin:/bin:/usr/bin
MAKE=make
MFLAGS=-j4
export LFS LC_ALL LFS_TGT PATH MAKE MFLAGS

