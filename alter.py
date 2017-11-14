#!/usr/bin/env python
# -*- coding:utf-8 -*-

#import python libs
import json,requests

class DingDing(object):
    def __init__(self,script_data,send_url):
        self.send_url = send_url
        self.header = {"Content-Type": "application/json;charset=utf-8"}
        self._data = script_data
        self.send_data = {'msgtype':'markdown','markdown':{'title':None,'text':None},'at':{'isAtAll':'false'}}

    @property
    def send(self):
        mytitle = self._data['title']
        #mytitle = u'来自' + self._data['from'] + u'告警'
        self.send_data['markdown']['title'] = mytitle
        mytext = u'''
**{0}**\n
时间：{1}\n
主机：{2}\n
脚本：{3}\n
内容：{4}
'''.format(mytitle,self._data['time'],self._data['from'],self._data['script'],self._data['content'])
        self.send_data['markdown']['text'] = mytext
        response = requests.post(self.send_url,data = json.dumps(self.send_data),headers=self.header)
        print response.text

#import flask libs
from flask import Flask,request,jsonify
from flask.ext.script import Manager

app = Flask(__name__)
manager = Manager(app)

send_url='https://oapi.dingtalk.com/robot/send?access_token='

@app.route('/alter',methods=['POST'])
def send_to_dd():
    alter_data = request.json
    ding = DingDing(alter_data,send_url)
    ding.send
    return jsonify({'msg':'send success'})

if __name__ == '__main__':
    manager.run()
