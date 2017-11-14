#!/bin/bash

#dns server
dns_server='192.168.254.253'

#yum server
yum_server='yum.server.local'

#ntp server
ntp_server='ntp.server.local'

system_info=`head -n 1 /etc/issue`
case "${system_info}" in
        'CentOS release 5'*)
                system='centos5'
                yum_source_name='centos5-lan'
                ;;
        'Red Hat Enterprise Linux Server release 5'*)
                system='rhel5'
                yum_source_name='RHEL5-lan'
                ;;
        'Red Hat Enterprise Linux Server release 6'*)
                system='rhel6'
                yum_source_name='RHEL6-lan'
                ;;
        *)
                system='unknown'
                echo "This script not support ${system_info}" 1>&2
                exit 1
                ;;
esac

mark_file="/etc/init_${system}.info"

[ -f "${mark_file}" ] && exit 1

#set time
mydate=`date -d now +"%Y%m%d%H%M%S"`

#add to dns
test -f /etc/resolv.conf && echo "nameserver ${dns_server}" > /etc/resolv.conf

yum='yum --skip-broken --nogpgcheck'

$yum install -y wget rsync lftp vim >/dev/null 2>&1 || eval "echo YUM Failed!;exit 1"

#set ntp
$yum -y install ntp >/dev/null 2>&1 || install_ntp='fail'
if [ "${install_ntp}" = "fail" ];then
        echo "yum fail! ntp install fail!" 1>&2
        exit 1
else
        grep 'ntpdate' /etc/crontab >/dev/null 2>&1 || ntp_set='no'
        if [ "${ntp_set}" = "no" ];then
                echo "*/15 * * * * root ntpdate ${ntp_server} > /dev/null 2>&1" >> /etc/crontab
                service crond restart
        fi
fi

#set ulimit
grep -E '^ulimit.*' /etc/rc.local >/dev/null 2>&1 || echo "ulimit -SHn 4096" >> /etc/rc.local
limit_conf='/etc/security/limits.conf'
grep -E '^#-=SET Ulimit=-' ${limit_conf} >/dev/null 2>&1 ||set_limit="no"
if [ "${set_limit}" = 'no' ];then
test -f ${limit_conf} && echo '
#-=SET Ulimit=-
* soft nofile 4096
* hard nofile 65536
' >> ${limit_conf}
fi
nproc_conf='/etc/security/limits.d/90-nproc.conf'
grep -Eq '^#-=SET Nproc=-' ${nproc_conf} ||set_nproc="no"
if [ "${set_nproc}" = 'no' ];then
test -f ${nproc_conf} && echo '
app          soft    nproc     40960
' >> ${nproc_conf}
fi

#disable ipv6
keys=('alias net-pf-10 off' 'alias ipv6 off' 'options ipv6 disable=1')
conf='/etc/modprobe.d/disable_ipv6.conf'
for key in "${keys[@]}"
do
   echo "${key}" >> ${conf}
done


/sbin/chkconfig --list|grep 'ip6tables' >/dev/null 2>&1 && /sbin/chkconfig ip6tables off
echo "ipv6 is disabled!"

#disable selinux
if [ -f "/etc/selinux/config" ];then
        cp /etc/selinux/config /etc/selinux/config.${mydate}
        sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
        echo "selinux is disabled,you must reboot!" 1>&2
fi

#vim
sed -i "8 s/^/alias vi='vim'/" /root/.bashrc
#echo 'syntax on' > /root/.vimrc
echo "alias vi='vim'"  >> /etc/profile.d/vim_alias.sh
grep -E '^set ts=4' /etc/vimrc >/dev/null 2>&1 ||\
echo "set nocompatible
set ts=4
set backspace=indent,eol,start
syntax on" >> /etc/vimrc

#init_ssh
ssh_cf="/etc/ssh/sshd_config"
if [ -f "${ssh_cf}" ];then
        sed -i "s/#UseDNS yes/UseDNS no/;s/^GSSAPIAuthentication.*$/GSSAPIAuthentication no/" $ssh_cf
        service sshd restart
echo "init sshd ok."
else
        echo "${ssh_cf} not find!"
        exit 1
fi

#tunoff services
chkconfig --list|awk '/:on/{print $1}'|\
grep -E 'NetworkManager|rpcbind|portreserve|autofs|auditd|cpuspeed|postfix|ip6tables|mdmonitor|pcscd|iptables|bluetooth|nfslock|portmap|ntpd|cups|avahi-daemon|yum-updatesd|sendmail'|\
while read line
do
        chkconfig "${line}" off
        service "${line}" stop >/dev/null 2>&1
        echo "service ${line} stop"
done
echo "init service ok."

#rm cron job
for cron_file in /etc/cron.daily/makewhatis.cron /etc/cron.weekly/makewhatis.cron /etc/cron.daily/mlocate.cron
do
        test -e ${cron_file} && chmod -x ${cron_file}
done

#close ctrl+alt+del
test -e /etc/inittab &&\
sed -i "s/ca::ctrlaltdel:\/sbin\/shutdown -t3 -r now/#ca::ctrlaltdel:\/sbin\/shutdown -t3 -r now/" /etc/inittab

echo "init ${system} ok" > ${mark_file} && exit 0
