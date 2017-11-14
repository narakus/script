#!/usr/bin/env python 
#coding:utf-8

from __future__ import division
import re
import os
import json
from common import analysis,helpstr,logcount
from django.shortcuts import render,render_to_response,HttpResponse,redirect
from models import TemplateMsg,project,CoreApply,UserProfile,SvnInfo,Files,BackUp,CheckOut,SpeedProecss,RecordLog
from app import forms
from app.BaseMsg import BaseInfo
from datetime import datetime
from service import service


#用于测试
def basePage(request):
        return render_to_response('base.html')

def showJobPage(request):
    form = forms.jobForm()
    if request.method == 'GET':
        return render_to_response('job.html',{'data':form})

def showSvnPage(request):
    form = forms.jobForm()
    if request.method == 'POST':
        form = forms.jobForm(request.POST)
        if form.is_valid():
            data = form.cleaned_data
            taskname = form.cleaned_data['taskname']
            choicetype = form.cleaned_data['choice_type']
            usetemp = form.cleaned_data['tempselect']
            useproject = form.cleaned_data['projectselect']
            svnurl = form.cleaned_data['url']

            #写入数据库
            proejctobj = project.objects.get(id = useproject)
            templateobj = TemplateMsg.objects.get(id = usetemp)
            #待修改
            userobj = UserProfile.objects.get(id = 2)

            appobj = CoreApply(name = taskname,
                               choicetype = choicetype,
                               usertemp = templateobj,
                               userproject = proejctobj,
                               applyuser = userobj,
                               inputurl = svnurl,
                     )
            appobj.save()
            taskid = appobj.taskid
            print "taskid: ",taskid
            apppath = templateobj.applypath
            ipstr = templateobj.applyipaddr
            iplist = ipstr.split(',')
            svnobj = BaseInfo()
            #读取svn与服务器文件信息，返回html
            svnobj = svnobj.svn_msg(svnurl,apppath,iplist)
            print svnobj
            return render_to_response('svn.html',{'data':svnobj,'taskid':taskid})

def showTempPage(request):
    form =  forms.templateForm()

    if request.method == "GET":
        return render_to_response('template.html',{'data':form})
    elif request.method == 'POST':
        print "POST data: ",request.POST
        form = forms.templateForm(request.POST)
        if form.is_valid():
            data = form.cleaned_data
            tempname = form.cleaned_data['tempname']
            path = form.cleaned_data['applypath']
            ipaddr = form.cleaned_data['ipaddr']
            rumcmd = form.cleaned_data['runcommand']
            logpath = form.cleaned_data['logpath']
            projectid = form.cleaned_data['projectselect']

            proejctobj = project.objects.get(id = projectid)
            templateobj = TemplateMsg(templatename = tempname,
                                      applyipaddr = ipaddr,
                                        applypath = path,
                                        runcommand = rumcmd,
                                        projectname = proejctobj,
                                        logpath = logpath,
                                      )
            templateobj.save()

            return redirect('/template')

def showProjectPage(request):
    all_data = TemplateMsg.objects.all()
    datalist = list(all_data.values())
    for item in datalist:
        proobj = project.objects.get(id=item['projectname_id'])
        itemname = proobj.projectname
        item['projectname_id'] = itemname
    print datalist

    return render_to_response('project.html',{'data':datalist})

def rcvProjName(request):
    if request.method == 'POST' and request.is_ajax:
        val = request.POST.get('k')
        try:
            p = project.objects.get(projectname=val)
            return HttpResponse('exists')
        except:
            project.objects.create(projectname=val)
            return HttpResponse('0')

