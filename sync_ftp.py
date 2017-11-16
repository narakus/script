#!/usr/bin/env python
# -*- coding utf-8 -*-

import logging
logging.basicConfig(
    level=logging.DEBUG, datefmt='%Y-%m-%d %H:%M:%S',
    format='[%(asctime)s] %(name)s/%(levelname)s - %(message)s',
    filename='/root/shell/ftp.log',
    filemode='w'
)

import sys,chilkat

def sync_ftpfiles(local,host,port,user,passwd):
    ftp = chilkat.CkFtp2()
    ftp.UnlockComponent("Anything for 30-day trial")

    ftp.put_Port(port)
    ftp.put_Hostname(host)
    ftp.put_Username(user)
    ftp.put_Password(passwd)
    try:
        s = ftp.Connect()
        ftp.SyncLocalTree(local,2)
        ftp.Disconnect()
        logging.info(ftp.sessionLog())
    except:
        logging.error(ftp.lastErrorText()) 
        sys.exit()
    finally:
        ftp.Disconnect()

if __name__ == '__main__':
    ftp_server=''
    port=
    username=''
    password=''
    localdir='/tmp/ftptmp'
    sync_ftpfiles(localdir,ftp_server,port,username,password)
