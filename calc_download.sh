#!/bin/bash

#用于统计每日app下载量
last_date=$(date +%Y-%m-%d -d '-1 days')
logs_dir="/data/logs/FAuth/"
logname="collect.log.${last_date}"
other_server="10.45.19.14"
tmp_file="/tmp/$$"

#merger logs
merger_logs="${tmp_file}/merger.log"
test -d ${tmp_file} || mkdir -p ${tmp_file}
scp root@${other_server}:${logs_dir}${logname} ${tmp_file}/ > /dev/null 
cat ${logs_dir}${logname} >> ${merger_logs} &&\
cat ${tmp_file}/${logname} >> ${merger_logs}

/bin/awk ' \
BEGIN{ FS=",";
result["约彩彩票"]    =  "com.vodone.caibo";                    
result["内涵段子"]    =  "com.ss.android.essay.joke";           
result["今日头条"]    =  "com.ss.android.article.news";         
result["男性私人医生"]=  "com.medapp.man";                      
result["紫马财行"]    =  "com.zimadai";                         
result["趣读"]        =  "com.sogou.qudu";                      
result["火山小视频"]  =  "com.ss.android.ugc.live";            
result["西瓜视频"]    =  "com.ss.android.article.video";        
result["翡翠岛理财"]  =  "com.fcd.cn";                          
result["锐派钱包"]    =  "com.ruipaiqianbao.rpqb";              
result["天天中彩票"]  =  "com.zhongcai500";                     
result["抖音短视频"]  =  "com.ss.android.ugc.aweme";            
result["翻阅小说"]    =  "com.ifeng.android";                   
result["公益彩票"]    =  "com.zkqc.safelottery";               
result["空间刷赞神器"]=  "com.nineton.loveqzone";               
result["趣读"]        =  "com.ss.android.article.interesting";  
result["悟空彩票"]    =  "com.zhangcai.wklottey";              
}\
{ if($14 != "") { apps[$14]++ } }\
END { for(app in apps) {  for(item in result) { if(result[item]==app) { print item,apps[app] } } } } ' ${merger_logs}

test -d ${tmp_file} && rm -rf ${tmp_file}
