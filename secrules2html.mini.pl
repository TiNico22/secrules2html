#!/usr/bin/perl -w
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
our $MAXINDEX = 14; ## number of index in the array
# init search pattern
our $Title="rem=Title:";
our $Type="type=";
our $Pattern="pattern=";
our $Desc="desc=";
our $Action="action=";
our $Thresh="thresh=";
our $Window="window=";
our $Desc2="desc2=";
our $Action2="action2=";
our $Thresh2="thresh2=";
our $Window2="window2=";
our $Time="time=";
# init array
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
$array[0][13]="Time";
$array[0][14]="Disable";

# Usage
sub usage_display {
  print "USAGE\
 perl secrules2html.mini.pl SECRULESFILE [OUTPUTNAME]\n\
 SECRULESFILE	: the file with sec rules such as myrules.sec\
 OUTPUTNAME	: Optional, default value is index.html\

 If you want to give Title to your rules use rem=Title:MyTitle\n";
}

# replace "key=value" by "value" only 
sub valueonly {
  my $valueonly = $_[0] =~ s/.*\=(.*)/$1/g;
  return $valueonly;
}
# replace "rem=Title:value" by "value" only 
sub titlevalueonly {
  my $titlevalueonly = $_[0] =~ s/.*\=Title:(.*)/$1/g;
  return $titlevalueonly;
}

# HTML output for Single With 2 Thresh
sub printSW2T {
  my $i = $_[0];
  # Print 1st line
  if ( defined $array[$i][14] && $array[$i][14] == 1 ){
    print FOUT "<tr bgcolor=silver>";
  } else {
    print FOUT "<tr>";
  }
  # print 0 to 4 rowspan=2
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

# output for line other than Single With 2 Thresh
sub printSTD {
  my $i = $_[0];
  # Print 1st line
  if ( defined $array[$i][14] && $array[$i][14] == 1 ){
    print FOUT "<tr bgcolor=silver>";
  } else {
    print FOUT "<tr>";
  }
  # print 0 to 8 and 13 to $MAXINDEX
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
##################################################
## 		main 				##
##################################################
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
##################################################
## parse the file for finding rules		##
##################################################
my $id=1;
my $Prefix="^";
while (<$fh_in>) {
# search for a block starting by type= and finishing by a blank line
  if (/$Type/ .. /\n\n/) {
    $array[$id][1]=$.;
    my $tmpLine=$_;
    if ( $tmpLine =~ /^$Type/ ){ # active line
      valueonly($tmpLine);
      $Prefix="^";
      $array[$id][3]=$tmpLine;
      $array[$id][0]=$id;
      $id++;
    } elsif ( $tmpLine =~ /^# ?$Type/ ) {
        valueonly($tmpLine);
        $Prefix="^# ?";
        $array[$id][3]=$tmpLine;
        $array[$id][0]=$id;
        $array[$id][14]=1;
        $id++;
    } elsif ( $tmpLine =~ /$Prefix$Title/ ){
        titlevalueonly($tmpLine);
        $array[$id-1][2]=$tmpLine;
    } elsif ( $tmpLine =~ /$Prefix$Pattern/ ){
        valueonly($tmpLine);
        $array[$id-1][4]=$tmpLine;
    } elsif ( $tmpLine =~ /$Prefix$Desc/ ){
        valueonly($tmpLine);
        $array[$id-1][5]=$tmpLine;
    } elsif ( $tmpLine =~ /$Action/ ){
        valueonly($tmpLine);
        $array[$id-1][6]=$tmpLine;
    } elsif ( $tmpLine =~ /$Thresh/ ){
        valueonly($tmpLine);
        $array[$id-1][7]=$tmpLine;
    } elsif ( $tmpLine =~ /$Window/ ){
        valueonly($tmpLine);
        $array[$id-1][8]=$tmpLine;
    } elsif ( $tmpLine =~ /$Desc2/ ){
        valueonly($tmpLine);
        $array[$id-1][9]=$tmpLine;
    } elsif ( $tmpLine =~ /$Action2/ ){
        valueonly($tmpLine);
        $array[$id-1][10]=$tmpLine;
    } elsif ( $tmpLine =~ /$Thresh2/ ){
        valueonly($tmpLine);
        $array[$id-1][11]=$tmpLine;
    } elsif ( $tmpLine =~ /$Window2/ ){
        valueonly($tmpLine);
        $array[$id-1][12]=$tmpLine;
    } elsif ( $tmpLine =~ /$Time/ ){
        valueonly($tmpLine);
        $array[$id-1][13]=$tmpLine;
    }
  }
}
$id--;
close ($fh_in);

##################################################
## generate the HML				##
##################################################
print FOUT '<html><head><title>secrules2hml</title>
<style media="screen" type="text/css">
table {
    border-collapse: collapse;
}
table, td, th {
    border: 1px solid black;
    padding: 5px
}
th {
    background-color: grey;
    color: white;\
}
</style>
</head>
<body bgcolor=#f5f5f5><h1>Extracted rules from '.$ARGV[0].'</h1>
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
