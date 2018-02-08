#!/usr/bin/perl

# cgi params:
# id
# table (+ column names for that table)
# update|delete|insert

use strict;
use warnings;
use graingenes::colleague;

my $gg = new graingenes::colleague || die;
my $dbh = $gg->{'DBI'};
my $cgi = $gg->{'CGI'};
my $tmpl = $gg->{'TMPL'};

my @messages = ();
my $id = $cgi->param('colleagueid') || $cgi->param('id');
my $table = $cgi->param('table') || 'colleague';

# db actions
if ($cgi->param('update')) {
    my $action = "update_$table";
    if ($gg->$action($cgi->param('id'))) {
	push(@messages,"$table update OK");
    } else {
	push(@messages,"$table update Failed");
    }
} elsif ($cgi->param('delete')) {
    my $action = "delete_$table";
    if ($gg->$action($cgi->param('id'))) {
	if ($table eq 'colleague') {
	    print $cgi->redirect("browse.cgi?class=colleague");
	    exit;
	} else {
	    push(@messages,"$table delete OK");
	}
    } else {
	push(@messages,"$table delete Failed");
    }
} elsif ($cgi->param('insert')) {
    my $action = "insert_$table";
    my $newid = undef;
    if ($newid = $gg->$action($cgi->param('id'))) {
	push(@messages,"$table insert OK");
    } else {
	push(@messages,"$table insert Failed");
    }
    $id = $newid if $table eq 'colleague';
}

# determine template
if ($table eq 'colleagueimage' || $table eq 'colleagueobtainedfrom') {
} else {
}

# check id
if ($gg->get_id($id)) {
    $tmpl->param('colleague'=>[$gg->get_colleague($id)]);
} else {
    push(@messages,"A valid Colleague ID is required");
}

$tmpl->param('messages'=>join('<br>',@messages));

print $cgi->header;
print $tmpl->output;
