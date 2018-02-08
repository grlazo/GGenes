#!/usr/bin/perl

use strict;
use warnings;
use graingenes::colleague;

my $gg = new graingenes::colleague || die;
my $dbh = $gg->{'DBI'};
my $cgi = $gg->{'CGI'};
my $tmpl = $gg->{'TMPL'};

if ($cgi->param('insert')) {
    my $id = $gg->insert_colleague;
    print $cgi->redirect("colleague.cgi?id=$id");
    exit;
} elsif ($cgi->param('cancel')) {
    print $cgi->redirect("browse.cgi?class=colleague");
    exit;
}

print $cgi->header;
print $tmpl->output;
