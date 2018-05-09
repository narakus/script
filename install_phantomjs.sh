#!/bin/bash

install_path="/usr/local/"
download_url="https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2"

yum -y install gcc gcc-c++ make flex bison gperf ruby \
       openssl-devel freetype-devel fontconfig-devel libicu-devel sqlite-devel \
       libpng-devel libjpeg-devel wget

cd ${install_path} && wget ${download_url}

gzfile=$(ls | grep "phantomjs*.gz")

tar xf ${gzfile} && rm -f ${gzfile}

echo "PHANTOMJS=/usr/local/phantomjs-2.1.1-linux-x86_64" >> /etc/profile

old_str=$(grep '^PATH=' /etc/profile|tail -n 1)

sed 's#\('$old_str'\)#\1:$PHANTOMJS/bin#' /etc/profile

source /etc/profile
