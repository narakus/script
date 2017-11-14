#!/usr/bin/evn python
#coding:utf-8

import os
import re
import yaml
import commands
import ConfigParser

class service(object):

        def __init__(self,configfile):
                self.config = ConfigParser.ConfigParser()
                self.f = os.path.realpath(configfile)
                self.f = configfile
                self.config.read(self.f)

        def allsrv(self):
                p = re.compile(r'\[(.*?)\]')
                with open(self.f,'r') as myfile:
                        m = myfile.read()
                        n = p.findall(m)
                return n

        def runSalt(self,ip,cmd):
                ret = {'status':'','pid':'','ip':ip}
                saltstr = "/usr/bin/salt '%s' cmd.run '%s'" %(ip,cmd)
                s,o = commands.getstatusoutput(saltstr)
                ret['status'] = s
                ret['pid'] = yaml.load(o)[ip]
                return ret

        def checkService(self,servername):
                result = []
                pidcmd = self.config.get(servername,'pid')
                ips = self.config.get(servername,'ip')
                for i in ips.split(','):
                        x = self.runSalt(i,pidcmd)
                        result.append(x)
                return result

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
        configfile='/root/work/work01/app/services.conf'
        y = service(configfile)
        z = y.checkService('test')
        m = y.allsrv()
        print m
        print z
