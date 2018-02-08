#!/usr/bin/perl

require 'urllib.pl';

sub escapesq {
    # escape single quotes in strings that end up in insert/update
    my $str = shift;
    $str =~ s/'/\\'/g;
    return $str;
}

sub countrecords {
    # count number of records in an sql query
    # expects an open db handle and an sql string, returns a number

    my $dbh = shift;
    my $sql = shift;
    my $counter = 0;
    my $sth = $dbh->prepare($sql); $sth->execute;
    while (() = $sth->fetchrow) {$counter++;} $sth->finish;
    return $counter;

}

sub counttablerows	# 8Oct2004 NL: to make sure user not hogging the CPU
{			# passed sql string, returns number
  my $sql = shift;
  my $explain_sql = "explain "."$sql";
  my $sth = $dbh->prepare($explain_sql); 
  $sth->execute;
  my $tablerowcount = 0;
  while (my @row = $sth->fetchrow) 
  {
    # add up the number of table rows that mySQL thinks it has to examine
    if ( defined($row[6]) && ($row[6] > 0) ) # if there *is* a value in 7th column
    {
      $tablerowcount += $row[6];
    }
  } 
  $sth->finish;
  return $tablerowcount;
}

sub setrange {
    # check/set the sql record range input
    # expects record count, record display size and start/end values
    # returns new start/end values
    my $records = shift;
    my $rnum = shift;
    my $start = shift;
    my $end = shift;
    # $rnum records or less
    if ($records <= $rnum) {
	if ($records) {
	    $start = 1; $end = $records;
	} else {
	    $start = 0; $end = 0;
	}
    # $records > $rnum, start/end exist
    } elsif ( $start && $end ) {
	# set back to defaults
	if ( ($start !~ /^\d+$/) || ($end !~ /^\d+$/) || ($start <= 0) || ($end <= 0) || ($end < $start) || ($start > $records) ) {
	    $start = 1; $end = $rnum;
	    # set range to $rnum
	} elsif ( (($end - $start) < ($rnum - 1)) || (($end - $start) > ($rnum - 1)) ) {
	    $end = $start + ($rnum - 1);
	}
	# set re to max
	if ($end > $records) {
	    $end = $records;
	    $start = int($records/$rnum)*$rnum+1;
	}
    # $records > $rnum, start exists, end doesn't
    } elsif ( $start && !$end ) {
	# set back to defaults
	if ( ($start !~ /^\d+$/) || ($start <= 0) || ($start > $records) ) {
	    $start = 1; $end = $rnum;
	}
	# set re
	$end = $start + ($rnum - 1);
	# set re to max
	if ($end > $records) {
	    $end = $records;
	    $start = int($records/$rnum)*$rnum+1;
	}
    # $records > $rnum, end exists, start doesn't
    } elsif ( !$start && $end ) {
	# set back to defaults
	if ( ($end !~ /^\d+$/) || ($end <= 0) ) {
	    $start = 1; $end = $rnum;
	}
	# set re to max
	if ($end > $records) {
	    $end = $records;
	    $start = int($records/$rnum)*$rnum+1;
	}
	# set rs to 1, range to $rnum
	if ($start < 1) {$start = 1; $end = $rnum;}
    # $records > $rnum, start/end don't exist
    } else {$start = 1; $end = $rnum;}

    return $start,$end;
}

