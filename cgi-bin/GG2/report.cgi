#!/usr/bin/perl -I/data/cgi-bin/graingenes

# report_dem.cgi, dem 1mar06, from:
# report.cgi

# Modify to allow exporting mapping scores from MapData records.


# created march 2004 by david hummel <hummel@pw.usda.gov>
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

# print graingenes object reports
# require report_<class>.pl depending on the class
# which defines the report elements to print

# todo:
# check for both header and footer before deciding to print either
# add "browse all <class>es" link next to "printable version"

# cgi params
# class: valid class required
# id|name: valid id or name required
# locusid|qtlid|rearrangementid: only included in links for class=map from these reports
#                                use to construct cmap link that highlights feature on map
# show (multivalued): list of report elements to expand
#                     'all' expands everything and suppresses show/hide links
#                     (see $showmax/$hideview)
# print (boolean): print report without site header/footer
#                  for "printable version" link
# static (boolean): turns off printing of CGI::header()
#                   use this from the command line with show=all and print
#                   to generate static html documents for htdig indexing
# query: to pass back to browse.cgi

use CGI qw(-no_xhtml);
use DBI;
use strict;
use warnings;

require "global.pl";
our ($user,$pass,$dsn,$classes,$browseclasses,$cgisyspath,$cgiurlpath,$cmapserver,$gbrowseserver,
     $html_include_header,$html_include_footer);

our $dbh = DBI->connect($dsn,$user,$pass);
our $cgi = new CGI;
our $showmax = 5; # max number of report element records to show before hiding
our $hideview = 1; # number of report element records to show while hiding
our $cellwrap = 15; # number of cell characters below which the cell will be nowrap
our $class = &cgi_valid_class($cgi);
our $id = &cgi_valid_id($cgi,$dbh,$class);
our $name = &cgi_valid_name($cgi,$dbh,$class);

our $query = $cgi->param('query');

#$cgisyspath = &cgi_cgiurlpath($cgi);
#print STDERR $cgisyspath;

