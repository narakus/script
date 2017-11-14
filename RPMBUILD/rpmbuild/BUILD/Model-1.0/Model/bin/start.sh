#!/bin/bash
basepath=$(cd `dirname $0`; pwd)
User=zeasn
sudo su - $User -c $basepath/startup.sh 
