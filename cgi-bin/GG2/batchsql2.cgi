#!/usr/bin/perl

# batchsql.cgi
# based on "sql.cgi," created by david hummel <hummel@pw.usda.gov>
# generic sql interface for the mysql.graingenes database
#
#  place premade queries in a require'd file named "batchsql.graingenes" (15Sep2004)
#  files should contain a ref to an array of array refs
#  where the first element is the query description
#  and the second element is the SQL query
#
# Modified: 21may04 dem, from wheat:/cgi-bin/sql/sql.cgi
# Modified: 21may04 DDH
# 15Sep2004 NLui to allow user to add specs (a,b...) to "where" clause, i.e., where x in ('a','b'...) 

# CGI params:
# pre -> premade query index
# sql -> sql string
# rs -> record start position
# re -> record end position
# list -> list of object names

use DBI;
use CGI qw(-no_xhtml);
use Template;

#use warnings;
require 'sqllib.pl';
require 'urllib.pl';
require 'global.pl';
CGI::ReadParse(*in);
$cgi = $in{CGI};
$| = 1; # Flush StdOut

# globals
$prog = $0; $prog =~ s/^.*\///;
$rnum = 25; # set maximum record display size
$maxbytes = 200000; # max bytes of uploaded data allowed (lower limit to preclude CPU overload)
#$maxbytes = 1048576; # max bytes of uploaded data allowed
$maxnames = 10000; # set maximum number of names user can enter
$maxtablerows = 200000; # set maximum number of sql table rows that query can examine
$names = ''; # string list of requested names
@names = (); # array with requested names
$requests = 0; # number of names entered
$reqbytes = 0; # bytes actually uploaded

print $cgi->header;
&printtop;

if ($cgi->param) {
    # bring in premade queries
    if (-r "batchsql.graingenes") {require "batchsql.graingenes";}

      # - remove invalid premade query number
    if (defined($in{'pre'}) && $in{'pre'} !~ /^\d+$/) {delete $in{'pre'};}

      # - "null"ify empty sql query
    if (!$in{'sql'} || $in{'sql'} =~ /^\s*$/) {$in{'sql'} = '';}   # nothing happens; page just reloads

      # - set record start/end points
    if (defined($in{'rs'}) && $in{'rs'} !~ /^\d+$/) {$in{'rs'} = 1;}
    if (defined($in{'re'}) && $in{'re'} !~ /^\d+$/) {$in{'re'} = $rnum;}

      # - if sql query entered in box (but no premade query selected):
    if ($in{'sql'} && (!defined($in{'pre'}) || $in{'pre'} eq '')) {
	$in{'sql'} =~ s/^\s*//; $in{'sql'} =~ s/\s*$//;
	# change \r\n (CRLF) to \n so comparisons with premade queries will succeed
	$in{'sql'} =~ s/\r\n/\n/g;
	&printform; 	
        &modifysql;	# evaluate the SQL query and reject/process

    } elsif (!$in{'sql'} && defined($in{'pre'}) && $in{'pre'} ne '') {
      # - if premade query selected (@premade values from batchsql.graingenes)
	if (@{${$premade}[$in{'pre'}]}) {
	    # set sql to premade query
	    $in{'sql'} = ${${$premade}[$in{'pre'}]}[1];
	}
        &printform;	# don't get query results yet if user just making dropdown selection

    } elsif ($in{'sql'} && defined($in{'pre'}) && $in{'pre'} ne '') {
      # - if sql query in box AND premade query selected
	# change \r\n (CRLF) to \n so comparisons with premade queries will succeed
	$in{'sql'} =~ s/\r\n/\n/g;
	if (@{${$premade}[$in{'pre'}]}) {
	    if ($in{'sql'} ne ${${$premade}[$in{'pre'}]}[1]) {
		# sql differs from premade query
		delete $in{'pre'};
	    }
	}
	&printform; 
        &modifysql;	# evaluate the SQL query and reject/process
    } else {&printform;}   # - if neither sql query entered nor premade selection made, just print form

} else {
# - initial page load: initialize variables and print form
	if (-r "batchsql.graingenes") {require "batchsql.graingenes";}
	delete $in{'pre'};
	$in{'sql'} = '';
	$in{'rs'} = 1;
	$in{'re'} = $rnum;
	&printform;
}

print $cgi->end_html
    unless (-r $html_include_footer && &print_include($html_include_footer));

