#!/usr/bin/perl

# report.cgi
# print graingenes object reports
# require report_<class>.pl depending on the class
# which defines the report elements to print

# cgi params
# class (valid class required)
# id (valid id or name required)
# name
# show (multivalued): list of report elements to expand
#                     'all' expands everything and suppresses show/hide links
#                     (see $showmax/$hideview)
# print (boolean): printable report with all elements expanded

use CGI;
use DBI;
use strict;
use warnings;

require "global.pl";
our ($user,$pass,$dsn,$classes,$scriptbasepath,
     $html_include_header,$html_include_footer);

our $dbh = DBI->connect($dsn,$user,$pass);
our $cgi = new CGI;
our $showmax = 5; # max number of report element records to show before hiding
our $hideview = 1; # number of report element records to show while hiding
our $cellwrap = 15; # number of cell characters below which the cell will be nowrap
our $class = &cgi_valid_class($cgi);
our $id = &cgi_valid_id($cgi,$dbh,$class);
our $name = &cgi_valid_name($cgi,$dbh,$class);

if (!$class) {
    # invalid class
    print $cgi->header;
    print $cgi->start_html(-title=>"GrainGenes Object Report")
          unless (-r $html_include_header && &print_include($html_include_header));
    print $cgi->h3("GrainGenes Object Report");
    print $cgi->p("Invalid Class!");
    print $cgi->end_html unless (-r $html_include_footer && &print_include($html_include_footer));
} elsif (!(-r "report_${class}.pl")) {
    # no report yet
    print $cgi->header;
    print $cgi->start_html(-title=>"GrainGenes $classes->{$class} Report")
          unless (-r $html_include_header && &print_include($html_include_header));
    print $cgi->h3("GrainGenes $classes->{$class} Report");
    print $cgi->p(sprintf("Sorry, the Report for Class %s is in development!",$cgi->b($classes->{$class})));
    print $cgi->end_html unless (-r $html_include_footer && &print_include($html_include_footer));
} elsif (!$id && !$name) {
    # invalid identifier
    print $cgi->header;
    print $cgi->start_html(-title=>"GrainGenes $classes->{$class} Report")
          unless (-r $html_include_header && &print_include($html_include_header));
    print $cgi->h3("GrainGenes $classes->{$class} Report");
    print $cgi->p("Invalid $classes->{$class} Identifier!");
    print $cgi->end_html unless (-r $html_include_footer && &print_include($html_include_footer));
} else {
    # get $id and $name
    if ($name && !$id) {
	$id = $dbh->selectrow_array(sprintf("select id from %s where name = %s",$class,$dbh->quote($name)));
	#$cgi->param(-name=>'id',-value=>$id);
    } elsif (!$name && $id) {
	$name = $dbh->selectrow_array(sprintf("select name from %s where id = %s",$class,$id));
	#$cgi->param(-name=>'name',-value=>$name);
    }
    # print report
    print $cgi->header;
    if (defined($cgi->param('print')) || !(-r $html_include_header)) {
	print $cgi->start_html(-title=>$cgi->escapeHTML("GrainGenes $classes->{$class} Report: $name"));
    } else {
	&print_include($html_include_header);
    }
    print $cgi->start_style({-type=>'text/css'}),"\nA {text-decoration: underline;}\n",$cgi->end_style;
    print $cgi->h3($cgi->escapeHTML("GrainGenes $classes->{$class} Report: $name"));
    print $cgi->p({-class=>'smalltext'},'[ '.$cgi->a({-href=>&get_self_url($cgi,{'print'=>'','show'=>['all']}),-target=>'_blank'},'Printable Version').' ]') unless (defined($cgi->param('print')));
    # print report table
    print $cgi->start_table({-cellpadding=>2,-class=>'smalltext'});
    require "report_${class}.pl";
    print $cgi->end_table;
    if (defined($cgi->param('print')) || !(-r $html_include_footer)) {
	print $cgi->end_html;
    } else {
	&print_include($html_include_footer);
    }
}

$dbh->disconnect;

#####

