# install kpm
cd $BUILDTMP
tar xvf $SCRIPTROOT/$KPM_TAR
cd $KPM_SRC
./configure --prefix=$CROSS
make
make install
cd ..
rm -rf $KPM_SRC
