#!/bin/bash

need_lib="gcc python-devel readline-devel zlib-devel zlib openssl-devel patch "
install_home="/usr/local/python27"
tmp_dir="${install_home}/tmp"
download_file='https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz'
pip_url="https://bootstrap.pypa.io/get-pip.py"

check_lib (){
	for item in ${need_lib};
	do
		rpm -q ${item} > /dev/null 2>&1
	if [ $? -ne 0 ];then
		yum install ${item} -y || YUM='fail'
		if [ "${YUM}" = "fail" ];then
			echo "install ${item} faild,plz check yum source!"
			exit 1
		fi
	fi
	done
	echo "Check lib complete"
}

mkdir_dir (){
	mkdir -p ${install_home} > /dev/null 2>&1
	if [ $? -ne 0 ];then
		echo "Mkdir ${install_home} filed!"
		exit 1
	fi
	mkdir -p ${tmp_dir} && touch ${install_home}/install.log
	echo "Mkdir complete."
}

download (){
	cd ${tmp_dir} && echo -en "Download python27,please wait..."
	wget -t 2 -o ${install_home}/install.log ${download_file} || WGET="fail"
	if [ "${wget}" = "fail" ];then
		echo -en "\ndownload ${download_file} Failed!\n"
		exit 1
	fi
	echo -en "done"
}

run_cmds (){
	for cmds in "$@";
	do
		${cmds} >> ${install_home}/install.log 2>&1 || CMDS="fail"
		if [ "${CMDS}" = "fail" ];then
			echo "${cmds} Failed,please read ${install_home}/install.log"
			exit 1
		fi
	done
}


install_python27 (){
	filename=`ls | grep -i "python"`
	tar -zxf ${filename}
	dirname=`ls -l | grep "^d"| awk '{print $9}'` 
	cd ${dirname} && echo -en "\nCompile ${dirname},please wait..."
	./configure --prefix=${install_home} --enable-shared >> ${install_home}/install.log 2>&1 || CONFIG="fail"
	if [ "${CONFIG}" = "fail" ];then
		echo -en "configure failed,please read ${install_home}/install.log\n"
		exit 1
	fi
	echo -en "done\nExecuted 'make and make install',please wait..."
	run_cmds 'make' 'make install'
	del_tmp
	echo -en "\nInstall python2.7 complete.\n"
}

check_version (){
	python -V > /tmp/version.txt 2>&1
	old_version=`cat /tmp/version.txt`
	v=`cat /tmp/version.txt | awk -F "." '{print $2}'`
	if [ $v = "7" ];then
		echo "The old version is ${old_version##Python}, Don't need install!"
		exit 0
	fi
}

add_env (){
	python_path=`which python`
	install_user=`whoami`
	mv ${python_path} ${python_path%python}python_old >> ${install_home}/install.log 2>&1 || MV="fail"
	if [ "${MV}" = "fail" ];then
		echo -en "\nChange old version failed,read ${install_home}/install.log\n"
		exit 1
	fi
	ln -s ${install_home}/bin/python2.7 ${python_path}
	sed -i '/^PATH/{s/$/:\/usr\/local\/python27\/bin/}' ~/.bash_profile >> ${install_home}/install.log 2>&1
	if [ $? -eq 0 ];then
		echo "Change env complete."
		. ~/.bash_profile
		sed -i 's/python/python_old/' /usr/bin/yum && echo "Repaired yum tools"
	else
		echo "Change env failed"
		exit 1
	fi
}

install_piptools (){
	cd ~ && echo "Te be install pip tools,please wait..."
	curl ${pip_url} | python 
	if [ $? -ne 0 ];then
		echo "Install pip tools failed!!"
		exit 1
	fi
}

install_ansible (){
	echo -en "\nInstall ansible tools,please wait..."
	pip install ansible >> ${install_home}/install.log 2>&1 
	if [ $? -ne 0 ];then
		echo -en "\nInstall ansible failed!!\n"
		exit 1
	fi
	echo -en "done\nThe installation is complete!!!\n"
}

repair_lib () {
        test -d ${install_home}/lib && \
	cp ${install_home}/lib/libpython2.7.so.1.0 /usr/local/lib && \
	ln -s /usr/local/lib/libpython2.7.so.1.0 /usr/local/lib/libpython2.7.so && \
	echo "/usr/local/lib/" >> /etc/ld.so.conf
	/sbin/ldconfig
}

add_tab (){

echo "#!/usr/bin/python
           
import sys   
import readline   
import rlcompleter   
import atexit   
import os    
readline.parse_and_bind('tab: complete')   
histfile = os.path.join(os.environ['HOME'], '.pythonhistory')   
try:   
    readline.read_history_file(histfile)   
except IOError:   
    pass   
atexit.register(readline.write_history_file, histfile)   
           
del os, histfile, readline, rlcompleter" > ${install_home}/bin/tab.py

chmod +x ${install_home}/bin/tab.py
sed -i -e '/^PATH/a\'"$install_home"'\/bin\/tab.py' ~/.bash_profile
. ~/.bash_profile

}



del_tmp (){
	if [ -d ${tmp_dir} ];then
		rm -rf ${tmp_dir}
	fi
}

main (){
check_version
mkdir_dir
check_lib
download
install_python27
repair_lib
add_env
install_piptools
#install_ansible
add_tab
}

main