if (!$class) {
    # invalid class
    print $cgi->header unless defined($cgi->param('static'));
    print $cgi->start_html(-title=>"GrainGenes Object Report")
          unless (-r $html_include_header && &print_header($html_include_header,"GrainGenes Object Report"));
    print $cgi->h3("GrainGenes Object Report");
    print $cgi->p("Invalid Class.");
    print $cgi->end_html unless (-r $html_include_footer && &print_include($html_include_footer));
    exit 1;
} elsif (!$id && !$name) {
    # invalid identifier
    print $cgi->header unless defined($cgi->param('static'));
    print $cgi->start_html(-title=>"GrainGenes $classes->{$class} Report")
          unless (-r $html_include_header && &print_header($html_include_header,"GrainGenes $classes->{$class} Report"));
    print $cgi->h3("GrainGenes $classes->{$class} Report");
    if ($cgi->param('name')) {
        #print $cgi->p("Invalid $classes->{$class} Identifier.");
	my $name = $cgi->b($cgi->escapeHTML($cgi->param('name')));
        print $cgi->p("$classes->{$class} $name not found.");
    } else {
        #print $cgi->p("Invalid $classes->{$class} Identifier.");
        print $cgi->p("$classes->{$class} not found.");
    }
    print $cgi->end_html unless (-r $html_include_footer && &print_include($html_include_footer));
    exit 1;
} elsif ($class eq 'map') {
    # redirect to cmap for map class
    # get $id and $name
    if ($name && !$id) {
	$id = $dbh->selectrow_array(sprintf("select id from %s where name = %s collate latin1_bin",$class,$dbh->quote($name)));
    } elsif (!$name && $id) {
	$name = $dbh->selectrow_array(sprintf("select name from %s where id = %s",$class,$id));
    }
# edited 050401 by DLH to fix how links are made to CMap
# Cmap now uses accession_id that are equal to the map
# names instead of id numbers.
#    my ($mapid,$mapsetid) = $dbh->selectrow_array(sprintf("select map_id,map_set_id from cmap_map where map_name = %s",$dbh->quote($name)));
## dem 3apr05: Also get the map_set accession_id by name instead of number.
##     my ($mapid,$mapsetid) = $dbh->selectrow_array(sprintf("select accession_id,map_set_id from cmap_map where map_name = %s",$dbh->quote($name))); 
    my ($mapid,$mapsetid) = $dbh->selectrow_array(sprintf("select map.name,mapdata.name from map join mapdata on mapdata.id=mapdataid where map.name = %s",$dbh->quote($name)));
    #my $cmapid = $dbh->selectrow_array(sprintf("select accession_id from cmap_map where map_name = %s",$dbh->quote($name)));
    my ($cmapid,$cmapsetid) = $dbh->selectrow_array(sprintf("select map_acc,map_name from cmap_map where map_name = %s",$dbh->quote($name))); 
	#my $mapurl = "$cmapserver/viewer?refMenu=&compMenu=&optionMenu=&addOpMenu=&ref_map_aid=$mapid&ref_map_set_aid=$mapsetid&data_source=GrainGenes";
    #my $mapurl = "$cmapserver/viewer?refMenu=1&compMenu=1&optionMenu=&addOpMenu=&ref_map_aids=$cmapid&data_source=GrainGenes";
	#my $mapurl = "$cmapserver/viewer?mapMenu=1&featureMenu=1&corrMenu=1&displayMenu=1&advancedMenu=1&ref_map_accs=$mapid&ref_map_set_acc=$mapsetid&data_source=GrainGenes";
	my $mapurl = "$cmapserver/viewer?mapMenu=1&featureMenu=1&corrMenu=1&displayMenu=1&advancedMenu=1&ref_map_accs=$cmapid&sub=Draw+Selected+Maps&ref_map_set_acc=$cmapsetid&data_source=GrainGenes";
    if ($cgi->param('locusid') || $cgi->param('qtlid') || $cgi->param('rearrangementid')) {
	# came from locus|qtl|rearrangement report, include flags to highlight feature in cmap
	my $featureid; my $featureclass;
	if ($cgi->param('locusid')) {$featureid = $cgi->param('locusid'); $featureclass = 'locus';}
	elsif ($cgi->param('qtlid')) {$featureid = $cgi->param('qtlid'); $featureclass = 'qtl';}
	elsif ($cgi->param('rearrangementid')) {$featureid = $cgi->param('rearrangementid'); $featureclass = 'rearrangement';}
	my $featurename = $dbh->selectrow_array("select name from $featureclass where id = $featureid");
	$mapurl .= "&highlight=".&geturlstring("\"$featurename\"")."&label_features=all";
    }
    print $cgi->redirect($mapurl);
    exit 1;
} elsif (!(-r "$cgisyspath/report_${class}.pl")) {
    # no report yet
    print $cgi->header unless defined($cgi->param('static'));
    print $cgi->start_html(-title=>"GrainGenes $classes->{$class} Report")
          unless (-r $html_include_header && &print_header($html_include_header,"GrainGenes $classes->{$class} Report"));
    print $cgi->h3("GrainGenes $classes->{$class} Report");
    print $cgi->p(sprintf("Sorry, the Report for Class %s is in development!",$cgi->b($classes->{$class})));
    print $cgi->end_html unless (-r $html_include_footer && &print_include($html_include_footer));
    exit 1;
} else {
    # get $id and $name
    if ($name && !$id) {
	$id = $dbh->selectrow_array(sprintf("select id from %s where name = %s collate latin1_bin",$class,$dbh->quote($name)));
    } elsif (!$name && $id) {
	$name = $dbh->selectrow_array(sprintf("select name from %s where id = %s",$class,$id));
    }
    # print report
    print $cgi->header unless defined($cgi->param('static'));
    if (defined($cgi->param('print')) || !(-r $html_include_header)) {
	print $cgi->start_html(-title=>$cgi->escapeHTML("GrainGenes $classes->{$class} Report: $name"),
			       -meta=>{'keywords'=>$cgi->escapeHTML($name)},
			       -BGCOLOR=>'white'
			       );#DLH 050421 added bgcolor=white for static html files
    } else {
	&print_header($html_include_header,$cgi->escapeHTML("GrainGenes $classes->{$class} Report: $name"));
    }
    # print browse.cgi form
    #print $cgi->h3("GrainGenes Class Browser: $classes->{$class}");
    print_browse_form();
    print $cgi->hr;
    print $cgi->h3($cgi->escapeHTML("GrainGenes $classes->{$class} Report: $name"));
#NLremoved to add link to comment.cgi: print $cgi->p({-style=>'font-size: 11px;'},'[ '.$cgi->a({-href=>&get_self_url($cgi,{'print'=>''}),-target=>'_blank'},'Printable Version').' ]') unless (defined($cgi->param('print')));
    print $cgi->p({-style=>'font-size: 11px;'},
                    '[ '.$cgi->a({-href=>&get_self_url($cgi,{'print'=>''}),-target=>'_blank'},'Printable Version').' ]'
    		   .'&nbsp;&nbsp;'
                   .'[ '.$cgi->a({-href=>"https://wheat.pw.usda.gov/cgi-bin/GG3/comment.php?class=$class&name=".&geturlstring($name)."&print=''&show=all",-target=>'_blank'},'Submit comment/correction').' ]') unless (defined($cgi->param('print')));
    #print $cgi->start_table({-cellpadding=>2,-cellspacing=>0,-style=>'font-size: small;'});
    #print $cgi->start_table({-cellpadding=>2,-cellspacing=>0,-class=>'main',-style=>'font-size: 13px;'});
    print $cgi->start_table({-cellpadding=>2,-cellspacing=>0,-class=>'main'});
    require "report_${class}.pl";
    print $cgi->end_table;
    
    # Offer to dump mapping scores if available.
    if ($class eq 'mapdata') {
	# Query whether this mapdata has mapping scores.
	my $sql = qq{
	    select distinct mapdata.id from mapdata
		join mapdatalocus on mapdatalocus.mapdataid = mapdata.id
		where mapdatalocus.scoringdata is not null
		and mapdata.id = $id
	    };
	my $sth = $dbh->prepare($sql); $sth->execute;
	my @data;
	while (@data = $sth->fetchrow_array) {
	    if ($data[0] == $id) {
	    print $cgi->p({-style=>'font-size: 13px;'},
			  '[ '.$cgi->a({-href=>"$cgiurlpath/quickquery.cgi?query=mapdata_scores&arg1=".&geturlstring($name),-target=>'_blank'},'Export mapping scores').' ]') unless (defined($cgi->param('print')));
	} }
    };

    if (defined($cgi->param('print')) || !(-r $html_include_footer)) {
	print $cgi->end_html;
    } else {
	&print_include($html_include_footer);
    }
    exit 0;
}

