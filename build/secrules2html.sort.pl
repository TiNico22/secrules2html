#!/usr/bin/perl -w
# use it under GPLv2
# TiNico22
# Generate an HTML table with sec rules key
# Input         : sec rules file such as myrules.sec
# Output        : result.html in the current directory
# Usage         : perl secrules2html.mini.pl FILENAME

use feature ':5.10';
use warnings;

our $BG_DISABLE="silver"; ## background color for disabled rules
$DIRNAME = $ARGV[0];
$ARGC = scalar(@ARGV);
our $MAXSECFILESIZE=1048576; ## 1Mb
our $MAXINDEX = 15; ## number of index in the array
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
sub setarray{
  undef @array; 
  my @array;
  $array[0][0]="Id";
  $array[0][1]="Line";
  $array[0][2]="Title";
  $array[0][3]="Type";
  $array[0][4]="Pattern";
  $array[0][5]="Desc";
  $array[0][6]="Action";
  $array[0][7]="Thr";
  $array[0][8]="Win";
  $array[0][9]="Desc2";
  $array[0][10]="Action2";
  $array[0][11]="Thresh2";
  $array[0][12]="Win2";
  $array[0][13]="Time";
  $array[0][14]="Dis";
  $array[0][15]="File";
  return @array;
}
#Usage
sub usage_display {
  print "USAGE\
 perl secrules2html.mini.pl SECRULESFILE [OUTPUTNAME]\
\
 SECRULESFILE   : the file with sec rules such as myrules.sec\
 OUTPUTNAME     : Optional, default value is index.html\

 If you want to give Title to your rules use rem=Title:MyTitle\n";
}
      
# replace "key=value" by "value" only 
sub valueonly {
  $valueonly = $_[0] =~ s/.*\=(.*)/$1/g;
  chomp $valueonly;
  return $valueonly;
}
# replace "rem=Title:value" by "value" only 
sub titlevalueonly {
  $titlevalueonly = $_[0] =~ s/.*\=Title:(.*)/$1/g;
  chomp($titlevalueonly);
  return $titlevalueonly;
}
##################################################
# Parse one unitary file and extract KEY=VALUE
# usage parseunitaryfile(filepath, filename);
##################################################
sub parseunitaryfile {
  my $filepath = $_[0];
  my $filename = $_[1];
  #init new array
  our @array = setarray();
  #check if the file is not too big
  open( my $fh_in, '<', "$filepath/$filename" ) or die "Can't open $filepath/$filename $!\n";
  my $filesize_in= -s $fh_in;
  if ( $filesize_in > $MAXSECFILESIZE ){
      die "Sec rules file is too big max file size is $MAXSECFILESIZE in byte";
  }
  #Parse the file to search each block starting by type=
  my $id=1;
  my $Prefix="^";
  while (<$fh_in>) {
# search for a block starting by type= and finishing by a blank line
    if (/$Type/ .. /\n\n/) {
      $array[$id][1]=$.; # starting rules line
      $array[$id][15]=$filename; # filename
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
      } elsif ( $tmpLine =~ /$Prefix$Action/ ){
          valueonly($tmpLine);
          $array[$id-1][6]=$tmpLine;
          while ( $array[$id-1][6] =~ /\\$/ ) { # multiligne action=
            $tmpLine=<$fh_in>;
            $tmpLine=~ s/^#(.*)/$1/;
            $array[$id-1][6].=$tmpLine;
          }
      } elsif ( $tmpLine =~ /$Prefix$Thresh/ ){
          valueonly($tmpLine);
          $array[$id-1][7]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Window/ ){
          valueonly($tmpLine);
          $array[$id-1][8]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Desc2/ ){
          valueonly($tmpLine);
          $array[$id-1][9]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Action2/ ){
          valueonly($tmpLine);
          $array[$id-1][10]=$tmpLine;
          while ( $array[$id-1][10] =~ /\\$/ ) { # multiligne action=
            $tmpLine=<$fh_in>;
            $tmpLine=~ s/^#(.*)/$1/;
            $array[$id-1][10].=$tmpLine;
          }
      } elsif ( $tmpLine =~ /$Prefix$Thresh2/ ){
          valueonly($tmpLine);
          $array[$id-1][11]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Window2/ ){
          valueonly($tmpLine);
          $array[$id-1][12]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Time/ ){
          valueonly($tmpLine);
          $array[$id-1][13]=$tmpLine;
      }
    }
  }
  $id--;
  close ($fh_in);
  return $id;
}


