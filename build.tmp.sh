
# install Tcl-core
cd $BUILDTMP
tar xvf $SRCROOT/$TCL_TAR
cd $TCL_SRC
ls
cd unix
./configure --prefix=$CROSS
$MAKE $MFLAGS
TZ=UTC $MAKE test
$MAKE install
chmod -v u+w $CROSS/lib/$TCL_LIB
$MAKE install-private-headers
ln -sv $TCL_BIN $CROSS/bin/tclsh
cd ../..
rm -rf $TCL_SRC

# install expect
cd $BUILDTMP
tar xvf $SRCROOT/$EXPECT_TAR
cd $EXPECT_SRC
cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure
./configure --prefix=$CROSS       \
            --with-tcl=$CROSS/lib \
            --with-tclinclude=$CROSS/include
$MAKE $MFLAGS
$MAKE test
$MAKE SCRIPTS="" install
cd ..
rm -rf $EXPECT_SRC

# install DejaGNU
cd $BUILDTMP
tar xvf $SRCROOT/$DEJAGNU_TAR
cd $DEJAGNU_SRC
./configure --prefix=$CROSS
$MAKE install
$MAKE check
cd ..
rm -rf $DEJAGNU_SRC
