#!/bin/bash

cat $1 |\
while read cobbler_name my_mac my_ip my_gw my_profile;
do

        #cobbler system add --name=${cobbler_name} --mac=${my_mac} --ip-address=${my_ip} --subnet=255.255.255.0 --gateway=${my_gw} --interface=eth0 --static=1 --profile=${my_profile} --hostname=${cobbler_name} --netboot-enabled=true --name-servers="${my_dns}"
        cobbler system add --name=${cobbler_name} --mac=${my_mac} --ip-address=${my_ip} --subnet=255.255.255.0 --gateway=${my_gw} --interface=eth0 --static=1 --profile=${my_profile} --hostname=${cobbler_name} --netboot-enabled=true
        if [ $? -eq 0 ];then
                echo -en "\ncreate ${cobbler_name} success!\n"
        fi
done 
