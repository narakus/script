#!/bin/bash
set -e

tmp_dir=/tmp/$$
mysql_deb="https://repo.mysql.com//mysql-apt-config_0.8.10-1_all.deb"

export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-server select mysql-5.7'
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/tools-component select mysql-tools'
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/repo-distro select ubuntu'
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-preview select '
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-tools select '
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/repo-url select http://repo.mysql.com/apt'
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/unsupported-platform select abort'
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/repo-codename select xenial'
debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-product select Ok'
debconf-set-selections <<< 'mysql-server root_password password '
debconf-set-selections <<< 'mysq-server root_password_again password '

test -d ${tmp_dir} || mkdir -p ${tmp_dir}
cd ${tmp_dir} && wget ${mysql_deb};dpkg -i `basename ${mysql_deb}`

sudo apt update && apt-get install mysql-server -y

sed -i 's/\/var\/lib\/mysql\//\/data\/mysql\//' /etc/apparmor.d/usr.sbin.mysqld
systemctl reload apparmor.service

mkdir -p /data/mysql;chown mysql.mysql /data/mysql

sed -i 's/^\(datadir\s*=\).*/\1 \/data\/mysql/' /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i -r 's/(^bind-address.*=).*/\1 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

echo 'character-set-server=utf8mb4
collation-server=utf8mb4_general_ci
' >> /etc/mysql/mysql.conf.d/mysqld.cnf

mysqld --initialize-insecure --datadir=/data/mysql/ --user=mysql

systemctl restart mysql.service
systemctl enable mysql.service

test -d ${tmp_dir} && rm -rf ${tmp_dir}
