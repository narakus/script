#!/usr/bin/env python

import re

def read_file_by_re(filename):
    f = open(filename,'rU')
    for item in f.xreadlines():
        remove_args = re.sub(r'(?<=\=)\s*(.*?)\s*.*? \1','',item)
        sql_key = hash(remove_args)
        yield (sql_key,remove_args)

def top_sql(data,result):
    k,v = data
    result.setdefault(k,0)
    result[k] += 1
    with open('./mapping.txt','a') as mapfile:
        mapfile.write(str(k) + ':' + v)

def show_result(mydata):
    f = open('./mapping.txt','rU')
    for k,v in mydata:
        for item in f.xreadlines():
            mk,sql = item.split(':')[0],item.split(':')[1]
            if int(k) == int(mk):
                print '{0}:\n{1}'.format(v,sql)
                break
        continue
    f.close()

if __name__ == '__main__':
    result = {}
    gen = read_file_by_re('/tmp/test.sql')
    for item in gen:
        top_sql(item,result)
    blist = sorted(result.items(),key=lambda item:item[1],reverse=True)
    m = blist[:10]
    show_result(m)
