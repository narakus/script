select id from information_schema.processlist  where command = 'query' and time > 60  and id != connection_id()  and user != 'root'  and command != 'binlog dump'  and state not regexp '(slave|relay|event)';
