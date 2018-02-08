#!/usr/bin/perl -I/data/cgi-bin/graingenes

# quickquery.cgi

# created june 2004 by david hummel <hummel@pw.usda.gov>
# Copyright (C) 2004 David Hummel <hummel@pw.usda.gov>
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# emulate ace/queryEdit

# cgi params:
# arg1,arg2,arg3,...
# query = name of predefined query in quickquery.pl

use CGI;
use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Request::Common;

require "global.pl";
our $cgiurlpath;
require "quickquery.pl";
our $quickquery;

my $cgi = new CGI;
my $query = $cgi->param('query');
my $maxargs = 10;
my $sql = $quickquery->{$query};
my $url = $cgi->url(-base => 1);

# fix args
foreach my $i (1..$maxargs) {
    my $param = "arg$i";
    my $value = $cgi->param($param);
    if ($value) {
	# escape %
	$value =~ s/([^\\]|^)\%/$1\\%/g;
	# escape _
	$value =~ s/([^\\]|^)_/$1\\_/g;
	# change * wildcard to % wildcard
	$value =~ s/([^\\]|^)\*/$1\%/g;
	# escape '
	$value =~ s/'/\\'/g;
	$cgi->param(-name=>$param,-value=>$value);
    } else {
	last;
    }
}

# substitute
$sql =~ s/\%(\d+)/$cgi->param("arg$1")/gse;

#print STDERR "\nSQL:\n$sql\n";

# redirect
#$url .= "$cgiurlpath/sql.cgi?sql=";
#$url .= &geturlstring($sql);
#print $cgi->redirect($url);

# post
$url .= "$cgiurlpath/sql.cgi";
my $ua = new LWP::UserAgent;
my $req = POST $url,
          [
            'sql'=>$sql
          ];
my $res = $ua->request($req);
if ($res->is_success) {
    print $cgi->header;
    print $res->content;
} else {
    print $cgi->header(-type=>'text/plain');
    print "unable to retrieve response\n";
}
