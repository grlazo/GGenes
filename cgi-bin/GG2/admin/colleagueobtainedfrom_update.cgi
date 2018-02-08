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

if ($cgi->param('update')) {
    $gg->update_colleagueobtainedfrom($id);
    print $cgi->redirect(sprintf("colleague.cgi?id=%s",$colleagueobtainedfrom->{'colleagueid'}));
    exit;
} elsif ($cgi->param('cancel')) {
    print $cgi->redirect(sprintf("colleague.cgi?id=%s",$colleagueobtainedfrom->{'colleagueid'}));
    exit;
}

my $sources = $gg->get_sources;
$colleagueobtainedfrom->{'sourceid'} = $cgi->popup_menu(
							-name=>'sourceid',
							-values=>[map {$_->{'id'}} @$sources],
							-default=>$colleagueobtainedfrom->{'sourceid'},
							-labels=>{map {$_->{'id'}=>$_->{'name'}} @$sources}
							);

$tmpl->param('colleagueobtainedfrom'=>[$colleagueobtainedfrom]);

print $cgi->header;
print $tmpl->output;
