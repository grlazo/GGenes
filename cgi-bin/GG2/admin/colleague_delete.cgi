#!/usr/bin/perl

use strict;
use warnings;
use graingenes::colleague;

my $gg = new graingenes::colleague || die;
my $dbh = $gg->{'DBI'};
my $cgi = $gg->{'CGI'};
my $tmpl = $gg->{'TMPL'};

my $id = $cgi->param('id') || die;

if ($cgi->param('delete')) {
    $gg->delete_colleague($id);
    print $cgi->redirect("browse.cgi?class=colleague");
} else {
    print $cgi->redirect("colleague.cgi?id=$id");
}
