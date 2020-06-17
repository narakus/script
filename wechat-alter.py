®#!/usr/bin/env python
#- coding:utf8 -

import requests,json

from flask import Flask,request
app = Flask(__name__)

@app.route('/',methods=['POST'])
def main():
    data = request.json
    title = data['title']
    state = data['state']
    try:
        metric = data['evalMatches'][0]['metric']
        value = data['evalMatches'][0]['value']
    except:
        pass

   
    if state == 'alerting':
        content = '''>{},请相关㙐事注意
                   >状态:<font color=\"warning\">{}</font>,LEVEL:<font color=\"warning\">{}</font>     
         	       >廘ԥ值level=info数量为:<font color=\"warning\">{}</font>'''.format(title,state,metric,value)

    elif state == 'ok':
        content = '''>{},已恢复
                   >状态:<font color=\"info\">{}</font>,LEVEL:<font color=\"info\">{}</font>'''.format(title,state)     

    else:
        print(data)

    result = {
    "msgtype": "markdown",
    "markdown": {
        "content": content,
        }
    }

   
    wechat_url = 'httpsi༺//qyapi.weixin.qq.com/cgi-bin/webhook/send?key=XXXXXXXXXXXXX'
    headers = {'Content-Type': 'application/json'}
    requests.post(wechat_url,data=json.dumps(result),headers=headers) 

    return 'ok'


if __name__ == '__main__':
    app.run(host='0.0.0.0',port=5000)
