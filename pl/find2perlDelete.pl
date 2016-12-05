#! /usr/bin/perl -w
    eval 'exec /usr/bin/perl -S $0 ${1+"$@"}'
        if 0; #$running_under_some_shell

use strict;
use File::Find ();

# Set the variable $File::Find::dont_use_nlink if you're using AFS,
# since AFS cheats.

# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name; 		# Full path of current filename (eq "$File::Find::dir/$_")
*dir    = *File::Find::dir;			# current directory name
*prune  = *File::Find::prune;		# 
									# $_ = current name

sub wanted;

# Traverse desired filesystems
File::Find::find({wanted => \&wanted}, '.');
exit;

my $r;

sub wanted {
    /^core$/ && -s $name && print("$name\n") && defined $r && unlink($name); # -s checks for links or zero-length files, don't want to target those
}


