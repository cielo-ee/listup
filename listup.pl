#!/usr/bin/perl

use strict;
use warnings;

use CGI;

my $filename = "list.tsv";

my $fh;
my $q  = new CGI;

print $q->header;
print $q->start_html;

if( -f $filename){
		open $fh,"<",$filename or die "file open failed!\n";
		print "file \"$filename\"is found\n";
}
else{
		print "file \"$filename\"is not found\n";
		exit;
}


while (my $line = <$fh>){
		chomp $line;
		my @items = split(/\t/,$line);
		print join("\t",@items);
		print "\n";
}

print $q->end_html;
