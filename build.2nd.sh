
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
readelf -l a.out | grep "$CROSS"
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
    --with-gxx-include-dir=$CROSS/$LFS_TGT/include/c++/5.3.0

$MAKE $MFLAGS
$MAKE $MFLAGS install

cd ../../
rm -rf  gcc-5.3.0

# build binutils-2
cd $BUILDTMP
tar xvf $SRCROOT/binutils-2.26.tar.bz2
cd binutils-2.26
mkdir -v build
cd build

CC=$LFS_TGT-gcc                \
AR=$LFS_TGT-ar                 \
RANLIB=$LFS_TGT-ranlib         \
../configure --prefix=$CROSS            \
             --with-sysroot             \
             --with-lib-path=$CROSS/lib \
             --disable-nls              \
             --disable-werror

$MAKE $MFLAGS
$MAKE $MFLAGS install
make -C ld clean
make -C ld LIB_PATH=/usr/lib:/lib
cp -v ld/ld-new $CROSS/bin
cd ../../
rm -rf binutils-2.26

# build gcc-2
cd $BUILDTMP
tar xvf $SRCROOT/gcc-5.3.0.tar.bz2
cd gcc-5.3.0

cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h

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

CC=$LFS_TGT-gcc                                    \
CXX=$LFS_TGT-g++                                   \
AR=$LFS_TGT-ar                                     \
RANLIB=$LFS_TGT-ranlib                             \
../configure                                       \
    --prefix=$CROSS                                \
    --with-local-prefix=$CROSS                     \
    --with-native-system-header-dir=$CROSS/include \
    --disable-multilib                             \
    --disable-libgomp                              \
    --disable-bootstrap                            \
    --disable-libstdcxx-pch                        \
    --enable-languages=c,c++

$MAKE $MFLAGS
$MAKE $MFLAGS install
ln -sv gcc $CROSS/bin/cc
ls gcc -al|grep gcc
echo 'int main(){}' > dummy.c
cc dummy.c
readelf -l a.out | grep "$CROSS"
ldd a.out
file a.out
rm -v dummy.c a.out
cd ../../
rm -rf  gcc-5.3.0


