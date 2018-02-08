#!/usr/bin/perl

use strict;
use warnings;
use graingenes::colleague;

my $gg = new graingenes::colleague || die;
my $dbh = $gg->{'DBI'};
my $cgi = $gg->{'CGI'};
my $tmpl = $gg->{'TMPL'};

my $id = $gg->get_id;

if ($id) {
    $tmpl->param('colleague'=>[$gg->get_colleague($id)]);
} else {
    $tmpl->param('messages'=>"A valid Colleague ID is required");
}

print $cgi->header;
print $tmpl->output;
