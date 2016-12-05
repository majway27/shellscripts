bleeder.bat
REM RMAY
ECHO %Date%, %Time% Bleeder job started >> d:\opt\bleeder\bleeder.log
cscript bleeder.vbs >> d:\opt\bleeder\bleeder.log
ECHO %Time% Bleeder Job Completed >> d:\opt\bleeder\bleeder.log
REM EOF
 
bleeder.vbs
'Move files in from hold when work count drops below threshold
' Config
OPTION EXPLICIT
' Variables
Dim moveThisAmountPerRun
Dim holdFileCount, workFileCount, workFileCountMinFiles
Dim objFSO, objFolder, objFile, colFiles, objSelectedFolder
Dim objHoldFolder, objDestFolder
Dim counter
'moveThisAmountPerRun = 3 'How many files do you want to move per run
moveThisAmountPerRun = 5000
holdFileCount=2 'Initialize hold count here, any postitive interger larger than initial value of workFileCount
workFileCount=1
workFileCountMinFiles=3
'objHoldFolder = "d:\opt\hold\" 'FS Target of moves
objHoldFolder = "D:\FunProduct\Folder8\Work"
'objDestFolder = "d:\opt\work\"  'Location of staged data, !NOTE! - don't forget to append trailing slash on path or cscript will think you are trying to move the folder itself
objDestFolder = ("d:\FunProduct\Folder8\Work2\")
' Main
While holdFileCount > workFileCount
   'WScript.Echo holdFileCount
   If workFileCount <= holdFileCount Then 'This will break us out once we reach the goal condition of processing all file backlog, otherwise drop in and do work
  'wscript.echo "Starting check"
  If workFileCount < workFileCountMinFiles Then 'Check if we have capacity, if so do work. Otherwise drop out and check again later.
   'wscript.echo "Starting move"
   Set objFSO = CreateObject("Scripting.FileSystemObject")
   Set objFolder = objFSO.GetFolder(objHoldFolder)
   Set colFiles = objFolder.Files
    counter=0
    'wscript.echo "Beginning copy work"
    For Each objFile in colFiles
     wscript.echo objFile
     objFile.Move (objDestFolder)
     If counter  >= moveThisAmountPerRun Then 'Check to see if we moved a wanted block yet (IE the script moves 100 at a time, etc)
      wscript.echo "Done"
      Exit For
     End If
     counter = counter + 1
    Next
  End If
 End If
 Set objSelectedFolder = objFSO.GetFolder(objDestFolder)
 workFileCount = objSelectedFolder.Files.Count
 wscript.echo "Work File Count: " & workFileCount
 Set objSelectedFolder = objFSO.GetFolder(objHoldFolder)
 holdFileCount = objSelectedFolder.Files.Count
 wscript.echo "Hold File Count: " & holdFileCount
 wscript.echo "Sleeping"
 WScript.Sleep(30000)
 'WScript.Sleep(5000)
Wend
' EOF
