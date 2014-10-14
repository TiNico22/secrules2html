#!/usr/bin/perl -w
# use it under GPLv2
# TiNico22
# Generate an HTML table with sec rules key
# Input         : sec rules file such as myrules.sec
# Output        : index.html in the current directory
# Usage         : perl secrules2html.mini.pl FILENAME

use feature ':5.10';
use warnings;

our $BG_DISABLE="wheat"; ## background color for disabled rules
our $DIRNAME = $ARGV[0];
our $ARGC = scalar(@ARGV);
our @ARGUMENTS = @ARGV;
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
  $array[0][7]="Thr.";
  $array[0][8]="Win(s)";
  $array[0][9]="Desc2";
  $array[0][10]="Action2";
  $array[0][11]="Thresh2";
  $array[0][12]="Win2(s)";
  $array[0][13]="Time";
  $array[0][14]="Dis.";
  $array[0][15]="File";
  return @array;
}
#Usage
sub usage_display {
  print "usage: ./secrules2html.mini.pl <FILENAME|DIRNAME> [<OUTPUTNAME>]\n
 FILENAME	: the file with sec rules such as myrules.sec\
 DIRNAME	: the directory with sec rules files\
 OUTPUTNAME     : Optional, default value is index.html\n
 If you want to give Title to your rules use rem=Title:MyTitle in your sec rules\n\n";
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

# HTML output for Single With 2 Thresh
sub printSW2T{
  my $i = $_[0];
  my $disable=$array[$i][14];
  # Print 1st line
  if ( defined $disable && $disable == 1 ){
    print FOUT "<tr bgcolor=$BG_DISABLE>";
  } else {
    print FOUT "<tr>";
  }
  # print 0 to 4 rowspan=2
  for ( my $j = 0 ; $j <= 4; $j++ ){
    print FOUT "<td rowspan=2>";
    if (defined $array[$i][$j] && $array[$i][$j] ne '') {
      if ( $j == 3 ){
        print FOUT "Single W2T"
      } else {
        print FOUT $array[$i][$j];
      }
    }
    print FOUT "</td>";
  }
  # print 5 to 8 desc1 ...
  for ( my $j = 5 ; $j <= 8; $j++ ){
    print FOUT "<td>";
    if (defined $array[$i][$j] && $array[$i][$j] ne '') {
      if ( $j == 6 ){ #replace \ at EOL by \<br> for html layout
        my $htmltxt = $array[$i][$j];
        $htmltxt =~ s/\\/\<br\>/g;
        print FOUT $htmltxt;
      } else {
        print FOUT $array[$i][$j];
      }
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
  if ( defined $disable && $disable == 1 ){
    print FOUT "<tr bgcolor=$BG_DISABLE>";
  } else {
    print FOUT "<tr>";
  }
  # print 9 to 12 desc2 to window2 in a specific row 
   for ( my $j = 9 ; $j <= 12; $j++ ){
    print FOUT "<td>";
    if (defined $array[$i][$j] && $array[$i][$j] ne '') {
      if ( $j == 10 ){ #replace \ at EOL by \<br> for html layout
        my $htmltxt = $array[$i][$j];
        $htmltxt =~ s/\\/\<br\>/g;
        print FOUT $htmltxt;
      } else {
        print FOUT $array[$i][$j];
      }
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
	  print FOUT "<tr bgcolor=$BG_DISABLE>";
  } else {
    print FOUT "<tr>";
  }
  # print 0 to 8 and 13 to $MAXINDEX
    for ( my $j = 0 ; $j <= $MAXINDEX; $j++ ){
    print FOUT "<td>";
    if (defined $array[$i][$j] && $array[$i][$j] ne '') {
      if ( $j == 3 && $array[$i][$j] eq "SingleWithThreshold\n" ) {
        print FOUT "Single WT"
      } elsif ( $j == 6 ){ #replace \ at EOL by \<br> for html layout
        my $htmltxt = $array[$i][$j];
        $htmltxt  =~ s/\\/\<br\>/g;
        print FOUT $htmltxt;
      } else {
        print FOUT $array[$i][$j];
      }
    }
    print FOUT "</td>";
    if ( $j == 8) {
      $j = 12; #jump to 13
    }
  }
  print FOUT "</tr>";
}   

## print a html table wich contain a secrules content
sub htmltable {
  #create a new table
  #print FOUT '<div><table class="table table-striped">';
  #print FOUT '<table class="table table-bordered">';
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
  print FOUT "<tbody>";
  for ( my $i = 1 ; $i <= $id ; $i++ ){
    print FOUT "<tr>";
    if ( $array[$i][3] eq "SingleWith2Thresholds\n"){
      printSW2T($i);
    } else {
      printSTD($i);#print 1 row
    }
  }
  #print FOUT "</table>";
}
##################################################
## generate the HML Header                      ##
##################################################
sub htmlheader{
print FOUT '<html>
  <head>
    <title>secrules2hml</title>
    <style media="screen" type="text/css">
    table {
      border-collapse: collapse;
    }
    table, td, th {
      border: 1px solid gray;
      padding: 4px
    }
    th {
      background-color: lightgray;
      color: black;\
    }
    </style>
  </head>
  <body bgcolor=#f5f5f5>
    <h1>Extracted rules from '.$ARGV[0].'</h1>';
}
##################################################
## generate the HML Footer                      ##
##################################################
sub htmlfooter{
  $datestring = localtime();
  print FOUT "<p align=right>generated by $0 at $datestring</p></body></html>";
  print FOUT "</body></html>";
}

##################################################
##              main                            ##
##################################################

# Open output file
# ARGV[0] file or dir to convert (mandatory)
# ARGV[1] outputname (if exist) else use index.html
if ($ARGC == 0){ # no arguments provided
  usage_display();
  die "File or Directory is not available";
} elsif ($ARGC == 1){
    print "No output file provided, using index.html as output file\n";
    open (FOUT, '>', 'index.html');
} elsif ($ARGC == 2){ ## use the named ouput file
    print "Output file  $ARGV[1]\n";
    open (FOUT, '>', $ARGV[1]);
} else {
    print "ERROR : Too many arguments\n\n";
    usage_display();
    exit 1;
}

## Start HTML CODE
htmlheader();
print FOUT '<table class="table table-bordered">';
## check if we have to parse a file or a directory
if ( -d $ARGUMENTS[0] ) {
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
} elsif ( -f $ARGUMENTS[0] ) {
  $MAXINDEX = 14; ## do not print the filename columns
  $id = parseunitaryfile(".",$ARGUMENTS[0]);
  htmltable($id);
}
print FOUT "</table>";
## end of sec files parsing
htmlfooter();
# End Of HTML code
close (FOUT);
exit 0;
