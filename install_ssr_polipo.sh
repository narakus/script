#!/bin/bash

# port:1080, listen:0.0.0.0

tmp_dir=/tmp/$$
tmp_dir="/usr/local"
ssr_url="https://github.com/shadowsocksr-backup/shadowsocksr-libev.git"
polipo_url="https://github.com/jech/polipo.git"

yum install git gcc autoconf libtool automake texinfo \
	 make zlib-devel openssl-devel asciidoc xmlto -y


run_cmds (){
	for cmds in "$@";
	do
		${cmds} >> ${tmp_dir}/install.log 2>&1 || CMDS="fail"
		if [ "${CMDS}" = "fail" ];then
			echo "${cmds} Failed,please read ${tmp_dir}/install.log"
			exit 1
		fi
	done
}

install_ssr() {
	test -e ${tmp_dir} || mkdir -p ${tmp_dir}
	cd ${tmp_dir} && git clone ${ssr_url}
	dirname=`ls -l | grep "^d" | grep "shadowsocksr" | awk '{print $9}'`
	cd ${dirname} && echo -en "\nCompile ${dirname},please wait..."
	./configure >> ${tmp_dir}/install.log 2>&1 || CONFIG="fail"
	if [ "${CONFIG}" = "fail" ];then
		echo -en "configure failed,please read ${tmp_dir}/install.log\n"
		exit 1
	fi
	echo -en "done\nExecuted 'make and make install',please wait..."
	run_cmds 'make' 'make install'
	echo -en "\nInstall shadowsocksr-libev complete.\n"
}


install_polipo() {
	cd ${tmp_dir} && git clone ${polipo_url}
	dirname="polipo"
	cd ${dirname} && git checkout polipo-1.1.1 > /dev/null
	run_cmds 'make all' 'make intsall'
	mkdir -p /etc/polipo
	cat <<EOF > /etc/polipo/config
"logSyslog = true
socksParentProxy = "localhost:1080"
socksProxyType = socks5
logFile = /var/log/polipo.log
logLevel = 4
proxyAddress = "0.0.0.0"
proxyPort = 8123
chunkHighMark = 50331648
objectHighMark = 16384

serverMaxSlots = 64
serverSlots = 16
serverSlots1 = 32"
EOF
	cat <<EOF > /usr/lib/systemd/system/polipo.service
"[Unit]
Description=polipo web proxy
After=network.target

[Service]
Type=simple
WorkingDirectory=/tmp
User=root
Group=root
ExecStart=/usr/local/bin/polipo -c /usr/local/polipo/config
Restart=always
SyslogIdentifier=Polipo

[Install]
WantedBy=multi-user.target"
EOF

systemctl start polipo.service
systemctl enable polipo	


}




