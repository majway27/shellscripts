@echo off
REM Script to restart Tomcat
sc stop "Apache Tomcat"
TIMEOUT /T 30 /NOBREAK
sc start "Apache Tomcat"
echo %Date%, %Time% Webapp Restarted via restart script >> WebappRestart.log 