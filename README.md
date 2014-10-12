#secrules2html
Convert SEC (simple event correlator) rules files into a web page

##secrules2html.mini.pl
###Synopsys
Simple converter, convert 1 secrulesfile to 1 html output in a table

###Usage
*$ perl secrules2html.mini.pl myrules.sec [outputfilename]*

If no outputfilename is given, writing result to index.html in the current directory

###writing rules in .sec files
####Title / rulename
The Title field is shown if the program find a rem=Title: on a rule block
####Inactive rule
A rule is detected as inactive if the program find a block starting with \#type= or \# type=

If you want to hide your commented rules simply add a # or more than one space
