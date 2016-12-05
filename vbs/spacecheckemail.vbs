'Send email
'Hostname
Dim HostName 
'Email
Dim objMessage, txtToAddr, messageBody
txtToAddr = "support@widget.com"
'Disk Check
Dim  Cspace, Dspace, CspaceMB, DspaceMB

'Get hostname
Set objNTInfo = CreateObject("WinNTSystemInfo")
HostName = lcase(objNTInfo.ComputerName) 
  
'Get DiskSpace
Set fso = CreateObject("Scripting.FileSystemObject")
Set Cspace = fso.GetDrive("C:")
Set Dspace = fso.GetDrive("D:")
CspaceMB = Round((Cspace.FreeSpace)/1024/1024)
DspaceMB = Round((Dspace.FreeSpace)/1024/1024)
  
 'Send Email
Set objMessage = CreateObject("CDO.Message") 
objMessage.Subject = HostName & " Disk Cleanup Report" 'objMessage.Sender = "bitbucket@widget.com" 
objMessage.From = "bitbucket@widget.com" 
objMessage.To = txtToAddr 
objMessage.Addattachment "d:\opt\Cleanup.txt"
objMessage.HTMLBody = HostName & " Disk Cleanup Report<br><br>Disk Space:<BR>C Free Space(mb): " & CspaceMB & "<BR>D Free Space(mb): " & DspaceMB
objMessage.Configuration.Fields.Item _ 
("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2 
objMessage.Configuration.Fields.Item _ 
("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "mailrelay@widget.com" 'INT MTA
objMessage.Configuration.Fields.Item _ 
("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25 
objMessage.Configuration.Fields.Update
objMessage.Send
