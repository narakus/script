#!/bin/bash

logpath='/data/logs/tou/'
mydate=$(date +"%Y/%m/%d" -d "-1 day")
logdate=$(date +"%Y-%m-%d" -d "-1 day")
myip=$(ifconfig | head -n 2 | grep -oP '(\d+\.){3}\d+' | grep -v '255')
s3_path="s3://uk-prod-log/tou/${mydate}/${myip}"

delete() {
while read logname;do    
        rm -f ${logname} &&\
        logger -t $0[$$] "delete ${logname}"
done
}

#save 3days
find ${logpath} -type f\
 \( -name '*_rule.log*' -o -name '*_notice.log*' -o -name '*_js.log*' -o -name '*_http.log*' \)\
 -mtime +3 | delete

#save 30days
find ${logpath} -type f \( -name '*_visit.log*' -o -name '*_error.log*' \) -mtime +30 | delete
mylist=$(cd ${logpath} && ls | grep -P '(api|cms)\.log\.\d+\.gz')
for i in ${mylist};do
	find ${logpath} -type f -name ${i} -mtime +30 | xargs rm -f &&\
	logger -t $0[$$] "delete ${logpath}${i}"
done

#upload last day to s3
upload_s3() {
uplist=$(find ${logpath} -type f \( -name '*_stat.log*' -o -name '*_stat2.log*' \) | grep ${logdate})
for i in ${uplist};do
	myname=$(basename $i)
	cp ${i} /tmp/ && gzip /tmp/${myname}
	gzname=${myname}".gz"
	#aws --profile logbak s3 cp ${logpath}${gzname} ${s3_path}/${gzname} > /dev/null 2>&1 || UPLOAD="fail"
	aws --profile logbak s3 cp /tmp/${gzname} ${s3_path}/${gzname} > /dev/null 2>&1 || UPLOAD="fail"
	rm -f  /tmp/${gzname}
	if [ "${UPLOAD}" = "fail" ];then
		logger -t $0[$$] "upload ${logpath}${gzname} to s3 failed"
		exit 1
	else
		logger -t $0[$$] "upload ${logpath}${gzname} to s3 success"
	fi
done
}

#save 14days
clear_logs() {
find ${logpath} -type f \( -name '*_stat.log*' -o -name '*_stat2.log*' \) -mtime +14 | delete
}

upload_s3 && clear_logs

