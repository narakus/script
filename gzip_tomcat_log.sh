#!/bin/bash

mydate=`date +%Y-%m-%d -d "-3 day"`
src="/usr/local/apache-tomcat-8.0.28/logs"
dst="/DJR/log/api-phone/68"

test -d ${dst}/${mydate} || mkdir -p ${dst}/${mydate}
filelist=$(find ${src} -type f -name "*.log" -o -name "*.txt" -o -name "catalina.out* ! -name "*.gz" " | grep ${mydate})

for myfile in ${filelist};do
        gzipname=$(basename ${myfile})".gz"
        gzip ${myfile}  && \
        mv ${src}/${gzipname} ${dst}/${mydate}
done
