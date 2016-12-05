#!/usr/bin/perl -w
#RMAY - 08Feb2012 - End Of Day Report, WONDER.  See 2-218446609 for requirements and project notes.
#Note - This script assumes that old archive files have been moved out of the way, leaving us with just the current day's files to work with


#Module declaration
	use strict;
	use warnings;
	use MIME::Lite;
	use Email::Sender::Transport::SMTP;
	use DateTime;
	use Number::Format qw(format_bytes);
	
	
#Variables
	##Support Config Points:
	my $ENV = "Prod";
	#my $ENV = "LowerEnv";
	my $appdir = "c:\\opt\\eod-rpt\\"; #Where should app dependencies be located -win
	my $CustomerRosterFile = "CustomerList.txt"; #Store friendly names for IDS aka Customer names like Northwinds
	my $logfile = "eodrptlog.txt"; #Log file
	my $FOOdir = "\\\\filesserver.widgets.com\\DataFolder\\"; #FOO File/BAR directory
	my $Data1dir = "\\\\filesserver.widgets.com\\DataFolder\\Import\\01\\Imported\\"; #BungaList/X100 directory
	my $readLengthFOO = 530; #How far should we read into a BARFOO file to get ID?
	my $email = 'team@widgets.com';
	#my $email = 'dude@widgets.com'; #SendTo email id
				
	##Other
	my ($size, $prettySize, $totalSize, $msg, $file, $fileFullPath, $fileContents, $ID, $CustomerName, $message); 
	my (@files, @filestats);
	##Temp
	my ($key,$value);
	
	##Build hashes to quickly match ID to pertinent data during 'Scan Stage' operations below
	# Load in a friendly name list from a FS flat file into a hash
	# example:
	#my %FOOVol = (IDstub	=>	0, 
	#			 104014753	=>	10);
	my (%FOOVol); # * ID -> FOO volume
	my (%VendVol);# * ID -> Data1 volume
	my (%CustomerList); #Pull ID~Human Friendly Customer Names into hash for later email munging


#Subs
	

