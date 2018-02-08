#!/usr/bin/perl

use strict;
use warnings;
use graingenes::colleague;

my $gg = new graingenes::colleague || die;
my $dbh = $gg->{'DBI'};
my $cgi = $gg->{'CGI'};
my $tmpl = $gg->{'TMPL'};

my $id = $cgi->param('id') || die;
my $colleagueimage = $gg->get_colleagueimage($id);

if ($cgi->param('delete')) {
    $gg->delete_colleagueimage($id);
}

print $cgi->redirect(sprintf("colleague.cgi?id=%s",$colleagueimage->{'colleagueid'}));
