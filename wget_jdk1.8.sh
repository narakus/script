#!/bin/bash

tmp_dir=/tmp/$$

test -e /etc/profile.d/java.sh && exit 1

mkdir ${tmp_dir}

sudo test -d /data/app || sudo mkdir -p /data/app/

cd ${tmp_dir} && wget --continue --no-check-certificate -O jdk-8u191-linux-x64.tar.gz --header "Cookie: oraclelicense=a" http://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.tar.gz

sudo test -d /data/app || mkdir  /data/app

tar xf jdk-8u191-linux-x64.tar.gz -C /data/app/

sudo echo "export JAVA_HOME=/data/app/jdk1.8.0_191
export CLASSPATH=$JAVA_HOME/lib
export PATH=$JAVA_HOME/bin:$PATH" > /etc/profile.d/java.sh

rm -rf ${tmp_dir}
