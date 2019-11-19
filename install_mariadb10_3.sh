#!/bin/bash

#export DEBIAN_FRONTEND=noninteractive
#debconf-set-selections <<< "mariadb-server-10.3 root_password password 123456"
#debconf-set-selections <<< "mariadb-server-10.3 root_password_again password 123456"
#debconf-set-selections <<< "mariadb-server-10.3 mysql-server/root_password password 123456"
#debconf-set-selections <<< "mariadb-server-10.3 mysql-server/root_password_again password 123456"

#sudo apt-get install software-properties-common -y
#sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
#sudo add-apt-repository 'deb [arch=amd64,arm64,i386,ppc64el] http://mariadb.mirror.anstey.ca/repo/10.3/ubuntu xenial main'

test -d /data || mkdir /data
cd /data/
wget https://downloads.mariadb.com/MariaDB/mariadb-10.3.20/repo/ubuntu/mariadb-10.3.20-ubuntu-xenial-amd64-debs.tar
tar xf mariadb-10.3.20-ubuntu-xenial-amd64-debs.tar
cd /data/ mariadb-10.3.20-ubuntu-xenial-amd64-debs/ && ./setup_repository

sudo apt update
sudo apt install mariadb-server -y

test -e /etc/mysql/my.cnf && mv /etc/mysql/my.cnf /etc/mysql/my.cnf_$(date "+%Y%m%d")

mkdir -p /data/{log/mariadb,mariadb} ; chown mysql.mysql /data/{mariadb,log/mariadb}

echo "[client]
port		= 3306
socket		= /var/run/mysqld/mysqld.sock
[mysqld_safe]
socket		= /var/run/mysqld/mysqld.sock
nice		= 0
[mysqld]
init_connect='SET collation_connection = utf8mb4_unicode_ci'
init_connect='SET NAMES utf8mb4'
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
skip-character-set-client-handshake
skip-host-cache
skip-name-resolve
log_slave_updates  = 1
log-error=/data/log/mariadb/error.log
user		= mysql
pid-file	= /var/run/mysqld/mysqld.pid
socket		= /var/run/mysqld/mysqld.sock
port		= 3306
basedir		= /usr
datadir		= /data/mariadb
tmpdir		= /tmp
lc_messages_dir	= /usr/share/mysql
lc_messages	= en_US
skip-external-locking
bind-address		= 0.0.0.0
max_connections		= 1000
connect_timeout		= 3600
wait_timeout		= 86400
max_allowed_packet	= 16M
thread_cache_size       = 128
sort_buffer_size	= 4M
bulk_insert_buffer_size	= 16M
tmp_table_size		= 32M
max_heap_table_size	= 32M
myisam_recover_options = BACKUP
key_buffer_size		= 128M
table_open_cache	= 400
myisam_sort_buffer_size	= 512M
concurrent_insert	= 2
read_buffer_size	= 2M
read_rnd_buffer_size	= 1M
query_cache_limit		= 128K
query_cache_size		= 64M
log_warnings		= 2
slow_query_log_file	= /data/log/mariadb/mariadb-slow.log
long_query_time = 10
log_slow_verbosity	= query_plan
server-id		= 2
log_bin			= /data/mariadb/mariadb-bin
log_bin_index		= /data/mariadb/mariadb-bin.index
expire_logs_days	= 21
max_binlog_size         = 100M
default_storage_engine	= InnoDB
innodb_buffer_pool_size	= 20G
innodb_log_buffer_size	= 8M
innodb_file_per_table	= 1
innodb_open_files	= 400
innodb_io_capacity	= 400
innodb_flush_method	= O_DIRECT
[galera]
[mysqldump]
quick
quote-names
max_allowed_packet	= 16M
[mysql]
[isamchk]
key_buffer		= 16M
!includedir /etc/mysql/conf.d/
" > /etc/mysql/my.cnf

mysql_install_db --datadir=/data/mariadb/ --user=mysql
systemctl restart mariadb
systemctl enable mariadb
