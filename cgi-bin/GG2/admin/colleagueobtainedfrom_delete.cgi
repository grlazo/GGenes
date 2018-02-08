#!/usr/bin/perl

use strict;
use warnings;
use graingenes::colleague;

my $gg = new graingenes::colleague || die;
my $dbh = $gg->{'DBI'};
my $cgi = $gg->{'CGI'};
my $tmpl = $gg->{'TMPL'};

my $id = $cgi->param('id') || die;
my $colleagueobtainedfrom = $gg->get_colleagueobtainedfrom($id);

if ($cgi->param('delete')) {
    $gg->delete_colleagueobtainedfrom($id);
}

print $cgi->redirect(sprintf("colleague.cgi?id=%s",$colleagueobtainedfrom->{'colleagueid'}));
