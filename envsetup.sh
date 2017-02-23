#!/bin/bash

export SRCROOT=/tool/7.9
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

BINUTILS_TAR=binutils-2.26.tar.bz2
BINUTILS_SRC=binutils-2.26
GCC_TAR=gcc-5.3.0.tar.bz2
GCC_SRC=gcc-5.3.0
MPFR_TAR=mpfr-3.1.3.tar.xz
MPFR_SRC=mpfr-3.1.3
GMP_TAR=gmp-6.1.0.tar.xz
GMP_SRC=gmp-6.1.0
MPC_TAR=mpc-1.0.3.tar.gz
MPC_SRC=mpc-1.0.3
KERNEL_TAR=linux-4.4.2.tar.xz
KERNEL_SRC=linux-4.4.2
GLIBC_TAR=glibc-2.23.tar.xz
GLIBC_SRC=glibc-2.23
TCL_TAR=tcl-core8.6.4-src.tar.gz
TCL_SRC=tcl8.6.4
TCL_BIN=tclsh8.6
TCL_LIB=libtcl8.6.so
EXPECT_TAR=expect5.45.tar.gz
EXPECT_SRC=expect5.45
DEJAGNU_TAR=dejagnu-1.5.3.tar.gz
DEJAGNU_SRC=dejagnu-1.5.3
