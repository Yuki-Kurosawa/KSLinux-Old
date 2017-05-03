
# link output folder
mkdir -p $KS$LIBPARENT 2>$OUTPUT 1>$OUTPUT
ln -sv $CROSS $KS$LIBPARENT$(echo $CROSS|sed -rne "s@$LIBPARENT@@p") 2>$OUTPUT 1>$OUTPUT

# build tmp system
ALL=2
OK=0
THIS='Build freestanding gcc'

# build binutils-1
cd $BUILDTMP 2>$OUTPUT 1>$OUTPUT
SHOW_MIXPROGRESS 'Extracting Binutils' 7
tar xvf $SRCROOT/$BINUTILS_TAR 2>$OUTPUT 1>$OUTPUT

if [ $? -ne 0 ];then
  SHOW_MIXPROGRESS 'Extracting Binutils' 10
  exit 1
else
  SHOW_MIXPROGRESS 'Extracting Binutils' 0
fi

cd $BINUTILS_SRC 2>$OUTPUT 1>$OUTPUT
mkdir -v build 2>$OUTPUT 1>$OUTPUT
cd build 2>$OUTPUT 1>$OUTPUT

SHOW_MIXPROGRESS 'Configure Binutils' 7
../configure --prefix=$CROSS            \
             --with-sysroot=$LFS        \
             --with-lib-path=$CROSS/lib \
             --target=$LFS_TGT          \
             --disable-nls              \
             --disable-werror 2>$OUTPUT 1>$OUTPUT

if [ $? -ne 0 ];then
  SHOW_MIXPROGRESS 'Configure Binutils' 10
  exit 1
else
  SHOW_MIXPROGRESS 'Configure Binutils' 0
fi

SHOW_MIXPROGRESS 'Configure Binutils' 0 'Build Binutils' 7
$MAKE $MFLAGS 2>$OUTPUT 1>$OUTPUT

if [ $? -ne 0 ];then
  SHOW_MIXPROGRESS 'Configure Binutils' 0 'Build Binutils' 10
  exit 1
else
  SHOW_MIXPROGRESS 'Configure Binutils' 0 'Build Binutils' 0
fi
case $(uname -m) in
  x86_64) mkdir -v $CROSS/lib && ln -sv lib $CROSS/lib64 ;;
esac

SHOW_MIXPROGRESS 'Configure Binutils' 0 'Build Binutils' 0 'Install Binutils' 7
$MAKE $MFLAGS install

if [ $? -ne 0 ];then
  SHOW_MIXPROGRESS 'Configure Binutils' 0 'Build Binutils' 0 'Install Binutils' 10
  exit 1
else
  SHOW_MIXPROGRESS 'Configure Binutils' 0 'Build Binutils' 0 'Install Binutils' 0
fi
cd ../../ 2>$OUTPUT 1>$OUTPUT
rm -rf $BINUTILS_SRC 2>$OUTPUT 1>$OUTPUT

# build gcc-1
cd $BUILDTMP
tar xvf $SRCROOT/$GCC_TAR
cd $GCC_SRC

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
    --disable-libmudflap                           \
    --enable-languages=c,c++ $GFLAGS

$MAKE $MFLAGS
$MAKE $MFLAGS install
cd ../../
rm -rf  $GCC_SRC


