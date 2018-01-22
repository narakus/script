#!/usr/bin/env python
#-*- codint:utf-8 -*-

import os
import re
import argparse
from datetime import datetime, timedelta

def search_log_list(logpath,days):
    result = []
    log_name = 'api_visit.log.'
    now = datetime.now()
    time_list = [ now - timedelta(days=item) for item in range(1,days) ]
    log_list = [ log_name + i.strftime('%Y-%m-%d') for i in time_list]
    for i in log_list:
        s = os.path.join(logpath,i)
        if os.path.exists(s):
            result.append(s)
    #print result
    return result

def filter_log(filename,tags,myip):
    result = {}
    privacy = 0
    index = 0
    other = 0
    f = open(filename,'rU')
    logtime = os.path.basename(filename).split('.')[2]
    for item in f.xreadlines():
        try:
            x = item.split('==>>')[1]
            if re.match(r'^request_url',x):
                req,redir = x.split('regredirback')
                if re.search(r'/privacy/',req):
                    result.setdefault('privacy',{})
                    privacy += 1
                    for i in tags:
                        if re.search(i,redir):
                            result['privacy'].setdefault(i,0)
                            result['privacy'][i] += 1
                elif '/index/' in req:
                    result.setdefault('index',{})
                    index += 1
                    for i in tags:
                        if re.search(i,redir):
                            result['index'].setdefault(i,0)
                            result['index'][i] += 1
                else:
                    other += 1
        except:pass
        #except:print item
    f.close()
    total={'privacy':privacy,'index':index}
    mark = (myip,logtime)
    return (total,result,mark)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Statistical tou access log')
    parser.add_argument("-d", "--lastdays", type=int,dest="lastdays",
                      action="store",required=True,
                      help="Statistics a few days ago log")
    args = parser.parse_args()
    tags = ['epg.corio.com','homepage_api','BluePortServlets','epg.zeasn.tv']
    mount_dir = '/home/zeasnlog/sp_prod_TouCMS_TouSP_RECms/'
    logdirs = os.listdir(mount_dir)
    result = {}
    if args.lastdays:
        for item in logdirs:
            logfile = os.path.join(mount_dir,item,'tou')
            logs = search_log_list(logfile,args.lastdays + 1)
            for i in logs:
                total,detail,mark = filter_log(i,tags,item)
                myip,mytime = mark
                result.setdefault(mytime,{})
                for key,values in total.items():
                    keyname = 'total_' + key
                    result[mytime].setdefault(keyname,0)
                    result[mytime][keyname] += values
                for mk,mv in detail.items():
                    result[mytime].setdefault(mk,{})
                    for myk,myv in mv.items():
                        result[mytime][mk].setdefault(myk,0)
                        result[mytime][mk][myk] += myv
        print result
