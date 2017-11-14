#!/bin/bash

usage (){
        program_name=`basename $0`
        echo "Usage: ${program_name} -a 192.168.1.2 -h localhost -g 192.168.1.1 -n 255.255.255.0" 1>&2
        exit 1
}

while getopts :a:h:g:n: opt
do
        case "$opt" in
        a) IPADDR="$OPTARG";;
        h) HOSTNAME="$OPTARG";;
        g) GATEWAY="$OPTARG";;
        n) NETMASK="$OPTARG";;
        *) usage;;
        esac
done

shift $[ $OPTIND - 1 ]

if [ -z "${IPADDR}" -o -z "${HOSTNAME}" -o -z "${GATEWAY}" -o -z "${NETMASK}" ];then
	usage && exit 1
fi

write_ifcfg() {

echo "DEVICE=eth0
TYPE=Ethernet
IPV6INIT=no
BOOTPROTO=static
IPADDR=${IPADDR}
GATEWAY=${GATEWAY}
NETMASK=${NETMASK}" > ${nic_file} && \
echo "setup ifcfg-eth0 complate!!"

}

#setup ifcfg-eth0
mydate=`date +"%Y%m%d"`
nic_file='/etc/sysconfig/network-scripts/ifcfg-eth0'

if [ -e ${nic_file} ];then
	mv "${nic_file}" "${nic_file}${mydate}.bak" && \
	write_ifcfg
else
	write_ifcfg
fi

#setup hostname
name_file='/etc/sysconfig/network'
test -e  ${name_file} && \
sed -i -r "s/(^HOSTNAME=)(.*)/\1${HOSTNAME}/" ${name_file}  && \
echo "setup hostname complate!!"


#repair rulesfiles
rules_file="/etc/udev/rules.d/70-persistent-net.rules"
test -e ${rules_file} && sed -i '/eth0/d;s/eth1/eth0/' ${rules_file} && \
echo "repair fulesfiles complate!!"

#reboot
reboot_time() {
for x in $(seq 5 | sort -nr);
do
	printf  "Will be reboot system after %s second....\r" ${x}
	sleep 1
done
}

reboot_time && reboot 
