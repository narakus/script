ʹ��cobbler��Ҫ�޸����¼��

/etc/hosts
10.8.10.250     cobbler.server.local cobbler

/etc/cobbler/dhcp.template
/etc/cobbler/dnsmasq.template 
/etc/cobbler/setting 

���ݱ��������޸����ϼ��������ļ�


�����µ�iso�������
mount -o loop /root/CentOS-7-x86_64-DVD-1503-01.iso /media/
cobbler import --arch=x86_64 --path=/media/  --name=CENTOS7-x86_64

�޸�ks�ļ�����
cobbler profile edit --name CENTOS7-x86_64 --kickstart=/var/lib/cobbler/kickstarts/custom/CENTOS7_NORMAL.ks

ͬ������
cobbler sync
