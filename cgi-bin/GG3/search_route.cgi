#!/usr/bin/perl -I/www/cgi-bin/graingenes

# search_route.cgi
# created by david hummel <hummel@pw.usda.gov>
# redirect to appropriate search interface
# depending on what button was pressed on
# main GG2 search box

# cgi params:
# query = query string
# site | db (required)

use CGI qw(-no_xhtml);
use strict;
use warnings;
require "global.pl";

my $cgi = new CGI;
my $url = undef;

#foreach my $key (sort keys %ENV) {print STDERR "$ENV{$key}\n";}

my $query = &cgi_valid_query($cgi);
$query =~ s/\*//g if $query;

# site.x, site.y, db.x, db.y are hacks for IE
if (defined($cgi->param('site')) || defined($cgi->param('site.x')) || defined($cgi->param('site.y'))) {
    # "search website" button pressed -> htdig website search
    $url = $cgi->url(-base => 1);
#    $url .= "/cgi-bin/htsearch?config=gg_websearch&method=and&sort=score&format=builtin-long&words=";
    $url .= "/cgi-bin/swish/site_search/search.cgi?query=";
    $url .= &geturlstring($query) if $query;
    $url .= "&submit=Search%21&metaname=swishdefault&sort=swishrank";
#} elsif (defined($cgi->param('db')) || defined($cgi->param('db.x')) || defined($cgi->param('db.y'))) {
} else {
    if ($query) {
	$url = $cgi->url(-base => 1);
	# htdig database search
#	$url .= "/cgi-bin/htsearch?config=ON&method=and&sort=score&format=long&words=";
#	$url .= &geturlstring($query);
# Swish database search
       $url .= "/cgi-bin/swish/search.cgi?query=";
       $url .= &geturlstring($query) if $query;
       $url .= "&submit=Search%21&metaname=swishdefault&sort=swishrank";
    } else {
	# class browser
	#$url .= "/cgi-bin/graingenes/browse.cgi";
	# back to referring page
	$url = $ENV{'HTTP_REFERER'}
    }
}

print $cgi->redirect($url);
