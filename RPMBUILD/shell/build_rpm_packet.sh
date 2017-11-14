#!/bin/bash

BUILD_PATH="./rpmbuild"
BASE_SPEC="${BUILD_PATH}/SPECS/Model-1.0.spec"
BASE_SOURCE="${BUILD_PATH}/SOURCES/Model"

usage (){
        program_name=`basename $0`
        echo "Usage: ${program_name} -n appname -p 8080 -s 18080 -v 1.0" 1>&2
        exit 1
}

while getopts n:p:s:v: opt
do
        case "$opt" in
        n) app_name="$OPTARG";;
        p) http_port="$OPTARG";; 
        s) shutdown_port="$OPTARG";; 
        v) version="$OPTARG";; 
        *) usage;;
        esac
done

shift $[ $OPTIND - 1 ]

if [ -z "${app_name}" -o -z "${http_port}" -o -z "${shutdown_port}" -o -z "${version}" ];then
        usage
fi

if [ ! -e ${BASE_SPEC} -o ! -d ${BASE_SOURCE} ];then
	echo -en "Can't find ${BASE_SPEC} or ${BASE_SOURCES} \n"
	exit 1
fi

full_name=${app_name}"-"${version}
dst_source=$(dirname ${BASE_SOURCE})/${app_name}
dst_spec=$(dirname ${BASE_SPEC})/${full_name}.spec
xml_conf=${dst_source}/conf/server.xml

test -d ${dst_source} && rm -rf ${dst_source}

if [ -e ${dst_spec} ];then
	echo -en "${dst_spec} already exists!\n"
	exit 1
fi

cp -r ${BASE_SOURCE} ${dst_source}&& cp ${BASE_SPEC} ${dst_spec}

sed -i "s/59999/$shutdown_port/g;s/9999/$http_port/g" ${xml_conf} &&\
sed -i "s/Model/$app_name/g;s/1.0/$version/g" ${dst_spec}

cd $(dirname ${dst_source}) ; tar cvf ${full_name}.tar.gz ${app_name} > /dev/null 2>&1

echo -en "Creating ${full_name} project,please wait..."
cd ${BUILD_PATH} ; /usr/bin/rpmbuild -ba ${dst_spec} > /dev/null 2>&1 || build="fail"
if [ "${build}" = "fail" ];then
	echo -en "Failed\n"
	exit 1	
fi
echo -en "done\n"
