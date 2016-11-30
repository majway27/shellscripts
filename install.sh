#!/bin/bash

rpm -Uvh https://download.thing.com/agent-5-3.noarch.rpm
yum install -y agent 
special-config --do-thing dakjdfkdfkajdfdsjfads
/etc/init.d/agent start

unzip /tmp/install.zip -d /usr/share/tomcat7/
chown -R tomcat:tomcat /usr/share/tomcat7/install/
chmod -R 774 /usr/share/tomcat7/install/

HOST=$(hostname)
sed -i "s/My\ Default/agent-$HOST/" /usr/share/tomcat7/install/agent.yml
sed -i 's/-special-java-config=false/-special-java-config=true -javaagent:\/usr\/share\/tomcat7\/install\/install.jar/' /etc/tomcat7/tomcat7.conf

#restart agent and service
#service tomcat7 stop

#service tomcat7 start
