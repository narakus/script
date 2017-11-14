#!/bin/bash

config_bak="/tmp/config_File"
test -d ${config_bak} || mkdir -p ${config_bak}

#backup configfile
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
		test -f ${config_bak}/$(basename $item) || \
		cp ${item} $config_bak
	fi
done

#password time
passwd_times() {
pass_file='/etc/login.defs'

test -f ${pass_file} || exit 1
sed -i 's/\(^PASS_MAX_DAYS\).*/\1   90/' ${pass_file}
sed -i 's/\(^PASS_MIN_DAYS\).*/\1   80/' ${pass_file}
sed -i 's/\(^PASS_MIN_LEN\).*/\1    10/' ${pass_file}
echo "###login.defs###"
grep -E '^PASS_M' ${pass_file}

grep -Eq '^SU_WHEEL_ONLY' ${pass_file} || \
echo "SU_WHEEL_ONLY yes" >> ${pass_file}
}

#password policy
passwd_ploicy() {
login_file='/etc/pam.d/system-auth'
passwd_policy=' retry=3  difok=3 minlen=10 ucredit=-1 lcredit=-2 dcredit=-1 ocredit=-1'
lock_policy='auth        required      pam_tally2.so onerr=fail deny=6 unlock_time=300'

test -f ${login_file} || exit 1
sed -i "s/\(^password.*requisite.*pam_cracklib.so\).*/\1${passwd_policy}/" ${login_file}
echo "###system-auth###"
grep -E '^password.*requisite.*pam_cracklib.so' ${login_file}

grep -Eq '^auth.*pam_tally2.so.*' ${login_file} || \
sed -i "/^auth.*required.*pam_env.so/a${lock_policy}" ${login_file}
grep -E '^auth.*pam_tally2.so.*' ${login_file}
}


#sshd_login_times

sshd_login_times() {
login_times_config='/etc/pam.d/sshd'
sshd_policy='auth       required     pam_tally2.so deny=3 unlock_time=300 even_deny_root root_unlock_time=300'

test -f ${login_times_config} || exit 1
grep -Eq '^auth.*required.*pam_tally2.so' ${login_times_config} || \
sed -i "/#%PAM-1.0/a${sshd_policy}" ${login_times_config}
echo "###pam.d/sshd###"
grep -E '^auth.*required.*pam_tally2.so' ${login_times_config}
}

#disable root login
disable_ssh() {
sshd_config='/etc/ssh/sshd_config'

test -f ${sshd_config} || exit 1
grep -Eq '^PermitRootLogin' ${sshd_config}
if [ $? -ne 0 ];then
	echo "PermitRootLogin no" >> ${sshd_config}
else
	sed 's/^\(PermitRootLogin\).*/\1 no/' ${sshd_config}
fi
s_policy="Ciphers aes128-ctr,aes192-ctr,aes256-ctr\nMACs hmac-sha1,umac-64@openssh.com,hmac-ripemd160"
echo -en ${s_policy} >> ${sshd_config}
echo "###sshd_config###"
grep -E '^PermitRootLogin' ${sshd_config}
grep -E '^Ciphers' ${sshd_config}
grep -E '^MAC' ${sshd_config}
}


#disable su command
disable_su() {
su_config='/etc/pam.d/su'

test -f ${su_config} || exit 1
grep -Eq '^auth.*required.*pam_wheel.so' ${su_config} 
if [ $? -ne 0 ];then
	sed -i 's/^#auth\(.*required.*pam_wheel.so.*\)/auth\1/'  ${su_config}
fi
echo "###pam.d/su###"
grep -E '^auth.*required.*pam_wheel.so' ${su_config}
}

#set timeout
set_timeout() {
profile_config='/etc/profile'

test -f ${profile_config} || exit 1
grep -q "TMOUT" ${profile_config} || \
echo "export TMOUT=300" >> ${profile_config}
echo "###profile ###"
grep 'TMOUT' ${profile_config}
}

#add user

user_add() {
awk -F: '{print $1}' /etc/passwd | grep -Eq '^sa$'
if [ $? -ne 0 ];then
	useradd -s /bin/bash -G wheel -m sa 
	echo 'xdjk2015'| passwd --stdin sa > /dev/null
else
	exit 0
fi
}

modify_sysctl() {

test -f /etc/sysctl.conf || exit 1
grep -Eq '^net.ipv4.tcp_timestamps' /etc/sysctl.conf || \
echo "net.ipv4.tcp_timestamps = 0" >> /etc/sysctl.conf
/sbin/sysctl -p > /dev/null 2>&1
grep -E '^net.ipv4.tcp_timestamps' /etc/sysctl.conf

}

main() {
user_add
passwd_times
passwd_ploicy
disable_ssh
disable_su
set_timeout
sshd_login_times
modify_sysctl
}

main
