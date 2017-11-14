#!/bin/bash

mypath="/data/logs/nginx"
mkdir ~/sumlog

cp ${mypath}/tou.zeasn.tv_ssl.access.log-20170927.gz ~/sumlog/
cd ~/sumlog && gzip -d tou.zeasn.tv_ssl.access.log-20170927.gz

cat ${mypath}/tou.zeasn.tv_ssl.access.log >> ~/sumlog/tou.zeasn.tv_ssl.access.log-20170927
