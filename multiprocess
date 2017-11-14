#!/usr/bin/env python

import commands
import yaml
from multiprocessing import Pool

ips = '''
10.180.110.47
10.180.110.48
10.180.110.49
10.180.110.83
10.180.120.81
10.180.120.82
10.180.120.83

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
    p = Pool(len(q))
    m = p.map(worker,q)
    p.close()
    p.join()
    print 'All subprocesses done.'