#Main
	##Log run
	my $dt1 = DateTime->now();
	open LOGGER, ">>$logfile" || die "Can't open log file: $!"; #Open(append mode) log file, should create if it doesn't exist
	print LOGGER "Starting EODRPT & $dt1\n"; #If exists write start entry blurb/timestamp
	close LOGGER; # Close file when done
	
	#pull in Customer names
	open(NAMES,$appdir.$CustomerRosterFile) || die "Can't open Customer List, $!\n"; #Open Customer roster file for read in
	$ID = 0; #Safety - clear this var
	while (<NAMES>) { #Work with Customer roster file in this loop, while we have new lines to work with through while loop
    	if ($_ !~  m/^\#.*$/) { #Use this to filter comments in Customer list roster file
    		chomp($_);
     		( $ID,$CustomerName ) = split(',', $_, 2); #Split out by comma
     		$CustomerList{$ID} = $CustomerName;
    	}; 
    } close NAMES;
	
	#Build Message Body
	my $messageBody = '<body><center><table border="0" cellpadding="15"><td><table width="100%" BORDERCOLOR="BLACK"><tr><td><center>
	<font size="5" color="08427b"><b></b></font></center></td></tr></table><table width="100%"><tr><td>
	<center><img src="https://server.widget.com/Data2/images/logo.gif"></center></td></tr></table><br><font face="Chicago">
	<table width="100%"><tr><td><font size="4" color="08427b"><table width="100%"><tr><td><font size="4" color="08427b"><b>Customer FOO Data Volume</b></font></td></tr></table>
	<table border="3" width="100%" bgcolor="CCCCCC" cellpadding="3">';

	##Scan Stage
	### **FOO Phase**
	print "Scanning FOO Files\n"; #Output Human Readable Confirmation -debugging
	opendir(DIR, "$FOOdir") || die "Can't open $FOOdir: $!\n"; #Move into directory/work with dir target
	@files = readdir(DIR); closedir(DIR); #Get list of files in directory, feed into array, cleanup/close dir
	foreach $file (@files) { #Iterate through files, select files
	    if (($file =~ m/\.xml$/) && ($file !~ m/^WONDER.*$/) && ($file !~ m/^.*WONDERData3\.xml$/)) { #Get only .xml files and ignore transforms
	    	$fileFullPath = $FOOdir.$file; #Build full path for OPEN function
	    	open(thisFile,$fileFullPath) || die "Can't open $file: $!\n"; #Try to OPEN
	    	@filestats = stat(thisFile); #Get file stats, we are interested in array position 7(total size of file, in bytes),  
	    									#and 9(last modify time in seconds since the epoch) -FUTURE WORK
	    	print "File: " . $file . " is this big: " . $filestats[7] . "\n"; #Output Human Readable size -debugging
	    	$size = $filestats[7]; #Take size out block and use later 	
	    	my $temp1 =read(thisFile,$fileContents,$readLengthFOO); #Open file, get ID, in order to Read first blah chars, regex ID and put into $ID
	    		if ($fileContents =~ m/([.\>])(1[0-9]{8})/ ) {my $temp2 = $1; $ID = $2; #Rip out ID of text extract
	        	print "File: $file has this ID: $ID\n"; #Output Human Readable size -debugging
	    		} else { print "I can't find the ID in $fileFullPath\n\n"; close thisFile; next}; #Goddess of Perl, protect us from corrupt xml files, complain & drop to next file in foreach if we catch this
	    		close thisFile; #Cleanup, close file handle#Iterate through files, select file
		# move into directory/assign FSO attribute of dir target via variable
	    	#Feed size into BAR volume hash, Have $ID as scalar, $size as scalar
	    	if (! exists $FOOVol{$ID}) { #IF short loop to check if ID exists via exists
	    		print "Don't know this ID, adding $ID\n"; #Doesn't exist, add it -debugging
	    		$FOOVol{$ID}= $size; #Capture size first time
	    		$totalSize = 0; #clear variable
	    		$totalSize = $FOOVol{$ID}; #Load for testing purposes
	    	    print "Setting total size for new ID $ID at $totalSize\n"; #Output Human Readable size -debugging
	    	    $FOOVol{$ID}= $totalSize; #Set updated size for testing purposes
	    	    print "Done, next file\n\n"; #Output Human Readable Confirmation -debugging
	    	} else { #   ELSE ID key did exist, pull $totalsize value as integer and set aside
	    	    print "Known ID: $ID\n"; #Output Human Readable Confirmation -debugging
	    	    $totalSize = 0; #clear variable
	    	    $totalSize = $FOOVol{$ID}; #Load last known compiled size for impending math operation  
	    	    print "Pre-Size is $size\n"; #Output Human Readable size -debugging
	    	    print "Pre-Total size for $ID is $totalSize\n"; #Output Human Readable size -debugging
	    	    $totalSize = $totalSize + $size; # Do math to compile new size value for this known ID aka add $size to $totalsize (totalsize = totalsize + size)
	    	    print "NEW Total size for $ID is $totalSize\n";
	    	    $FOOVol{$ID}= $totalSize; #Set updated size aka update key value to new $totalsize 
	    	    print "Done, next file\n\n"; #Output Human Readable Confirmation -debugging    						
	    	};
	    	# Work with timestamps -FUTURE WORK
	    	#  Capture timestamp and compare against oldest/newest, updating scalar appropriately, etc -FUTURE WORK
	    } #Close if
	}; #Close for each
	
	
	### **Bunga List Phase**
	print "Scanning Bunga List Files\n"; #Output Human Readable Confirmation -debugging
	opendir(DIR, "$Data1dir") || die "Can't open $Data1dir: $!\n"; #Move into directory/work with dir target
	@files = readdir(DIR); closedir(DIR); #Get list of files in directory, feed into array, cleanup/close dir
	foreach $file (@files) { #Iterate through files, select files
	    if (($file =~ m/\.xml$/) && ($file !~ m/^WONDER.*$/) && ($file !~ m/^.*WONDERData3\.xml$/)) { #Get only .xml files and ignore transforms
	    	$fileFullPath = $Data1dir.$file; #Build full path for OPEN function
	    	print "$fileFullPath\n";
	    	open(thisFile,$fileFullPath) || die "Can't open $file: $!\n"; #Try to OPEN
	    	@filestats = stat(thisFile); #Get file stats, we are interested in array position 7(total size of file, in bytes),  
	    									#and 9(last modify time in seconds since the epoch) -FUTURE WORK
	    	print "File: " . $file . " is this big: " . $filestats[7] . "\n"; #Output Human Readable size -debugging
	    	$size = $filestats[7]; #Take size out block and use later 	
	    	my $temp1 =read(thisFile,$fileContents,$readLengthFOO); #Open file, get ID, in order to Read first blah chars, regex ID and put into $ID
	    		if ($fileContents =~ m/([.\>])(1[0-9]{8})/ ) {my $temp2 = $1; $ID = $2; #Rip out ID of text extract
	        	print "File: $file has this ID: $ID\n"; #Output Human Readable size -debugging
	    		} else { print "I can't find the ID in $fileFullPath\n\n"; close thisFile; next}; #Goddess of Perl, protect us from corrupt xml files, complain & drop to next file in foreach if we catch this
	    		close thisFile; #Cleanup, close file handle
	    	#Feed size into x100 volume hash, Have $ID as scalar, $size as scalar
	    	if (! exists $VendVol{$ID}) { #IF short loop to check if ID exists via exists
	    		print "Don't know this ID, adding $ID\n"; #Doesn't exist, add it -debugging
	    		$VendVol{$ID}= $size; #Capture size first time
	    		$totalSize = 0; #clear variable
	    		$totalSize = $VendVol{$ID}; #Load for testing purposes
	    	    print "Setting total size for new ID $ID at $totalSize\n"; #Output Human Readable size -debugging
	    	    $VendVol{$ID}= $totalSize; #Set updated size for testing purposes
	    	    print "Done, next file\n\n"; #Output Human Readable Confirmation -debugging
	    	} else { #   ELSE ID key did exist, pull $totalsize value as integer and set aside
	    	    print "Known ID: $ID\n"; #Output Human Readable Confirmation -debugging
	    	    $totalSize = 0; #clear variable
	    	    $totalSize = $VendVol{$ID}; #Load last known compiled size for impending math operation  
	    	    print "Pre-Size is $size\n"; #Output Human Readable size -debugging
	    	    print "Pre-Total size for $ID is $totalSize\n"; #Output Human Readable size -debugging
	    	    $totalSize = $totalSize + $size; # Do math to compile new size value for this known ID aka add $size to $totalsize (totalsize = totalsize + size)
	    	    print "NEW Total size for $ID is $totalSize\n";
	    	    $VendVol{$ID}= $totalSize; #Set updated size aka update key value to new $totalsize 
	    	    print "Done, next file\n\n"; #Output Human Readable Confirmation -debugging
			};
	    	# Work with timestamps -FUTURE WORK
	    	#  Capture timestamp and compare against oldest/newest, updating scalar appropriately, etc -FUTURE WORK
	    } #Close if
	}; #Close for each
	
	
	#output
	#$key = ""; $value = ""; #Dump Hash Table Human Readable -debugging
	#while (($key,$value) = each(%CustomerList)){print "$key, $value\n"}; #Dump Hash Table Human Readable -debugging 
	#print "\n\n"; #Dump Hash Table Human Readable -debugging
	
	#while (($key, $value) = each(%FOOVol)){print $key.", ".$value."\n"}; #Dump Hash Table Human Readable -debugging 
	#print "\n\n"; #Dump Hash Table Human Readable -debugging
	
		
	##Build Email from data above, format any nessesary data
	#Read through Customerlist, evaluating an ID one by one for FOO
	foreach $ID (sort (keys(%CustomerList))) { #Pick next ID
   		$CustomerName = $CustomerList{$ID}; #Get corresponding Customer name
   			foreach $key (sort(keys(%FOOVol))) { #find if we collected data for ID, in order to only feed out IDs that had activity
   				if ($key=$ID) { #Take sorted key above and match to ID sloted by parent loop
        			$size = $FOOVol{$key} if exists $FOOVol{$ID};  
        			$prettySize = format_bytes($size) if exists $FOOVol{$ID};
        			$message = '<tr><td width="75%">'.$ID.'&nbsp&nbsp&nbsp'.$CustomerName.'</td><td>&nbsp&nbsp'.$prettySize.'&nbsp</td></tr>' if exists $FOOVol{$ID}; 
        			$messageBody .= $message if exists $FOOVol{$ID};
        			last; #Drop out, no need to work in loop further now that we matched
        		};  		
        	};
   	};
   	
   	#Close FOO Volume sub table in message body
   	$messageBody .= '</table><br><table width="100%"><tr><td><font size="4" color="08427b"><b>Customer Bunga List Data Volume</b></font></td></tr></table><table border="3" width="100%" bgcolor="CCCCCC" cellpadding="3">';
   	
   	#Read through Customerlist, evaluating an ID one by one for BungaList
	foreach $ID (sort (keys(%CustomerList))) { #Pick next ID
   		$CustomerName = $CustomerList{$ID}; #Get corresponding Customer name
   			foreach $key (sort(keys(%VendVol))) { #find if we collected data for ID, in order to only feed out IDs that had activity
   				if ($key=$ID) { #Take sorted key above and match to ID sloted by parent loop
        			$size = $VendVol{$key} if exists $VendVol{$ID};  
        			$prettySize = format_bytes($size) if exists $VendVol{$ID};
        			$message = '<tr><td width="75%">'.$ID.'&nbsp&nbsp&nbsp'.$CustomerName.'</td><td>&nbsp&nbsp'.$prettySize.'&nbsp</td></tr>' if exists $VendVol{$ID}; 
        			$messageBody .= $message if exists $VendVol{$ID};
        			last; #Drop out, no need to work in loop further now that we matched
        		};  		
        	};
   	};
	
	##Notifcation Stage
	# create a new MIME Lite based email
	#finish messagebody
	$messageBody = $messageBody . '</table><br><table width="100%"><tr><td><center>Please contact support@widget.com with any questions regarding this report.</center></td></tr></table><br><br></td></font></table></center></body></html>';
	$msg = MIME::Lite->new(Subject => "$ENV WONDER Daily Recap & Performance", From    => 'bitbucket@widget.com', To      => $email, Type    => 'text/html',Data    => $messageBody,);
	$msg->send('smtp','mailhost.widget.com');  #$msg->send('smtp','mailhost.widget.com', Debug=>1 ) Send Email or log and die
	
	##Write historyfile for trend analysis?  Probably a datasource...

	##Log Finish
	my $dt2 = DateTime->now();
	open LOGGER, ">>$logfile" || die "Can't open log file: $!"; #Open(append mode) log file, should create if it doesn't exist
	print LOGGER "Finished EODRPT & $dt2\n"; #If exists write start entry blurb/timestamp
	close LOGGER; #Close file when done


#EOF
