#!/usr/bin/perl

use strict;
use warnings;
use graingenes::colleague;

my $gg = new graingenes::colleague || die;
my $dbh = $gg->{'DBI'};
my $cgi = $gg->{'CGI'};
my $tmpl = $gg->{'TMPL'};

my $id = $cgi->param('id') || die;
my $colleagueaddress = $gg->get_colleagueaddress($id);

if ($cgi->param('update')) {
    $gg->update_colleagueaddress($id);
}

print $cgi->redirect(sprintf("colleague.cgi?id=%s",$colleagueaddress->{'colleagueid'}));