##################################################
## print a html table wich contain a secrules content
##################################################
sub htmltable {
  #print table body (data)
  for ( my $i = 1 ; $i <= $id ; $i++ ){
    print FOUT "<tr>";

  for ( my $j = 0 ; $j <= $MAXINDEX; $j++ ){
      print FOUT "<td>";
      if (defined $array[$i][$j] && $array[$i][$j] ne '') {
        if ( $j == 3 && $array[$i][$j] eq "SingleWithThreshold\n" ) {
          print FOUT "Single WT"
        } elsif ( $j == 3 && $array[$i][$j] eq "SingleWith2Thresholds\n" ) {
          print FOUT "Single W2T";
        } elsif ( $j == 6 ){ #replace \ at EOL by \<br> for html layout
          my $htmltxt = $array[$i][$j];
          $htmltxt  =~ s/\\/\<br\>/g;
          print FOUT $htmltxt;
        } else {
          print FOUT $array[$i][$j];
        }
      }
      print FOUT "</td>";
    }
    print FOUT "</tr>";
  }
}
##################################################
## Print HTML header
##################################################
sub htmlheader{
  print FOUT '<!DOCTYPE html>
<html>
<head>
        <meta charset="utf-8">
        <title>secrules2html</title>
        <link rel="stylesheet" type="text/css" href="css/bootstrap.min.css">
        <link rel="stylesheet" type="text/css" href="css/demo.css">
        <link rel="stylesheet" type="text/css" href="css/shCore.css">
        <link rel="stylesheet" type="text/css" href="css/dataTables.bootstrap.css">
        <style type="text/css" class="init">

        body { font-size: 140%; }

        </style>
        <script type="text/javascript" language="javascript" src="js/jquery.js"></script>
        <script type="text/javascript" language="javascript" src="js/jquery.dataTables.js"></script>
        <script type="text/javascript" language="javascript" src="js/dataTables.bootstrap.js"></script>
        <script type="text/javascript" language="javascript" src="js/shCore.js"></script>
        <script type="text/javascript" language="javascript" src="js/demo.js"></script>
        <script type="text/javascript" language="javascript" class="init">

$(document).ready(function() {
  $(\'#rules\').dataTable( {
    "order": [[ 15, "asc" ]],
    "lengthMenu": [[-1, 5, 10, 25, 50], ["All", 5, 10, 25, 50]],
    "columnDefs": [
            {
                "targets": [ 1 ],
                "visible": false,
                "searchable": false
            }
        ],
  } );
} );

        </script>
</head>';
  print FOUT "\n<body>\n  <h1>Extracted rules from ".$ARGV[0]."</h1>\n";
}

##################################################
## Print HTML  footer
##################################################
sub htmlfooter{
  $datestring = localtime();
  print FOUT "<p align=right>generated by $0 at $datestring</p>";
  print FOUT "</body></html>";
}

##################################################
## Main
##################################################
# Open output file
open (FOUT, '>', "index.html");

## Start HTML CODE
htmlheader();
print FOUT "<div>";
print FOUT '<table id="rules" class="table table-striped table-bordered" cellspacing="0" width="100%">';
print FOUT "<thead><tr>";
my @array = setarray();
# print table HEADER
for ( my $j = 0 ; $j <= $MAXINDEX; $j++ ){
  print FOUT "<th>"; print FOUT $array[0][$j]; print FOUT "</th>";
}
print FOUT "</tr></thead>";
print FOUT "<tbody>";
## search .sec files in a directory
opendir(DIR, $DIRNAME) or die $!;
while (my $file = readdir(DIR)) {
  # We only want files
  next unless (-f "$DIRNAME/$file");
  # find files ending in .sec
  next unless ($file =~ m/\.sec$/);
  $id = parseunitaryfile($DIRNAME,$file);
  htmltable($id);
}
closedir(DIR);
print FOUT "</tbody>";
print FOUT "</table>";
print FOUT "</div>";
## end of sec files parsing
htmlfooter();
## End Of HTML code
close (FOUT);
exit 0;
