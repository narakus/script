#!/usr/bin/env python

import commands
import yaml
from threading import Thread
from Queue import Queue

ips = '''
10.180.150.71
10.180.150.72
10.180.150.73
10.180.150.74
10.180.150.75
10.180.150.76
10.180.150.77
10.180.150.78
10.180.150.79
10.180.150.80
10.180.190.51
10.180.190.52
'''

def prepare():
    cmdlist = []
    iplist = [ x for x in ips.split('\n') if x != '' ] 
    for ip in iplist:
        saltstr = '/usr/bin/salt "%s" cmd.run "hostname"' %(ip)
        cmdlist.append(saltstr)
    return cmdlist

def worker(cmd):
    s,o = commands.getstatusoutput(cmd)
    p = yaml.load(o)
    print p
    return yaml.load(o)

if __name__ == "__main__":
    q = prepare()
    threads = []
    for i in q:
        threads.append(Thread(target=worker,args=(i,)))
    for t in threads:
        t.setDaemon(True)
        t.start()
    for t in threads:
        t.join()
    print "All thread complate"
