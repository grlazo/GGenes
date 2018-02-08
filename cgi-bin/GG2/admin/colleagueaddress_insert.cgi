#!/usr/bin/perl

use strict;
use warnings;
use graingenes::colleague;

my $gg = new graingenes::colleague || die;
my $dbh = $gg->{'DBI'};
my $cgi = $gg->{'CGI'};
my $tmpl = $gg->{'TMPL'};

my $colleagueid = $cgi->param('colleagueid') || die;

if ($cgi->param('insert')) {
    $gg->insert_colleagueaddress;
}

print $cgi->redirect(sprintf("colleague.cgi?id=%s",$colleagueid));
