#!/usr/bin/perl -I/www/cgi-bin/graingenes

# googleSearch.cgi
# NL 15Nov2004  (borrowed heavily from David Hummel's quickquery.cgi)

use CGI;
use strict;
use warnings;
require 'urllib.pl';		# &geturlstring 

$|=1;                        	# ensure buffer is immediately flushed after 'print'

my $cgi = new CGI;

# initialize values
my $q =  $cgi->param('q');		# args from googleSearch.html
my $site = $cgi->param('sitesearch');

if ( $site eq 'wheat.pw.usda.gov' )
{
  $q .= " site:wheat.pw.usda.gov";	# to do search of wheat.pw.usda.gov		
}

$q = &geturlstring($q);

# redirect
my $url = "http://www.google.com/search?";
$url .= "q=${q}";
print $cgi->redirect($url);
exit;