##### SUBROUTINES (in alpha order) #####
sub grabnames			# grab contents of 'names' textbox
{
  $names = '';			# (re-)initialize
  if ( $names .= $in{'list'} ) {}
  $reqbytes = length($names);
  if ( $reqbytes > $maxbytes ) 
  {
    print "You have uploaded too much data.<br>";
    print "You uploaded $reqbytes bytes.  The limit is $maxbytes bytes.<br><br>";
    print "Please <a href=\"$cgiurlpath/batchsql.cgi\">try again</a>\n";
    exit(0);  # end program
  }  
}
#####
sub modifysql		# reject or process SQL query
{ 
  $sql = $in{'sql'};	# put parameter from SQL box into query variable
  &grabnames;		# grab contents of 'names' textbox

  if (( $sql =~ /where.*in\s*$/ ) && ( $names eq '' || $names =~ /^\s*$/ )) 
  {			# SQL box has "where...in" clause but 'names' box is empty
    print "Please enter a list of names to limit your query results or remove&frasl;modify the &ldquo;where&rdquo; clause in your SQL query.";
    # unnec: $in{'sql'} = ''; exit(0);
  }
  elsif ( $names eq '' || $names =~ /^\s*$/ ) 	# 'names' box is empty
  {			# (user may have intended to submit a valid query w/o list, e.g., "show tables")
    &printresults;	# print query results
  }
  else			# there is something in 'names' box
  {
    if ( $sql =~ /(where.*in\s*$)|(where.*like\s*$)/ )	# 'names' there, and SQL query ends with "where...in" clause
    {
      &parsenames;
      $in{'sql'} = $sql;	# put finished query into parameter (needed by sqldump.cgi and 'require' subs)
      &printresults;		# print query results
    }
    else			# 'names' there, SQL query has "where...in," but does NOT end in "where...in"
    {
      $sql = $in{'sql'};

      if ( $sql =~ s/(where.*in\s*)|(where.*like\s*$)\(.*\)\s*$/$1/is ) # get rid of everything after "where...in"
      {		# because clicking navlink puts entire SQL parameter, incl. names, in SQL box
      		#  If user then modifies 'list,' the old names have to be replaced with new names.
        &grabnames;
        &parsenames;
        $in{'sql'} = $sql;
        &printresults;
      }
      else			# 'names' there, but SQL query does NOT contain "where...in"
      {
        print "You provided a list of names but your SQL query does not end with a &ldquo;where...in&rdquo; clause.";
      }
    } # end if sql query ends with "where...in"
  } # end if nothing/something in 'names' box

# for debug; remove when testing complete:
print "Input parameter is: ZZZ", "$in{'sql'}", "ZZZ\n";
print "Final query is: XXX","$sql", "XXX";

} # end modifysql
#####
sub parsenames
{
  $names =~ s/^\s+//; $names =~ s/\s+$//; 	# get rid of leading/trailing spaces/rows
						# unnec: @names = ();
  @names = split (/[\r\n]+/, $names);		# split list out into individual names
  $requests = @names;	  			# number of names

  if ($requests > $maxnames)			# too many names entered
  { 
    print "You have entered more than $maxnames names.<br><br>";
    print "Please <a href=\"$cgiurlpath/batchsql.cgi\">try again</a> with &lt;= $maxnames accessions.\n";
    exit(0); 
  }  
  else						# not too many names -> append names to sql query
  {
    $sql .= " (\"";		# (single quote not used due to objects like Locus 'Sr21')
    foreach $name (@names)
    {
      $name =~ s/^\s+//; 	# remove leading/trailing spaces
      $name =~ s/\s+$//;
      $sql .= "$name"."\",\"";
    }
    $sql .= "\")"; 		# extra "" doesn't matter
  }
}
#####
sub printform {
    # premade queries dropdown menu
    print "<table>\n";
    if (@$premade) {  # @premade is an array populated in file "batchsql.graingenes"
	my $values = undef; $values->[0] = 'sel'; push(@$values,(0..$#{$premade}));
	my $labels = undef; $labels->{'sel'} = "-- select one --"; foreach my $i (0..$#{$premade}) {$labels->{$i} = $premade->[$i]->[0];}
	print "<tr>\n";
	print "<td><small><b>Premade Queries:</b></small> </td><td colspan=\"2\">";
	print $cgi->popup_menu(
			       -name=>'pre',
			       -values=>$values,
			       -default=>'sel',
			       -labels=>$labels,
			       -onchange=>"location.href='".$cgi->url."?pre="."'+this.options[this.selectedIndex].value;"
			       );
	print "</td></tr>\n";
    }

    # SQL entry box 
    print "<tr>";
    print $cgi->start_form;
    print "<td valign=\"top\"><small><b>SQL query:</b></small>
           <small>
           <li>End query with <i>&ldquo;where ... in&rdquo;&nbsp;</i>
           </small></td>";
    print "<td colspan=\"2\"><textarea name=\"sql\" cols=\"60\" rows=\"6\" wrap=\"virtual\">$in{'sql'}</textarea></td>";
    print "</tr>\n";

    # box to add list of names
    #  (space-delimited list would not work for multi-word names)
    print "<tr>";
    # specifying td width in next line doesn't fix textwrap problem.
    print "<td valign=\"top\">
           <small>
           <b>Enter list</b> of up to $maxnames names:&nbsp;
           <li>One name per line
               <li>Click <i>&ldquo;Submit&rdquo;</i>
           </small>
           </td>";
    print "<td colspan=\"2\">";
    printf "<textarea name=\"list\" cols=\"60\" rows=\"6\" wrap=\"virtual\">%s</textarea>",$in{'list'};
    print "</td>";
    print "</tr>";
    
    print "<tr>";
    print "<td></td>";
    print "<td><input type=\"submit\" value=\"Submit\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Schema:</b> <a href=\"/ggmigration/gg_schema_mysql/image/\">Diagrams</a> | <a href=\"/ggmigration/gg_schema_mysql/\">Table definitions</a></td>";
    print $cgi->end_form;
    print "</tr>\n";
    print "</table>\n";
}
#####
sub printresults {
    $dbh = DBI->connect($dsn,$user,$pass);

    # make sure user not examining too many table rows in db
    if ( $sql =~ /^\s*select/i )	# mysql 'explain' only works with 'select'
    { 
      $tablerowcount = &counttablerows($sql);
      if ( $tablerowcount > $maxtablerows )	
      {
        $dbh->disconnect;
        print "This query would overload our resources.<br>";
        print "It would involve examining at least $tablerowcount rows from our GrainGenes tables.<br>";
        print "The limit is $maxtablerows rows.<br><br>";
        print "Please modify your query (maybe add a \"where\" clause or reduce its scope) and try again. [ <a href=\"$cgiurlpath/batchsql.cgi\">Reset</a> ]\n";
        exit(0);  # end program
      }
    } # end if sql starts w/select

    $records = &countrecords($dbh,$sql);  # previously: $records = &countrecords($dbh,$in{'sql'});

    ($in{'rs'},$in{'re'}) = &setrange($records,$rnum,$in{'rs'},$in{'re'});

    # limit rows to view for select statements
    #if ($sql =~ /^select/i) {
    	#$sqloffset = $in{'rs'} - 1; $sqlmax = $in{'re'} - $sqloffset;
   	#$sql .= " limit $sqloffset,$sqlmax";
    #}

    $sth = $dbh->prepare($sql); $sth->execute; $ErrNum = $dbh->err; $ErrText = $dbh->errstr;
#    if ($ErrNum) {print "<b>Sorry, but there was a problem with your query</b>: $ErrText";}
# 12Nov2004 NL add more informative message for if too-long process is killed by pkill.pl:
    if ($ErrNum) {
      if (($ErrNum == 2013) || ($ErrNum == 2006))
        { $ErrText .= " (The connection may have timed out because your query was too broad.  If a more specific query does not work, please use the \"Contact Curators\" link for assistance.)"; }
      print "<b>Sorry, but there was a problem with your query</b>: $ErrText";
    }

    else { # start printing results
	## print 'download text' button
	print $cgi->start_form(-action=>"$cgiurlpath/sqldump.cgi");
	print $cgi->hidden(-name=>'db',-default=>'graingenes');
	print $cgi->hidden(-name=>'sql',-default=>$in{'sql'});
	print $cgi->submit(-name=>'submit',-value=>'download text');
	print $cgi->end_form;
	## print nav links
	if ($records > $rnum) {&printnav($records,$rnum,'rs','re',\%in,$prog);}
	### print field names
	$fields_ref = $sth->{NAME};
	printf("Showing record%s %s of %s record%s", 
	        $in{'rs'} == $in{'re'} ? "" : "s", 
		$in{'rs'} != $in{'re'} ? sprintf("%s through %s", $cgi->b($in{'rs'}), $cgi->b($in{'re'})) : $cgi->b($in{'rs'}), 
		$cgi->b($records), 
		$records == 1 ? "" : "s");
	#originally: print "Showing records <b>$in{'rs'}</b> through <b>$in{'re'}</b> of <b>$records</b> records";
	print "<table border=\"1\" cellpadding=\"5\" cellspacing=\"0\">\n";
	print "<tr>";
	foreach (@$fields_ref) {print "<td valign=\"top\"><b>$_</b></td>";}
	print "</tr>\n";
	### print each record
	my $ctr = 0;
	my $linkcols = &sql_link_cols($sql);
	while (@row = $sth->fetchrow) {
	    $ctr++; unless ($ctr >= $in{'rs'} && $ctr <= $in{'re'}) {next;}
	    if ($ctr > $in{'re'}) {$sth->finish; last;}
	    print "<tr>"; # open row
	    foreach (0..$#row) {
		my $cell = '';
		#if (!defined($row[$_])) {$cell = 'NULL';}
		if (!defined($row[$_]) || $row[$_] eq "") {$cell = "\&nbsp;";}
		elsif ((my ($class) = ($fields_ref->[$_] =~ /^(?:[a-z]+_|)([a-z]+)id$/))) {
		    # link to report.cgi for <class>id columns
		    if (&valid_class($class)) {
		        my $id = $row[$_];
		        $cell = "<a href=\"/cgi-bin/graingenes/report.cgi?class=$class;id=$id\">$id</a>";
		    } else {
		        $cell = $row[$_];
		    }
		} elsif ($linkcols->{$_}) {
		    # link to report.cgi for valid name columns
		    #$cell = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=$linkcols->{$_};name=".&geturlstring($row[$_])},
		    #		    $cgi->escapeHTML($row[$_])
		    #		    );
		    # NL 8Nov2004:  inserted fork to account for maps not yet in cmap:
		    if ( $linkcols->{$_} eq 'map' )		# account for map records not yet in cmap
                    {
	              my ($cmapname) = $dbh->selectrow_array(sprintf("select map_name from cmap_map where map_name = %s",$dbh->quote($row[$_])));
	              if ($cmapname) 
	              {
	                # make a link
                        $cell = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map&name=".&geturlstring($row[$_]),-target=>'_blank'},$row[$_]);
	              } 
	              else 
	              {
	                # just print the name of the map
                        $cell = $cgi->escapeHTML($row[$_]);
	              }
                    }
                    else  	# not a 'map' --> make a link
                    {
                      $cell = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=$linkcols->{$_};name=".&geturlstring($row[$_])},
                                               $cgi->escapeHTML($row[$_])
                                     );
                    } # NL end fork
		} else {
		    $cell = $cgi->escapeHTML($row[$_]);
		}
		print "<td valign=\"top\"><small>$cell</small></td>";
	    }
	    print "</tr>\n"; # close row
	}
	$dbh->disconnect;
	print "</table>\n";
	## print nav links again
	if ($records > $rnum) {&printnav($records,$rnum,'rs','re',\%in,$prog);}
    }
}
#####
sub printtop {
print $cgi->start_html(-title=>"GrainGenes Batch SQL Interface")
    unless (-r $html_include_header && &print_header($html_include_header));
print $cgi->h3("GrainGenes Batch SQL Interface");
print qq~
<small>
<p>
This page allows you to query GrainGenes directly using SQL. 
Please <a href="/GG2/SQLhelp.shtml"><b>click here</b></a> for detailed
information on how to use it.  
</p>
<p>
Unlike our regular <a href="sql.cgi">GrainGenes SQL Interface</a>,
this page can accept a list of names and restrict query results to only those items. 
Simply enter a "select...where...in" query in the <b>SQL</b> box (or choose a 
<b>Premade Query</b>),
then enter the names of interest in the lower box.  
</p>
<p>
For designing queries, the four Premade Queries at the bottom of the menu may be helpful in exploring the GrainGenes schema.
</p>
</small>
~;
}
#####
sub sql_link_cols {
    # parse sql to look for columns with valid class names
    # so that report links can be made to them
    # columns must be of the form <class>[_<whatever>].name
    my $sql = shift;
    my %linkcols = ();
    $sql =~ s/^ *(--|\#).*$//gm; # remove SQL comments
    $sql =~ s/^.*select\s+(distinct|)//is; # remove select
    $sql =~ s/\s*from.*$//is; # remove from...
    my @cols = split(/,/, $sql);
    foreach my $i (0..$#cols) {
	$cols[$i] =~ s/^\s+//; # remove leading space
	$cols[$i] =~ s/\s+$//; # remove trailing space
	$cols[$i] =~ s/\s+(as|)\s+\w+$//i; # remove alias
        if ($cols[$i] =~ m/\.name/i) {
	    my ($table) = split(/\./, $cols[$i]);
	    # allow for table aliases of the form <class>_<whatever>
	    # so those columns can still become report links
	    $table =~ s/_[a-z0-9]+$//i;
	    if (&valid_class($table)) {
		$linkcols{$i} = $table;
	    }
	}
    }
    return \%linkcols;
}
