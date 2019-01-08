#!/bin/bash

#bash2syslog
test -d /etc/profile.d/ &&\
sudo echo 'PROMPT_COMMAND=$(history -a)
typeset -r PROMPT_COMMAND

function log2syslog
{
   declare command
   command=$BASH_COMMAND
   logger -p local1.notice -t bash2syslog -i -- ${ADVSSH_USERNAME} $USER : $PWD : $command

}
trap log2syslog DEBUG' > /etc/profile.d/rec_his.sh

#his
test -d /etc/profile.d &&\
sudo echo '# History format
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
export HISTTIMEFORMAT' > /etc/profile.d/history_date.sh

#2rsyslog
test -d /etc/rsyslog.d &&\
sudo /bin/echo '#SET Standard timestamp
$template myformat,"%$NOW% %TIMESTAMP:8:15% %HOSTNAME% %syslogtag% %msg%\n"
$ActionFileDefaultTemplate myformat
$template GRAYLOGRFC5424,"<%PRI%>%PROTOCOL-VERSION% %TIMESTAMP:::date-rfc3339% %HOSTNAME% %APP-NAME% %PROCID% %MSGID% %STRUCTURED-DATA% %msg%\n"
#log to syslog server
*.*            @172.21.194.178:514;GRAYLOGRFC5424' > /etc/rsyslog.d/10-graylog.conf

sudo /usr/sbin/service rsyslog restart

#audit
sudo echo > /etc/securetty
sudo sed -i '/user@houyi/d' /home/sysop/.ssh/authorized_keys

#mk agent
sudo /usr/bin/apt update &&\
sudo /usr/bin/apt install check-mk-agent xinetd -y
test -f /etc/xinetd.d/check_mk &&\
sudo sed -r -i 's/disable.*$/disable        = no/' /etc/xinetd.d/check_mk
test -f /etc/xinetd.d/check_mk &&\
sudo sed -r -i 's/#only_from.*$/only_from = 172.21.160.176/' /etc/xinetd.d/check_mk
sudo service xinetd restart

#install nrpe
ls /usr/bin/apt > /dev/null 2>&1 ||\
eval "echo apt not found!;exit 1"

sudo /usr/bin/apt install nagios-nrpe-server xinetd -y ||\
exit 1

sudo service nagios-nrpe-server stop
sleep 1s

test -d /etc/xinetd.d/ &&
sudo echo 'service nrpe
{
        flags           = REUSE
        socket_type     = stream
        port            = 5666
        wait            = no
        user            = nagios
        group           = nagios
        server          = /usr/sbin/nrpe
        server_args     = -c /etc/nagios/nrpe.cfg --inetd
        log_on_failure  += USERID
        disable         = no
        only_from       = 172.21.160.176
}' > /etc/xinetd.d/nrpe

nrpe_config='/etc/xinetd.d/nrpe'

if [ -f "${nrpe_config}" ];then
        sudo sed -r -i 's/log_on_failure.*$/log_type = file \/dev\/null/' ${nrpe_config}
fi

if [ -f /etc/services ];then
        grep -E '^nrpe' /etc/services >/dev/null 2>&1 || sudo echo "nrpe 5666/tcp #NRPE" >> /etc/services
        sudo service xinetd restart
fi

/bin/systemctl list-unit-files|grep enable|grep nrpe &&\
sudo /bin/systemctl disable nagios-nrpe-server.service
sudo /bin/systemctl enable xinetd.service

#modify mk
test -f /etc/xinetd.d/check_mk &&\
sudo sed -r -i 's/#only_from.*$/only_from = 172.21.160.176/' /etc/xinetd.d/check_mk
sudo service xinetd restart

#sysinfo
grep 'cron_sysinfo.sh' /etc/crontab >/dev/null 2>&1 || cron_sysinfo_set='no'
if [ "${cron_sysinfo_set}" = "no" ];then
        sysinfo_shell='/usr/sbin/cron_sysinfo.sh'
                test -f ${sysinfo_shell} && rm -f ${sysinfo_shell}
        wget -q https://raw.githubusercontent.com/June-Wang/github4shell/master/cron_sysinfo.sh -O ${sysinfo_shell} ||\
        echo "Download cron_sysinfo.sh fail!" &&\
        echo "* * * * * root ${sysinfo_shell} > /dev/null 2>&1" >> /etc/crontab
        test -f ${sysinfo_shell} && chmod +x ${sysinfo_shell}
fi
