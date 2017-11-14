#!/usr/bin/env python
#coding:utf-8

import os
import yaml
import commands
from time import sleep
from datetime import datetime
from urlparse import urlparse
from svn import remote
from datetime import tzinfo
from Queue import Queue
from common import delFirstLine,mktag

class BaseInfo(object):
	def __init__(self,username='liujing',password='@liujing'):
		self.username = username
		self.password = password

	def run(self,ip,path,svnurl):
		serverlist = []
		filename = svnurl.split('/')[-1]
		print "search filename is: ",filename
		salt_command = '/usr/bin/salt "%s" file.find %s type f name=%s' %(ip,path,filename)
		status,output = commands.getstatusoutput(salt_command)
		if not yaml.load(output).values() == [None]:
			outlist = yaml.load(output).values()[0]
			for item in outlist:
				if svnurl in item:
					print "find is: ",item
					serverlist.append(item)	
			if len(serverlist) == 0:
				suburl = '/'.join(svnurl.split('/')[:-1])
				return self.run(ip,path,suburl)
		else:
			suburl = '/'.join(svnurl.split('/')[:-1])
			return self.run(ip,path,suburl)
		return ''.join(serverlist)
		

	def svn_msg(self,urllink,path,ipaddr):
		p = path.encode('utf-8')
		result = {}
		for ip in range(len(ipaddr)):
			d = {}
			i = ipaddr[ip]
			i = i.encode('utf-8')
			r = remote.RemoteClient(urllink,username=self.username,password=self.password)
			for item in r.list_recursive():
				svnpath = item[0] + '/' + item[1]['name']
				filename = item[1]['name']

				server_path = self.run(i,p,svnpath)
				
				if not urllink.endswith('/'):
					urllink = urllink + '/'
				
				status = 3  #0替换, 1新增, 2未找到,3初始值
			 	k = item[0] + '/' + item[1]['name']
				svnpath = urllink + k

				if server_path == 'error':
					status = 2
				elif server_path.split('/')[-1] == svnpath.split('/')[-1]:
					status = 0
				else:
					status = 1
					if not server_path.endswith('/'):
						server_path = server_path + '/' + filename
	
				v = {'filename':filename,
					'author':item[1]['author'],
					'upload_time':item[1]['date'].strftime('%Y-%m-%d %H:%M:%S'),
					'svnpath':svnpath,
					'commit_revision':item[1]['commit_revision'],
					'commit_size':item[1]['size'],
					'server_path':server_path,
					'status':status,
					}
				d[k] = v
				result[i] = d
		return result

	def tranFile(self,ip,src,dst):
		ip = ip.encode('utf-8')
		#删除文件
		salt_rm = '/usr/bin/salt "%s" cmd.run "rm -f %s"' %(ip,dst)
		commands.getoutput(salt_rm)
		salt_command = '/usr/bin/salt "%s" cp.get_file salt:/%s %s' % (ip,src,dst)
		s,o = commands.getstatusoutput(salt_command)
		v =  yaml.load(o)

		if v.values() == [None]:
			print "tranfile failed!"
		else:
			print "tranfile %s successful" % src
		dd = {} 
		for key,values in v.items():
			dd['ip'] = key
			dd['values'] = values
		return dd

	def downLoadSvnFile(self,urllink,localpath):
		r = remote.RemoteClient(urllink,username=self.username,password=self.password)
		o = urlparse(r.url)
		base_dir = o.path.split('os')[1].split('/')[1]
		tag_dir = datetime.now().strftime('%Y%m%d_%H%M%S')
		download_dir = os.path.join(localpath,base_dir,tag_dir)
		if not os.path.exists(download_dir):
			os.makedirs(download_dir)
		try:
			r.checkout(download_dir)
		except UnicodeDecodeError as e: pass
		return download_dir

	def backup(self,iplist,apppath):
		ret = {'backupfile':'','backuppath':''}
		if not apppath.endswith('/'):
			apppath = apppath + '/'
		tarname = apppath.split('/')[-2]
		mytarname = tarname + '_' + datetime.now().strftime('%Y%m%d') + mktag() + '.tar.gz'
		myyear = datetime.now().strftime('%Y')
		mymonth = datetime.now().strftime('%m')
		backuppath = '/appbackup'
		mypath = os.path.join('/appbackup',myyear,mymonth)
		mkdir_command = 'test -d ' + mypath + ' || mkdir -p ' + mypath 
		uplevel = '/'.join(apppath.split('/')[:-2])
		tar_command = 'cd ' + uplevel + ' && tar czf ' + mytarname + ' ' + tarname + ' && mv ' + mytarname + ' ' + mypath
		
		print mkdir_command
		print tar_command

		q = Queue()
		for ip in iplist:
			q.put(ip)
		while(q.qsize() > 0):
			ip = q.get()
			salt_mkdir = '/usr/bin/salt "%s" cmd.run "%s"' %(ip,mkdir_command)
			s,o = commands.getstatusoutput(salt_mkdir)
			if s == 0:
				print "%s mkdir %s successful" % (ip,mypath)

				salt_tar = '/usr/bin/salt "%s" cmd.run "%s"' %(ip,tar_command)
				s2,o2 = commands.getstatusoutput(salt_tar)
				if s2 == 0:
					print "%s backup %s successful" % (ip,mytarname)
				else:
					print "error code is: ",s2

		ret['backupfile'] = mytarname
		ret['backuppath'] = mypath
		return ret

	def rollback(self,ip,apppath,backupfile,cmd):
		if not apppath.endswith('/'):
			apppath = apppath + '/'
		m = apppath.split('/')
		copydir = '/'.join(m[:-2])
		print copydir
		filename = apppath.split('/')[-2]
		rolldir = '/tmp/' + datetime.now().strftime('%Y%m%d') + '/' +  datetime.now().strftime('%H%M%S')
		print rolldir
		copy_command = "mkdir -p %s && mv %s %s && tar -xf %s -C %s  && %s" %(rolldir,apppath,rolldir,backupfile,copydir,cmd)
		salt_command = '/usr/bin/salt "%s" cmd.run "%s" ' %(ip,copy_command)
		print copy_command,salt_command
		s,o = commands.getstatusoutput(salt_command)
		if s == 0:
			return True
		else: 
			return False
	
	
	def localFileList(self,localpath):
		checklist = []
		for root,dirs,files in os.walk(localpath):
			if ".svn" in root:
				continue
			else:
				for file in files:
					checkp = root + '/' + file
					checklist.append(checkp)
		return checklist

	def runcmd(self,ip,cmd,logfile):
		m = []
		salt_log = '/usr/bin/salt "%s" cmd.run "cat %s | wc -l"' %(ip,logfile)
		before = yaml.load(commands.getoutput(salt_log))
		print "before: ",before
		salt_cmd = '/usr/bin/salt "%s" cmd.run "%s"' %(ip,cmd)
		s,o = commands.getstatusoutput(salt_cmd)
		sleep(5)
		commandout = delFirstLine(o)
		print "output is: ",commandout
		print "outstatus is: ",s

		if s == 0:
			after = yaml.load(commands.getoutput(salt_log))
			afternum = after[ip]
			print "after: ",after
			connum = int(afternum) - int(before[ip])
			print "connum: ",connum 
			salt_logcon = '/usr/bin/salt "%s" cmd.run "tail -n %d %s"' %(ip,connum,logfile)
			logcon = commands.getoutput(salt_logcon)
			logdata = delFirstLine(logcon)
			alldata = commandout + '\n' + logdata
			m.append(afternum)
			m.append(alldata)
			print "runcmd out: ",m
			return m
		else:
			print 'run shell command failed!'


	def showLog(self,ip,logfile,lastnum):
		m = []
		salt = '/usr/bin/salt "%s" cmd.run "cat %s | wc -l"' %(ip,logfile)
		nowcon = yaml.load(commands.getoutput(salt))
		nownum = nowcon[ip]
		connum = int(nownum) - int(lastnum)
		if connum > 0:
			tailcommand = '/usr/bin/salt "%s" cmd.run "tail -n %d %s"' %(ip,connum,logfile)
			logout = commands.getoutput(tailcommand)
			logout = delFirstLine(logout)
		else:
			logout = "None"
		m.append(nownum)
		m.append(logout)
		print "showlog out: ",m
		return m


#if __name__ == '__main__':
#	obj = BaseInfo()
#	obj.runcmd('192.168.254.254','pgrep java | xargs kill -9 && sleep 2 && sh /usr/local/apache-tomcat-8.5.11/bin/startup.sh','/usr/local/apache-tomcat-8.5.11/logs/catalina.out')
#	d = obj.svn_msg('http://10.167.200.50/yunwei/os/DJR_data/API-WWZ/20160802','/tmp',['192.168.254.254','192.168.254.253'])
#	d = obj.svn_msg('http://10.167.200.50/yunwei/os/DJR_data/API-APP/20170210/10.150.120.58%E5%92%8C10.150.120.68/ROOT','/tmp',['192.168.254.254'])
#	obj.cp_file('192.168.254.254','test_file','/tmp')
#	for k,v in d.items():
#		print k,v
