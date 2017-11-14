#!/usr/bin/env python

import os
from gevent import monkey; monkey.patch_socket()
import gevent

def show_count(myfile):
    count = 0
    try:
        with open(myfile,'r') as f:
            for item in f.xreadlines():
                try:
                    count += 1
                except StopIteration:
                    break
    except:
        print 'read failed: ',myfile
    with open('result.txt','a') as f2:
        f2.write(myfile + ':' + str(count) + '\n')
    return count

if __name__ == '__main__':
    glist = []
    all_file_list = os.listdir('.')
    for i in all_file_list:
        glist.append(gevent.spawn(show_count,i))
    gevent.joinall(glist)
