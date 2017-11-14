#!/usr/bin/env python
# -*- coding:utf-8 -*-
from __future__ import unicode_literals
from django.db import models
from django.utils import timezone

status_choice = (
                (0, u'成功'),
                (1, u'失败'),
                (2, u'未执行'),
                (3, u'已回滚'),
                )

class UserProfile(models.Model):
        name = models.CharField(u'用户名',max_length=32)
        email = models.EmailField(u'邮箱',max_length=32)
        phone = models.CharField(u'座机',max_length=32)
        mobile = models.CharField(u'手机',max_length=32)
        memo = models.TextField(u'备注',blank=True)
        create_at = models.DateTimeField(default = timezone.now)

        def __unicode__(self):
                return self.name

class project(models.Model):
        projectname = models.CharField(u'项目名称',max_length=30)

        def __unicode__(self):
                return self.projectname
                
class TemplateMsg(models.Model):
        templatename = models.CharField(u'模板名称',max_length=64)
        applyipaddr = models.CharField(u'应用服务器地址',max_length=256)
        applypath = models.CharField(u'程序部署路径',max_length=256)
        logpath = models.CharField(u'启动日志路径',max_length=256)
        runcommand = models.CharField(u'执行命令',max_length=256)
        projectname = models.ForeignKey('project')
        create_at = models.DateTimeField(default = timezone.now)

        def __unicode__(self):
                return self.templatename

class CoreApply(models.Model):
        type_choice = (
                (0, u'新任务'),
                (1, u'BUG修复'),
                (2, u'未执行'),
                )
        name = models.CharField(u'投产名称',max_length=128)
        inputurl = models.CharField(u'用户输入svn地址',max_length=256)
        choicetype = models.IntegerField(u'投产类型',choices=type_choice,default=2)
        applytime = models.DateTimeField(default = timezone.now)
        applyuser = models.ForeignKey(UserProfile)
        usertemp = models.ForeignKey(TemplateMsg)
        userproject = models.ForeignKey(project)
        applystatus = models.IntegerField(choices=status_choice, default=2)
        taskid = models.AutoField(primary_key=True)

        def __unicode__(self):
                return self.taskid

class SvnInfo(models.Model):
        #svnurl = models.CharField(u'svnurl',max_length=256)
        filename = models.CharField(u'上传文件名',max_length=256)
        svnfilepath = models.CharField(u'SVN上传文件路径',max_length=256)
        upload_user = models.CharField(u'上传人',max_length=32)
        file_upload_at = models.DateTimeField(u'上传日期')
        commit_revision = models.IntegerField(u'提交版本号')
        commit_size = models.IntegerField(u'提交大小')
        #check_out_path = models.CharField(u'CHEKCOUT路径',max_length=256)
        taskid = models.ForeignKey(CoreApply)

        def __unicode__(self):
                return self.svnurl

class CheckOut(models.Model):
#        checkoutfile = models.CharField(u'checkout文件',max_length=256)
        downloadpath = models.CharField(u'下载文件路径',max_length=256)
        checkouttime = models.DateTimeField(default = timezone.now)
        checkoutstatus = models.IntegerField(choices=status_choice, default=2)
        taskid = models.ForeignKey(CoreApply)

        def __unicode__(self):
                return self.checkoutfile
                
class BackUp(models.Model):

#        temp = models.ForeignKey('TemplateMsg')
        backupfile = models.CharField(u'备份文件名',max_length=256)
        backstatus = models.IntegerField(choices=status_choice, default=2)
        backuppath = models.CharField(u'备份路径',max_length=256)
        backuptime = models.DateTimeField(u'备份日期',default = timezone.now)
        taskid = models.ForeignKey(CoreApply)

        def __unicode__(self):
                return self.backupfile

class Files(models.Model):
        exec_choice = (
                (0, u'添加'),
                (1, u'替换'),
                (2, u'异常'),
                )
        file = models.CharField(u'更新文件',max_length=256)
        serverpath = models.CharField(u'服务器路径',max_length=256)
        execument = models.IntegerField(choices=exec_choice) 
#        updata_file_count = models.IntegerField(u'更新文件数')
        taskid = models.ForeignKey(CoreApply)

        def __unicode__(self): 
                return self.file

class SpeedProecss(models.Model):
        speed = models.FloatField(default=0)
        conment = models.CharField(u'执行内容',max_length=256)
        taskid = models.ForeignKey(CoreApply)

        def __unicode__(self):
            return self.conment

class RecordLog(models.Model):
        runip = models.CharField(u'ip地址',max_length=256)
        linenum = models.IntegerField(default=0)
#        conment = models.TextField(u'内容')
        taskid = models.ForeignKey(CoreApply)

        def __unicode__(self):
            return self.linenum
