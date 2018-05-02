mkdir -pv $KS/{dev,proc,sys,run}
mkdir -pv $KS/{bin,sbin,etc,usr}
mkdir -pv $KS/usr/{bin,sbin}

mknod -m 600 $KS/dev/console c 5 1
mknod -m 666 $KS/dev/null c 1 3
cat > $KS/sbin/init << EOF
#!/bin/bash
TERM="$TERM"
PS1='\u:\w\$ '
PATH=/bin:/usr/bin:/sbin:/usr/sbin:$CROSS/bin:$CROSS/sbin
HOME=/root
export TERM PS1 PATH HOME
mount -vt devtmpfs devtmpfs /dev
mount -vt proc proc /proc
mount -vt sysfs sysfs /sys
mkdir /dev/pts
mount -vt devpts devpts /dev/pts
mount -vt tmpfs tmpfs /run
mount -vt tmpfs tmpfs /tmp
clear
exec /bin/bash --login +h 
EOF

chmod 0777 $KS/sbin/init
ln -s /sbin/init $KS/init

cat > $KS/sbin/setup.sh << EOF
#!/tool/bin/bash
mkdir -pv /{dev,proc,sys}
mkdir -pv /{boot,etc/{opt,sysconfig},home,lib/firmware,mnt,opt}
mkdir -pv /{media/{floppy,cdrom},sbin,srv,var}
install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp
mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -v  /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -v  /usr/libexec
mkdir -pv /usr/{,local/}share/man/man{1..8}

case $(uname -m) in
 x86_64) ln -sv lib /lib64
         ln -sv lib /usr/lib64
         ln -sv lib /usr/local/lib64 ;;
esac

mkdir -v /var/{log,mail,spool}
ln -sv /run /var/run
ln -sv /run/lock /var/lock
mkdir -pv /var/{opt,cache,lib/{color,misc,locate},local}

ln -sv $CROSS/bin/{bash,cat,echo,pwd,stty} /bin
ln -sv $CROSS/bin/perl /usr/bin
ln -sv $CROSS/lib/libgcc_s.so{,.1} /usr/lib
ln -sv $CROSS/lib/libstdc++.so{,.6} /usr/lib
sed 's$CROSS/usr/' $CROSS/lib/libstdc++.la > /usr/lib/libstdc++.la
ln -sv bash /bin/sh

ln -sv /proc/self/mounts /etc/mtab
touch /var/log/{btmp,lastlog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664 /var/log/lastlog
chmod -v 600 /var/log/btmp
rm -rf $KS/sbin/setup.sh
EOF

cat > $KS/etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF
chmod 0644 $KS/etc/passwd

cat > $KS/etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
systemd-journal:x:23:
input:x:24:
mail:x:34:
nogroup:x:99:
users:x:999:
EOF
chmod 0644 $KS/etc/group

cat > $KS/etc/issue <<EOF
KSLinux 18.04 LTS (Package Build Enviroment) \n \l
EOF
chmod 0644 $KS/etc/issue

chroot "$KS" $CROSS/bin/env -i \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='\u:\w\$ '              \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:$CROSS/bin \
    $CROSS/bin/bash /sbin/setup.sh
