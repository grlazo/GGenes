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

if ($cgi->param('update')) {
    $gg->update_colleagueimage($id);
    print $cgi->redirect(sprintf("colleague.cgi?id=%s",$colleagueimage->{'colleagueid'}));
    exit;
} elsif ($cgi->param('cancel')) {
    print $cgi->redirect(sprintf("colleague.cgi?id=%s",$colleagueimage->{'colleagueid'}));
    exit;
}

my $images = $gg->get_images;
$colleagueimage->{'imageid'} = $cgi->popup_menu(
						-name=>'imageid',
						-values=>[map {$_->{'id'}} @$images],
						-default=>$colleagueimage->{'imageid'},
						-labels=>{map {$_->{'id'}=>$_->{'name'}} @$images}
						);

$tmpl->param('colleagueimage'=>[$colleagueimage]);

print $cgi->header;
print $tmpl->output;
