#!/usr/bin/evn python
#coding:utf-8

import os
import re
import yaml
import commands
import ConfigParser
from threading import Thread

class service(object):

        def __init__(self,configfile):
                self.config = ConfigParser.ConfigParser()
                self.f = os.path.realpath(configfile)
                self.f = configfile
                self.config.read(self.f)
                self.data = []

        def allsrv(self):
                p = re.compile(r'\[(.*?)\]')
                with open(self.f,'r') as myfile:
                        m = myfile.read()
                        n = p.findall(m)
                return n

        def runSalt(self,ip,cmd,srv):
                ret = {'status':'','pid':'','ip':ip}
                saltstr = "/usr/bin/salt '%s' cmd.run '%s'" %(ip,cmd)
                s,o = commands.getstatusoutput(saltstr)
                ret['status'] = s
                ret['pid'] = yaml.load(o)[ip]
		ret['master'] = srv
                return ret

        def checkService(self,servername):
                pidcmd = self.config.get(servername,'pid')
                ips = self.config.get(servername,'ip')
                for i in ips.split(','):
                        x = self.runSalt(i,pidcmd,servername)
                        self.data.append(x)
                return x

        def run(self):
               threads = []
               srvs = self.allsrv()
               for srv in srvs:
                   threads.append(Thread(target=self.checkService,args=(srv,)))
               for t in threads:
                   t.setDaemon(True)
                   t.start() 
               for t in threads:
                   t.join()
               print self.data
               return self.data

        def startService(self,servername):
                result = []
                startcmd = self.config.get(servername,'startcmd')
                ips = self.config.get(servername,'ip')
                for i in ips.split(','):
                        x = self.runSalt(i,startcmd)
                        result.append(x)
                return result

        def stopService(self,servername):
                result = []
                stopcmd = self.config.get(servername,'stopcmd')
                ips = self.config.get(servername,'ip')
                for i in ips.split(','):
                        x = self.runSalt(i,stopcmd)
                        result.append(x)
                return result

        def restartService(self,servername):
                result = []
                restartcmd = self.config.get(servername,'restartcmd')
                ips = self.config.get(servername,'ip')
                for i in ips.split(','):
                        x = self.runSalt(i,restartcmd)
                        result.append(x)
                return result

if "__main__" == __name__:
        configfile='/root/work/app/services.conf'
        y = service(configfile)
        y.run()
