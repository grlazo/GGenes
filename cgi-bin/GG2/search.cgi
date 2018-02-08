#!/usr/bin/perl -I/data/cgi-bin/graingenes

# search.cgi
# created april 2004 by david hummel <hummel@pw.usda.gov>
# graingenes contextual class search
# search in a class on one or more search elements
# require specific class search elements from search_<class>.pl
# which defines $search_elements for the class
# each search element must return unique (distinct) results

# todo:
# fix get_results to handle whitespace in query boxes
# check params for valid values
# calculate $high_param higher up in the program
# put navlinks and beginpopngo in global.pl functions (same for browse.cgi)
# add checkboxes for 'not like' and '!='
# add logic clustering ()
# allow for numeric queries / deal with float comparison problem
# add "tips" if not results, such as links that include wildcards if not there
# add rolodex?
# proceed option for > max_results

# cgi params:
# class = class name
#         valid class required
#         drop-down pop-n-go to other classes
# q1/e1/l1,q2/e2/l2... = query box / element drop down
#                        qX = element query box
#                        eX = element to query
#                        lX = and|or logic between elements (not needed for last element)
#                        these are added and removed by 'add' and 'remove' submit buttons
#                        max allowed is number of search elements for the class
# add = submit button name
#       don't search, just add another search element
# remove = submit button name
#          don't search, just remove last search element, but not first one
# begin = number of first record to view
#         must be 1 or (multiple of $recordview)+1

use CGI qw(-no_xhtml);
use DBI;
use strict;
use warnings;

require "global.pl";
our ($user,$pass,$dsn,$cgiurlpath,$cgisyspath,$classes,
     $html_include_header,$html_include_footer);

my $dbh = DBI->connect($dsn,$user,$pass);
my $cgi = new CGI;

# dem 2oct04 Removed searchclass 'probe' for now.
my $searchclasses = [qw/gene sequence/]; # for class select drop-down
                                               # one for each search_<class>.pl
my $max_query_elements = 10; # max number of query elements
my $max_results = 100000; # max number of results allowed
                         # need this because "where <col> in ()" gets slow
my $recordview = 48; # number of records to view at once
my $columns = 4; # number of columns in record table
my $rows = 12; # number of rows in record table
my $tablewidth = 700; # width of record table
my $recordlimit = 30000; # if below, use names in pop-n-go navigation
                         # if above, use numbers in pop-n-go navigation
my $namelength = 30; # maximum name length in pop-n-go navigation
my $cellwidth = sprintf("%d",$tablewidth/$columns); # width of record table columns
#my $cellwidth = sprintf("%d%%",100/$columns); # width of record table columns

# DDH 2005-04-05
# copied from browse.cgi
# read cache of total row counts for innodb
# use this in count_class() if no $query
my %classcounts;
open(CT,"$cgisyspath/class_counts");
while (<CT>) {
    my ($cl,$ct) = split(/\t/,$_);
    $classcounts{$cl} = $ct;
}
close(CT);

my $class = &cgi_valid_class($cgi);

if (!$class) {
    # invalid class
    print $cgi->header;
    print $cgi->start_html(-title=>"GrainGenes Field-based Search")
	unless (-r $html_include_header && &print_header($html_include_header));
    print $cgi->h3("GrainGenes Field-based Search");
    &print_class_select_form;
    print $cgi->p($cgi->hr);
    print $cgi->p($cgi->b("Please select a valid class."));
    print $cgi->end_html
	unless (-r $html_include_footer && &print_include($html_include_footer));
    exit;
}

if (!(-r "search_${class}.pl")) {
    # search elements not available
    print $cgi->header;
    print $cgi->start_html(-title=>"GrainGenes Field-based Search")
	unless (-r $html_include_header && &print_header($html_include_header));
    print $cgi->h3("GrainGenes Field-based Search");
    &print_class_select_form;
    print $cgi->p($cgi->hr);
    print $cgi->p($cgi->b("Field-based search not yet available for $classes->{$class}. Please select another."));
    print $cgi->end_html
	unless (-r $html_include_footer && &print_include($html_include_footer));
    exit;
}

# load search element definitions
require "search_${class}.pl";
our $search_elements;

