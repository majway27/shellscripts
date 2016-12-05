#/usr/bin/perl -s   run via: perl -s fileSearchRecusive.pl -r
# Note use of -s for switch processing.  Under windows you will need to call this script explicitly with -s (ie perl -s script) of you do not have perl file associations in place.

use Cwd;						# module for finding current working directory

# This subroutine takes the name of a directory and recursively scans down the filesystem from that point looking for files named "core"

sub ScanDirectory {
	my $workdir = shift;
	my $startdir = cwd;			# keep track of where we began
	
	print $startdir;
	
	chdir $workdir or die "Unable to enter dir $workdir: $!\n";
	opendir my $DIR, '.' or die "Unable to open dir $workdir: $!\n";
	my @names = readdir $DIR or die "Unable to read $workdir: $!\n";
	closedir $DIR;

	foreach my $name (@names) {
	next if ($name eq '.'); 	# skip the current directory entry
	next if ($name eq '..'); 	# skip the parent directory entry
	
	if (-d $name) {				# is this a directory?
		ScanDirectory($name);
		next;					# can skip to the next name in the for loop
	}
	if ($name eq 'core') {		# is this a file named "core"?  this compare is very strict, will only target core and not corelation
		# if -r specified on command line, acutally delete the file
		if ( defined $r ) {
			unlink $name or die "Unable to delete $name: $!\n";
		}
		else {
			print "found one in $workdir!\n";
		}
	}							# close if
	}							# close foreach
	chdir $startdir or die "Unable to change to dir $startdir: $!\n";
}  								

ScanDirectory('.');

# end