#add tomcat pid
ProjectName=`echo $CATALINA_BASE|awk -F '/' '{print $NF}'`
CATALINA_PID=$CATALINA_BASE/${ProjectName}.pid
#add java opts
JAVA_OPTS="-Xms4096M -Xmx4096M -XX:PermSize=1024M -XX:MaxPermSize=1024M -Djava.awt.headless=true"
