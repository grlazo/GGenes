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
    $gg->insert_colleagueimage;
    print $cgi->redirect("colleague.cgi?id=$colleagueid");
    exit;
} elsif ($cgi->param('cancel')) {
    print $cgi->redirect("colleague.cgi?id=$colleagueid");
    exit;
}

my $images = $gg->get_images;
my $imageid = $cgi->popup_menu(
			       -name=>'imageid',
			       -values=>[map {$_->{'id'}} @$images],
			       -default=>undef,
			       -labels=>{map {$_->{'id'}=>$_->{'name'}} @$images}
			       );

$tmpl->param('colleagueimage'=>[{
				'colleagueid'=>$colleagueid,
				'colleaguename'=>$gg->get_colleaguename($colleagueid),
				'imageid'=>$imageid
				 }]);

print $cgi->header;
print $tmpl->output;
