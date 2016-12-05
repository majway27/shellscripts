Response Steps:
If the email has a red box, then we have problems.
 
If the email has a green box, things are running smoothly, and no further action is required.

Red Box - bad

ScanDir4data-Files.bat
@echo off
echo %date% %time% %username% >> d:\opt\FileScan\scheduled_FileScan_log.txt
cscript //nologo d:\opt\FileScan\ScanDir4data-Files.vbs 1>> d:\opt\FileScan\scheduled_FileScan_log.txt 2>>&1
echo %date% %time% "Done" >> d:\opt\FileScan\scheduled_FileScan_log.txt
 
ScanDir4data-Files.vbs
'' ScanDir4data-Files.vbs v5
'' RMAY - 22Sept2011
'' Script examines work, archive, and error subdirectories.  Script looks for newData data files reports on findings, scope variable by timestamp. V4 loops through 1+ Customers.  Captures estimate of data size to process.

'' Define Variables
Dim fso, folder, customerFolder, customerFolders(1), file 'FileSystem, note adding Customers to script means incrementing arrays 3x here
Dim fileTimeCheck, timeNow, timeRange 'Time
Dim search, newDataCompareSlot, newDataReferenceValue, newDataFreshness 'String
Dim dataCount, nondataCount, errordataCount, cntrctCount 'Counters
Dim dataDataSize, cntrctDataSize, archDataSize
Dim objMessage, txtToAddr, messagcustomerdy, bgColor 'Email
'' Load variables
customerFolders(0) = "d:\optdata\Northwind\inbound" 'prod Work Directory to scan, not recursive
customerFolders(1) = "d:\optdata\Gotham\inbound" 'prod Work Directory to scan, not recursive
search="data" 'String to look for, string comparison handles upper/lower case
newDataCompareSlot = "" 'Dynamic loaded parsed filename value to compare
newDataReferenceValue = "newData.vrl" 'Static value to compare against.  Note - Use lowercase if you modify
newDataFreshness =0
timeNow =0
timeRange = 12
dataDataSize = 0
cntrctDataSize = 0
archDataSize = 0
txtToAddr = "support@widgets.com"
messagcustomerdy = "OOPS"

