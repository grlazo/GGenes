#!/usr/bin/perl

use CGI qw(-no_xhtml);
use DBI;
use strict;
use warnings;
require 'urllib.pl';
require "global.pl";

# open db
#$dbh = DBI->connect("DBI:mysql:$mysqldb", $mysqluser, $mysqlpass);
my $cgi = new CGI;

foreach (@$results){print "$_\n";}
print $cgi->header;

print "list";
print $cgi->end_html;
