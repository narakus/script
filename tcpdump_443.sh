#!/bin/bash

runtime=0
mydata=$(date '+%Y%m%d_%H%M%S')
outdir='/root/tcpdump/'

test -d ${outdir} || mkdir -p ${outdir}
test -e /sbin/tcpdump || yum install tcpdump -y >/dev/null 2>&1
nohup /sbin/tcpdump -i any tcp port 22 -vv -n -w ${outdir}${mydata}.dump > /dev/null 2>&1 & 
while((${runtime} < 120));do
    sleep 1;
    let runtime+=1 
done
pgrep tcpdump | xargs kill -15 && exit 0