def rcvAllDate(request):
    if request.method == 'POST' and request.is_ajax:
        alldate =  request.POST
        alldict =  alldate.dict()
        print alldict
        taskid = alldict['taskid']
        print taskid
        coreobj = CoreApply.objects.get(taskid=taskid)
        
        #写入svninfo,files表
        rr = re.compile(r'(\S*\.?\S+)\[(\w+)\]')
        iplist = []
        f = []
        tag = []
        alldict.pop('taskid')
        for item in alldict.keys():
            p = item.split('___')
            print p[0],p[1]
            iplist.append(p[0])
            f.append(rr.match(p[1]).group(1))
            tag.append(rr.match(p[1]).group(2))
            sf = set(f)
            stag = set(tag)
            siplist = set(iplist)

        for myfilename in sf:
            svnk = iplist[0] + '___' + myfilename + '[svnpath]'
            serverk = iplist[0] + '___' + myfilename + '[serverpath]'
            sizek = iplist[0] + '___' + myfilename + '[size]'
            uploaderk = iplist[0] + '___' + myfilename + '[uploader]'
            uploadtimek = iplist[0] + '___' + myfilename + '[uploadtime]'
            versionk = iplist[0] + '___' + myfilename + '[version]'
            statk = iplist[0] + '___' + myfilename + '[stat]'
            svnval = alldict[svnk]
            serverval = alldict[serverk]
            sizeval = alldict[sizek]
            uploaderval = alldict[uploaderk]
            uploadtimeval = alldict[uploadtimek]
            versionval = alldict[versionk]
            statval = alldict[statk]
            SvnInfo.objects.create(filename = myfilename,
                                   svnfilepath = svnval,
                                   upload_user = uploaderval,
                                   file_upload_at = uploadtimeval,
                                   commit_revision = versionval,
                                   commit_size = sizeval,
                                   taskid = coreobj,
                                   )

            Files.objects.create(file = myfilename,
                                 serverpath = serverval,
                                 execument = statval,
                                 taskid = coreobj,
                                )
        return HttpResponse('ok')

def getspeed(request):
    if request.method == 'POST' and request.is_ajax:
        m = {'speed':'','connent':''}
        data = request.POST
        mydata = data.dict()
        taskid = mydata['taskid']
        coreobj = CoreApply.objects.get(taskid=taskid)
        speedobj = SpeedProecss.objects.filter(taskid=coreobj)

        #判断获取数据是否为空
        if len(list(speedobj.values())) == 0:
            #执行备份,获取模板中使用ip地址，以及路径
            tempobj = TemplateMsg.objects.filter(coreapply__taskid=taskid)
            apppath = list(tempobj.values('applypath'))[0]['applypath']
            querylist =  list(tempobj.values('applyipaddr'))
            iplist = querylist[0]['applyipaddr'].encode('utf-8').split(',')
            backstr = u'正在执行备份...'
            SpeedProecss.objects.create(conment=helpstr(backstr),taskid=coreobj) #写入进度表，用于前台调用
            backupobj = BaseInfo()
            ret = backupobj.backup(iplist,apppath)

            #写入backup表
            BackUp.objects.create(backupfile = ret['backupfile'],
                                  backuppath = ret['backuppath'],
                                  backstatus = 0,
                                  taskid = coreobj,
                                  )

            #执行checkout,并写入checkout表
            baseobj = BaseInfo()
            localpath = '/srv/salt/'
            inputurl = coreobj.inputurl
            checkstr = u'正在下载SVN文件...'
            SpeedProecss.objects.create(conment=helpstr(checkstr),taskid=coreobj)
            checkpath = baseobj.downLoadSvnFile(inputurl,localpath)
            print "checkpath is: ",checkpath
            CheckOut.objects.create(downloadpath = checkpath,
                                    checkoutstatus = 0,
                                    taskid = coreobj
                                   )
            #获取checkout所有文件以及对应服务器路径,生成字典
            locallist = baseobj.localFileList(checkpath)
            realdict = analysis(locallist,apppath,taskid)

            #校验生成数据结果
            for src,dst in realdict.items():
                fileobj = Files.objects.filter(taskid=taskid)
                try:
                    f2 = fileobj.get(serverpath=dst)
#                except DoesNotExist as e:
                except Exception as e:
                    raise Exception(dst + 'DoesNotExist!')
            print "check readlist complate!" 
            print realdict

            #复制文件至远程服务器，并写入进度表
            num = len(realdict.keys()) * len(iplist)
            step = round(100 / num,1)
            for myip in iplist:
                for src,dst in realdict.items():
                    src = src[9:]
                    currentstep = SpeedProecss.objects.filter(taskid=coreobj)
                    now = currentstep.order_by("-id")[0]
                    nextstep = round(now.speed + step,1)
                    mystr = str(myip) + ': ' +  helpstr(dst.split('/')[-1])
                    SpeedProecss.objects.create(conment=mystr,taskid=coreobj,speed=nextstep)
                    baseobj.tranFile(myip,src,dst)

            mynow = speedobj.order_by("-id")[0]
            m['speed'] = mynow.speed
            m['connent'] = mynow.conment

            #将任务状态设置成功
            coreobj.applystatus = 0
            coreobj.save()
            
            return HttpResponse(json.dumps(m))

        else:
            mynow = speedobj.order_by("-id")[0]
            m['speed'] = str(mynow.speed)
            m['connent'] = mynow.conment

        
            return HttpResponse(json.dumps(m))

