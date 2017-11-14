#!/bin/bash

#set download server
YUM_SERVER='10.167.210.154'

usage (){
        program_name=`basename $0`
        echo "Usage: ${program_name} -v [6|7|8] -u USER -d PATH" 1>&2
        exit 1
}

check_system (){
SYSTEM_INFO=`head -n 1 /etc/issue`
case "${SYSTEM_INFO}" in
        'CentOS release 5'*)
                SYSTEM='centos5'
                YUM_SOURCE_NAME='centos5-lan'
                ;;
        'Red Hat Enterprise Linux Server release 5'*)
                SYSTEM='rhel5'
                YUM_SOURCE_NAME='RHEL5-lan'
                ;;
        'Red Hat Enterprise Linux Server release 6'*)
                SYSTEM='rhel6'
                YUM_SOURCE_NAME='RHEL6-lan'
                ;;
        'Oracle Linux Server release 6'*)
                SYSTEM='rhel6'
                YUM_SOURCE_NAME='RHEL6-lan'
                ;;
        'CentOS release 6'*)
                SYSTEM='rhel6'
                YUM_SOURCE_NAME='RHEL6-lan'
                ;;
        'Debian GNU/Linux 6'*)
                SYSTEM='debian6'
                ;;
        'Debian GNU/Linux 7'*)
                SYSTEM='debian7'
                ;;
        *)
                SYSTEM='unknown'
                echo "This script not support ${SYSTEM_INFO}" 1>&2
                exit 1
                ;;
esac
}

create_tmp_dir () {
mkdir -p "${TEMP_PATH}" && cd "${TEMP_PATH}" || local mkdir_dir='fail'
if [ "${mkdir_dir}" = "fail"  ];then
        echo "mkdir ${TEMP_PATH} fail!" 1>&2
        exit 1
fi
}

del_tmp () {
test -d "${TEMP_PATH}" && rm -rf "${TEMP_PATH}"
}

download_file () {
local   url="$1"
local   file=`echo ${url}|awk -F'/' '{print $NF}'`

if [ ! -f "${file}" ]; then
        echo -n "download ${url} ...... "
        wget -q "${url}" -O ${TEMP_PATH}/${file} && echo 'done.' || local download='fail'
        if [ "${download}" = "fail" ];then
                echo "download ${url} fail!" 1>&2 && del_tmp
                exit 1
        fi
fi
}

decompress_file () {
local file="$1"
test -f ${TEMP_PATH}/${file} && tar xzf ${TEMP_PATH}/${file} || eval "echo ${file} not exsit!;del_tmp;exit 1"
}

install_tomcat () {
local tomcat_file="${tomcat_path}.tar.gz"
local file_url="http://${YUM_SERVER}/software/${tomcat_file}"
download_file "${file_url}"
decompress_file "${tomcat_file}"

local tomcat_install_path="${dst_path}"
mv "${TEMP_PATH}/${tomcat_path}" ${tomcat_install_path}
test -d ${tomcat_install_path} && cd ${tomcat_install_path}/${tomcat_path}/webapps && rm -rf ./*
chown $user:$user -R ${dst_path}

}

echo_bye () {
echo "Install ${tomcat_path} complete!"
}


while getopts v:u:d: opt
do
        case "$opt" in
        v) tomcat_version="$OPTARG";; 
        u) user="$OPTARG";; 
        d) dst_path="$OPTARG";;
        *) usage;;
        esac
done

shift $[ $OPTIND - 1 ]

if [ -z "${tomcat_version}" -o -z "$user" -o -z "${dst_path}" ];then
        usage
fi

case "${tomcat_version}" in
        6)
                tomcat_path='apache-tomcat-6.0.48'
                ;;
        7)
                tomcat_path='apache-tomcat-7.0.75'
                ;;
        8)
                tomcat_path='apache-tomcat-8.5.11'
                ;;
        *)
                echo "This script not support ${tomcat_version}" 1>&2
                exit 1
                ;;
esac

main () {
TEMP_PATH="/tmp/tmp.$$"
trap "exit 1"           HUP INT PIPE QUIT TERM
trap "rm -rf ${TEMP_PATH}"  EXIT
check_system
create_tmp_dir
install_tomcat
del_tmp
echo_bye
}

main