sub printnav {
    # print sql record nav links
    # assumes $records > $rnum
    my $records = shift; # number of records
    my $rnum = shift; # record display size
    my $startkey = shift; # key of record start parameter
    my $endkey = shift; # key of record end parameter
    my $parmref = shift; # cgi parameter hash ref
    my $cgipath = shift; # web server's cgi path
    my %parm = %{$parmref}; # copy to cgi parameter hash
    my ($e4start,$e4end,$e3start,$e3end,$e2start,$e2end,$e2mult,$recstart);
    my $urlstring;
    my $rnum_t = $rnum * 10;
    my $rnum_h = $rnum * 100;
    print "<p>[&nbsp;";
    ## print TOP link
    if ($parm{$startkey} != 1) {
	my %parmlocal = %parm;
	$parmlocal{$startkey} = 1; $parmlocal{$endkey} = $rnum;
	$urlstring = &geturlparms(\%parmlocal);
	print "<a href=\"$cgipath?$urlstring\">TOP</a>\n";
    } else {print "TOP";}
    print '&nbsp;|&nbsp;';
    ## back $rnum_h records
    if ($records >= $rnum_h) {
	if ($parm{$startkey} >= 1 && $parm{$startkey} <= $rnum_h) { # in first multiple of $rnum_h
	    print "&lt;&lt;$rnum_h";
	} else {
	    my %parmlocal = %parm;
	    $e4start = (int($parm{$startkey}/$rnum_h)-1)*$rnum_h+1; $e4end = (int($parm{$startkey}/$rnum_h)-1)*$rnum_h+$rnum;
	    $parmlocal{$startkey} = $e4start; $parmlocal{$endkey} = $e4end;
	    $urlstring = &geturlparms(\%parmlocal);
	    print "<a href=\"$cgipath?$urlstring\">&lt;&lt;$rnum_h</a>\n";
	}
	print '&nbsp;|&nbsp;';
    }
    ## back $rnum_t records
    if ($records >= $rnum_t) {
	if ($parm{$startkey} >= 1 && $parm{$startkey} <= $rnum_t) { # in first multiple of $rnum_t
	    print "&lt;&lt;$rnum_t";
	} else {
	    my %parmlocal = %parm;
	    $e3start = (int($parm{$startkey}/$rnum_t)-1)*$rnum_t+1; $e3end = (int($parm{$startkey}/$rnum_t)-1)*$rnum_t+$rnum;
	    $parmlocal{$startkey} = $e3start; $parmlocal{$endkey} = $e3end;
	    $urlstring = &geturlparms(\%parmlocal);
	    print "<a href=\"$cgipath?$urlstring\">&lt;&lt;$rnum_t</a>\n";
	}
	print '&nbsp;|&nbsp;';
    }
    ## back $rnum records
    if ($parm{$startkey} >= 1 && $parm{$startkey} <= $rnum) { # in first multiple of $rnum
	print "&lt;&lt;$rnum";
    } else {
	my %parmlocal = %parm;
	$e2start = (int($parm{$startkey}/$rnum)-1)*$rnum+1; $e2end = (int($parm{$startkey}/$rnum)-1)*$rnum+$rnum;
	$parmlocal{$startkey} = $e2start; $parmlocal{$endkey} = $e2end;
	$urlstring = &geturlparms(\%parmlocal);
	print "<a href=\"$cgipath?$urlstring\">&lt;&lt;$rnum</a>\n";
    }
    print '&nbsp;|&nbsp;';
    ## links for each $rnum
    #if ($records >= $rnum) {
	#my $e2mult;
	#if (int($records/$rnum_t) > int($parm{$startkey}/$rnum_t)) { # still in multiple of $rnum_t
	    #$e2mult = 9;
	#} else { # in last multiple of $rnum_t
	    #$e2mult = int( (($records-1)-(int($records/$rnum_t))*$rnum_t) / $rnum );
	#}
	#for (0..$e2mult) { # for multiples of $rnum
	    #if ($parm{$startkey} == (int($parm{$startkey}/$rnum_t))*$rnum_t+$_*$rnum+1) {
		#print "<b>$_</b>";
	    #} else {
		#my %parmlocal = %parm;
		#$e2start = (int($parm{$startkey}/$rnum_t))*$rnum_t + ($_*$rnum+1); $e2end = (int($parm{$startkey}/$rnum_t))*$rnum_t + ($_*$rnum+$rnum);
		#$parmlocal{$startkey} = $e2start; $parmlocal{$endkey} = $e2end;
		#$urlstring = &geturlparms(\%parmlocal);
		#print "<a href=\"$cgipath?$urlstring\">$_</a>\n";
	    #}
	    #print '&nbsp;|&nbsp;' unless $_ == $e2mult;
	#}
    #}
    print "<b>$parm{$startkey}</b> - <b>$parm{$endkey}</b> of <b>$records</b>";
    ## forward $rnum records
    print '&nbsp;|&nbsp;';
    if (int($records/$rnum) > int($parm{$endkey}/$rnum)) { # still multiple(s) of $rnum left
	my %parmlocal = %parm;
	$e2start = (int($parm{$startkey}/$rnum)+1)*$rnum+1; $e2end = (int($parm{$startkey}/$rnum)+1)*$rnum+$rnum;
	$parmlocal{$startkey} = $e2start; $parmlocal{$endkey} = $e2end;
	$urlstring = &geturlparms(\%parmlocal);
	print "<a href=\"$cgipath?$urlstring\">&gt;&gt;$rnum</a>\n";
    } else {
	print "&gt;&gt;$rnum";
    }
    ## forward $rnum_t records
    if ($records >= $rnum_t) {
	print '&nbsp;|&nbsp;';
	if (int($records/$rnum_t) > int($parm{$endkey}/$rnum_t)) { # still multiple(s) of $rnum_t left
	    my %parmlocal = %parm;
	    $e3start = (int($parm{$startkey}/$rnum_t)+1)*$rnum_t+1; $e3end = (int($parm{$startkey}/$rnum_t)+1)*$rnum_t+$rnum;
	    $parmlocal{$startkey} = $e3start; $parmlocal{$endkey} = $e3end;
	    $urlstring = &geturlparms(\%parmlocal);
	    print "<a href=\"$cgipath?$urlstring\">&gt;&gt;$rnum_t</a>\n";
	} else {
	    print "&gt;&gt;$rnum_t";
	}
    }
    ## forward $rnum_h records
    if ($records >= $rnum_h) {
	print '&nbsp;|&nbsp;';
	if (int($records/$rnum_h) > int($parm{$endkey}/$rnum_h)) { # still multiple(s) of $rnum_h left
	    my %parmlocal = %parm;
	    $e4start = (int($parm{$startkey}/$rnum_h)+1)*$rnum_h+1; $e4end = (int($parm{$startkey}/$rnum_h)+1)*$rnum_h+$rnum;
	    $parmlocal{$startkey} = $e4start; $parmlocal{$endkey} = $e4end;
	    $urlstring = &geturlparms(\%parmlocal);
	    print "<a href=\"$cgipath?$urlstring\">&gt;&gt;$rnum_h</a>\n";
	} else {
	    print "&gt;&gt;$rnum_h";
	}
    }
    ## print BOTTOM link
    print '&nbsp;|&nbsp;';
    if ($parm{$endkey} != $records) {
	my %parmlocal = %parm;
	$recstart = int(($records-1)/$rnum)*$rnum+1;
	$parmlocal{$startkey} = $recstart; $parmlocal{$endkey} = $records;
	$urlstring = &geturlparms(\%parmlocal);
	print "<a href=\"$cgipath?$urlstring\">BOTTOM</a>\n";
    } else {print "BOTTOM";}
    print "&nbsp;]</p>\n";
}