$dbh->disconnect;

#####

sub print_browse_form {
    # use globals $cgi $query $class $classes $browseclasses
    print $cgi->start_table({-border=>0});
    # form row
    print $cgi->start_form(-action=>'browse.cgi');
    print $cgi->Tr(
		   $cgi->td($cgi->b('Query&nbsp;<small>(optional)</small>&nbsp;')),
		   $cgi->td($cgi->textfield(-name=>'query',-size=>25)),
		   $cgi->td($cgi->b('&nbsp;in&nbsp;Class&nbsp;')),
		   $cgi->td($cgi->popup_menu(-name=>'class',
					     -values=>['all',sort(keys(%$browseclasses))],
					     -default=>'all',
					     -labels=>{'all'=>'All',%$browseclasses})),
		   $cgi->td($cgi->submit(-value=>'GO'))
		   );
    # go back to first page when resubmitting the form
    print $cgi->hidden(-name=>'begin',-default=>1,-override=>1);
    print $cgi->endform;
    print $cgi->end_table;
}

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
	return if !defined($val) || $val =~ /^\s+$/;
    }
    # count results
    my $rowcount = scalar(@$rows);
    # squeeze columns
    foreach my $col (@$squeeze) {&squeeze_value($rows,$col);}
    # begin element
    print $cgi->start_Tr;
    #print $cgi->td({-valign=>'top'},$cgi->b($label));

    #print $cgi->td({-valign=>'top'},$cgi->table({-cellpadding=>2,-cellspacing=>0,-class=>'main'},$cgi->Tr($cgi->td($cgi->b($label)))));
    #NL 25Aug2004 
    #replaced with: (to produce bigger subsection labels for marker report)
    if ( ($class eq 'marker') &&
         ($element eq 'name') &&
         ($label eq 'Probe' || $label eq 'Gene' || $label eq 'Locus'))
    {
      # (bigger label) BTW, changing valign values at 1st/2nd <TD> level has no effect.
      #print $cgi->td({-valign=>'top'},$cgi->table({-cellpadding=>2,-cellspacing=>0,-class=>'main',-style=>'font-size: 15px;'},$cgi->Tr($cgi->td($cgi->b($label)))));
      # cellpadding=1 helps with text-text alignment in Firefox browser:
      print $cgi->td({-valign=>'top'},$cgi->table({-cellpadding=>1,-cellspacing=>0,-class=>'main',-style=>'font-size: 15px;'},$cgi->Tr($cgi->td($cgi->b($label)))));
    }
    else
    {
      print $cgi->td({-valign=>'top'},$cgi->table({-cellpadding=>2,-cellspacing=>0,-class=>'main'},$cgi->Tr($cgi->td($cgi->b($label)))));
    }
    #end replacement
    
    print $cgi->start_td({-valign=>'top'});
    print $cgi->start_table({-cellpadding=>2,-cellspacing=>0,-class=>'main'});
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
	#NL04Oct2004my $hidelink = $cgi->a({-href=>$hideurl},"Hide all but $hideview of $rowcount");
	my $hidelink = $cgi->i($cgi->a({-href=>$hideurl},"Hide all but $hideview of $rowcount"));
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
                            #'middle'/'bottom' makes no diff: print $cgi->td({-valign=>'middle'},
