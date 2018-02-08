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
    $gg->insert_colleagueobtainedfrom;
    print $cgi->redirect("colleague.cgi?id=$colleagueid");
    exit;
} elsif ($cgi->param('cancel')) {
    print $cgi->redirect("colleague.cgi?id=$colleagueid");
    exit;
}

my $sources = $gg->get_sources;
my $sourceid = $cgi->popup_menu(
				-name=>'sourceid',
				-values=>[map {$_->{'id'}} @$sources],
				-default=>undef,
				-labels=>{map {$_->{'id'}=>$_->{'name'}} @$sources}
				);

$tmpl->param('colleagueobtainedfrom'=>[{
				       'colleagueid'=>$colleagueid,
				       'colleaguename'=>$gg->get_colleaguename($colleagueid),
				       'sourceid'=>$sourceid
				        }]);

print $cgi->header;
print $tmpl->output;
