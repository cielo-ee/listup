#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use File::Copy;

use Data::Dumper;

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


my @entries = &loadList($filename);

#追加/更新
if( $q->param('item')){
		my $lastno = 1;
		my ($second, $minute, $hour, $mday, $month, $year) = localtime;
		$month += 1;
		$year  += 1900;
		my $today = sprintf("%04d%02d%02d",$year,$month,$mday);
		my %entry = (
				itemno      => $lastno,
				prior       => $q->param('priority'),
				item        => $q->param('item'),
#				add_date    => $add_date,
				modify_date => $today,
				limit_date  => $q->param('limit_date'),
				detail      => $q->param('detail')
				);
#		print Dumper %entry;
		if( $q->param('modifyitem')){ #更新
				$entry{'add_date'} = $entries[$q->param('modifyitem')-1]->{add_date};
				splice(@entries,$q->param('modifyitem')-1,1,\%entry);
		}
		else{                         #追加
				$entry{'add_date'} = $today;
				push @entries,\%entry;
		}

		saveList($filename,@entries);
}


#削除
my @deleteItems = $q->param('deleteitem');
if(@deleteItems){
		@deleteItems = reverse(@deleteItems); #インデックスがずれないように後ろから削除する
		foreach my $index(@deleteItems){
				splice(@entries,$index-1,1);
		}
		saveList($filename,@entries);
#		print join(",",@deleteItems);
#		print "を削除しました\n";
}


print <<'EOS';
<form action="./listup.pl" method="post">
<table border ="1">
<tr bgcolor=" 	paleturquoise">
<td>#</td><td>優先度</td><td>項目</td><td>登録日</td><td>更新日</td><td>期日</td><td>詳細</td><td>変更</td><td>削除</td>
</tr>

EOS

my $i = 0;
foreach my $entry(@entries){
		#中身を表示
		$i++;
		print "<tr>";
		print "<td>".$q->escapeHTML($entry->{itemno})."</td>";
		print "<td>".$q->escapeHTML($entry->{prior})."</td>";
		print "<td>".$q->escapeHTML($entry->{item})."</td>";
		print "<td>".$q->escapeHTML($entry->{add_date})."</td>";
		print "<td>".$q->escapeHTML($entry->{modify_date})."</td>";
		print "<td>".$q->escapeHTML($entry->{limit_date})."</td>";
		print "<td>".$q->escapeHTML($entry->{detail})."</td>";
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
</form>

EOF

print $q->end_html;

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
						itemno      => $data[0],
						prior       => $data[1],
						item        => $data[2],
						add_date    => $data[3],
						modify_date => $data[4],
						limit_date  => $data[5],
						detail      => $data[6]
					});
		}
		close $fh or die "Error closing $filename:$!";

		return @entries;

}


sub saveList
{
		my ($filename,@entries) = @_;
		my $tmpfile  = "tmp$$";
		
		open $fh, ">", $tmpfile or die "Cannot open $tmpfile: $!";

		#print "<pre>";
		#print Dumper @entries;
		#print "</pre>";
		
		foreach my $entry(@entries){
				my $line = join("\t",($entry->{itemno},
									  $entry->{prior},
									  $entry->{item},
									  $entry->{add_date},
									  $entry->{modify_date},
									  $entry->{limit_date},
									  $entry->{detail})
								);
				print $fh $line;
				print $fh "\n";
		}
		close $fh or die "Error closing $tmpfile:$!";
		
		#ファイルの内容を書き戻す
		File::Copy::move($tmpfile, $filename) or die "Cannot move $tmpfile to $filename";
		

}