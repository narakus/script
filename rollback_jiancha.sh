#!/bin/bash

config_file="/tmp/config_File"
test -d ${config_file} || echo "No such file."

file_list="login.defs  profile  sshd_config  su  system-auth sshd sysctl.conf"
for i in $file_list;
do
	test -e ${config_file}/$i || TEST="FAIL"
	if [ "${TEST}" = "FAIL" ];then
		echo "no find $i configfile" && exit 1
	fi
done

my_dirs=(
	'/etc/login.defs'
	'/etc/profile'
	'/etc/ssh/sshd_config'
	'/etc/pam.d/su'
	'/etc/pam.d/system-auth'
	'/etc/pam.d/sshd'
	'/etc/sysctl.conf'
)

for item in "${my_dirs[@]}"
do
	if [ -e "${item}" ];then
		rm -r ${item} && \
	    mv  ${config_file}/$(basename ${item}) $(dirname ${item})/
		echo -en "recover $item/\n"
	else
		echo "no find config files." && exit 1
	fi
done

/sbin/sysctl -p > /dev/null 2>&1 
rm -rf ${config_file}
userdel -r sa
/etc/init.d/sshd reload
