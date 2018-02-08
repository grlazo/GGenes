#!/usr/bin/perl
# $Id: browsen.cgi,v 1.1 2006/02/23 07:57:15 hummel Exp $

# cgi params:
# class (optional)
# query (optional)
# begin

use strict;
use warnings;
use graingenes::browse;

my $ggb = new graingenes::browse || die;
my $dbh = $ggb->{'DBI'};
my $cgi = $ggb->{'CGI'};
#my $jscode = "";

my $recordview = $graingenes::browse::recordview;
my $columns = $graingenes::browse::columns;
my $rows = $graingenes::browse::rows;
my $tablewidth = $graingenes::browse::tablewidth;
my $recordlimit = $graingenes::browse::recordlimit;
my $namelength = $graingenes::browse::namelength;
my $cellwidth = $graingenes::browse::cellwidth;
my $classes = $graingenes::browse::classes;

my $header = $ggb->get_html_header;
my $footer = $ggb->get_html_footer;

my $class = $ggb->get_class;
my $query = $ggb->get_query;
my $begin = $ggb->get_begin;

my $classcount = $ggb->count_classes;

# redo with wildcards if querying
while ($query && scalar(keys(%$classcount)) == 0) {
    if ($query !~ /([^\\]|^)\*$/) {
	# add trailing wildcard
	$query = $query . '*';
	$cgi->param(-name=>'query',-value=>$query);
	$classcount = $ggb->count_classes;
	next;
    } elsif ($query !~ /^([^\\]|)\*/) {
	# add leading wildcard
	$query = '*' . $query;
	$cgi->param(-name=>'query',-value=>$query);
	$classcount = $ggb->count_classes;
	next;
    } else {
	last;
    }
}

# determine type of output based on $classcount
if (scalar(keys(%$classcount)) == 0) {
    # no results
    print $cgi->header;
    print $cgi->start_html(-title=>"GrainGenes Admin Class Browser")
	  unless (-r $header && $ggb->print_include($header));
    print $cgi->title("GrainGenes Admin Class Browser");
    print $cgi->h3("GrainGenes Admin Class Browser");
    $ggb->print_form;
    print $cgi->p($cgi->hr);
    print $cgi->p($cgi->b('No Results!'));
    print $cgi->end_html
	  unless (-r $footer && $ggb->print_include($footer));
} elsif (scalar(keys(%$classcount)) == 1) {
    ### only one class with results
    my ($class) = keys(%$classcount);
    my $recordcount = $classcount->{$class};
    $cgi->param('class',$class);
    my $pagerecords = $ggb->get_page_records;
    my $rows = $rows;
    $rows = scalar(@$pagerecords) if (scalar(@$pagerecords) < $rows);
    if ($recordcount == 1) {
	# go directly to the update page
	my $id = $pagerecords->[0]->{'id'};
	my $name = $pagerecords->[0]->{'name'};
	#print $cgi->redirect($cgi->url(-base=>1)."/$class.cgi?id=$id");
	print $cgi->redirect("report.cgi?class=$class&name=$name");
	exit;
    } else {
	# list record names as links to reports
	print $cgi->header;
	print $cgi->start_html(-title=>"GrainGenes Class Browser")
	      unless (-r $header && $ggb->print_include($header));
	print $cgi->title("GrainGenes Class Browser: $classes->{$class}");
	#print $cgi->p("<script>".$jscode."</script>");
	print $cgi->h3("GrainGenes Class Browser");
	$ggb->print_form;
	print $cgi->p($cgi->hr);
	print $cgi->p($cgi->b('Results'),':&nbsp;');
	 print "<div id=details class='listlink'>";
         print $cgi->p( sprintf("%s Record%s%s in Class %s",
			      $cgi->b($recordcount),
			      $recordcount == 1 ? "" : "s",
			      $query ? sprintf(" matching %s",$cgi->b($query)) : '',
			      $cgi->b($classes->{$class})
			      )
		      );
		# pager and name drop-down
	if ($recordcount > $recordview) {	    
	    $ggb->print_pager;
	}
	# print the update links in a table
	print $cgi->start_p;
	print $cgi->start_table({-border=>0,-cellpadding=>3});
	for (my $row=1; $row<=$rows; $row++) {
	    print $cgi->start_Tr;
	    foreach my $column (1..$columns) {
		my $pagerecord = (($column-1)*$rows)+$row;
		my $absoluterecord = $pagerecord+($begin-1);
		if ($pagerecord > scalar(@$pagerecords)) {
		    print $cgi->td({-valign=>'top'},'&nbsp;');
		} else {
		    # report link
		    my $link = undef;
		    my $href= "report.cgi?class=$class&name=".$cgi->escape($pagerecords->[$pagerecord-1]->{'name'});
		    $link = $cgi->a({-class=>'listlink',
				     -href=>$href},
				    $pagerecords->[$pagerecord-1]->{'name'});
		    print $cgi->td({-valign=>'top',-width=>$cellwidth,-class=>'listlink'}, $link);
		}
	    }
	    print $cgi->end_Tr;
	}
	print $cgi->end_table;
	print $cgi->end_p;
        print "</div>";
        print $cgi->end_p;

	print $cgi->end_html unless (-r $footer && $ggb->print_include($footer));
    }
} elsif (scalar(keys(%$classcount)) > 1) {
    # more than one class with results
    # provide links in a table that recall this script for each class
    my $totalcount = 0;
    foreach my $cl (keys(%$classcount)) {$totalcount += $classcount->{$cl}}
    print $cgi->header;
    print $cgi->start_html(-title=>"GrainGenes Admin Class Browser")
	  unless (-r $header && $ggb->print_include($header));
    print $cgi->title("GrainGenes Class Browser");
    print $cgi->h3("GrainGenes Class Browser");
    $ggb->print_form;
    print $cgi->p($cgi->hr);
    print $cgi->p($cgi->b('Results:&nbsp;'),
                  sprintf("%s Record%s%s in %s Classes",
			  $cgi->b($totalcount),
			  $totalcount == 1 ? "" : "s",
		          $query ? sprintf(" matching %s",$cgi->b($query)) : '',
			  $cgi->b(scalar(keys(%$classcount)))
			  )
		  );
    print $cgi->start_p;
    print $cgi->start_table({-border=>0,-cellpadding=>0,-cellspacing=>0,-style=>'font-size: small;'});
    print $cgi->Tr($cgi->td({-class=>'listlink'},[$cgi->b($cgi->u('Class')).'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;','&nbsp;&nbsp;&nbsp;',$cgi->b($cgi->u('Records'))]));
    foreach my $class (sort(keys(%$classcount))) {
	my $url = $ggb->get_self_url({'class'=>$class});
	print $cgi->start_Tr;
        print $cgi->td({-class=>'listlink'},$cgi->a({-href=>"$url"},$classes->{$class}));
        print $cgi->td('&nbsp;&nbsp;&nbsp;');
        print $cgi->td({-align=>'right', -class=>'listlink'},$classcount->{$class});
	print $cgi->end_Tr;
    }
    print $cgi->end_table;
    print $cgi->end_p;
    print $cgi->end_html unless (-r $footer && $ggb->print_include($footer));
}
