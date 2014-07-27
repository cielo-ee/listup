#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use File::Copy;

my $filename = "list.tsv";


my $fh;
my $q  = new CGI;

#ファイルが存在しない場合、自動で作る
if( -f $filename){
		open  $fh,">",$filename or die "Cannot open $filename:$!";
		close $fh or die "Cannot close $filename:$!";
}

print $q->header(-charset=>'utf-8');
print $q->start_html(-title=>"listup method");

print $q->h1("今日のリスト");
print "\n";

my ($second, $minute, $hour, $mday, $month, $year) = localtime;
$month += 1;
$year  += 1900;
print "<p>";
print "今日は$year年$month月$mday日<br>";
print "</p>";

if( $q->param('state')){
		print "更新：";
		print $q->param('state');
		print "優先度";
		print $q->param('priority');
		print "項目";
		print $q->param('item');
		print "登録日";
		print "期限";
		print $q->param('limit_date');
		print "詳細";
		print $q->param('detail');
		print "<br />";
		&updateList($filename,$q);
}




open $fh,"<",$filename or die "Cannot open $filename:$!";
print "<table border =\"1\">";

my $lastno = 0;
while (my $line = <$fh>){
		#中身を表示
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

		$lastno = $consecutive + 1;
}
print "</table>";
close $fh or die "Error closing $filename:$!";



	 
print <<'EOF';

<form action="./listup.pl" method="post">
優先度：<select name="priority">
<option value="A">A</option>
<option value="B">B</option>
<option value="C">C</option>
<option value="D">D</option>
<option value="E">E</option>
</select>
項目：<input type="text" name="item" size="40">
期限：<input type="text" name="limit_date" size="20">
詳細：<input type="text" name="detail" size="40">
<input type="submit" value="送信">
<input type="reset" value="リセット">
<input type="hidden" name="state" value=1>
</form>

EOF

print $q->end_html;

sub updateList
{
		my ($filename, $q) = @_;
		
		#書き出し用テンプファイル
		my $tmpfile  = "tmp$$";

		#ファイルの内容を一旦コピー
		File::Copy::move($filename,$tmpfile) or die "Cannot move $tmpfile to $filename:$!";

		my $lastno = 1;
		
		#登録内容を書き込む
		open(my $tmpfh, ">>", $tmpfile) or die "Cannot open $tmpfile: $!";
		my $date = sprintf "$year$month$mday";
		my $line = join("\t",("\n",$lastno,$q->param('priority'), $q->param('item'),$q->param('limit_date'),$q->param('detail')));
		print $tmpfh $line or die "Error Writing $tmpfile: $!";
		close $tmpfh or die "Error closing $tmpfile:$!";

		#ファイルの内容を書き戻す
		File::Copy::move($tmpfile, $filename) or die "Cannot move $tmpfile to $filename";
}