#!/usr/bin/perl -w
# Use it under GPLv2 http://www.gnu.org/licenses/gpl-2.0.html
# copyright TiNico22 
# Latest version : https://github.com/TiNico22/secrules2html
#
# Generate an HTML table with sec rules key
# Input         : sec rules file (or directory) such as myrules.sec
# Output        : index.html in the current directory or specified filename
# Usage         : perl secrules2html.mini.pl <FILENAME|DIRNAME> [OUTPUTFILE]

use feature ':5.10';
use warnings;

our $BG_DISABLE="wheat"; ## background color for disabled rules
our $DIRNAME = $ARGV[0];
our $ARGC = scalar(@ARGV);
our @ARGUMENTS = @ARGV;
our $MAXSECFILESIZE=1048576; ## 1Mb
our $MAXINDEX = 16; ## number of index in the array
# init search pattern
our $Title="rem=Title:";
our $Type="type=";
our $Ptype="ptype=";
our $Pattern="pattern=";
our $Desc="desc=";
our $Action="action=";
our $Thresh="thresh=";
our $Window="window=";
our $Pattern2="pattern2=";
our $Ptype2="ptype2=";
our $Desc2="desc2=";
our $Action2="action2=";
our $Thresh2="thresh2=";
our $Window2="window2=";
our $Time="time=";
our $Context="context=";
our $Varmap="varmap=";
our $Script="script=";
our $Continue="continue=";
our $Context2="context2=";
our $Varmap2="varmap2=";
our $Continue2="continue2=";
our $Label="label=";
# Columns ID
our $IdID=0;
our $LineID=1;
our $TitleID=2;
our $TypeID=3;
our $PatternID=4;
our $PtypeID=18;
our $DescID=5;
our $ActionID=6;
our $ThreshID=7;
our $WindowID=8;
our $Pattern2ID=17;
our $Ptype2ID=19;
our $Desc2ID=9;
our $Action2ID=10;
our $Thresh2ID=11;
our $Window2ID=12;
our $TimeID=13;
our $OtherID=14;
our $DisableID=15;
our $FileID=16;
our $ContextID=20;
our $VarmapID=21;
our $ScriptID=22;
our $ContinueID=23;
our $Context2ID=24;
our $Varmap2ID=25;
our $Continue2ID=26;
our $LabelID=27;
# init array
sub setarray{
  undef @array; 
  my @array;
  $array[0][$IdID]="Id";
  $array[0][$LineID]="Line";
  $array[0][$TitleID]="Title";
  $array[0][$TypeID]="Type";
  $array[0][$PtypeID]="Ptype";
  $array[0][$PatternID]="Pattern";
  $array[0][$DescID]="Desc";
  $array[0][$ActionID]="Action";
  $array[0][$ThreshID]="Thr.";
  $array[0][$WindowID]="Win(s)";
  $array[0][$Pattern2ID]="Pattern2";
  $array[0][$Ptype2ID]="Ptype2";
  $array[0][$Desc2ID]="Desc2";
  $array[0][$Action2ID]="Action2";
  $array[0][$Thresh2ID]="Thresh2";
  $array[0][$Window2ID]="Win2(s)";
  $array[0][$TimeID]="Time";
  $array[0][$OtherID]="Other";
  $array[0][$DisableID]="Dis.";
  $array[0][$FileID]="File";
  return @array;
}
#Print usage on tty
sub usage_display {
  print "usage: ./secrules2html.mini.pl <FILENAME|DIRNAME> [<OUTPUTNAME>]\n
 FILENAME	: the file with sec rules such as myrules.sec\
 DIRNAME	: the directory with sec rules files\
 OUTPUTNAME     : Optional, default value is index.html\n
advice:  
 If you want to give Title to your rules use rem=Title:<MyTitle>\n\n";
}
      
