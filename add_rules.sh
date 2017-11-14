#!/bin/bash

other_port=`netstat -ntlp | tail -n +3 | grep -v nginx | grep -v "::" |awk '{print $4}' | awk -F":" '{print $2}'`

backup() {
mydate=`date +%Y%m%d"_"%H%M%S`
conf="/etc/sysconfig/iptables"

test -e ${conf} &&\
cp ${conf} ${conf}${mydate}
echo -en "backup ${conf} complate!\n"

}

init_iptables() {
modprobe ip_tables
modprobe iptable_nat
modprobe ip_nat_ftp
modprobe ip_conntrack
/sbin/iptables -F
/sbin/iptables -X
/sbin/iptables -Z
/sbin/iptables -P INPUT DROP
/sbin/iptables -P FORWARD ACCEPT
/sbin/iptables -P OUTPUT ACCEPT
/sbin/iptables -A INPUT -i lo -j ACCEPT
/sbin/iptables -A OUTPUT -o lo -j ACCEPT
echo -en "init iptables complete!\n"
}

add_other_port() {
for item in ${other_port};do
/sbin/iptables -t filter -A INPUT -p tcp --dport ${item} -j ACCEPT || OTHER='fail'
if [ "${OTHER}" = "fail" ];then
        echo "add rules to accept ${i} port failed!" && exit 1
fi
done
/sbin/iptables -t filter -A INPUT -p tcp  --dport 28080 -j ACCEPT
echo -en "add other port complete!\n"
}

accept_ipaddr() {
echo "10.180.120.101
10.180.120.102
10.180.120.103
10.180.120.104
10.180.120.105
10.180.120.106
10.180.120.107
10.180.120.108
10.180.120.109
10.180.120.110
10.180.120.111
10.180.120.112
10.180.120.113
10.180.120.114
10.180.120.115
10.180.120.116
10.180.120.117
10.180.120.118
10.180.120.119
10.180.120.120
10.180.120.121
10.180.120.122
10.180.120.123
10.180.120.124
10.180.120.125
10.180.120.126
10.180.120.127
10.180.120.128
10.180.120.129
10.180.120.130
10.180.120.131
10.180.120.132
10.180.120.133
10.180.120.134
10.180.120.135
10.180.120.136
10.180.120.137
10.180.120.138
10.180.120.139
10.180.120.140
10.180.120.141
10.180.120.142
10.180.120.143
10.180.120.144
10.180.120.145
10.180.120.146
10.180.120.147
10.180.120.148
10.180.120.149
10.180.120.150
10.180.120.164
10.180.120.165
10.180.120.81
10.180.120.85
10.180.120.86
10.150.33.169
10.150.33.170
10.160.2.155
10.160.2.156
10.160.2.157
10.160.2.171
10.160.2.172
10.160.2.173
10.180.140.54
10.180.140.58
10.180.140.211
10.167.201.22
10.180.110.163
10.180.110.164
10.180.110.180
10.180.110.181
10.180.110.182
10.55.110.182
10.55.110.181" |\
while read line;
do
        for i in $(seq 203 219);
        do
                if [ \( $i -eq 210 \) -o \( $i -eq 211 \) -o \( $i -eq 212 \) ];then
                        continue;
                fi
        /sbin/iptables -t filter -A INPUT -p tcp -s ${line} --dport ${i} -j ACCEPT || NGINX='fail'
        if [ "${NGINX}" = "fail" ];then
        echo "add rules ${line} failed!" && exit 1
        fi
        done
done
}

add_normal() {
/sbin/iptables -t filter -A INPUT -p icmp -j ACCEPT
/sbin/iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -t filter -A INPUT -p tcp -j DROP
/sbin/iptables -t filter -A INPUT -p udp -j DROP
echo -en "add normal rules complate!\n"

}

main() {
backup
init_iptables
add_other_port
accept_ipaddr
add_normal
}

main

/etc/init.d/iptables save
/sbin/chkconfig iptables on
/etc/init.d/iptables restart
