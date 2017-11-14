#!/bin/bash

httpserver="http://10.167.210.154/"
packget="cronolog-1.6.2.tar.gz"
tmp_dir="/tmp/tmp.$$"

test -d ${tmp_dir} || mkdir -p ${tmp_dir}

download (){
        cd ${tmp_dir} && echo -en "Download cronlog,please wait..."
        wget  ${httpserver}"software/"${packget} > /dev/null 2>&1 || WGET="fail"
        if [ "${wget}" = "fail" ];then
                echo -en "\ndownload ${packget} Failed!\n"
                exit 1
        fi
        echo -en "done"
}

run_cmds (){
        for cmds in "$@";
        do
                ${cmds} >> /dev/null 2>&1 || CMDS="fail"
                if [ "${CMDS}" = "fail" ];then
                        echo "${cmds} Failed!"
                        exit 1
                fi
        done
}

install_cronlog (){
        cd ${tmp_dir}
        packname=`ls | grep -i cronolog`
        tar xf ${packname}
        dirname=`ls -l | grep "^d"| awk '{print $9}'`
        cd ${dirname} && echo -en "\nCompile ${dirname},please wait..."
        ./configure  > /dev/null 2>&1 || CONFIG="fail"
        if [ "${CONFIG}" = "fail" ];then
                echo -en "configure failed!\n"
                exit 1
        fi
        echo -en "done\nExecuted 'make and make install',please wait..."
        run_cmds 'make' 'make install'
        del_tmp
        echo -en "\nInstall ${dirname} complete.\n"
}

del_tmp (){
        if [ -d ${tmp_dir} ];then
                rm -rf ${tmp_dir}
        fi
}

main() {
download
install_cronlog
}

main
