#!/usr/bin/env python

import os
from array import array
from multiprocessing import Process,Lock,Manager

def make_log_list(logfile):
    fp = open(logfile,'rU')
    logarr = array('l')
    for i in fp.xreadlines():
        mid = i.split(',')[3]
        try:
            logarr.append(int(mid))
        except:
            pass
    fp.close()
    return logarr

def write_file(myarr,q,lock):
    result_file = '/tmp/A13-result.txt'
    while not q.empty():
        x = q.get()
        count = myarr.count(x)
        if count != 0:
            lock.acquire() 
            with open(result_file,'a') as fp:
                fp.write(str(x) + ':' + str(count) + '\n')
            lock.release()

if __name__ == '__main__':
    manager = Manager()
    Q = manager.Queue()
    lock = Lock()
    procs = []
    myarray = make_log_list('/data02/sp_back/toulog/total.log')
    with open('/root/A13.log','rU') as fp:
        for i in fp.xreadlines():
            mid = int(i.rstrip('\r\n'))
            Q.put(mid)
    for i in xrange(2):
        p = Process(target=write_file,args=(myarray,Q,lock))
        p.start()
        procs.append(p)
    for proc in procs:
        proc.join() 
