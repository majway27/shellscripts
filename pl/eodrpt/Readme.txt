eodRpt.pl

Purpose - Daily report on Customer processing volume

Functional Requirements -
+ Run on server.widget.com, reading off of app NFS directory.
+ Email report
+ Compile report data
+ Dump results out to CSV file

Flow:
##Log start entry
###Create file, open file, write to file then close handle or die
##Scan Stage
###POH Phase
####Iterate through files, select file
#####Per File Attribute check - Pull Timestamp
#####Per File Attribute check - Pull Size
#####Open File
#####Per File Read File Pull Transaction Type Tag
#####Per File Read File Pull Client Code Type Tag
#####Close File
####Next File until end of directory
###Vendor List Phase
###Iterate through files, select file
####Per File Attribute check - Pull Timestamp
####Per File Attribute check - Pull Size
####Open File
####Per File Read File Pull Transaction Type Tag
####Per File Read File Pull Client Code Type Tag
####Close File
###Next File until end of directory
##Notification Stage
$msg->send('smtp','mailhost.widget.com');  #$msg->send('smtp','mailhost.widget.com', Debug=>1 ) Send Email or log and die
##Log Finish entry

Matrix Detail (Example):
[ID, Friendly Name, data volume (bytes), otherdata volume (bytes)]
[...,...,...,...]

CustomerList.txt
is used for feeding in friendly names of IDS, mainly used at time email report is built & sent.
