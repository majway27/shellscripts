# run as root
#!/bin/bash
CERT=CA-2.cer
KEYSTOREALIAS=2017CA
JAVAHOME=/opt/app/java

# JDK has JRE inside
$JAVAHOME/bin/keytool -import -file /opt/app/certificate/$CERT -keystore $JAVAHOME/jre/lib/security/cacerts -storepass changeit -alias $KEYSTOREALIAS

# Back up newest cacerts
cp $JAVAHOME/jre/lib/security/cacerts /opt/app/certificate/