#!/bin/bash

tmp_dir=/tmp/$$
mkdir -p ${tmp_dir}
sudo apt-get install build-essential tcl wget -y
cd ${tmp_dir} && wget -c http://download.redis.io/releases/redis-4.0.8.tar.gz
tar -xvf redis-4.0.8.tar.gz;cd redis-4.0.8
make && make install
cd utils;curl -s https://raw.githubusercontent.com/narakus/script/master/install_server.sh | bash
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf
systemctl restart redis_6379
systemctl enable redis_6379

rm -rf  ${tmp_dir}
