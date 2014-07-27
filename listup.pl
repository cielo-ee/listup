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
if( !(-f $filename)){
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
		print "以下の内容を追加しました：";
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

my @entries = &loadList($filename);


print <<'EOS';
<form action="./listup.pl" method="post">
<table border ="1">
<tr bgcolor=" 	paleturquoise">
<td>#</td><td>優先度</td><td>項目</td><td>登録日</td><td>期日</td><td>詳細</td><td>変更</td><td>削除</td>
</tr>

EOS

my $i = 0;
foreach my $entry(@entries){
		#中身を表示
		$i++;
		print "<tr>";
		print "<td>$entry->{itemno}</td>";
		print "<td>$entry->{prior}</td>";
		print "<td>$entry->{item}</td>";
		print "<td>$entry->{add_date}</td>";
		print "<td>$entry->{limit_date}</td>";
		print "<td>$entry->{detail}</td>";
		print "<td><input type=\"radio\" name=\"modifyitem\" value=\"$i\"></td>"; #変更
		print "<td><input type=\"checkbox\" name=\"deleteitem\" value=\"$i\"></td>";
		print "</tr>\n";

#		$lastno = $entry->itemno + 1;
}


print "</table>";


print <<'EOF';

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
		File::Copy::copy($filename,$tmpfile) or die "Cannot copy $tmpfile to $filename:$!";

		my $lastno = 1;
		my ($second, $minute, $hour, $mday, $month, $year) = localtime;
		$month += 1;
		$year  += 1900;
		my $date = sprintf("%04d%02d%02d",$year,$month,$mday);
#		print $date;
		
		#登録内容を書き込む
		open(my $tmpfh, ">>", $tmpfile) or die "Cannot open $tmpfile: $!";
		my $line = join("\t",($lastno,$q->param('priority'),$q->param('item'),$date,$q->param('limit_date'),$q->param('detail')));
#		print $line;
		print $tmpfh "\n" or die "Error Writing $tmpfile: $!";
		print $tmpfh $line or die "Error Writing $tmpfile: $!";
		close $tmpfh or die "Error closing $tmpfile:$!";

		#ファイルの内容を書き戻す
		File::Copy::move($tmpfile, $filename) or die "Cannot move $tmpfile to $filename";
}

sub loadList
{
		my $filename = shift;
		
		open $fh,"<",$filename or die "Cannot open $filename:$!";

		my @lines = <$fh>;

		my @entries =();

		foreach my $line(@lines){
				chomp($line);
				my @data  = split('\t',$line);
				push(@entries,{
						itemno     => $data[0],
						prior      => $data[1],
						item       => $data[2],
						add_date   => $data[3],
						limit_date => $data[4],
						detail     => $data[5]
					});
		}
		close $fh or die "Error closing $filename:$!";

		return @entries;

}
