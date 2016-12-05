OrderChex.bat
@echo off
echo %date% %time% %username% >> d:\opt\OrderChex\OrderChex_log.txt
cscript //nologo d:\opt\OrderChex\Orderchex.vbs 1>> d:\opt\OrderChex\OrderChex_log.txt 2>>&1
echo %date% %time% "Done">> d:\opt\OrderChex\OrderChex_log.txt
 
Orderchex.vbs
'''  Orderchex.vbs v2
''   RMAY - 21Oct2011
''   Script loops through 1+ Companies in Company.txt, filters on time, queries per Company, emails team if Order found.
''   Carries this out via the following steps:
''     1. Windows scheduler runs the script
''     2. Script reads in the roster file, admits X Companies
''     3. x Companies eligible, loaded into array, using isSystemUp()
''     4. Per Company in array
''       a) sql
''         y] (goto step 5) Dump query into variable
''         n] (goto step 6)
''     5. Email customer, alerting to PO info
''     6. Read array for more Companies to process
''       a] (Yes - goto step 4)
''       b] (No - goto step 7)
''     7. Exit/Sleep
''  
''   Subs/Functions documentation:
''     stuckOrderFinder(), runs dev provided sql against db, takes in dbName, outputs Orders exist (y/n), if yes returns OrderDATA1(Orderid,Ordernum,poid,Orderstatuscode,ageinmin, difflines,countlines)
''     isSystemUp(), takes in Company shortname from flat file System.txt, outputs System live (y/n)
''     sendEmail(), takes in Company shortname, reads in flat file Company.txt, sends email
''

''  Declare variables
Dim objFSO, objFile 'filesystem
Dim CompanyLine, CompanyList(), CompanyEnabled, CompaniestartTime, CompanyEndTime, CompanieshortName, timeNow, stuckOrders 'input file processing
'Dim dbToRead 'db fed in from conf file, matches to Company shortname
CompanieshortName = ""
timeNow = Now() 'Load current time/date into timeNow
Set objFSO = CreateObject("Scripting.FileSystemObject")

'''  Start Processsing
 'wscript.echo "Order Check Starting For All Companies Configured " & timeNow & vbcrlf 'Log Actvity
'' Script reads in the roster file, admits X Companies, Takes in flat file Company.txt, outputs CompanyDATA1(shortName "Nome", dbName "Northwind", email(s) "dude@widgets.com", enabled (y/n))
 Const ForReading = 1
        Set objFile = objFSO.OpenTextFile("d:\opt\OrderChex\Company.txt", ForReading)
 i = 0
 Do Until objFile.AtEndOfStream
  Redim Preserve CompanyList(i)
  CompanyList(i) = objFile.ReadLine
  i = i + 1
 Loop
 objFile.Close
 For Each CompanyLine in CompanyList 'Check first to make sure Company is enabled
  CompanyEnabled = (Right(CompanyLine,1))  'Strip to enabled character
  If CompanyEnabled = 1 Then 'Proceed if Company enabled
   CompanyLineSplitter="~"
   CompanieshortName = (Left(CompanyLine,InStr(CompanyLine,CompanyLineSplitter)-1)) 'Pull short name out of string
'' x Companies eligible, loaded into array, using isSystemUp()
   If isSystemUp(CompanieshortName) = 1 Then 'Check to see if we should bother alerting
'' Per Company in array a) sql y] (goto step 5) Dump query into variable n] (goto step 6)
    stuckOrderFinder() 'Orders?
    stuckOrders = stuckOrderFinder 'Load into stuckOrders
    'wscript.echo len(stuckOrders)
    If len(stuckOrders) > 132 Then 'We have Orders now do this
'' Email customer, alerting to PO info
     sendEmail() 'Generate and send email
    Else 'No stuck Orders then do this
     wscript.echo "No Stuck Orders for " & CompanieshortName 'Log Activity
    End If
   End If
  End if
'' Read array for more Companies to process a] (Yes - goto step 4) b] (No - goto step 7) 
 Next 'Next Company or quit
'' Exit/Sleep
 timeNow = Now() 'Load current time/date into timeNow
 'wscript.echo "Order Check Complete For All Companies Configured " & timeNow & vbcrlf 'Log Actvity

'' Subs/Functions
Function isSystemUp(CompanieshortName)
 'some statements
 isSystemUp=1
