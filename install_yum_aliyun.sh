#!/bin/bash

yum_path="/etc/yum.repos.d"
aliyun="http://mirrors.aliyun.com/repo"

#system_info=`head -n 1 /etc/issue`
system_info=`head -n 1 /etc/redhat-release`

case "${system_info}" in
        'CentOS release 5'*)
                system='centos5'
                ;;
        'CentOS release 6'*)
                system='centos6'
                ;;
        'CentOS Linux release 7'*)
                system='centos7'
                ;;
        'Red Hat Enterprise Linux Server release 5'*)
                system='rhel5'
                ;;
        'Red Hat Enterprise Linux Server release 6'*)
                system='rhel6'
                ;;
        *)
                system='unknown'
                echo "This script not support ${system_info}" 1>&2
                exit 1
                ;;
esac

install_aliyun() {

mydate=$(date +%Y%m%d-%H:%M)
system_version=$(echo "${system}"| egrep -o '[4-7]')
yum_name="Centos-${system_version}.repo"
epel_name="epel-${system_version}.repo"

find ${yum_path} -type f  | xargs -i mv {} {}-${mydate}
if [ $? -eq 0 ];then
        echo -en "Install ${yum_name}..."
        wget -O ${yum_path}/${yum_name} ${aliyun}/${yum_name} > /dev/null 2>&1 && \
        eval sed -i 's/\$releasever/${system_version}/g' ${yum_path}/${yum_name}
        echo -en "complete!\nInstall ${epel_name}..."
        wget -O ${yum_path}/${epel_name} ${aliyun}/${epel_name} >/dev/null 2>&1 
        yum clean all > /dev/null 2>&1 && echo -en "complete!\n"
        echo "yum ${system} ok" >> ${mark_file} && exit 0
fi
}

mark_file="/etc/init_${system}.info"

if [ -f "${mark_file}" ];then
        grep -q 'yum' ${mark_file} && \
        eval "echo 'Yum is already init!!';exit 1" || install_aliyun
else
        install_aliyun
fi
