#!/usr/bin/perl -I/data/cgi-bin/graingenes

# report_links.cgi
# created by david hummel <hummel@pw.usda.gov>
# generate report links for htdig indexing

# cgi params
# class (valid class required)

use CGI;
use DBI;
use strict;
use warnings;

require "global.pl";
our ($user,$pass,$dsn,$cgiurlpath);

our $dbh = DBI->connect($dsn,$user,$pass);
our $cgi = new CGI;
our $class = &cgi_valid_class($cgi);
#our $class = 'library';

if (!$class) {
    # invalid class
    print $cgi->header;
    print $cgi->start_html;
    print $cgi->end_html;
} else {
    my $sth = $dbh->prepare("select id,name from $class"); $sth->execute;
    my $rows = $sth->fetchall_arrayref({});
    print $cgi->header;
    print $cgi->start_html;
    foreach my $row (@$rows) {
	#my $url = "$cgiurlpath/report.cgi?class=$class;id=$row->{'id'};show=all;print=";
	my $url = sprintf("$cgiurlpath/report.cgi?class=$class;name=%s;show=all;print=",&geturlstring($row->{'name'}));
	print $cgi->a({-href=>$url},$cgi->escapeHTML($row->{'name'}));
	print $cgi->br;
    }
    print $cgi->end_html;
}
