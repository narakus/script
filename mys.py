#!/usr/bin/env python
#-*- coding:utf-8 -*-

import os 
from subprocess import check_call

class clear_and_ungz(object):
    '''创建临时日志，解压，清理临时日志'''

    def __init__(self,gzipfile):
        self.gzipfile = gzipfile
        self.tmpfile = None
    
    @property
    def cpy_gzip(self):
        tmp_name = os.path.join('/tmp',os.path.basename(self.gzipfile))
        shell_str = 'cp ' + self.gzipfile + ' ' + tmp_name
        status = check_call(shell_str,shell=True)
        if status == 0:
            self.tmpfile = tmp_name
            return tmp_name 
        else:
            return False
    
    @property 
    def ungz_file(self):
        tmpfile = self.cpy_gzip
        if tmpfile:
            gzip_shell_str = 'gzip -d ' + tmpfile
            status = check_call(gzip_shell_str,shell=True)
            if status == 0:
                t = self.tmpfile.split('.gz')[0]
                self.tmpfile = t
                return True
        else:
            return False

    @property
    def clear_tmp(self):
        if os.path.exists(self.tmpfile):
            shell_str = 'rm -f ' + self.tmpfile
            status = check_call(shell_str,shell=True)
            if status == 0:
                return True
        else:
            return False

