#!/usr/bin/perl
# use it under GPLv2
# TiNico22
# Generate an HTML table with sec rules key
# Input 	: sec rules file such as myrules.sec
# Output	: result.html in the cuurrent directory
# Usage		: perl secrules2html.mini.pl FILENAME
 
use feature ':5.10';
use warnings;

my $ARGC = scalar(@ARGV);
my $MAXSECFILESIZE=1048576; ## 1Mb
our $MAXINDEX = 13;
my @array;
$array[0][0]="ID";
$array[0][1]="Line";
$array[0][2]="Title";
$array[0][3]="Type";
$array[0][4]="Pattern";
$array[0][5]="Desc";
$array[0][6]="Action";
$array[0][7]="Thresh";
$array[0][8]="Window";
$array[0][9]="Desc2";
$array[0][10]="Action2";
$array[0][11]="Thresh2";
$array[0][12]="Window2";
$array[0][13]="Calendar";

# Usage
sub usage_display {
  print "USAGE\
 perl secrules2html.mini.pl SECRULESFILE [OUTPUTNAME]\
\
 SECRULESFILE	: the file with sec rules such as myrules.sec\
 OUTPUTNAME	: Optional, default value is index.html\

 If you want to give Title to your rules use rem=Title:MyTitle\n";
}

# replace "key=value" by "value" only 
sub valueonly {
  $valueonly = $_[0] =~ s/.*\=(.*)/$1/g;
  return $valueonly;
}
# replace "rem=Title:value" by "value" only 
sub titlevalueonly {
  $titlevalueonly = $_[0] =~ s/.*\=Title:(.*)/$1/g;
  return $titlevalueonly;
}
sub printSW2T {
# Print 1st line
print FOUT "<tr>";
# print 0 to 4 rowspan=2
  my $i = $_[0];
  for ( my $j = 0 ; $j <= 4; $j++ ){
    print FOUT "<td rowspan=2>";
    if (defined $array[$i][$j] && $array[$i][$j] ne '') {
        print FOUT $array[$i][$j];
    }
    print FOUT "</td>";
  }
# print 5 to 8 desc1 ...
  for ( my $j = 5 ; $j <= 8; $j++ ){
    print FOUT "<td>";
    if (defined $array[$i][$j] && $array[$i][$j] ne '') {
        print FOUT $array[$i][$j];
    }
    print FOUT "</td>";
  }
# print 13 to $MAXINDEX rowspan=2
  for ( my $j = 13 ; $j <= $MAXINDEX; $j++ ){
    print FOUT "<td rowspan=2>";
    if (defined $array[$i][$j] && $array[$i][$j] ne '') {
        print FOUT $array[$i][$j];
    }
    print FOUT "</td>";
  }
  print FOUT "</tr>";
  # Print 2nd line
  print FOUT "<tr>";
  # print 9 to 12 desc2 to window2 in a specific row 
  for ( my $j = 9 ; $j <= 12; $j++ ){
    print FOUT "<td>";
    if (defined $array[$i][$j] && $array[$i][$j] ne '') {
        print FOUT $array[$i][$j];
    }
    print FOUT "</td>";
  }
print FOUT "</tr>";
}
sub printSTD {
  print FOUT "<tr>";
  # print 0 to 8 and 13 to $MAXINDEX
  my $i = $_[0];
  for ( my $j = 0 ; $j <= $MAXINDEX; $j++ ){
    print FOUT "<td>";
    if (defined $array[$i][$j] && $array[$i][$j] ne '') {
        print FOUT $array[$i][$j];
    }
    print FOUT "</td>";
    if ( $j == 8) {
      $j = 12; #jump to 13
    }
  }
  print FOUT "</tr>";
}
print "Trying to convert sec rules config files (.sec) to an HTML output\n";
# check if a file to convert is provided
if ($ARGC == 0){ # no filename provided
  usage_display();
  die "File is not available";
} elsif ($ARGC == 1){
    print "No output file provided, using index.html as output file\n";
    open (FOUT, '>', 'index.html');
} elsif ($ARGC == 2){
    print "Output file  $ARGV[1]\n";
    open (FOUT, '>', $ARGV[1]);
}    
#check if the file is not too big
open( my $fh_in, '<', $ARGV[0] ) or die "Can't open $ARGV[0] $!\n";
my $filesize_in= -s $fh_in;
if ( $filesize_in > $MAXSECFILESIZE ){
    say "$filesize_in file size in byte, max file size is $MAXSECFILESIZE";
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
    } elsif ( $tmpLine =~ /^rem=Title:/ ){
        titlevalueonly($tmpLine);
        $array[$id-1][2]=$tmpLine;
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
    } elsif ( $tmpLine =~ /^time=/ ){
        valueonly($tmpLine);
        $array[$id-1][13]=$tmpLine;
    }
    $array[$id][3]="End of File";
  }
}
print FOUT '<html><head><title>secrules2hml</title>
<style media="screen" type="text/css">
table {
    border-collapse: collapse;
}
table, td, th {
    border: 1px solid darkblue;
    padding: 2px
}
th {
    background-color: grey;
    color: white;\
}
</style>
</head>
<body><h1>Extracted rules from '.$ARGV[0].'</h1>
<table>';
#print table header
print FOUT "<thead><tr>";
# print 0 to 8 and 13 to $MAXINDEX
for ( my $j = 0 ; $j <= $MAXINDEX; $j++ ){
  print FOUT "<th>"; print FOUT $array[0][$j]; print FOUT "</th>";
  if ( $j == 8) {
    $j = 12 #jump to 13
  }
}
print FOUT "</tr></thead>";
#print table body (data)
for ( my $i = 1 ; $i <= $id ; $i++ ){
  print FOUT "<tr>";
  if ( $array[$i][3] eq "SingleWith2Thresholds\n"){
    printSW2T($i);
  } else {
    printSTD($i);#print 1 row
  }
  print FOUT "</tr>";
}
print FOUT "</table>";
$datestring = localtime();
print FOUT "<p align=right>generated by $0 at $datestring</p></body></html>";

close (FOUT);
close ($fh_in);
