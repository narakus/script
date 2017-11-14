#!/bin/bash

aliyun_url="mirrors.aliyun.com"
ping -c 4 ${aliyun_url} > /dev/null 2>&1 || fail='FAIL'
if [ "${fail}" = "FAIL" ];then
        echo -en "\nInstall salt-minion failed!\n"
        exit 1
else
        echo -en "Install salt-minion..."
        yum install salt-minion -y > /dev/null || YUM='FAIL'
        if [ "${YUM}" = "FAIL" ];then
        echo "failed!\n" && exit 1
        else
                sed -i 's/^#master: salt/master: salt.server.local/' /etc/salt/minion && \
                service salt-minion restart > /dev/null 
                echo -en "compilete!\n"
        fi
fi

