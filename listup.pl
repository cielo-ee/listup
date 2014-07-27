#!/usr/bin/perl

use strict;
use warnings;

use CGI;

my $filename = "list.tsv";

my $fh;
my $q  = new CGI;

print $q->header(-charset=>'utf-8');
print $q->start_html(-title=>"listup method");

print $q->h1("今日のリスト");
print "\n";

if( -f $filename){
		open $fh,"<",$filename or die "file open failed!\n";
		print "file \"$filename\"is found\n";
}
else{
		print "file \"$filename\"is not found\n";
		exit;
}

print "<table border =\"1\">";


while (my $line = <$fh>){
		print "<tr>";
		chomp $line;
		my @items = split(/\t/,$line);
		my ($consecutive,$priority,$add_date,$limit_date,$detail) = @items;
		print "<td>$consecutive</td>";
		print "<td>$priority</td>";
		print "<td>$add_date</td>";
		print "<td>$limit_date</td>";
		print "<td>$detail</td>";
		print "</tr>\n";
}

print "</table>";

print <<'EOF';

<form action="./listup.pl" method="post">
優先度：<select name="priority">
<option value="A">A</option>
<option value="B">B</option>
<option value="C">C</option>
<option value="D">D</option>
<option value="E">E</option>
</select>
期限：<input type="text" name="limit_date" size="40">
詳細：<input type="text" name="detail" size="40">
<input type="submit" value="送信">
<input type="reset" value="リセット">
</form>

EOF

print $q->end_html;