End Function  
Function stuckOrderFinder()
 Dim dbToRead
 Dim resultList
 CompanyLineSplitter="^"
 dbToRead = Right(Left(CompanyLine,InStr(CompanyLine,CompanyLineSplitter)-1),Len(Left(CompanyLine,InStr(CompanyLine,CompanyLineSplitter)))-(InStr(CompanyLine,"~"))-1)
 Set conn = CreateObject("ADODB.Connection")
 conn.open "orderdb","monitoruser","nastypassword"
 conn.DefaultDatabase = dbToRead
 'strSQLQuery = "select * from AdHocType"
 strSQLQuery = "select OrderID,OrderNum,PoID,OrderStatusCode,AgeInMin from (select Order.Orderid,Order.Ordernum,Orderpo.poid,ri.linenum,rs.BuyerCode as Orderstatuscode,datediff(mi, Order.Orderstatusdate,getutcdate()) as AgeInMin, case when Order.Orderstatusid <> ri.Orderstatusid then 1 else 0 end as LineDiff    from Orderitem ri (nolock) inner join Order (nolock) on ri.Orderid = Order.Orderid inner join Orderpo (nolock) on Order.Orderid = Orderpo.Orderid inner join OrderStatus rs (nolock) on rs.OrderStatusID = Order.OrderStatusID where Order.Orderstatusid in (7,99,10) and Order.Orderstatusdate between dateadd(wk, -2, getutcdate()) and dateadd(mi, -15, getutcdate())) as t group by t.Orderid,t.Ordernum,t.poid,t.Orderstatuscode,t.ageinmin having min(t.AgeInMin)> 900 and max(t.AgeInMin)< 5760 order by t.AgeInMin desc"
 Set rs = CreateObject("ADODB.Recordset")
 rs.Open strSQLQuery, conn, 3, 3
  resultList = "<table border=""1"" width=""100%""><tr>"
  for each x in rs.Fields
   resultList = resultList & "<th>" & x.name & "</th>"
  next
  resultList = resultList & "</tr>"
  do until rs.EOF
   resultList = resultList & "<tr>"
    for each x in rs.Fields
     resultList =  resultList & "<td>" & x.value & "</td>"
    next
   rs.MoveNext
   resultList = resultList & "</tr>"
  loop
 resultList = resultList & "</table>"
 stuckOrderFinder = resultList
 conn.close
 set conn = Nothing
 set rs = Nothing
End Function
Sub sendEmail()
 CompanyLineSplitter = "^"
 txtToAddr = Left(Right(CompanyLine,Len(Companyline)-InStr(CompanyLine,CompanyLineSplitter)),Len(Companyline)-InStr(CompanyLine,CompanyLineSplitter)-2)
 messagCompanydy = "<html> <link type=""text/css"" rel=""stylesheet"" href=""main.css"" /></head><body style=""margin: 0 auto; padding: 0; background-color: #1F5FA6;""><table width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""0""> <tr><td align="" left""><table width=""100%""> <tr><td valign=""top"" align=""left"" width=""25%""><div id="" layer1""> <table width=""100%"" cellpadding=""0"" cellspacing=""0"" border=""0""> <tr><td><table height=""61px"" cellpadding=""0"" cellspacing=""0"" border=""0"" width=""100%""><tr><td width=""27%"">&nbsp;</td><td></td><td width=""28%""></td></tr><tr><td colspan=""3"" class=""highlight""><img height=""1"" width=""1"" src=""spacer.gif""/></td></tr></table></td></tr></table></div><table align=""center"" cellpadding=""0"" cellspacing=""0"" border=""0"" width=""100%""> <tr><td rowspan=""2"" width=""3%"" valign=""top""></td><td height=""28""><img height=""1"" width=""1"" src=""spacer.gif""/></td><td rowspan=""2"" width=""3%"" valign=""top""></td></tr> <tr><td><table cellpadding=""0"" cellspacing=""0"" border=""0"" width=""100%"" bgcolor=""#1F5FA6"" style=""border: 3px solid #b9cde5;""> <tr><td style=""padding: 10px"" class=""cell-center""><img align=""right"" height=""61px"" width=""160px"" src=""header-logo-tranparent.gif""><br /><font color=""white""><h4>opt Idle Order Check &nbsp;" & Date & "</h4></font></tr></table><table bgcolor=""#b9cde5"" style=""padding:17px""><tr><br /><br />Dear Customer,<br /><br />This is a system generated alert to notify you that one or more new Orders were sent to your System but have not yet received at least one line status update in the Widget application.<br /><br />Please contact opt@Northwind.com with any questions or concerns regarding this report.<br /><br /><table width=""100%""> <tr><td valign=""top"" align=""left"" width=""25%""><table cellpadding=""12"" cellspacing=""0"" border=""0"" class=""center"" width=""100%""><tr><td><b>Buying Organization&#58;</b><font color=""white"">" & "&nbsp;"  & (UCase(CompanieshortName)) & "</font>" & "<br/><br/><font color =""black"">Idle Order Report Detail:<b><br />" & stuckOrders & "<br /><br /></b></td></font></tr> </table></td></tr></table></td></tr></table></td></tr> </table></td></tr></table></td></tr></table></body><br/> <body> <table align = ""center""><tr><td width = ""100%"" class=""center"" align=""center""><img src=""Northwindlogo.jpg"" width=""40px"" /><td></td></tr> </table> </body></html>"
 Set objMessage = CreateObject("CDO.Message") 
  objMessage.Subject = "Northwind opt Idle Order Check, " & CompanieshortName 'objMessage.Sender = "bitbucket@widget.com" 
  objMessage.From = "bitbucket@widget.com" 
  objMessage.To = txtToAddr 
  objMessage.HTMLBody = messagCompanydy
  objMessage.Configuration.Fields.Item _ 
  ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2 
  objMessage.Configuration.Fields.Item _ 
  ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "mailhost.widget.com" 'MTA
  '("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "mailhost.widget.com" 'MTA
  objMessage.Configuration.Fields.Item _ 
  ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25 
  objMessage.Configuration.Fields.Update
  objMessage.Send
 'wscript.echo "Email sent to " & CompanieshortName & vbcrlf & stuckOrders 'Log Activity
End Sub
'' EOF

Company.txt
Example Company Nickname~Company_TEMPLATEDB^support@Northwind.com;patCustomer@Northwind.com:0

 
System.txt
NorthPlace 0800 2000 