'' File Search and Build Report
Set fso = CreateObject("Scripting.FileSystemObject") 'Instantiate fso as WSH filessystem object
timeNow = Now() 'Load current time/date into timeNow
messagcustomerdy = "<h4>Support data/Contract File Check  &nbsp;&nbsp;" & Date & "</h4>" 'Start building email body M-E-G-A string
'''' Processing loop, Run thorough once for each customer-Folder we want to process
For Each customerFolder in customerFolders 'Step through customer folder array, for work sub folders values
'' Work Folder 
' Loop to count total newData files in dir
 cntrctCount = 0 'Initialize count variable for Total newData files
 workFolder = customerFolder & "\work" 'Crucial - Here we set target subdirectory by appending string
 Set folder = fso.GetFolder(workFolder) 'Feed workFolder into folder
  For Each file In folder.files 'Step through directory
  newDataCompareSlot = fso.GetBaseName(file) 'Load read in files one-by-one into newDataCompareSlot variable
  newDataCompareSlot = (LCase(Right(newDataCompareSlot,8))) 'Takes basename, strips chars of to last 8 on right, lowercases entire file contents, loads into newDataCompareSlot
   If (StrComp(newDataCompareSlot,newDataReferenceValue,1)) = 0 Then 'Textual compare of newDataCompareSlot & newDataReferenceValue strings, evaluate for = else escape
    cntrctCount = cntrctCount + 1 'If newDataCompareSlot & newDataReferenceValue strings are equal (text compare) increment cntrctCount and loop
   End If
  Next 'Drop out of For Each Loop
' Loop to count files containing 'data'
 dataCount = 0 'Initialize count variable for data files
 dataDataSize = 0 'Initialize
 cntrctDataSize = 0 'Initialize
 Set folder = fso.GetFolder(workFolder)
  For Each file In folder.files 'Step through directory
   Set filestr = fso.OpenTextFile(file, 1)'Open handle to selected file for reading
   If InStr(LCase(filestr.ReadAll),search) Then 'Evaluate presence of "search" string, use LCase for case-insensitivity
    dataCount = dataCount + 1 'Increment count variable
    dataDataSize = dataDataSize + file.Size 'Grow dataDataSize
   Else 'Else grow contrctDataSize
    cntrctDataSize = cntrctDataSize + file.Size
   End If 'Just above we also grew data size on a or condition, decided if it was a data by sting read of file "If InStr(LCase(filestr.ReadAll),search) Then"
   filestr.Close() 'Close file handle
  Next ' Drop out of For Each loop.
  
 bgColor = "test"
 If dataCount > 0 Then
  bgColor = "#D69999"
 Else dataCount = 0 
  bgColor = "#D2E2D2"
 End If
 
 nondataCount = 0 'Initialize count variable for newData files that aren't datas
 nondataCount = cntrctCount - dataCount 'Post Search processing
 
 dataDataSize = dataDataSize / 1048576 'Convert to mb
 dataDataSize = Round(dataDataSize,2) 'Trim trailing decimals
 cntrctDataSize = cntrctDataSize / 1048576 'Convert to mb
 cntrctDataSize = Round(cntrctDataSize,2) 'Trim trailing decimals
 
 '  Build messsagcustomerdy by appending data gathered above
 messagcustomerdy = messagcustomerdy & VbCrLf & "<br><table border = ""1"" cellpadding = ""2"" bgcolor=""" & bgColor & """><tr><b>customer:&nbsp;&nbsp" & (UCase(customerFolder)) & "</b><br><br>"
 messagcustomerdy = messagcustomerdy & VbCrLf & "<table border=""1"" bgcolor=""#FFFFFF""><tr><td>&nbspFolderd Active data File Count:&nbsp</td><th><b>&nbsp" & dataCount & "&nbsp</b></th><th>&nbsp" & dataDataSize & "mb&nbsp</th></tr>"
 messagcustomerdy = messagcustomerdy & VbCrLf & "<tr><td>&nbspFolderd Active Non-data Count:&nbsp</td><th><b>&nbsp" & nondataCount & "&nbsp</b></th><th>&nbsp" & cntrctDataSize & "mb&nbsp</th></tr>"

'' Check Archive Dir
 archivedataCount = 0 'Initialize
 archDataSize = 0 'Initialize
 archiveFolder = customerFolder & "\archive" 'Crucial - Here we set target subdirectory by appending string
 Set folder = fso.GetFolder(archiveFolder)
 For Each file In folder.files
 set fileTimeCheck = fso.GetFile(file)
 newDataFreshness = fileTimeCheck.DateLastModified
 If DateDiff("h",newDataFreshness,timeNow) < 12 Then 'Filter-Funnel, take only files in timeRange
  Set filestr = fso.OpenTextFile(file, 1)'Open handle to selected file for reading
  If InStr(LCase(filestr.ReadAll),search) Then 'Evaluate presence of "search" string, use LCase for case-insensitivity
   archivedataCount = archivedataCount + 1 'Increment count variable
   archDataSize = archDataSize + file.Size
   filestr.Close() 'Close file handle
  End If 'Drop out to next file
 End If
 archDataSize = archDataSize / 1048576 'Convert to mb
 archDataSize = Round(archDataSize,2) 'Trim trailing decimals
 Next
 'messagcustomerdy = messagcustomerdy & VbCrLf & "</b><br>&nbsp;&nbspdata Archive Count (past "& timeRange & " hours): <b>" & archivedataCount
 messagcustomerdy = messagcustomerdy & VbCrLf & "<tr><td>&nbspdata Archive Count (past "& timeRange & " hours):&nbsp</td><th><b>&nbsp" & archivedataCount & "&nbsp</b></th><th>&nbsp" & archDataSize & "mb&nbsp</th></tr></table><br><br></table>"
Next 'Close Processing Loop
messagcustomerdy = messagcustomerdy & VbCrLf & VbCrLf & VbCrLf & "<br><br>Please contact #Tier3Cat@ghx.com with any questions or concerns regarding this report."

'' Mail Report
Set objMessage = CreateObject("CDO.Message") 
objMessage.Subject = "Support Northwind dataFile Check" 'objMessage.Sender = "bitbucket@widget.com" 
objMessage.From = "bitbucket@widget.com" 
objMessage.To = txtToAddr 
objMessage.HTMLBody = messagcustomerdy
objMessage.Configuration.Fields.Item _ 
("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2 
objMessage.Configuration.Fields.Item _ 
("http://schemas.microsoft.com/cdo/configuration/smtpserver") = "mailhost.widget.com" 'prod MTA
objMessage.Configuration.Fields.Item _ 
("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25 
objMessage.Configuration.Fields.Update
objMessage.Send
'' EOF