# replace "key=value" by "value" only 
sub valueonly {
  $valueonly = $_[0] =~ s/\#?[a-zA-Z]*[0-9]?\=(.*)/$1/;
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
# label=
    if (/$Label/ .. /\n\n/) {
      $array[$id][$LineID]=$.; # starting rules line
      $array[$id][$FileID]=$filename; # filename
      my $tmpLine=$_;
      if ( $tmpLine =~ /^$Label/ ){ # active line
        valueonly($tmpLine);
        $Prefix="^";
        $array[$id][$TypeID]=$tmpLine;
        $array[$id][$IdID]=$id;
        $id++;
      } elsif ( $tmpLine =~ /^# ?$Label/ ) {
          valueonly($tmpLine);
          $Prefix="^# ?";
          $array[$id][$TypeID]=$tmpLine;
          $array[$id][$IdID]=$id;
          $array[$id][$DisableID]=1;
          $id++;
      }
    }  
# search for a block starting by type= and finishing by a blank line
    if (/$Type/ .. /\n\n/) {
      $array[$id][$LineID]=$.; # starting rules line
      $array[$id][$FileID]=$filename; # filename
      my $tmpLine=$_;
      if ( $tmpLine =~ /^$Type/ ){ # active line
        valueonly($tmpLine);
        $Prefix="^";
        $array[$id][$TypeID]=$tmpLine;
        $array[$id][$IdID]=$id;
        $id++;
      } elsif ( $tmpLine =~ /^# ?$Type/ ) {
          valueonly($tmpLine);
          $Prefix="^# ?";
          $array[$id][$TypeID]=$tmpLine;
          $array[$id][$IdID]=$id;
          $array[$id][$DisableID]=1;
          $id++;
      } elsif ( $tmpLine =~ /$Prefix$Title/ ){
          titlevalueonly($tmpLine);
          $array[$id-1][$TitleID]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Pattern/ ){
          valueonly($tmpLine);
          $array[$id-1][$PatternID]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Ptype/ ){
          valueonly($tmpLine);
          chomp($tmpLine);
          $array[$id-1][$PtypeID]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Desc/ ){
          valueonly($tmpLine);
          $array[$id-1][$DescID]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Action/ ){
          valueonly($tmpLine);
          $array[$id-1][$ActionID]=$tmpLine;
          while ( $array[$id-1][$ActionID] =~ /\\$/ ) { # multiligne action=
            $tmpLine=<$fh_in>;
            $tmpLine=~ s/^#(.*)/$1/;
            $array[$id-1][$ActionID].=$tmpLine;
          }
      } elsif ( $tmpLine =~ /$Prefix$Thresh/ ){
          valueonly($tmpLine);
          $array[$id-1][$ThreshID]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Window/ ){
          valueonly($tmpLine);
          $array[$id-1][$WindowID]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Pattern2/ ){
          valueonly($tmpLine);
          $array[$id-1][$Pattern2ID]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Ptype2/ ){
          valueonly($tmpLine);
          chomp($tmpLine);
          $array[$id-1][$Ptype2ID]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Desc2/ ){
          valueonly($tmpLine);
          $array[$id-1][$Desc2ID]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Action2/ ){
          valueonly($tmpLine);
          $array[$id-1][$Action2ID]=$tmpLine;
          while ( $array[$id-1][$Action2ID] =~ /\\$/ ) { # multiligne action=
            $tmpLine=<$fh_in>;
            $tmpLine=~ s/^#(.*)/$1/;
            $array[$id-1][$Action2ID].=$tmpLine;
          }
      } elsif ( $tmpLine =~ /$Prefix$Thresh2/ ){
          valueonly($tmpLine);
          $array[$id-1][$Thresh2ID]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Window2/ ){
          valueonly($tmpLine);
          $array[$id-1][$Window2ID]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Time/ ){
          valueonly($tmpLine);
          $array[$id-1][$TimeID]=$tmpLine;
      } elsif ( $tmpLine =~ /$Prefix$Context/ ){
          valueonly($tmpLine);
          $array[$id-1][$ContextID]=$tmpLine;
          $array[$id-1][$OtherID]++;
      } elsif ( $tmpLine =~ /$Prefix$Varmap/ ){
          valueonly($tmpLine);
          $array[$id-1][$VarmapID]=$tmpLine;
          $array[$id-1][$OtherID]++;
      } elsif ( $tmpLine =~ /$Prefix$Script/ ){
          valueonly($tmpLine);
          $array[$id-1][$ScriptID]=$tmpLine;
          $array[$id-1][$OtherID]++;
      } elsif ( $tmpLine =~ /$Prefix$Continue/ ){
          valueonly($tmpLine);
          $array[$id-1][$ContinueID]=$tmpLine;
          $array[$id-1][$OtherID]++;
      } elsif ( $tmpLine =~ /$Prefix$Context2/ ){
          valueonly($tmpLine);
          $array[$id-1][$Context2ID]=$tmpLine;
          print "$. CTX $Context2ID: $array[$id-1][$Context2ID]\n";
          $array[$id-1][$OtherID]++;
      } elsif ( $tmpLine =~ /$Prefix$Varmap2/ ){
          valueonly($tmpLine);
          $array[$id-1][$Varmap2ID]=$tmpLine;
          $array[$id-1][$OtherID]++;
          print "$. VAR $Varmap2ID: $array[$id-1][$Varmap2ID]\n";
      } elsif ( $tmpLine =~ /$Prefix$Continue2/ ){
          valueonly($tmpLine);
          $array[$id-1][$Continue2ID]=$tmpLine;
          $array[$id-1][$OtherID]++;
          print "$. CONT $Continue2ID: $array[$id-1][$Continue2ID]\n";
#      } elsif ( $tmpLine =~ /$Prefix$Label/ ){
#          valueonly($tmpLine);
#          $array[$id-1][$LabelID]=$tmpLine;
      }
    }
  }
  $id--;
  close ($fh_in);
  return $id;
}

