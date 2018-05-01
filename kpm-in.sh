# install kpm
cd $BUILDTMP
tar xvf $SCRIPTROOT/$KPM_TAR
cd $KPM_SRC
./configure --prefix=$CROSS
make
make install
cd ..
rm -rf $KPM_SRC
touch $KS$CROSS/var/lib/kpm/status
cp -av $KS$CROSS/Dpkg.pm $KS$CROSS/lib/perl5/5.26.1
cp -arv $KS$CROSS/Dpkg $KS$CROSS/lib/perl5/5.26.1
rm -rf $KS$CROSS/Dpkg $KS$CROSS/Dpkg.pm