if (
    # add or remove button was pressed
    ( defined($cgi->param('add')) || defined($cgi->param('remove')) ) ||
    # don't have at least one query element yet
    ( !(defined($cgi->param('q1')) && defined($cgi->param('e1'))) )
    ) {
    # just print the form
    print $cgi->header;
    print $cgi->start_html(-title=>"GrainGenes Field-based Search")
	unless (-r $html_include_header && &print_header($html_include_header));
    print $cgi->h3("GrainGenes Field-based Search");
    &print_class_select_form;
    print $cgi->p($cgi->hr);
    &print_query_form($cgi,$search_elements);
    print $cgi->p($cgi->hr);
    print $cgi->end_html
	unless (-r $html_include_footer && &print_include($html_include_footer));
    exit;
}

# do the search and print the results
my $results = &get_results($cgi,$class,$search_elements);
my $recordcount = undef;
if (ref($results) eq 'ARRAY') {
    $recordcount = scalar(@$results);
}
if (!defined($recordcount)) {
    # too many results
    print $cgi->header;
    print $cgi->start_html(-title=>"GrainGenes Field-based Search")
	unless (-r $html_include_header && &print_header($html_include_header));
    print $cgi->h3("GrainGenes Field-based Search");
    &print_class_select_form;
    print $cgi->p($cgi->hr);
    &print_query_form($cgi,$search_elements);
    print $cgi->p($cgi->hr);
    print $cgi->p($cgi->b("More than $max_results results. Please refine the search criteria."));
    print $cgi->end_html
	unless (-r $html_include_footer && &print_include($html_include_footer));
    exit;
} elsif ($recordcount == 0) {
    # no results
    print $cgi->header;
    print $cgi->start_html(-title=>"GrainGenes Field-based Search")
	unless (-r $html_include_header && &print_header($html_include_header));
    print $cgi->h3("GrainGenes Field-based Search");
    &print_class_select_form;
    print $cgi->p($cgi->hr);
    &print_query_form($cgi,$search_elements);
    print $cgi->p($cgi->hr);
    print $cgi->p($cgi->b("No results. Please refine the search criteria."));
    print $cgi->end_html
	unless (-r $html_include_footer && &print_include($html_include_footer));
    exit;
} elsif ($recordcount == 1) {
    # go directly to the single report
    my $id = $results->[0];
    my $url = $cgi->url(-base=>1);
    $url .= "$cgiurlpath/report.cgi?class=$class&id=$id";
    print $cgi->redirect($url);
    exit;
} else {
    # list record names as links to reports
    my $begin = &cgi_valid_begin($cgi,$recordcount,$recordview);
    my $pagerecords = &get_page_results($class,$results,$begin);
    $rows = scalar(@$pagerecords) if (scalar(@$pagerecords) < $rows);
    print $cgi->header;
    print $cgi->start_html(-title=>"GrainGenes Field-based Search")
	unless (-r $html_include_header && &print_header($html_include_header));
    #print $cgi->start_html(-title=>"GrainGenes Field-based Search");
    print $cgi->h3("GrainGenes Field-based Search");
    &print_class_select_form;
    print $cgi->p($cgi->hr);
    &print_query_form($cgi,$search_elements);
    print $cgi->p($cgi->hr);
    # david hummel 2005-01-12
    # added "Download FASTA" button
    # table added so that "Download FASTA" button aligns properly
    print $cgi->start_table(-border=>0);
    print $cgi->start_Tr;
    print $cgi->start_td;
    print $cgi->p($cgi->b('Results'),':&nbsp;',
		  sprintf("%s Record%s",
			  $cgi->b($recordcount),
			  $recordcount == 1 ? "" : "s"
			  )
		  );
    print $cgi->end_td;
    if ($class eq 'sequence' && $recordcount <= 10000) {
        print $cgi->td('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
        print $cgi->start_td;
        print $cgi->start_form(-action=>"$cgiurlpath/fasta.cgi");
        print $cgi->hidden(-name=>'t',-default=>'i');
        print $cgi->hidden(-name=>'e',-default=>join(' ',@$results));
        print $cgi->submit(-value=>'Download FASTA');
        print $cgi->end_form;
        print $cgi->end_td;
    }
    print $cgi->end_Tr;
    print $cgi->end_table;
    # navigation links and pop-n-go navigation table
    if ($recordcount > $recordview) {	    
	print $cgi->start_p;
	print $cgi->start_table({-border=>0});
	# navigation links and range row
	print $cgi->start_Tr,
	# first page
	$cgi->td({-align=>'center'},
		 '&nbsp;',
		 sprintf("%s", ($begin > 1) ?
			 $cgi->a({href=>&get_self_url($cgi,{'begin'=>1})},"|&lt;&lt;") :
			 "|&lt;&lt;"),
		 '&nbsp;'
		 ),
	# back one page
        $cgi->td({-align=>'center'},
		 '&nbsp;',
		 sprintf("%s", ($begin > 1) ?
			 $cgi->a({href=>&get_self_url($cgi,{'begin'=>$begin-$recordview})},"&lt;&lt;") :
			 "&lt;&lt;"),
		 '&nbsp;'
		 ),
	# pages and records
	$cgi->td({-align=>'center'},
		 '&nbsp;',
		 sprintf("[Page %s of %s: Records %s - %s]",
			 $cgi->b(sprintf("%d",$begin/$recordview)+1),
			 $cgi->b(($recordcount%$recordview) ?
				 (sprintf("%d",$recordcount/$recordview)+1) :
				 (sprintf("%d",$recordcount/$recordview))),
			 $cgi->b($begin),
			 $cgi->b((($begin+$recordview-1) > $recordcount) ?
				 $recordcount :
				 ($begin+$recordview-1))),
		 '&nbsp;'
		 ),
	# forward one page
	$cgi->td({-align=>'center'},
		 '&nbsp;',
		 sprintf("%s", ($recordcount > ($begin+$recordview-1)) ?
			 $cgi->a({href=>&get_self_url($cgi,{'begin'=>$begin+$recordview})},"&gt;&gt;") :
			 "&gt;&gt;"),
		 '&nbsp;'
		 ),
	# last page
	$cgi->td({-align=>'center'},
		 '&nbsp;',
		 sprintf("%s",
			 ($recordcount > ($begin+$recordview-1)) ?
			 $cgi->a({href=>&get_self_url($cgi,{'begin'=>($recordcount%$recordview) ?
								(sprintf("%d",($recordcount/$recordview))*$recordview+1) :
								((sprintf("%d",($recordcount/$recordview))-1)*$recordview+1)
							    })},"&gt;&gt;|") :
			 "&gt;&gt;|"),
		 '&nbsp;'
		 ),
	$cgi->end_Tr;
	# pop-n-go navigation row
	print $cgi->start_Tr;
	print $cgi->td({-colspan=>2});
	print $cgi->start_td({-align=>'center'});
	my $beginvalues = [];
	my $beginlabels = {};
	my $pagefactor = 1;
	while (int($recordcount/$recordview)/$pagefactor > 200) {
	    $pagefactor++;
	}
	for (my $i=1; $i<=$recordcount; $i=$i+($recordview*$pagefactor)) {
	    push(@$beginvalues,$i);
	    $beginlabels->{$i} = sprintf(
					 "%d ... %d",
					 $i,
					 ($i+($recordview-1)) < $recordcount ? ($i+($recordview-1)) : $recordcount
					 );
	}
	#if ($recordcount <= $recordlimit) {
	## get_begin_names slow for lots of records
	#$beginlabels = &get_begin_names($class,$query);
	#}
	#print &cgi_get_popngo($cgi,'begin',0,$beginvalues,$begin,$beginlabels);
	print $cgi->popup_menu(
			       -name=>'begin',
			       -values=>$beginvalues,
			       -default=>undef,
			       -labels=>$beginlabels,
			       -onchange=>"location.href='".&get_self_url($cgi,{'begin'=>undef}).";begin="."'+this.options[this.selectedIndex].value;"
			       );
	print $cgi->end_td;
	print $cgi->td({-colspan=>2});
	print $cgi->end_Tr;
	print $cgi->end_table;
	print $cgi->end_p;
    }
    # print the report links in a table
    print $cgi->start_p;
    print $cgi->start_table({-border=>0,-cellpadding=>3,-style=>'font-size: small;'});
    for (my $row=1; $row<=$rows; $row++) {
	print $cgi->start_Tr;
	foreach my $column (1..$columns) {
	    my $pagerecord = (($column-1)*$rows)+$row;
	    my $absoluterecord = $pagerecord+($begin-1);
	    if ($pagerecord > scalar(@$pagerecords)) {
		#print $cgi->td({-valign=>'top'},'&nbsp;');
		print $cgi->td({-valign=>'top'},'&nbsp;');
	    } else {
		#print $cgi->td({-valign=>'top'},$cgi->small($absoluterecord));
		print $cgi->td({-valign=>'top',-width=>$cellwidth},
			       $cgi->a({href=>"$cgiurlpath/report.cgi?class=$class&id=$pagerecords->[$pagerecord-1]->{'id'}"},
				       $pagerecords->[$pagerecord-1]->{'name'})
			       );
	    }
	}
	print $cgi->end_Tr;
    }
    print $cgi->end_table;
    print $cgi->end_p;
    print $cgi->end_html unless (-r $html_include_footer && &print_include($html_include_footer));
    #print $cgi->end_html;
}    

$dbh->disconnect;

###############

sub print_class_select_form {
    print $cgi->start_p;
    #print $cgi->start_center;
    print $cgi->start_form;
    print $cgi->start_table({-border=>0});
    print $cgi->start_Tr;
    print $cgi->td($cgi->b('Class&nbsp;'));
    print $cgi->start_td;
    print $cgi->popup_menu(
			   -name=>'class',
			   #-values=>['none',sort(keys(%$classes))],
			   -values=>['none',@$searchclasses],
			   -default=>'none',
			   -labels=>{'none'=>'--',%$classes},
			   -onchange=>"location.href='".$cgi->url."?class="."'+this.options[this.selectedIndex].value;"
			   );
    print $cgi->end_td;
    print $cgi->td($cgi->submit(-value=>'Select'));
    if ($class) {
	#my ($ct) = $dbh->selectrow_array("select count(*) from $class");
	my ($ct) = $classcounts{$class};
	print $cgi->td("[&nbsp;<b>$ct</b> Records in Class <b>$classes->{$class}</b>&nbsp;]");
    }
    print $cgi->end_Tr;
    print $cgi->end_table;
    print $cgi->endform;
    #print $cgi->end_center;
    print $cgi->end_p;
}

sub print_query_form {
    # use global $max_query_elements
    my $cgi = shift;
    my $search_elements = shift;
    my $high_param = 1; # highest submitted query element param number
                        # print at least 1 query element
    my $e_values = $search_elements->{'order'}; # values for eX drop-downs
    my $e_labels = {}; # labels for eX drop-downs
    # get $e_labels
    foreach my $el (@$e_values) {
	$e_labels->{$el} = $search_elements->{$el}->{'realname'};
    }
    # get highest submitted query element param number
    foreach my $i (1..$max_query_elements) {
	if (defined($cgi->param("q$i")) && defined($cgi->param("e$i"))) {
	    $high_param = $i;
	}
    }
    # increase by 1 if add button pressed, but not if maxed already
    if (defined($cgi->param('add'))) {$high_param++ unless $high_param == $max_query_elements;}
    # decrease by 1 if remove button pressed, but don't remove first one
    if (defined($cgi->param('remove'))) {$high_param-- unless $high_param == 1;}
    #print $cgi->p($cgi->b("Find $classes->{$class} objects based on the contents of $classes->{$class} fields"));
    print $cgi->start_p;
    print $cgi->start_table({-border=>0});
    print $cgi->start_form;
    # form header row
    print $cgi->Tr(
		   $cgi->td({-align=>'center'},
			    $cgi->b('Query&nbsp;',
				    $cgi->small("( * = wildcard )")
				    )
			    ),
		   $cgi->td({-align=>'center'},'&nbsp;'),
		   $cgi->td({-align=>'center'},
			    #$cgi->b($classes->{$class},'&nbsp;Field')
			    $cgi->b('Field')
			    ),
		   $cgi->td({-align=>'center'},'&nbsp;')
		   );
    # row for each element
    foreach my $i (1..$high_param) {
	print $cgi->Tr(
		       $cgi->td({-align=>'center'},$cgi->textfield(-name=>"q$i",-size=>30)),
		       $cgi->td({-align=>'center'},$cgi->b('&nbsp;in&nbsp;')),
		       $cgi->td({-align=>'center'},
				$cgi->popup_menu(
						 -name=>"e$i",
						 -values=>$e_values,
						 -default=>'name',
						 -labels=>$e_labels
						 )
				),
		       $cgi->td({-align=>'center'},
				$i == $high_param ? '&nbsp;' :
				$cgi->popup_menu(
						 -name=>"l$i",
						 -values=>['and','or'],
						 -default=>'and',
						 -labels=>{'and'=>'and','or'=>'or'}
						 )
				)
		       );
    }
    # buttons row
    print $cgi->Tr(
		   $cgi->td({-align=>'center'},
		            $cgi->submit(-value=>'Search')
			    ),
		   $cgi->td({-colspan=>3,-align=>'center'},
		            $cgi->submit(-name=>'add',-value=>'Add'),
			    $high_param > 1 ? '&nbsp;or&nbsp;'.$cgi->submit(-name=>'remove',-value=>'Remove') : '',
			    '&nbsp;search&nbsp;criterion'
			    )
		   );
    # maintain class and go back to first page when resubmitting
    print $cgi->hidden(-name=>'begin',-default=>1,-override=>1);
    print $cgi->hidden(-name=>'class',-default=>'none');
    print $cgi->endform;
    print $cgi->end_table;
    print $cgi->end_p;
}

sub get_results {
    # obtain class ids from all queriable search elements
    # return ref to array of class ids
    # return ref to empty array for no results
    # return undef if any one search element yields more than $max_results results
    # use global $max_query_elements and $max_results
    my $cgi = shift;
    my $class = shift;
    my $search_elements = shift;
    my $high_param = 1; # highest submutted query element param number
    my $elementresults = []; # ref to array of class id array refs for each element search
    my $resultssql = undef; # final sql statement to get class ids for $results
    my $results = [()]; # ref to array of class ids common to all element searches
    # get highest submitted query element param number
    foreach my $i (1..$max_query_elements) {
	if (defined($cgi->param("q$i")) && defined($cgi->param("e$i"))) {
	    $high_param = $i;
	}
    }
    # get class ids for each queriable element
    foreach my $i (1..$high_param) {
	my $query = $cgi->param("q$i");
	my $element = $cgi->param("e$i");
	my $postlogic = $cgi->param("l$i") ? $cgi->param("l$i") : 'and';
	my $prelogic = $cgi->param("l".($i-1)) ? $cgi->param("l".($i-1)) : 'and';
	my $sql = $search_elements->{$element}->{'sql'};
	if ($sql =~ /where/i) {$sql .= ' and (';} else {$sql .= ' where (';}
	my $ctsql = undef;
	my $ct = undef;
	my $elresults = [];
	my $cmp = '=';
	if (defined($query) && $query !~ /^\s*$/) {
	    # escape %
	    $query =~ s/([^\\]|^)\%/$1\\%/g;
	    # escape _
	    $query =~ s/([^\\]|^)_/$1\\_/g;
	    # change * wildcard to % wildcard
	    $query =~ s/([^\\]|^)\*/$1\%/g;
	    # escape '
	    $query =~ s/'/\\'/g;
	    if ($query =~ /([^\\]|^)\%/) {
		$cmp = 'like';
	    } else {
		$cmp = '=';
	    }
	    foreach my $col (@{${${$search_elements}{$element}}{'searchcols'}}) {
		if ($query eq '%') {
		    $sql .= "$col is not null or ";
		} else {
		    if (
			exists $search_elements->{$element}->{'searchtypes'} &&
			exists $search_elements->{$element}->{'searchtypes'}->{$col} &&
			$search_elements->{$element}->{'searchtypes'}->{$col} eq 'match'
			) {
                        # ddh 2006-06-15 innodb doesn't support fulltext indexes
			#$sql .= "match ($col) against ('$query') or ";
			$sql .= "$col $cmp '$query' or ";
		    } else {
			$sql .= "$col $cmp '$query' or ";
		    }
		}
	    }
	    $sql =~ s/ or $//; $sql .= ')';
	    # count the number of records and return undef if too many
	    #$ctsql = $sql;
	    # speed up count() for name element
	    #$ctsql =~ s/where.*$//i if ($query eq '%' && $element eq 'name');
	    #$ctsql =~ s/select\s+(distinct\s+\S+|\S+)\s+from/select count($1) from/si;
	    #$ctsql =~ s/select\s+(\S.*\S)\s+from/select count($1) from/si;
	    #print STDERR "\$ctsql: $ctsql\n";
	    #($ct) = $dbh->selectrow_array($ctsql);
	    #print STDERR "\$ct: $ct\n";
	    #return undef if ($ct > $max_results);
	    #print STDERR "\$sql: $sql\n";
	    $elresults = $dbh->selectcol_arrayref($sql);
	    # save results
	    push(@$elementresults,&unique_array_elements([$elresults]));
	} else {
	    push(@$elementresults,[]);
	}
    }

    # get class ids common to all elements

#    # retrieve combined results with IN () query
#    # mysql doesn't like this for _lots_ of records (i.e. sequence)
#    if (@$elementresults) {
#	if (scalar(@$elementresults) == 1 && @{${$elementresults}[0]}) {
#	    # only 1 search element and non-empty
#           # need to check for $max_results here
#	    return $elementresults->[0];
#	} elsif (scalar(@$elementresults) == 1 && !@{${$elementresults}[0]}) {
#	    # only 1 search element and empty
#	} elsif (scalar(@$elementresults) > 1) {
#	    # more than 1 search element
#	    foreach my $i (1..$high_param) {
#		my $postlogic = $cgi->param("l$i") ? $cgi->param("l$i") : 'and';
#		my $prelogic = $cgi->param("l".($i-1)) ? $cgi->param("l".($i-1)) : 'and';
#		if (@{${$elementresults}[$i-1]}) {
#		    $resultssql .= sprintf("id in (%s) $postlogic ",join(',',@{${$elementresults}[$i-1]}));
#		} elsif ($i > 1 && $prelogic eq 'and') {
#		    # can't and to no results
#		    return [()];
#		}
#	    }
#	    if ($resultssql) {
#		$resultssql =~ s/ (?:and|or) $//;
#		$resultssql = "select id from $class where " . $resultssql;
#		#print STDERR "resultssql: $resultssql\n";
#		$results = $dbh->selectcol_arrayref($resultssql);
#	    }
#	}
#    }

    # retrieve combined results with common_array_elements (and) and unique_array_elements (or)
    if (@$elementresults) {
	foreach my $i (1..$high_param) {
	    if ($i == 1) {
		push(@$results,@{${$elementresults}[$i-1]});
		next;
	    }
	    my $prelogic = $cgi->param("l".($i-1)) ? $cgi->param("l".($i-1)) : 'and';
	    if ($prelogic eq 'and') {
		if (@$results && @{${$elementresults}[$i-1]}) {
		    $results = &common_array_elements([$results,$elementresults->[$i-1]]);
		} else {
		    # can't and no results
		    return [()];
		}
	    } elsif ($prelogic eq 'or') {
		$results = &unique_array_elements([$results,$elementresults->[$i-1]]);
	    }
	}
    }

    # retrieve combined results with common_array_elements (assumes all and's)
    #$results = &common_array_elements($elementresults);

    # return results
    if (@$results && scalar(@$results) <= $max_results) {
	return $results;
    } elsif (@$results && scalar(@$results) > $max_results) {
	return undef;
    } else {
	return [()];
    }
}

sub get_page_results {
    # get id and name of records for a page of results
    # return ref to array of hash refs, keys: id, name
    my $class = shift;
    my $results = shift;
    my $begin = shift;
    my $recordcount = scalar(@$results);
    my $sql = sprintf("select id,name from $class where id in (%s) order by name",join(',',@$results));
    # add limit clause
    if ($recordcount > $recordview) {
	$sql .= sprintf(" limit %s,%s",
			$begin-1,
			((($begin-1)+$recordview) > $recordcount) ? ($recordcount-($begin-1)) : $recordview);
    }
    my $sth = $dbh->prepare($sql); $sth->execute;
    return $sth->fetchall_arrayref({});
}

sub get_begin_names {
    # get begin number and name of records for pop-n-go navigation
    # return hash ref: begin => name
    # use global $namelength
    my $class = shift;
    my $results = shift;
    my $beginnames = {};
    my $sql .= sprintf("select id,name from $class where id in (%s) order by name",join(',',@$results));
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $records = $sth->fetchall_arrayref({});
    my $recordcount = scalar(@$records);
    for (my $i = 1; $i <= $recordcount; $i = $i+$recordview) {
	my $name = $records->[$i-1]->{'name'};
	if (length($name) > $namelength) {
	    $name = substr($name,0,$namelength);
	}
	$name .= '...';
	$beginnames->{$i} = $name;
    }
    return $beginnames;
}
