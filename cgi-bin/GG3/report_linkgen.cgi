#!/usr/bin/perl -I/www/cgi-bin/graingenes

# david hummel <dhummel@chip.org> 2005-02-01
# generate report.cgi links from object id or name

# cgi params
# class: valid class required
# id|name: valid id or name required

use CGI;
use DBI;
use strict;
use warnings;

require "global.pl";
our ($user,$pass,$dsn,$classes,$cgisyspath,$cgiurlpath,
     $html_include_header,$html_include_footer);

our $dbh = DBI->connect($dsn,$user,$pass);
our $cgi = new CGI;
our $class = &cgi_valid_class($cgi);
our $id = &cgi_valid_id($cgi,$dbh,$class);
our $name = &cgi_valid_name($cgi,$dbh,$class);

# start html
print $cgi->header;
print $cgi->start_html(-title=>"GrainGenes Report Link Generator")
    unless (-r $html_include_header && &print_include($html_include_header));
print $cgi->title("GrainGenes Report Link Generator");
print $cgi->h3("GrainGenes Report Link Generator");

# print form
print $cgi->start_form;
print $cgi->start_table;
print $cgi->start_Tr;
print $cgi->td($cgi->b('Class'));
#print $cgi->td($cgi->textfield(-name=>'class',
#			       -default=>undef,
#			       -size=>12,
#			       -maxlength=>25));
print $cgi->td($cgi->popup_menu(-name=>'class',
				-values=>['none',sort(keys(%$classes))],
				-default=>'none',
				-labels=>{'none'=>'select',%$classes}));
print $cgi->td('&nbsp;- and -&nbsp;');
print $cgi->td($cgi->b('ID'));
print $cgi->td($cgi->textfield(-name=>'id',
			       -default=>undef,
			       -size=>6,
			       -maxlength=>25));
print $cgi->td('&nbsp;- or -&nbsp;');
print $cgi->td($cgi->b('Name'));
print $cgi->td($cgi->textfield(-name=>'name',
			       -default=>undef,
			       -size=>20,
			       -maxlength=>25));
print $cgi->td($cgi->submit(-value=>'Submit'));
print $cgi->end_Tr;
print $cgi->end_table;
print $cgi->end_form;

# check input
if ($class && ($id || $name)) {
    # valid
    if ($name && !$id) {
	$id = $dbh->selectrow_array(sprintf("select id from %s where name = %s collate latin1_bin",$class,$dbh->quote($name)));
    } elsif (!$name && $id) {
	$name = $dbh->selectrow_array(sprintf("select name from %s where id = %s",$class,$id));
    }
    my $idurl = $cgi->url(-base=>1).$cgiurlpath."/report.cgi?class=$class&id=$id";
    my $nameurl = $cgi->url(-base=>1).$cgiurlpath.sprintf("/report.cgi?class=$class&name=%s",&geturlstring($name));
    print $cgi->start_p;
    print $cgi->b('Class').': '.$class;
    print $cgi->br;
    print $cgi->b('ID').': '.$id if $id;
    print $cgi->br;
    print $cgi->a({-href=>$idurl},$cgi->escapeHTML($idurl));
    print $cgi->br;
    print $cgi->b('Name').': '.$cgi->escapeHTML($name) if $name;
    print $cgi->br;
    print $cgi->a({-href=>$nameurl},$cgi->escapeHTML($nameurl));
    print $cgi->end_p;
} else {
    # invalid
    print $cgi->p("Invalid Class and/or ID/Name.");
}


print $cgi->end_html unless (-r $html_include_footer && &print_include($html_include_footer));
exit 0;
