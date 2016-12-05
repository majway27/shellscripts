#!/usr/bin/perl -w
#RMAY - 05May2012 - Flexible File management utility
#Note - Use this utililty to move, rename, truncate files en-masse with logging and notification capability.  Built to be ran as a periodic job.  Options for NT/Nix.
#Note - I was sloppy with slashes and path building, check through script when porting between OSs for proper slash direction and escaping


#Module declaration
	use strict;
	use warnings;
	use MIME::Lite;
	use Email::Sender::Transport::SMTP;
	use DateTime;
	use File::Copy;
	
	
#Variables
	##Support Config Points:
	#my $ENV = "Prod";
	my $ENV = "LowerEnv";
	my $appdir = "c:\\opt\\Data2Mover\\"; #Where should app dependencies be located -win
	my $logFile = "monkey-filer-log.txt"; #Log file
	my $sourcePath = "\\\\filesserver.widgets.com\\DataFolder\\Import\\Data2s\\BTXML01\\Imported\\"; 			
	my $targetPath = "\\\\filesserver.widgets.com\\DataFolder\\File_import_archive_for_support\\Node01\\BTXML01\\";		
	my $targetDir;
	my $bakDir = "bak";
	my $messageBody = ""; 
	#my $email = 'team@widgets.com";
	#my $email = 'dude@widgets.com'; #SendTo email id
				
	##Other
	my @files;
	my ($msg, $message, $dt1, $file, $fileFullPath);
	my $fileCounter = 0;
	my $maxLen = 20;
	my $shortFileName = "";
	my $oldlocation = "";
	my $newlocation = "";


#Main
	##Log run
	$dt1 = DateTime->now();
	open LOGGER, ">>$logFile" || die "Can't open log file: $!"; #Open(append mode) log file, should create if it doesn't exist
	print LOGGER "Starting fileMonkey & $dt1\n"; #If exists write start entry blurb/timestamp
	close LOGGER; # Close file when done
	
	##File Management
	#Generate target dir name
	$targetDir = DateTime->now(); #set variable
	$targetDir = $targetDir->mdy('_'); #via DateTime function, use dmy method to build folder with date as the folder name 
	#check for target dir
	if (! -e $targetPath . $targetDir . "\\" ) { #create if nessesary
		print "The target directory doesn't exist, creating\n";
		mkdir $targetPath. $targetDir . "\\";
	} else { 
		print "The target directory exists, proceding\n"};
		
	#open source dir
	print "Scanning $sourcePath\n"; #Output Human Readable Confirmation -debugging
	opendir(DIR, "$sourcePath") || die "Can't open $sourcePath: $!\n"; #Move into directory/work with dir target
	@files = readdir(DIR); closedir(DIR); #Get list of files in directory, feed into array, cleanup/close dir
	foreach $file (@files) { #Iterate through files, select files
	    if (($file =~ m/\.xml$/) && (! -d $file) && ($file !~ m/..$/g)) { #Get only .xml files
	    	$fileFullPath = $sourcePath . $file; #Build full path for move/copy function
	    	#check length, truncate via move or copy via string operation
  			print "Length: (length($file) ";
  			print length($file)."\n";
      		if (length($file) > $maxLen) { #check for long filename, deal with it while move/copying
        		$shortFileName = substr($file, 0, 50);
        		$shortFileName = $shortFileName . ".xml";
        		print "shortname: $shortFileName\n";
        		$oldlocation = $sourcePath . $file;
				$newlocation = $targetPath . $targetDir . "\\" . $shortFileName;
				if (! -e $targetPath . $targetDir . "\\" . $shortFileName) {
					move($oldlocation, $newlocation);
					$fileCounter ++; #count
					print "Long file, truncated and moved\n"; }
      			} elsif (-e $targetPath . $targetDir . "\\" . $shortFileName) { #file existed, move to bak dir
      				if (! -e $targetPath . $targetDir . "\\" . $bakDir) {
      					mkdir $targetPath. $targetDir . "\\" . $bakDir;
      					print "Created $targetPath$targetDir\\$bakDir\\n"; }
      				$newlocation = $targetPath . $targetDir . "\\" . $bakDir . "\\" . $shortFileName;
      				move($oldlocation, $newlocation);
      				$fileCounter ++; #count
      				print "$targetPath$targetDir\\$shortFileName existed, moved to alternate target $targetPath$targetDir$bakDir\\$shortFileName\n";}
      				#print "No work done";}	
      		} elsif (length($file) > 3) { #not a long filename, just move/copy, filter directories .. .
      			$oldlocation = $sourcePath . $file;
				$newlocation = $targetPath . $targetDir . "\\" . $file;
      			if (! -e $targetPath . $targetDir . "\\" . $file) {
					move($oldlocation, $newlocation);
					$fileCounter ++; #count
					print "File moved\n";
      			} elsif (-e $targetPath . $targetDir . "\\" . $file) { #file existed, move to bak dir
      				if (! -e $targetPath . $targetDir . "\\" . $bakDir) {
      					mkdir $targetPath. $targetDir . "\\" . $bakDir;
      					print "Created $targetPath$targetDir\\$bakDir/\n"; }
      				$newlocation = $targetPath . $targetDir . "\\" . $bakDir . "\\" . $file;
      				move($oldlocation, $newlocation);
      				$fileCounter ++; #count
      				print "$targetPath$targetDir\\$file existed, moved to alternate target dir $targetPath$targetDir\\$bakDir\\$file\n"; }
	    }; #close .xml if
	} #Close foreach
	print "Done moving $fileCounter file(s)\n";
	
		
	##Notifcation Stage
	# create a new MIME Lite based email
	#$messageBody = $messageBody . '</table><br><table width="100%"><tr><td><center>Please contact support@widget.com with any questions regarding this report.</center></td></tr></table><br><br></td></font></table></center></body></html>';
	#$msg = MIME::Lite->new(Subject => "$ENV WONDER Daily File Archive", From    => 'bitbucket@widget.com', To      => $email, Type    => 'text/html',Data    => $messageBody,);
	#$msg->send('smtp','mailhost.widget.com');  #$msg->send('smtp','mailhost.widget.com', Debug=>1 ) Send Email or log and die
		
	##Log Finish
	my $dt2 = DateTime->now();
	open LOGGER, ">>$logFile" || die "Can't open log file: $!"; #Open(append mode) log file, should create if it doesn't exist
	print LOGGER "Finished fileMonkey & $dt2\n"; #If exists write start entry blurb/timestamp
	close LOGGER; #Close file when done	
	
#EOF