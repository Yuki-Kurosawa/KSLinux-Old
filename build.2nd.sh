#!/bin/bash

#export SRCROOT=/tool/7.9
#export KS=/ks/ramfs
#export BUILDTMP=/tool/tmp
#export CROSS=/tool/cross

# set env var
#rm -rf {$KS,$BUILDTMP,$CROSS} 2>/dev/null
#mkdir -p {$KS,$BUILDTMP,$CROSS} 2>/dev/null

#set +h
#umask 022
#LFS=$KS
#LC_ALL=POSIX
#LFS_TGT=$(uname -m)-ks-linux-gnu
#PATH=$CROSS/bin:/bin:/usr/bin
#MAKE=make
#MFLAGS=-j4
#export LFS LC_ALL LFS_TGT PATH MAKE MFLAGS


# build tmp system
cd $BUILDTMP

# install kernel headers
tar xvf $SRCROOT/linux-4.4.2.tar.xz
cd linux-4.4.2
make mrproper
make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* $CROSS/include
cd ..
rm -rf linux-4.4.2

# install glibc
tar xvf $SRCROOT/glibc-2.23.tar.xz
cd glibc-2.23
mkdir -v build
cd       build

../configure                             \
      --prefix=$CROSS                    \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --disable-profile                  \
      --enable-kernel=2.6.32             \
      --enable-obsolete-rpc              \
      --with-headers=$CROSS/include      \
      libc_cv_forced_unwind=yes          \
      libc_cv_ctors_header=yes           \
      libc_cv_c_cleanup=yes

$MAKE $MFLAGS
$MAKE $MFLAGS install
echo 'int main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep '/tools'
ldd a.out
file a.out
rm -v dummy.c a.out
cd ../../
rm -rf glibc-2.23


# build Libstdc++
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

../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --prefix=$CROSS                 \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-threads     \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=$CROSS/include/c++/5.3.0

$MAKE $MFLAGS
$MAKE $MFLAGS install

cd ../../
rm -rf  gcc-5.3.0

# build binutils-2



