使用cobbler需要修改以下几项：

/etc/hosts
10.8.10.250     cobbler.server.local cobbler

/etc/cobbler/dhcp.template
/etc/cobbler/dnsmasq.template 
/etc/cobbler/setting 

根据本地网络修改以上几个配置文件


导入新的iso镜像操作
mount -o loop /root/CentOS-7-x86_64-DVD-1503-01.iso /media/
cobbler import --arch=x86_64 --path=/media/  --name=CENTOS7-x86_64

修改ks文件配置
cobbler profile edit --name CENTOS7-x86_64 --kickstart=/var/lib/cobbler/kickstarts/custom/CENTOS7_NORMAL.ks

同步配置
cobbler sync