sub print_element {
    # perform the SQL query for a report element
    # and print the row in the report for this element
    # element values go into an embedded table in the 2nd report column
    # do special processing on certain element values
    # depending on names contained in $cell
    # use global $cellwrap
    my $cgi = shift;
    my $dbh = shift;
    my $element = shift; # element name
    my $label = shift; # element label
    my $sql = shift; # SQL or results for this element
                     # if array ref, then assume this contains results in ref to array of hashrefs
                     # otherwise, assume this is SQL and use fetchall_arrayref to retrieve results
                     # column names/aliases must correspond to those used in $cells
    my $cells = shift; # array ref with keys of column names
                       # columns will print in this order
                       # special values:
                       # reference_id -> print get_complete_reference
                       # url -> use description as link text if available
                       # [<pre>_]<class>_link -> use [<pre>_]<class>_id and [<pre>_]<class>_name to print report link
                       # <col>_html -> HTML is being passed so don't escape it
    my $squeeze = shift; # array ref with keys of column names to squeeze
                         # $rows should be ordered by these
    my $rows = undef;
    my $sth = undef;
    # get results
    if (ref($sql) eq 'ARRAY') {
	# already have results
	$rows = $sql;
    } else {
	# perform query
	$sth = $dbh->prepare($sql); $sth->execute;
	$rows = $sth->fetchall_arrayref({});
    }
    # stop if no results
    if (!@$rows) {
	return;
    } elsif (scalar(@$rows) == 1 && scalar(keys(%{$rows->[0]})) == 1) {
	# pesky single row / single column cases
	my ($val) = values(%{$rows->[0]});
	return if !$val || $val =~ /^\s+$/;
    }
    # count results
    my $rowcount = scalar(@$rows);
    # squeeze columns
    foreach my $col (@$squeeze) {&squeeze_value($rows,$col);}
    # begin element
    print $cgi->start_Tr;
    print $cgi->td({-valign=>'top'},$cgi->b($label));
    print $cgi->start_td({-valign=>'top'});
    print $cgi->start_table({-cellpadding=>2,-class=>'smalltext'});
    # truncate element value rows for show/hide
    if ($rowcount > $showmax &&
	(!&cgi_check_multivalue($cgi,'show',$element) && !&cgi_check_multivalue($cgi,'show','all'))) {
	@$rows = @{$rows}[0..($hideview-1)];
    }
    # hide link row
    if ($rowcount > $showmax &&
	(&cgi_check_multivalue($cgi,'show',$element) && !&cgi_check_multivalue($cgi,'show','all'))) {
	my @showvals = $cgi->param('show');
	my $showvals = &array_remove_item([@showvals],$element);
	my $hideurl = &get_self_url($cgi,{'show'=>$showvals});
	my $hidelink = $cgi->a({-href=>$hideurl},"Hide all but $hideview of $rowcount");
	print $cgi->Tr($cgi->td({-colspan=>scalar(@$cells)},'[ '.$hidelink.' ]'));
    }
    # print element value rows
    foreach my $row (@$rows) {
	print $cgi->start_Tr;
	foreach my $cell (@$cells) {
	    # handle special columns first
	    if ($cell eq 'reference_id') {
		# complete reference
		print $cgi->td({-valign=>'top'},&get_complete_reference($cgi,$dbh,$row->{'reference_id'}));
	    } elsif ($cell eq 'url') {
		# url link with description as link text if available
		print $cgi->td({-valign=>'top'},
			       $cgi->a({-href=>$row->{'url'}},
				       $row->{'description'} ?
				       $cgi->escapeHTML($row->{'description'}) :
				       $cgi->escapeHTML($row->{'url'})
				       )
			       );
	    } elsif ($cell =~ /_link$/) {
		# report link
		my $class = undef;
		my ($pre) = ($cell =~ /^(.*)_link$/);
		if ($pre =~ /_/) {
		    (undef,$class) = split(/_/,$pre);
		} else {
		    $class = $pre;
		}
		my $id = $pre . '_id';
		my $name = $pre . '_name';
		if ($row->{$id} && $row->{$name}) {
		    print $cgi->td({-valign=>'top'},
				   $cgi->a({-href=>"$scriptbasepath/report.cgi?class=$class&id=$row->{$id}"},
					   $cgi->escapeHTML($row->{$name})
					   )
				   );
		} else {
		    print $cgi->td({-valign=>'top'},'&nbsp;');
		}
	    } elsif ($cell =~ /_html$/) {
		# don't escape HTML
		my ($col) = ($cell =~ /^(.*)_html$/);
		if (!exists($row->{$col}) || !defined($row->{$col}) || ($row->{$col} =~ /^\s*$/)) {
		    # can't get rid of the stupid "odd number of elements in hash assignment error"
		    # &nbsp;
		    print $cgi->td({-valign=>'top'},'&nbsp;');
		} elsif (length($row->{$col}) <= $cellwrap) {
		    # nowrap
		    print $cgi->td({-valign=>'top',-nowrap},$row->{$col});
		} else {
		    # just print it
		    print $cgi->td({-valign=>'top'},$row->{$col});
		}
	    } else {
		if (!exists($row->{$cell}) || !defined($row->{$cell}) || ($row->{$cell} =~ /^\s*$/)) {
		    # can't get rid of the stupid "odd number of elements in hash assignment error"
		    # &nbsp;
		    print $cgi->td({-valign=>'top'},'&nbsp;');
		} elsif (length($row->{$cell}) <= $cellwrap) {
		    # nowrap
		    print $cgi->td({-valign=>'top',-nowrap},$cgi->escapeHTML($row->{$cell}));
		} else {
		    # just print it
		    print $cgi->td({-valign=>'top'},$cgi->escapeHTML($row->{$cell}));
		}
	    }
	}
    }
    print $cgi->end_Tr;
    # show link row
    if ($rowcount > $showmax &&
	(!&cgi_check_multivalue($cgi,'show',$element) && !&cgi_check_multivalue($cgi,'show','all'))) {
	my @showvals = $cgi->param('show');
	push(@showvals,$element);
	my $showurl = &get_self_url($cgi,{'show'=>[@showvals]});
	my $showlink = $cgi->a({-href=>$showurl},"Show all $rowcount");
	print $cgi->Tr($cgi->td({-colspan=>scalar(@$cells)},'[ '.$showlink.' ]'));
    }
    # end element
    print $cgi->end_table;
    print $cgi->end_td;
    print $cgi->end_Tr;
}

sub squeeze_value {
    # remove repetitive values from an ordered array of hash refs
    # use on return value of DBI fetchall_arrayref({}) in report elements
    # relies on correct sort order in SQL statement
    my $array = shift; # ret to array of hash refs
    my $key = shift; # key of value to squeeze
    my $value = undef;
    foreach my $i (0..$#{@$array}) {
	$array->[$i]->{$key} =~ s/_/ /g;
	if ($i == 0) {$value = $array->[$i]->{$key}; next;}
	if ($array->[$i]->{$key} eq $value) {
	    #delete $array->[$i]->{$key};
	    $array->[$i]->{$key} = '';
	} else {
	    $value = $array->[$i]->{$key};
	}
    }
}
