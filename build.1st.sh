
# link output folder
mkdir -p $KS$LIBPARENT
ln -sv $CROSS $KS$LIBPARENT$(echo $CROSS|sed -rne "s@$LIBPARENT@@p")

# build tmp system
cd $BUILDTMP
# build binutils-1

tar xvf $SRCROOT/$BINUTILS_TAR
cd $BINUTILS_SRC
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
rm -rf $BINUTILS_SRC

# build gcc-1
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
rm -rf  $GCC_SRC


