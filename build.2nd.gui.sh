
# build tmp system
cd $BUILDTMP

# install kernel headers
tar xvf $SRCROOT/$KERNEL_TAR
cd $KERNEL_SRC
make mrproper
make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* $CROSS/include
cd ..
rm -rf $KERNEL_SRC

# install glibc
tar xvf $SRCROOT/$GLIBC_TAR
cd $GLIBC_SRC
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
rm -rf $GLIBC_SRC

# build Libstdc++
cd $BUILDTMP
tar xvf $SRCROOT/$GCC_TAR
cd $GCC_SRC

tar -xf $SRCROOT/$MPFR_TAR
mv -v $MPFR_SRC mpfr
tar -xf $SRCROOT/$GMP_TAR
mv -v $GMP_SRC gmp
tar -xf $SRCROOT/$MPC_TAR
mv -v $MPC_SRC mpc

for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h -o -name aarch64-linux.h -o -name linux-eabi.h)
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
rm -rf  $GCC_SRC

# build binutils-2
cd $BUILDTMP
tar xvf $SRCROOT/$BINUTILS_TAR
cd $BINUTILS_SRC
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
rm -rf $BINUTILS_SRC

# build gcc-2
cd $BUILDTMP
tar xvf $SRCROOT/$GCC_TAR
cd $GCC_SRC

cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h

case "$UNAMEM" in
		i386|i486|i586|i686|amd64|x86_64)
      tar -xf $SRCROOT/$MPFR_TAR
      mv -v $MPFR_SRC mpfr
      tar -xf $SRCROOT/$GMP_TAR
      mv -v $GMP_SRC gmp
      tar -xf $SRCROOT/$MPC_TAR
      mv -v $MPC_SRC mpc
			;;
		armv7l|armhf|armv8l|aarch64)
      ./contrib/download_prerequisites
			;;
	esac

for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h -o -name aarch64-linux.h -o -name linux-eabi.h)
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
    --enable-languages=c,c++ $GFLAGS

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
rm -rf  $GCC_SRC