#NL8Dec2004rev.(because locus names wrapping in IE)  print $cgi->td({-valign=>'top'},
  		    		    print $cgi->td({-valign=>'top',-nowrap=>undef},
                                   # change to name param DDH 050203
				   $cgi->a({-href=>sprintf("$cgiurlpath/report.cgi?class=$class;name=%s",&geturlstring($row->{$name}))},
					   $cgi->escapeHTML($row->{$name})
					   )
				   );
		} else {
#NL24Sep2004removed because of extra blank rows in reports:   print $cgi->td({-valign=>'top'},'&nbsp;');
		}
	    } elsif ($cell =~ /_html$/) {
		# don't escape HTML
		my ($col) = ($cell =~ /^(.*)_html$/);
		if (!exists($row->{$col}) || !defined($row->{$col}) || ($row->{$col} =~ /^\s*$/)) {
		    # &nbsp;
#NL24Sep2004remove		    print $cgi->td({-valign=>'top'},'&nbsp;');
		} elsif (length($row->{$col}) <= $cellwrap) {
		    # nowrap
		    print $cgi->td({-valign=>'top',-nowrap=>undef},$row->{$col});
		} else {
		    # just print it
		    print $cgi->td({-valign=>'top'},$row->{$col});
		}
	    } else {
		# escape HTML
		if (!exists($row->{$cell}) || !defined($row->{$cell}) || ($row->{$cell} =~ /^\s*$/)) {
		    # &nbsp;
		    print $cgi->td({-valign=>'top'},'&nbsp;'); # leave in so that squeezed values not misaligned NL 27Sep2004
#NL24Sep2004remove		    print $cgi->td({-valign=>'top'},'&nbsp;');
		} elsif (length($row->{$cell}) <= $cellwrap) {
		    # nowrap
		    print $cgi->td({-valign=>'top',-nowrap=>undef},$cgi->escapeHTML($row->{$cell}));
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
	#NL,04Oct2004my $showlink = $cgi->a({-href=>$showurl},"Show all $rowcount");
	my $showlink = $cgi->i($cgi->a({-href=>$showurl},"Show all $rowcount"));
	print $cgi->Tr($cgi->td({-colspan=>scalar(@$cells)},'[ '.$showlink.' ]'));
    }
    # end element
    print $cgi->end_table;
    print $cgi->end_td;
    print $cgi->end_Tr;
}

sub squeeze_value {
    # empty repetitive values from an ordered array of hash refs
    # use on return value of DBI fetchall_arrayref({}) in report elements
    # relies on correct sort order in SQL statement
    my $array = shift; # ret to array of hash refs
    my $key = shift; # key of value to squeeze
    my $value = undef;
#    foreach my $i (0..$#{@$array}) {   This gives error in perl v5.10.1.
    foreach my $i (0..$#{$array}) {
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

