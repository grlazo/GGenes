#!/usr/bin/perl

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
    # only one class with results
    my ($class) = keys(%$classcount);
    my $recordcount = $classcount->{$class};
    my $pagerecords = $ggb->get_page_records;
    my $rows = $rows;
    $rows = scalar(@$pagerecords) if (scalar(@$pagerecords) < $rows);
    if ($recordcount == 1) {
	# go directly to the update page
	my $id = $pagerecords->[0]->{'id'};
	my $name = $pagerecords->[0]->{'name'};
	#print $cgi->redirect($cgi->url(-base=>1)."/$class.cgi?id=$id");
	print $cgi->redirect("$class.cgi?id=$id");
	exit;
    } else {
	# list record names as links to update pages
	print $cgi->header;
	print $cgi->start_html(-title=>"GrainGenes Admin Class Browser")
	      unless (-r $header && $ggb->print_include($header));
	print $cgi->title("GrainGenes Admin Class Browser: $classes->{$class}");
	print $cgi->h3("GrainGenes Admin Class Browser");
	$ggb->print_form;
	print $cgi->p($cgi->hr);
	print $cgi->p($cgi->b('Results'),':&nbsp;',
		      sprintf("%s Record%s%s in Class %s",
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
		    # absolute record number
		    #print $cgi->td({-valign=>'top'},$cgi->small($absoluterecord));
		    # update link
		    my $link = undef;
		    $link = $cgi->a({-href=>"$class.cgi?id=$pagerecords->[$pagerecord-1]->{'id'}"},
				    $pagerecords->[$pagerecord-1]->{'name'});
		    print $cgi->td({-valign=>'top',-width=>$cellwidth,-style=>'font-size: smaller;'}, $link);
		}
	    }
	    print $cgi->end_Tr;
	}
	# print a link to insert a new record
	print $cgi->Tr($cgi->td({-colspan=>$columns},'&nbsp;'));
	print $cgi->Tr(
		       $cgi->td(
				{-colspan=>$columns,-style=>'text-align: center;'},
				$cgi->a({-href=>"${class}_insert.cgi"},"Add a new $classes->{$class}")
				)
		       );
	print $cgi->end_table;
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
    print $cgi->title("GrainGenes Admin Class Browser");
    print $cgi->h3("GrainGenes Admin Class Browser");
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
    print $cgi->Tr($cgi->td([$cgi->b($cgi->u('Class')),'&nbsp;&nbsp;&nbsp;',$cgi->b($cgi->u('Records'))]));
    foreach my $class (keys(%$classcount)) {
	my $url = $ggb->get_self_url({'class'=>$class});
	print $cgi->start_Tr;
        print $cgi->td($cgi->a({-href=>"$url"},$classes->{$class}));
        print $cgi->td('&nbsp;&nbsp;&nbsp;');
        print $cgi->td({-align=>'right'},$classcount->{$class});
	print $cgi->end_Tr;
    }
    print $cgi->end_table;
    print $cgi->end_p;
    print $cgi->end_html unless (-r $footer && $ggb->print_include($footer));
}
