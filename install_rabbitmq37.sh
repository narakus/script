#!/bin/bash
set -e

tmp_dir=/tmp/$$
source_erlang="/etc/apt/sources.list.d/erlang.list"
source_rabbitmq="/etc/apt/sources.list.d/rabbitmq-server.list"
plugins="https://dl.bintray.com/rabbitmq/community-plugins/3.7.x/rabbitmq_delayed_message_exchange/rabbitmq_delayed_message_exchange-20171201-3.7.x.zip"

install_erlang21() {

wget -O - 'https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc' | sudo apt-key add -
sudo echo "deb http://dl.bintray.com/rabbitmq/debian xenial erlang-21.x" > ${source_erlang}
sudo apt update && apt install erlang-nox -y

}

install_rabbitmq() {

wget -O - 'https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc' | sudo apt-key add -
sudo test -e ${source_erlang} && rm -f ${source_erlang}
sudo echo "deb https://dl.bintray.com/rabbitmq/debian xenial main" > ${source_rabbitmq}
sudo apt update && apt install rabbitmq-server -y

#install plugins
sudo apt install unzip -y
test -d ${tmp_dir} || mkdir -p ${tmp_dir}
cd ${tmp_dir} && wget ${plugins} 
unzip `basename ${plugins}`
plugins_dir=$(find /usr/lib/rabbitmq/lib/ -type d -name "rabbitmq_server*")
sudo mv rabbitmq_delayed_message_exchange-20171201-3.7.x.ez ${plugins_dir}/plugins/

#enable plugins
sudo rabbitmq-plugins enable rabbitmq_management
sudo rabbitmq-plugins enable rabbitmq_delayed_message_exchange

#set admin passwd
sudo rabbitmqctl add_user admin advance.ai2016
sudo rabbitmqctl set_user_tags admin administrator
sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"

#set started
sudo systemctl enable rabbitmq-server

test -d ${tmp_dir} && rm -rf ${tmp_dir}

}

install_erlang21 && install_rabbitmq

