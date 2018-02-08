#!/usr/bin/perl

# sql.cgi
# created by david hummel <hummel@pw.usda.gov>
# generic sql interface for the mysql.graingenes database
#
#  place premade queries in a require'd file named sql.graingenes
#  files should contain a ref to an array of array refs
#  where the first element is the query description
#  and the second element is the SQL query
#
# Modified: 21may04 dem, from wheat:/cgi-bin/sql/sql.cgi
# Modified: 21may04 DDH
# NL 8Oct2004 added call to &counttablerows and variable $maxtablerows

# CGI params:
# pre -> premade query index
# sql -> sql string
# rs -> record start position
# re -> record end position

use DBI;
use CGI qw(-no_xhtml);
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
$maxtablerows = 200000;

print $cgi->header;
&printtop;

if ($cgi->param) {
    # bring in premade queries
    if (-r "sql.graingenes") {require "sql.graingenes";}
    # check params
    if (defined($in{'pre'}) && $in{'pre'} !~ /^\d+$/) {delete $in{'pre'};}
    if (!$in{'sql'} || $in{'sql'} =~ /^\s*$/) {$in{'sql'} = '';}
    if (defined($in{'rs'}) && $in{'rs'} !~ /^\d+$/) {$in{'rs'} = 1;}
    if (defined($in{'re'}) && $in{'re'} !~ /^\d+$/) {$in{'re'} = $rnum;}
    if ($in{'sql'} && (!defined($in{'pre'}) || $in{'pre'} eq '')) {
	$in{'sql'} =~ s/^\s*//; $in{'sql'} =~ s/\s*$//;
	# change \r\n (CRLF) to \n so comparisons with premade queries will succeed
	$in{'sql'} =~ s/\r\n/\n/g;
	&printform; &printresults;
    } elsif (!$in{'sql'} && defined($in{'pre'}) && $in{'pre'} ne '') {
	if (@{${$premade}[$in{'pre'}]}) {
	    # set sql to premade query
	    $in{'sql'} = ${${$premade}[$in{'pre'}]}[1];
	    # change \n to \r\n (CRLF) so comparisons with submitted values will succeed
	    #$in{'sql'} =~ s/([^\r])\n/$1\r\n/g;
	}
	&printform; &printresults;
    } elsif ($in{'sql'} && defined($in{'pre'}) && $in{'pre'} ne '') {
	# change \n to \r\n (CRLF) so comparisons with submitted values will succeed
	#$in{'sql'} =~ s/([^\r])\n/$1\r\n/g;
	# change \r\n (CRLF) to \n so comparisons with premade queries will succeed
	$in{'sql'} =~ s/\r\n/\n/g;
	if (@{${$premade}[$in{'pre'}]}) {
	    if ($in{'sql'} ne ${${$premade}[$in{'pre'}]}[1]) {
		# sql differs from premade query
		delete $in{'pre'};
	    }
	}
	&printform; &printresults;
    } else {&printform;}
} else {
	if (-r "sql.graingenes") {require "sql.graingenes";}
	delete $in{'pre'};
	$in{'sql'} = '';
	$in{'rs'} = 1;
	$in{'re'} = $rnum;
	&printform;
}

print $cgi->end_html
    unless (-r $html_include_footer && &print_include($html_include_footer));

#############

sub printtop {
print $cgi->start_html(-title=>"GrainGenes SQL Interface")
    unless (-r $html_include_header && &print_header($html_include_header));
print $cgi->h3("GrainGenes SQL Interface");
print qq~
<p><small>This page allows you to perform raw SQL queries directly.  This is the
ultimate power query.  We don't know of any other Web-accessible databases that
open this privilege to their users.  It entails some
risk but we're confident that it's minimal because we know our users are
responsible.  But, we hope, not timid.  We want this interface to be used.
Please <a href="/GG2/SQLhelp.shtml"><b>click here</b></a> for full
information on how to use it.</p></small>
~;
}

sub printform {
    # premade queries dropdown menu
    print "<table>\n";
    if (@$premade) {
	my $values = undef; $values->[0] = 'sel'; push(@$values,(0..$#{$premade}));
	my $labels = undef; $labels->{'sel'} = "-- select one --"; foreach my $i (0..$#{$premade}) {$labels->{$i} = $premade->[$i]->[0];}
	print "<tr>\n";
	print "<td><small><b>Premade Queries: </b></small></td><td colspan=\"2\">";
	print $cgi->popup_menu(
			       -name=>'pre',
			       -values=>$values,
			       -default=>'sel',
			       -labels=>$labels,
			       -onchange=>"location.href='".$cgi->url."?pre="."'+this.options[this.selectedIndex].value;"
			       );
	print "</td></tr>\n";
    }
    # sql entry box and submit/reset
    print "<tr>";
    print $cgi->start_form;
    print "<td valign=\"top\"><small><b>SQL query:&nbsp;</b></small></td>";
    print "<td colspan=\"2\"><textarea name=\"sql\" cols=\"60\" rows=\"6\" wrap=\"virtual\">$in{'sql'}</textarea></td>";
    print "</tr>\n";
    print "<tr>";
    print "<td></td>";
    print "<td><input type=\"submit\" value=\"Submit\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Schema:</b> <a href=\"/ggmigration/gg_schema_mysql/image/\">Diagrams</a> | <a href=\"/ggmigration/gg_schema_mysql/\">Table definitions</a></td>";
    print $cgi->end_form;
    print "</tr>\n";
    print "</table>\n";
}

sub printresults {
     $dbh = DBI->connect($dsn,$user,$pass);

    # make sure user not examining too many table rows in db (NL 8Oct2004)
    if ( $in{'sql'} =~ /^\s*select/i )	# mysql 'explain' only works with 'select' 
    { 
      $tablerowcount = &counttablerows($in{'sql'});
      if ( $tablerowcount > $maxtablerows )
      {
        $dbh->disconnect;
        print "This query would overload our resources.<br>";
        print "It would involve examining at least $tablerowcount rows from our GrainGenes tables.<br>";
        print "The limit is $maxtablerows rows.<br><br>";
        print "Please modify your query (maybe add a \"where\" clause or reduce its scope) and try again. [ <a href=\"$cgiurlpath/sql.cgi\">Reset</a> ]\n";
        exit(0);  # end program
      }
    } # end if sql is a 'select'

    $records = &countrecords($dbh,$in{'sql'});
    ($in{'rs'},$in{'re'}) = &setrange($records,$rnum,$in{'rs'},$in{'re'});
    $sql = $in{'sql'};
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
	## print dump as text button
	print $cgi->start_form(-action=>"$cgiurlpath/sqldump.cgi");
	print $cgi->hidden(-name=>'db',-default=>'graingenes');
	print $cgi->hidden(-name=>'sql',-default=>$in{'sql'});
	print $cgi->submit(-name=>'submit',-value=>'download text');
	print $cgi->end_form;
	## print nav links
	if ($records > $rnum) {&printnav($records,$rnum,'rs','re',\%in,$prog);}
	### print field names
	$fields_ref = $sth->{NAME};
	print "Showing records <b>$in{'rs'}</b> through <b>$in{'re'}</b> of <b>$records</b> records";
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
