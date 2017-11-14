#!/usr/bin/env python
#coding:utf-8

import os 
import yaml
import commands
import random
from models import CheckOut
from string import digits
from string import ascii_letters as letters

def mktag():
	return ''.join([random.choice(letters + digits) for i in range(12)])

def run(ip,path,svnurl):
	filename = svnurl.split('/')[-1]
	salt_command = '/usr/bin/salt "%s" file.find %s type f name=%s' %(ip,path,filename)
	status,output = commands.getstatusoutput(salt_command)
	if not yaml.load(output).values() == [None]:
		outlist = yaml.load(output).values()[0]
		for item in outlist:
			if svnurl in item:
				return item
	else:
		suburl = '/'.join(svnurl.split('/')[:-1])
		run(ip,path,suburl)

def analysis(locallist,apppath,taskid): #checkout目录，配置模板用户输入路径，任务id
	realdict = {}
	if apppath.endswith('/'):
		apppath = apppath[:-1]
	checkobj = CheckOut.objects.get(taskid=taskid)
	downloadpath = checkobj.downloadpath
	for item in locallist:
		real = apppath + item[len(downloadpath):]
		realdict[item] = real
	return realdict

def helpstr(rcvstr):
	return rcvstr.encode('utf-8')

def logcount(logfile):
	c = 0
	f = open(logfile,'r')
	while True:
		buffer = f.read(8 * 1024 * 1024)
		if not buffer:
			break
		c += buffer.count('\n')
	f.close()
	return c

def delFirstLine(conment):
	return '\n'.join(conment.split('\n')[1:])


if __name__ == '__main__':
	run('192.168.254.254','/tmp','/tmp/ROOT/WEB-INF/lib/DJR_activityService-1.0.0-SNAPSHOT.jar')
