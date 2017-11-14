#!/bin/bash

total_days=7
log_path='/data/logs/tou/'
log_name='api_visit.log.'

tag_list=(
'BluePortHome'
'homepage_api'
'request_url'
'.*epg.*\.zeasn\.tv.*'
'.*epg.*\.corio\.com.*'
)

filter_logs() {
for item in "${tag_list[@]}";do
	result=$(grep -P ${item} $1 | wc -l)
	echo -en "${item}:${result} "
done
}

while ((${total_days} > 0));do
	ext="true"
	mark_date=$(date +"%Y-%m-%d" -d "-${total_days} day")
	now_logname=${log_name}${mark_date}
	test -e ${log_path}${now_logname} || ext="faild"
  	if [ "${ext}" = "faild" ];then
		let total_days-=1
		continue
	fi
	echo -en "\n${now_logname}\n"
	filter_logs ${log_path}${now_logname}
	let total_days-=1
done
