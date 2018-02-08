#!/usr/bin/perl

use strict;
use warnings;
use graingenes::colleague;

my $gg = new graingenes::colleague || die;
my $dbh = $gg->{'DBI'};
my $cgi = $gg->{'CGI'};
my $tmpl = $gg->{'TMPL'};

my $id = $cgi->param('id') || die;
my $colleagueremark = $gg->get_colleagueremark($id);

if ($cgi->param('update')) {
    $gg->update_colleagueremark($id);
}

print $cgi->redirect(sprintf("colleague.cgi?id=%s",$colleagueremark->{'colleagueid'}));
