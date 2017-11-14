#!/bin/bash

conf_file="/etc/profile"
script_dir="/var/log/script"
comm='
if [ $UID -ge 500 -o $UID -eq 0 ]; then\n\texec /usr/bin/script -t 2>/var/log/script/$USER-$UID-`date +%Y%m%d%H%M`.date  -a -f -q /var/log/script/$USER-$UIDO-`date +%Y%m%d%H%M`.log\nfi'

if [ -d $script_dir ];then
        chmod 777 $script_dir
else
        mkdir -p ${script_dir} && chmod 777 ${script_dir}
fi

if [ -e $conf_file ];then
        grep -q "${script_dir}" ${conf_file} || \
        echo -en ${comm} >> $conf_file 
fi

. ${conf_file}
