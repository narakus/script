#!/bin/bash

send_message() {
runscript=$1
title=$2
content=$3
myip=$(/sbin/ifconfig  | grep -oP '(?<=inet\s)(\d+\.){3}\d+' | grep -v '^127' | head -n 1)
send_time=$(date +"%Y%m%d-%H:%M:%S")
data=$(eval echo '\{\"title\":\"$title\",\"content\":\"$content\",\"from\":\"$myip\",\"time\":\"$send_time\",\"script\":\"$runscript\"\}')
curl -i -H "Content-Type: application/json" -X POST -d $data "http://127.0.0.1:5000/alter"
}

send_message $1 $2 $3
