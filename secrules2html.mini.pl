#!/usr/bin/perl
# Use it under GPLv2
#
# Generate an HTML table with sec rules key
# Input         : sec rules file such as myrules.sec
# Output        : result.html in the cuurrent directory
# Usage         : perl secrules2html.mini.pl FILENAME
 
use feature ':5.10';

my $MAXSECFILESIZE=1048576; ## 1Mb
my @array;
$array[0][0]="ID";
$array[0][1]="line";
$array[0][2]="title";
$array[0][3]="type";
$array[0][4]="pattern";
$array[0][5]="desc";
$array[0][6]="action";
$array[0][7]="thresh";
$array[0][8]="window";
$array[0][9]="desc2";
$array[0][10]="action2";
$array[0][11]="thresh2";
$array[0][12]="window2";

# replace "key=value" by "value" only 
sub valueonly {
  $valueonly = $_[0] =~ s/.*\=(.*)/\1/g;
  return $valueonly;
}

print "Trying to convert sec rules config files (.sec) to an HTML output\n";

# Open output file
open (FOUT, '>', 'result.html');

# check if a file to convert is provided
die "File is not available" unless (@ARGV ==1);

#check if the file is not too big
open( my $fh_in, '<', $ARGV[0] ) or die "Can't open $ARGV[0] $!\n";
my $filesize_in= -s $fh_in;
say "$filesize_in file size in byte, max file size is $MAXSECFILESIZE";
if ( $filesize_in > $MAXSECFILESIZE ){
    die "Sec rules file is too big";
}
my $id=1;
while (<$fh_in>) {
  if (/^type=/ .. /\n\n/) {
    $array[$id][1]=$.;
    my $tmpLine=$_;
    if ( $tmpLine =~ /^type=/ ){
      valueonly($tmpLine);
      $array[$id][3]=$tmpLine;
      $array[$id][0]=$id;
      $id++;
    } elsif ( $tmpLine =~ /^pattern=/ ){
        valueonly($tmpLine);
        $array[$id-1][4]=$tmpLine;
    } elsif ( $tmpLine =~ /^desc=/ ){
        valueonly($tmpLine);
        $array[$id-1][5]=$tmpLine;
    } elsif ( $tmpLine =~ /^action=/ ){
        valueonly($tmpLine);
        $array[$id-1][6]=$tmpLine;
    } elsif ( $tmpLine =~ /^thresh=/ ){
        valueonly($tmpLine);
        $array[$id-1][7]=$tmpLine;
    } elsif ( $tmpLine =~ /^window=/ ){
        valueonly($tmpLine);
        $array[$id-1][8]=$tmpLine;
    } elsif ( $tmpLine =~ /^desc2=/ ){
        valueonly($tmpLine);
        $array[$id-1][9]=$tmpLine;
    } elsif ( $tmpLine =~ /^action2=/ ){
        valueonly($tmpLine);
        $array[$id-1][10]=$tmpLine;
    } elsif ( $tmpLine =~ /^thresh2=/ ){
        valueonly($tmpLine);
        $array[$id-1][11]=$tmpLine;
    } elsif ( $tmpLine =~ /^window2=/ ){
        valueonly($tmpLine);
        $array[$id-1][12]=$tmpLine;
    }
    $array[$id][3]="End of File";
  }
}
print FOUT "<html><head><title>SECrules2hml</title></head>
<body><h1>Extracted rules from $ARGV[0]</h1>\
<table border=1>";
for ( my $i = 0 ; $i <= $id ; $i++ ){
  print FOUT "\n";
  print FOUT "<tr>";
  for ( my $j = 0 ; $j <= 12; $j++ ){
    print FOUT "<td>"; print FOUT $array[$i][$j]; print FOUT "</td>";
  }
  print FOUT "</tr>";
}
print FOUT "</table></body></html>";

close (FOUT);
close ($fh_in);
