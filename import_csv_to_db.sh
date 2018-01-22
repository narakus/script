#!/bin/bash

#用于统计昨天TOUAPI日志，写入至对应日期表

#table_date=$(date +'%m_%d' -d '-1 day')
table_date=$(date +'%Y%m%d' -d '-1 day')
log_date=$(date +'%Y-%m-%d' -d '-1 day')
table_name="z_api_stat_"${table_date}
log_name="api_stat.log."${log_date}

#table_name="z_api_stat_0927_bak"
mydate=$(date  '+%Y%m%d-%H:%M:%S')
echo "${mydate} insert ${log_name} to ${table_name}"

/bin/mysql -uroot -p1234567 <<EOF
use z_api_stat;

CREATE TABLE ${table_name} (
  time varchar(100) NOT NULL,
  ip varchar(100) NOT NULL,
  action varchar(100) NOT NULL,
  device_id varchar(100) NOT NULL,
  manufacturer_id varchar(100) NOT NULL,
  consumer_id varchar(100) NOT NULL,
  country varchar(100) NOT NULL,
  lang varchar(100) NOT NULL,
  profile_id varchar(50) NOT NULL,
  category_id varchar(100) NOT NULL,
  product_id varchar(10) NOT NULL,
  brand_id varchar(100) NOT NULL,
  ctn varchar(100) NOT NULL,
  target varchar(275) NOT NULL,
  param varchar(275) NOT NULL,
  result varchar(275) NOT NULL,
  KEY idx_action (action) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


load data infile '/tou_api_stat_log/10.8.130.1/${log_name}'
into table ${table_name} 
fields terminated by ',' 
optionally enclosed by '"' 
escaped by '"' 
lines terminated by '\n';

load data infile '/tou_api_stat_log/10.8.137.3/${log_name}'
into table ${table_name} 
fields terminated by ',' 
optionally enclosed by '"' 
escaped by '"' 
lines terminated by '\n';

load data infile '/tou_api_stat_log/10.8.20.2/${log_name}'
into table ${table_name} 
fields terminated by ',' 
optionally enclosed by '"' 
escaped by '"' 
lines terminated by '\n';

load data infile '/tou_api_stat_log/10.8.21.1/${log_name}'
into table ${table_name} 
fields terminated by ',' 
optionally enclosed by '"' 
escaped by '"' 
lines terminated by '\n';

load data infile '/tou_api_stat_log/10.8.30.1/${log_name}'
into table ${table_name} 
fields terminated by ',' 
optionally enclosed by '"' 
escaped by '"' 
lines terminated by '\n';

load data infile '/tou_api_stat_log/10.8.136.1/${log_name}'
into table ${table_name} 
fields terminated by ',' 
optionally enclosed by '"' 
escaped by '"' 
lines terminated by '\n';

load data infile '/tou_api_stat_log/10.8.137.1/${log_name}'
into table ${table_name} 
fields terminated by ',' 
optionally enclosed by '"' 
escaped by '"' 
lines terminated by '\n';

load data infile '/tou_api_stat_log/10.8.137.2/${log_name}'
into table ${table_name} 
fields terminated by ',' 
optionally enclosed by '"' 
escaped by '"' 
lines terminated by '\n';

load data infile '/tou_api_stat_log/10.8.20.3/${log_name}'
into table ${table_name} 
fields terminated by ',' 
optionally enclosed by '"' 
escaped by '"' 
lines terminated by '\n';

load data infile '/tou_api_stat_log/10.8.21.2/${log_name}'
into table ${table_name} 
fields terminated by ',' 
optionally enclosed by '"' 
escaped by '"' 
lines terminated by '\n';

load data infile '/tou_api_stat_log/10.8.21.3/${log_name}'
into table ${table_name} 
fields terminated by ',' 
optionally enclosed by '"' 
escaped by '"' 
lines terminated by '\n';

EOF
