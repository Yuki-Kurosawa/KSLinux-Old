#!/bin/bash

export SRCROOT=/tool/7.9
export KS=/ks/ramfs
export BUILDTMP=/tool/tmp
export CROSS=/tool/cross
export LIBPARENT=/tool

# set env var
rm -rf {$KS,$BUILDTMP,$CROSS} 2>/dev/null
mkdir -p {$KS,$BUILDTMP,$CROSS} 2>/dev/null

set +h
umask 022
LFS=$KS
LC_ALL=POSIX
LFS_TGT=$(uname -m)-ks-linux-gnu
PATH=$CROSS/bin:/bin:/usr/bin
MAKE=make
MFLAGS=-j4
export LFS LC_ALL LFS_TGT PATH MAKE MFLAGS

# link output folder
mkdir -p $KS$LIBPARENT
ln -sv $CROSS $KS$CROSS

# build tmp system
cd $BUILDTMP
# build binutils-1

tar xvf $SRCROOT/binutils-2.26.tar.bz2
cd binutils-2.26
mkdir -v build
cd build


../configure --prefix=$CROSS            \
             --with-sysroot=$LFS        \
             --with-lib-path=$CROSS/lib \
             --target=$LFS_TGT          \
             --disable-nls              \
             --disable-werror

$MAKE $MFLAGS

case $(uname -m) in
  x86_64) mkdir -v $CROSS/lib && ln -sv lib $CROSS/lib64 ;;
esac

$MAKE $MFLAGS install
cd ../../
rm -rf binutils-2.26

# build gcc-1
cd $BUILDTMP
tar xvf $SRCROOT/gcc-5.3.0.tar.bz2
cd gcc-5.3.0

tar -xf $SRCROOT/mpfr-3.1.3.tar.xz
mv -v mpfr-3.1.3 mpfr
tar -xf $SRCROOT/gmp-6.1.0.tar.xz
mv -v gmp-6.1.0 gmp
tar -xf $SRCROOT/mpc-1.0.3.tar.gz
mv -v mpc-1.0.3 mpc

for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
  cp -uv $file{,.orig}
  sed -e "s@/lib\(64\)\?\(32\)\?/ld@$CROSS&@g" \
      -e "s@/usr@$CROSS@g" $file.orig > $file
  echo "
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 \"$CROSS/lib/\"
#define STANDARD_STARTFILE_PREFIX_2 \"\"" >> $file
  touch $file.orig
done

mkdir -v build
cd       build

../configure                                       \
    --target=$LFS_TGT                              \
    --prefix=$CROSS                                \
    --with-glibc-version=2.11                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --with-local-prefix=$CROSS                     \
    --with-native-system-header-dir=$CROSS/include \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++

$MAKE $MFLAGS
$MAKE $MFLAGS install
cd ../../
rm -rf  gcc-5.3.0
source /tool/build.2nd.sh

