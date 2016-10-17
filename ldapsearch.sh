#ldapsearch -LLL -H ldap://dc.widget.com -W -D "widget\myuser"  -b "dc=widget,dc=net" userPrincipalName="myuser@widget.com"

# LDAPS Don't check cert
#LDAPTLS_REQCERT=never ldapsearch -x -H ldaps://dc.widget.com:636 -b "DC=widget,DC=net" -D "myuser@widget.com" -W -s sub "sAMAccountName=myuser" name -LLL

# Don't follow referrals -C
#LDAPTLS_REQCERT=never ldapsearch -C -x -H ldaps://dc.widget.com:636 -b "DC=widget,DC=net" -D "myuser@widget.com" -W -s sub "sAMAccountName=myuser" name -LLL