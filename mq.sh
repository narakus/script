#!/bin/bash
set -e

tmp_dir=/tmp/$$
source_erlang="/etc/apt/sources.list.d/erlang.list"
source_rabbitmq="/etc/apt/sources.list.d/rabbitmq-server.list"
plugins="https://dl.bintray.com/rabbitmq/community-plugins/3.7.x/rabbitmq_delayed_message_exchange/rabbitmq_delayed_message_exchange-20171201-3.7.x.zip"

install_erlang21() {

wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
sudo dpkg -i erlang-solutions_1.0_all.deb

#cat > ${source_erlang} << EOF
#deb https://packages.erlang-solutions.com/ubuntu trusty contrib
#deb https://packages.erlang-solutions.com/ubuntu saucy contrib
#deb https://packages.erlang-solutions.com/ubuntu precise contrib
#EOF

echo "deb https://packages.erlang-solutions.com/ubuntu trusty contrib" | sudo tee ${source_erlang}
echo "deb https://packages.erlang-solutions.com/ubuntu saucy contrib" | sudo tee ${source_erlang}
echo "deb https://packages.erlang-solutions.com/ubuntu precise contrib" | sudo tee ${source_erlang}


wget https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | sudo apt-key add erlang_solutions.asc
sudo apt list --upgradable
sudo apt update && apt install esl-erlang=1:22.1.8-1  -y

}

install_rabbitmq() {

echo "deb https://dl.bintray.com/rabbitmq/debian xenial main" | sudo tee ${source_rabbitmq}
wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -
sudo apt list --upgradable
sudo apt update && apt install rabbitmq-server=3.7.21-1 -y


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


mkdir -p /data/rabbitmq
chown -R rabbitmq.rabbitmq /data/rabbitmq
echo "RABBITMQ_MNESIA_BASE=/data/rabbitmq/mnesia" >> /etc/rabbitmq/rabbitmq-env.conf
echo "RABBITMQ_LOG_BASE=/data/rabbitmq/log"  >> /etc/rabbitmq/rabbitmq-env.conf
systemctl restart rabbitmq-server.service


#set admin passwd
sudo rabbitmqctl add_user admin advance.ai2016
sudo rabbitmqctl set_user_tags admin administrator
sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
systemctl restart rabbitmq-server.service

#set started
sudo systemctl enable rabbitmq-server


test -d ${tmp_dir} && rm -rf ${tmp_dir}

}

install_erlang21 && install_rabbitmq
