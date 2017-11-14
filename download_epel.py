#!/usr/bin/env python

import os,sys,urllib,urllib2,Queue,time,platform
import BeautifulSoup as bs
from multiprocessing import Pool

def getSysInfo():
        sys_info = {
        'osname':platform.dist()[0],
        'release':platform.dist()[1].split('.')[0],
        'basearch':platform.machine()
        }
        return sys_info

def allDownloadUrl():
        save_dir = "/var/www/html/"
        tStr = "http://mirrors.aliyun.com"
        tList = ["/epel/6/x86_64/","/centos/6/os/x86_64/","/centos/6/updates/x86_64/","/centos/6/extras/x86_64/","/centos/6/centosplus/x86_64/","/centos/6/contrib/x86_64/"]
        os.chdir(save_dir)
        for i in tList:
                i = '.' + i
                if not os.path.isdir(i):
                        os.makedirs(i)
        return [ tStr + i  for i in tList ]

def rpm_list(urllink):
    download_list = []
    html_doc = urllib2.urlopen(urllink)
    html_bs = bs.BeautifulSOAP(html_doc)
    for i in html_bs.findAll('a'):
        download_list.append(i.attrs[0][1])
    return download_list[1:]


def check_list(file_list):


def download_proc(myurl,name):
    urllib.urlretrieve(myurl,name)

if __name__ == "__main__":
        for i in downloadUrl:
                print i 

    q = Queue.Queue()
    for i in rpm_list(sys.argv[1]):
        q.put(i)
    pool = Pool(processes=10)
    while True:
        if q.qsize() > 0:
            tmp_name = q.get()
            tmp_url = sys.argv[1] + tmp_name
            result = pool.apply_async(download_proc,(tmp_url,tmp_name,))
            print "Downloading %s" %(tmp_url)
        else:break
    pool.close()
    pool.join()