def runCommand(request):
    if request.method == 'POST' and request.is_ajax:
        data = request.POST
        mydata = data.dict()
        taskid = mydata['taskid']
        coreobj = CoreApply.objects.get(taskid=taskid)
        tempobj = TemplateMsg.objects.filter(coreapply__taskid=taskid)
        runcommand = list(tempobj.values('runcommand'))[0]['runcommand']
        logpath = list(tempobj.values('logpath'))[0]['logpath']
        querylist =  list(tempobj.values('applyipaddr'))
        iplist = querylist[0]['applyipaddr'].encode('utf-8').split(',')
        print "len iplist is: ",len(iplist)
        runobj = BaseInfo()
        print iplist,runcommand,logpath

        loglist = []
        for ip in iplist:
            startoutput = runobj.runcmd(ip,runcommand,logpath)
            startoutput.append(ip)
            loglist.append(startoutput)
            RecordLog.objects.create(runip = ip,
                                     linenum = startoutput[0],
                                     taskid = coreobj,
                                    )

        return HttpResponse(json.dumps(loglist))


def tailLog(request):
    if request.method == 'POST' and request.is_ajax:
        data = request.POST
        mydata = data.dict()
        taskid = mydata['taskid']
        coreobj = CoreApply.objects.get(taskid=taskid)
        tempobj = TemplateMsg.objects.filter(coreapply__taskid=taskid)
        logpath = list(tempobj.values('logpath'))[0]['logpath']
        querylist =  list(tempobj.values('applyipaddr'))
        iplist = querylist[0]['applyipaddr'].encode('utf-8').split(',')

        loglist = []
        tailobj = BaseInfo()
        for ip in iplist:
            recordobj = RecordLog.objects.get(taskid=coreobj,runip=ip)
            lastnum = recordobj.linenum
            tailout = tailobj.showLog(ip,logpath,lastnum)
            tailout.append(ip)
            loglist.append(tailout)
            recordobj.linenum = tailout[0]
            recordobj.save()
        return HttpResponse(json.dumps(loglist))

def searchPag(request):
    if request.method == "GET":
        alldata = CoreApply.objects.all().order_by('-taskid')
        datalist = list(alldata.values())
        for item in datalist:
            proobj = project.objects.get(id=item['userproject_id'])
            item['userproject_id'] = proobj.projectname
            tempobj = TemplateMsg.objects.get(id=item['usertemp_id'])
            item['usertemp_id'] = tempobj.templatename
            userobj = UserProfile.objects.get(id=item['applyuser_id'])
            type_choice = {
                0: u'新任务',
                1: u'BUG修复',
                2: u'未执行',
                }
            status_choice = {
                0: u'成功',
                1: u'失败',
                2: u'未执行',
                3: u'已回滚',
                }
            item['applyuser_id'] = userobj.name
            choice = item['choicetype']
            item['choicetype'] = type_choice[choice]
            status = item['applystatus']
            item['applystatus'] = status_choice[status]

        return render_to_response('search.html',{'data':datalist})


def rollback(request):
    ret = {'status':''}
    if request.method == "POST":
        data = request.POST.dict()
        taskid = data['taskid']
        coreobj = CoreApply.objects.get(taskid=taskid)
        tempobj = TemplateMsg.objects.filter(coreapply__taskid=taskid)
        backupobj = BackUp.objects.get(taskid=taskid)

        backpath = backupobj.backuppath
        backname = backupobj.backupfile
        backupfile = os.path.join(backpath,backname)

        apppath = list(tempobj.values_list())[0][3]
        cmd = list(tempobj.values_list())[0][5]
        iplist = list(tempobj.values_list())[0][2]
        
        roll = BaseInfo()
        for ip in iplist.encode('utf-8').split(','):
            result = roll.rollback(ip,apppath,backupfile,cmd)

        coreobj.applystatus = 3
        coreobj.save()

        ret['status'] = 0
        return HttpResponse(json.dumps(ret))

def services(request):
    conf = os.path.join(''.join(os.path.split(os.path.realpath(__file__))[:-1]),'services.conf')
    x = service(conf)
    if request.method == "GET":
        z = []
        srvlist = x.allsrv()
        for srv in srvlist:
            y = x.checkService(srv)
            for m in y:
                m['master'] = srv
            print y
            z = z + y
        return render_to_response('services.html',{'data':z})

    elif request.method == "POST" and  request.is_ajax:
        querydict = request.POST
        data = querydict.dict()
        action = int(data['action'])
        appname = data['appname'].encode('utf-8')
        if action == 0:
            result = x.startService(appname)
        elif action == 1:
            result = x.stopService(appname)
        else:
            result = x.restartService(appname)

        return HttpResponse(json.dumps(result))
