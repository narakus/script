#!/bin/bash

#set download server
YUM_SERVER='10.167.210.154'

usage (){
        program_name=`basename $0`
        echo "Usage: ${program_name} -v [1.7|1.8] -p [x86|x64]" 1>&2
        exit 1
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
        wget -q "${url}"  && echo 'done.' || local download='fail'
        if [ "${download}" = "fail" ];then
                echo "download ${url} fail!" 1>&2 && del_tmp
                exit 1
        fi
fi
}

decompress_file () {
local file="$1"
test -f ${file} && tar xzf ${file} || eval "echo ${file} not exsit!;del_tmp;exit 1"
}

install_jdk () {
local jdk_file="${jdk_path}-${jdk_platform}.tar.gz"
local file_url="http://${YUM_SERVER}/software/${jdk_file}"
#cd ${TEMP_PATH}
download_file "${file_url}"
decompress_file "${jdk_file}"


local jdk_install_path="/usr/local/${jdk_path}"
mv "${TEMP_PATH}/${jdk_path}" ${jdk_install_path}

env_path="/usr/local/env"
test -d "${env_path}" || mkdir -p "${env_path}"

jdk_env_profile="${env_path}/jdk.env"
echo "export JAVA_HOME=${jdk_install_path}
export JRE_HOME=${jdk_install_path}
export CLASSPATH=\$CLASSPATH:\$JAVA_HOME/lib:\$JAVA_HOME/jre/lib
export PATH=\$JAVA_HOME/bin:\$JAVA_HOME/jre/bin:\$PATH" > ${jdk_env_profile}

system_user_profile="/etc/profile"
if [ -f "${system_user_profile}" ];then
        grep -E '^#SET JDK ENV' "${system_user_profile}" >/dev/null 2>&1||\
        echo -en "#SET JDK ENV\nsource ${jdk_env_profile}\n" >> "${system_user_profile}" 
else
        echo -en "#SET JDK ENV\nsource ${jdk_env_profile}\n" >> "${system_user_profile}"
fi
}

echo_bye () {
echo "Install ${jdk_path} complete!
JDK Environment:
${jdk_env_profile}"
}

while getopts p:v: opt
do
        case "$opt" in
        p) jdk_platform="$OPTARG";;
        v) jdk_version="$OPTARG";; 
        *) usage;;
        esac
done

shift $[ $OPTIND - 1 ]

if [ -z "${jdk_platform}" -o -z "${jdk_version}" ];then
        usage
fi

echo "${jdk_platform}"|grep -oE 'x86|x64' >/dev/null 2>&1 ||\
eval "echo Error parameters: ${jdk_platform}.Please enter x86 or x64.;usage"

echo "${jdk_version}"|grep -oE '1.7|1.8' >/dev/null 2>&1 ||\
eval "echo Error parameters: ${jdk_version}.Support 1.7 or 1.8 ;usage"

case "${jdk_version}" in
        1.7)
                jdk_path='jdk1.7'
                ;;
        1.8)
                jdk_path='jdk8'
                ;;
        *)
                echo "This script not support jdk ${jdk_version}" 1>&2
                exit 1
                ;;
esac

main () {
TEMP_PATH="/tmp/tmp.$$"
trap "exit 1"           HUP INT PIPE QUIT TERM
trap "rm -rf ${TEMP_PATH}"  EXIT
create_tmp_dir
install_jdk
del_tmp
echo_bye
}

main