# HTML output for rowspan layout (Single W2T & Pair*) 
sub print2lines{
  my $i = $_[0];
  my $disable=$array[$i][$DisableID];
  # Print 1st line
  if ( defined $disable && $disable == 1 ){
    print FOUT "\n<tr bgcolor=$BG_DISABLE>";
  } else {
    print FOUT "\n<tr>";
  }
  # print 0 to 3 rowspan=2
  for ( my $j = 0 ; $j <= 3; $j++ ){
    if ( defined $array[$i][$j] && $j == $PatternID ) {
      print FOUT "<td rowspan=2 title=\"$array[$i][$PtypeID]\">";
    } else {
      print FOUT "<td rowspan=2>";
    }
    if (defined $array[$i][$j] && $array[$i][$j] ne '') {
      if ( $j == $TypeID ){
        if ( lc ($array[$i][$j]) eq lc ("SingleWith2Thresholds\n") ) {
          print FOUT "Single W2T"
        } elsif ( lc ($array[$i][$j]) eq lc ("PairWithWindow\n") ) {
          print FOUT "Pair Win";
        } elsif ( lc ($array[$i][$j]) eq lc ("Pair\n") ) {
          print FOUT "Pair";
        }
      } else {
        print FOUT $array[$i][$j];
      }
    }
    print FOUT "</td>";
  }
  # print 4 
  if ( lc ($array[$i][$TypeID]) eq lc ("PairWithWindow\n") ) {
    print FOUT "<td title=\"$array[$i][$PtypeID]\">$array[$i][$PatternID]</td>";
  } elsif ( lc ($array[$i][$TypeID]) eq lc ("Pair\n") ) {
    print FOUT "<td title=\"$array[$i][$PtypeID]\">$array[$i][$PatternID]</td>";
  } else {
      print FOUT "<td rowspan=2 title=\"$array[$i][$PtypeID]\">$array[$i][$PatternID]</td>";
  }
  # print 5 to 8 desc1 ...
  for ( my $j = 5 ; $j <= 8; $j++ ){
    print FOUT "<td>";
    if (defined $array[$i][$j] && $array[$i][$j] ne '') {
      if ( $j == $ActionID ){ #replace \ at EOL by \<br> for html layout
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
      if ( $j == $OtherID ){ #replace \ at EOL by \<br> for html layout
        my $htmltxt='';
        if (defined $array[$i][$ContextID] && $array[$i][$ContextID] ne '') {
          $htmltxt .= "context:$array[$i][$ContextID]";
        }
        if (defined $array[$i][$VarmapID] && $array[$i][$VarmapID] ne '') {
          $htmltxt .= "varmap:$array[$i][$VarmapID]";
        }
        if (defined $array[$i][$ScriptID] && $array[$i][$ScriptID] ne '') {
          $htmltxt .= "script:$array[$i][$ScriptID]";
        }
        if (defined $array[$i][$ContinueID] && $array[$i][$ContinueID] ne '') {
          $htmltxt .= "continue:$array[$i][$ContinueID]";
        }
##"label:$array[$i][$LabelID]";
      $htmltxt =~ s/\n/\<br\>/g;
      print FOUT $htmltxt;
      } else {
        print FOUT $array[$i][$j];
      }
    }
    print FOUT "</td>";
  }
  print FOUT "</tr>";
  ############# Print 2nd line
  if ( defined $disable && $disable == 1 ){
    print FOUT "\n<tr bgcolor=$BG_DISABLE>";
  } else {
    print FOUT "\n<tr>";
  }
  # print 8 if Pair rules
  if ( lc ($array[$i][$TypeID]) eq lc ("PairWithWindow\n") ) {
      print FOUT "<td title=\"$array[$i][$Ptype2ID]\">$array[$i][$Pattern2ID]</td>";
  } elsif ( lc ($array[$i][$TypeID]) eq lc ("Pair\n") ) {
      print FOUT "<td title=\"$array[$i][$Ptype2ID]\">$array[$i][$Pattern2ID]</td>";
  }

  # print 9 to 12 desc2 to window2 in a specific row 
   for ( my $j = 9 ; $j <= 12; $j++ ){
    print FOUT "<td>";
    if (defined $array[$i][$j] && $array[$i][$j] ne '') {
      if ( $j == $Action2ID ){ #replace \ at EOL by \<br> for html layout
        my $htmltxt = $array[$i][$j];
        $htmltxt =~ s/\\/\<br\>/g;
        print FOUT $htmltxt;
      } else {
        print FOUT $array[$i][$j];
      }
    }
    print FOUT "</td>";
  }
  ## other 2
  if (defined $array[$i][$OtherID] && $array[$i][$OtherID] ne '') {
  #replace \ at EOL by \<br> for html layout
    my $htmltxt='';
    if (defined $array[$i][$Context2ID] && $array[$i][$Context2ID] ne '') {
      $htmltxt .= "context:$array[$i][$Context2ID]";
    }
    if (defined $array[$i][$Varmap2ID] && $array[$i][$Varmap2ID] ne '') {
      $htmltxt .= "varmap:$array[$i][$Varmap2ID]";
    }
    if (defined $array[$i][$Continue2ID] && $array[$i][$Continue2ID] ne '') {
      $htmltxt .= "continue:$array[$i][$Continue2ID]";
    }
    $htmltxt =~ s/\n/\<br\>/g;
    print FOUT $htmltxt;
  } 
  print FOUT "</tr>";
}

# output for mono line type
sub print1line {
  my $i = $_[0];
  # Print 1st line
  if ( defined $array[$i][$DisableID] && $array[$i][$DisableID] == 1 ){
	  print FOUT "<tr bgcolor=$BG_DISABLE>";
  } else {
    print FOUT "\n<tr>";
  }
  # print 0 to 8 and 13 to $MAXINDEX
    for ( my $j = 0 ; $j <= $MAXINDEX; $j++ ){
      if ( defined $array[$i][$j] && $j == $PatternID ) {
        print FOUT "<td title=\"$array[$i][$PtypeID]\">";
      } else {
        print FOUT "<td>";
      }
    if (defined $array[$i][$j] && $array[$i][$j] ne '') {
      if ( $j == $TypeID && lc ($array[$i][$j]) eq lc ("SingleWithThreshold\n") ) {
        print FOUT "Single WT";
      } elsif ( $j == $TypeID && lc ($array[$i][$j]) eq lc ("SingleWithScript\n") ) {
        print FOUT "Single Script";
      } elsif ( $j == $TypeID && lc ($array[$i][$j]) eq lc ("SingleWithSuppress\n") ) {
        print FOUT "Single Supp";
      } elsif ( $j == $TypeID && lc ($array[$i][$j]) eq lc ("PairWithWindow\n") ) {
        print FOUT "Pair Win";
      } elsif ( $j == $TypeID && lc ($array[$i][$j]) eq lc ("EventGroup\n") ) {
        print FOUT "Event Group";
      } elsif ( $j == $ActionID ){ #replace \ at EOL by \<br> for html layout
        my $htmltxt = $array[$i][$j];
        $htmltxt  =~ s/\\/\<br\>/g;
        print FOUT $htmltxt;
      } elsif ( $j == $OtherID ){ #replace \ at EOL by \<br> for html layout
        my $htmltxt='';
        if (defined $array[$i][$ContextID] && $array[$i][$ContextID] ne '') {
          $htmltxt .= "context:$array[$i][$ContextID]";
        }
        if (defined $array[$i][$VarmapID] && $array[$i][$VarmapID] ne '') {
          $htmltxt .= "varmap:$array[$i][$VarmapID]";
        }
        if (defined $array[$i][$ScriptID] && $array[$i][$ScriptID] ne '') {
          $htmltxt .= "script:$array[$i][$ScriptID]";
        }
        if (defined $array[$i][$ContinueID] && $array[$i][$ContinueID] ne '') {
          $htmltxt .= "continue:$array[$i][$ContinueID]";
        }
##"label:$array[$i][$LabelID]";
        $htmltxt =~ s/\n/\<br\>/g;
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
  print FOUT "<thead>\n<tr>";
  # print 0 to 8 and 13 to $MAXINDEX
  for ( my $j = 0 ; $j <= $MAXINDEX; $j++ ){
    print FOUT "<th>"; print FOUT $array[0][$j]; print FOUT "</th>";
      if ( $j == 8) {
        $j = 12 #jump to 13
      }
    }
    print FOUT "</tr>\n</thead>\n";
  #print table body (data)
  print FOUT "<tbody>";
  for ( my $i = 1 ; $i <= $id ; $i++ ){
    if ( lc ($array[$i][$TypeID]) eq lc ("SingleWith2Thresholds\n") || lc ($array[$i][$TypeID]) eq lc ("PairWithWindow\n") || lc ($array[$i][$TypeID]) eq lc ("Pair\n") ){
      print2lines($i);
    } else {
      print1line($i);#print 1 row
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
print FOUT "\n<table class=\"table table-bordered\">\n";
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
  $MAXINDEX--; ## do not print the filename columns
  $id = parseunitaryfile(".",$ARGUMENTS[0]);
  htmltable($id);
}
print FOUT "\n</table>\n";
## end of sec files parsing
htmlfooter();
# End Of HTML code
close (FOUT);
exit 0;
