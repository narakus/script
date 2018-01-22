#!/usr/bin/env python
# -*- coding:utf-8 -*-

import subprocess
import os,logging,zipfile,MySQLdb
from collections import namedtuple

base_dir=os.path.dirname(os.path.abspath(__file__))

logging.basicConfig(
    level=logging.DEBUG, datefmt='%Y-%m-%d %H:%M:%S',
    format='[%(asctime)s] %(name)s/%(levelname)s - %(message)s',
    filename=os.path.join(base_dir,'work.log'),
    filemode='a'
)

def insert_xml_data(env,filename):
    db = namedtuple('DB',['host','user','passwd','dbname'])
    if env == 'ACC':
        mydb = db('dbhost','dbusername','dbpassword','dbname')
    elif env == 'PROD':
        #mydb = db('localhost','user01','passwd','db01')
        #mydb = db('ppsp-zeasn-uk.cluster-cj55qjjwucwa.eu-west-1.rds.amazonaws.com','REEngine','RoojeiYueth2Ea','prod_content')
        mydb = db('dbhost','dbusername','dbpassword','dbname')
    f = os.path.basename(filename).split('.')[0]
    sql1 = '''LOAD XML LOCAL INFILE '{0}' REPLACE INTO TABLE z_launcher_period ROWS IDENTIFIED BY '<TVAIRING>' (@TVCHANNEL_GN_ID, @TVPROGRAM_GN_ID, @TVCHANNEL_TVTV_ID, @ID,@START,@END) SET on_use = 1,create_by = '{1}',create_time=unix_timestamp(NOW())*1000 , channel_id=@TVCHANNEL_GN_ID, item_id=@TVPROGRAM_GN_ID, tv_channel_id=@TVCHANNEL_TVTV_ID,uuid=@ID,start_time=unix_timestamp(@START)*1000,end_time=unix_timestamp(@END)*1000;'''.format(filename,f)
    sql2 = '''SELECT @a:=start_time FROM z_launcher_period AS a WHERE create_by = "{0}" ORDER BY start_time ASC limit 1;'''.format(f)
    sql3 = '''DELETE FROM z_launcher_period WHERE start_time >= @a AND create_by != "{0}";'''.format(f)
    sqls = (sql1,sql2,sql3)

    conn=MySQLdb.connect(host=mydb.host,user=mydb.user,passwd=mydb.passwd,db=mydb.dbname,port=3306)
    cur=conn.cursor()

    alter_title = "检测上传XML"
    try:
       for sql in sqls:
           logging.info(sql)
           result = cur.execute(sql)
           logging.info('Exexuted ' + str(result.real))
           conn.commit()
       alter_msg = "成功:文件{0}在{1}库执行完成".format(f,env)
       alter_cmd= "curl -s http://zeasn-file.oss-cn-beijing.aliyuncs.com/eli/send_message.sh | bash -s fsi.py {0} {1}".format(alter_title,alter_msg)
       subprocess.call(alter_cmd,shell=True)
    except MySQLdb.Error,e:
       errmsg = "Mysql Error " + str(e.args[0]) + ": " + str(e.args[1])
       logging.error(errmsg)
       alter_msg = "失败:文件{0}在{1}库执行异常，{2}".format(f,env,errmsg)
       alter_cmd= "curl -s http://zeasn-file.oss-cn-beijing.aliyuncs.com/eli/send_message.sh | bash -s fsi.py {0} {1}".format(alter_title,alter_msg)
       subprocess.call(alter_cmd,shell=True)
#       return
    finally:
        cur.close()
        conn.close()

def unzip_file(filepath):
    tmpdir = '/data/unzipdir'
    usenv = os.path.basename(os.path.dirname(filepath))
    mytmpdir = os.path.join(tmpdir,usenv)
    if not os.path.exists(mytmpdir):
        os.makedirs(mytmpdir)
    if zipfile.is_zipfile(filepath):
        zipf = zipfile.ZipFile(filepath)
        for item in zipf.namelist():
            zipf.extract(item,mytmpdir)
            xmlfile = os.path.join(mytmpdir,item)
            logging.info('unzip ' + xmlfile)
            insert_xml_data(usenv,xmlfile)

             
import pyinotify

wm = pyinotify.WatchManager()  # Watch Manager
mask = pyinotify.ALL_EVENTS  # watched events

class EventHandler(pyinotify.ProcessEvent):

    def process_IN_CREATE(self, event):
        logging.info("Create:" + event.pathname)

    def process_IN_DELETE(self, event):
        logging.info("Remove:" + event.pathname)

    def process_IN_CLOSE_WRITE(self, event):
        logging.info("Writeclose:" + event.pathname)
        unzip_file(event.pathname)

if __name__ == '__main__':

    handler = EventHandler()
    notifier = pyinotify.Notifier(wm, handler)
    wdd = wm.add_watch('/data/ftp/blr/TranslationTable', mask, rec=True)
    notifier.loop()
