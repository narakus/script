#!/usr/bin/env python
# -*- coding:utf-8 -*-
from django import forms
from models import TemplateMsg
from models import project

class jobForm(forms.Form):
    url = forms.URLField(max_length=256,
                         min_length=5,
                         error_messages={'required':('URL不能为空'),'invalid':"URL格式错误"},
                         widget=forms.TextInput(attrs={'class':'form-control',
                                                      'type':'text',
                                                      'placeholder':'svnurl',
                                                      'id':'svnurl'}))
    taskname = forms.CharField(max_length=50,
                       min_length=5,
                       error_messages={'required':u'名称不能为空',
                                       'invalid':u"名称格式错误"},
                       widget=forms.TextInput(attrs={'class':'form-control',
                                                     'type':'text',
                                                     'placeholder':'TaskName',
                                                     'id':'taskname'}))
    
    CHOICES = (('0', u'新任务',), ('1', u'BUG修复',))
    choice_type = forms.ChoiceField(widget=forms.RadioSelect, choices=CHOICES)


    projectselect = forms.IntegerField(widget=forms.Select(attrs={'class':"selectpicker","id":"s2"}))
    tempselect = forms.IntegerField(widget=forms.Select(attrs={'class':"selectpicker","id":"s1"}))

    def __init__(self,*args,**kwargs):
        super(jobForm,self).__init__(*args,**kwargs)
        self.fields['tempselect'].widget.choices = TemplateMsg.objects.all().values_list("id",'templatename')
        self.fields['projectselect'].widget.choices = project.objects.all().values_list('id','projectname')


class templateForm(forms.Form):
    tempname = forms.CharField(max_length=50,
                               min_length=2,
                               error_messages={'required':u'模板名称不能为空',
                                               'invalid':u"模板名称格式错误"},
                               widget=forms.TextInput(attrs={'class':'form-control',
                                                             'type':'text',
                                                             'placeholder':'TemplateName',
                                                             'id':'templatename'}))
    applypath = forms.CharField(max_length=256,
                                min_length=2,
                                error_messages={'required':u'部署路径不能为空',
                                                'invalid':u"路径格式错误"},
                                widget=forms.TextInput(attrs={'class':'form-control',
                                                              'type':'text',
                                                              'placeholder':'Path',
                                                              'id':'path'}))


    logpath = forms.CharField(max_length=256,
                                min_length=2,
                                error_messages={'required':u'日志路径不能为空',
                                                'invalid':u"路径格式错误"},
                                widget=forms.TextInput(attrs={'class':'form-control',
                                                              'type':'text',
                                                              'placeholder':'logpath',
                                                              'id':'log'}))


    ipaddr = forms.CharField(widget=forms.widgets.Textarea(attrs={'class': "form-control no-radius", 
                                                                        'placeholder': u'192.168.1.1,192.168.1.2', 
                                                                        'type':'text',
                                                                        'rows': 3,
                                                                        'id':'ipaddres'}))

    runcommand = forms.CharField(widget=forms.widgets.Textarea(attrs={'class': "form-control no-radius", 
                                                                        'placeholder': u'执行命令', 
                                                                        'type':'text',
                                                                        'rows': 6,
                                                                        'id':'start'}))

    projectselect = forms.IntegerField(widget=forms.Select(attrs={'class':"selectpicker","id":"s2"}))

    def __init__(self,*args,**kwargs):
        super(templateForm,self).__init__(*args,**kwargs)
        self.fields['projectselect'].widget.choices = project.objects.all().values_list('id','projectname')


#暂时没用
#class TempSelectForm(forms.Form):
#    tempselect = forms.IntegerField(widget=forms.Select(attrs={'class':"selectpicker","id":"s1"}))
#    def __init__(self,*args,**kwargs):
#        super(tempselect,self).__init__(*args,**kwargs)
#        self.fields['tempselect'].widget.choices = TemplateMsg.objects.all().values_list('id','templatename')
#
