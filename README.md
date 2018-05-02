# KSLinux

A Linux Distribution Based on GNU/Linux with Following extra packages:<br/>
Kurosawa Package Manager (KPM) [conflicts: dpkg]<br/>
Kuroasawa Package Toolset (KPT) [conflicts: apt]<br/>
Supported Architecture: i386(i686) amd64(x86-64) armhf aarch64(arm64)

KPM

---------
Install Packages: kpm -i xxx.kpm<br/>
Remove Packages: kpm -r xxx<br/>
Purge Packages: kpm -p xxx<br/>
Build Packages via kpm-pkg: kpm-pkg -b /opt/xxx xxx.kpm<br/>
<br/>

KPT

---------
Update Package List: kpt update<br/>
Install Packages: kpt install xxx<br/>
Remove Packages: kpt remove xxx<br/>
Purge Packages: kpm purge xxx<br/>
Update Packages: kpm upgrade xxx<br/>

Note for conflicts

---------
You can use dpkg and apt as usual like debian or ubuntu.<br/>
But KSLinux is not based on debian or ubuntu series.<br/>

Build Information

---------
1. Download Source code from:<br/>
http://www.linuxfromscratch.org/lfs/view/stable/<br/>
http://www.linuxfromscratch.org/blfs/view/stable/<br/>
https://www.gnu.org/<br/>
https://packages.debian.org/<br/>
<font color="blue">
**WARNING: Other version not tested**
</font><br/>
2. using these commands to check your enviroment:<br/>
./configure<br/>
it will create makefile if check test complete successfully<br/>
3. Run following command to build<br/>
make<br/>
<font color="red">**ERROR: DO NOT RUN AS ROOT**</font><br/>
<font color="blue">**NOTE: KSLinux has not been compiled completely, please don't use KSLinux in production environments.**</font><br/>
<br/>
Current Status:
Last Compiled: temporary system for building release packages (tmp_system)
Next Compile: zlib1g for temporary system (tmp_system)
