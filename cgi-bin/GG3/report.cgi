#!/usr/bin/perl -w -I/www/cgi-bin/GG3

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
# DLH - add cmap coordinates for locus report

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

require "globalGG3.pl";
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
} 
elsif (!(-r "$cgisyspath/report_${class}.pl")) {
    # Error message if no report is defined for this $class yet.
    print $cgi->header unless defined($cgi->param('static'));
    print $cgi->start_html(-title=>"GrainGenes $classes->{$class} Report")
          unless (-r $html_include_header && &print_header($html_include_header,"GrainGenes $classes->{$class} Report"));
    print $cgi->h3("GrainGenes $classes->{$class} Report");
    print $cgi->p(sprintf("Sorry, the Report for Class %s is in development!",$cgi->b($classes->{$class})));
    print $cgi->end_html unless (-r $html_include_footer && &print_include($html_include_footer));
    exit 1;
}
else {
    # Get $id and $name.
    if ($name && !$id) {
	$id = $dbh->selectrow_array(sprintf("select id from %s where name = %s collate latin1_bin",$class,$dbh->quote($name)));
    } 
    elsif (!$name && $id) {
	$name = $dbh->selectrow_array(sprintf("select name from %s where id = %s",$class,$id));
    }
    # Output the report page.
    print $cgi->header unless defined($cgi->param('static'));
    if (defined($cgi->param('print')) || !(-r $html_include_header)) {
	print $cgi->start_html(-title=>$cgi->escapeHTML("GrainGenes $classes->{$class} Report: $name"),
			       -meta=>{'keywords'=>$cgi->escapeHTML($name)},
			       -BGCOLOR=>'white'
			       );#DLH 050421 added bgcolor=white for static html files
    } 
    else {
	&print_header($html_include_header,$cgi->escapeHTML("GrainGenes $classes->{$class} Report: $name"));
    }
    # Print browse.cgi form.
    print_browse_form();
    print $cgi->hr;
    # Print "GrainGenes Report" banner.
    print $cgi->h3($cgi->escapeHTML("GrainGenes $classes->{$class} Report: $name"));
    print $cgi->p({-style=>'font-size: 11px;'},
		  '[ '.$cgi->a({-href=>&get_self_url($cgi,{'print'=>''}),-target=>'_blank'},'Printable Version').' ]'
		  .'&nbsp;&nbsp;'
                   .'[ '.$cgi->a({-href=>"$cgiurlpath/comment.php?class=$class&name=".&geturlstring($name),-target=>'_blank'},'Submit comment/correction').' ]') unless (defined($cgi->param('print')));

	#	  .'[ '.$cgi->a({-href=>"$cgiurlpath/comment.cgi?class=$class;name="
#		  .&geturlstring($name)."&sendto=curator\@graingenes.org&print=''&show=all",-target=>'_blank'},'Submit comment/correction')
#		  .' ]') 
#	unless (defined($cgi->param('print')));
    # Insert some CSS style. Pad two pixels left and right.
    print "<style>";
    print "td,th {vertical-align:top; padding:0 2 0 2}";
    print "table {width:auto}";
    print "</style>";

    # Toplevel table. Print the tags and values (elements) for this $id of this $class.
    print $cgi->start_table();
    print "\n\n\n";
    require "report_${class}.pl";
    print $cgi->end_table();
    print "\n\n\n";
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
    #print $cgi->start_table({-border=>0});
    # form row
    print $cgi->br;
    print $cgi->start_form(-action=>'browse.cgi');
    print $cgi->b('Query&nbsp;<small>(optional)</small>&nbsp;&nbsp;'),
		   $cgi->textfield(-name=>'query',-size=>25),
		   $cgi->b('&nbsp;in&nbsp;Class&nbsp;'),
		   $cgi->popup_menu(-name=>'class',
					     -values=>['all',sort(keys(%$browseclasses))],
					     -default=>'all',
					     -labels=>{'all'=>'All',%$browseclasses});
                         print "&nbsp;";
		   print $cgi->submit(-value=>'GO');
    # go back to first page when resubmitting the form
    print $cgi->hidden(-name=>'begin',-default=>1,-override=>1);
    print $cgi->endform;
    #print $cgi->end_table;
}
sub print_browse_formdlh {
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

    # Get results.
    if (ref($sql) eq 'ARRAY') {
	# already have results
	$rows = $sql;
    } 
    else {
	# Perform query.
	$sth = $dbh->prepare($sql); $sth->execute;
	$rows = $sth->fetchall_arrayref({});
    }
    # Stop if no results.
    if (!@$rows) {
	return;
    } 
    elsif (scalar(@$rows) == 1 && scalar(keys(%{$rows->[0]})) == 1) {
	# pesky single row / single column cases
	my ($val) = values(%{$rows->[0]});
	return if !defined($val) || $val =~ /^\s+$/;
    }
    # Count results.
    my $rowcount = scalar(@$rows);
    # Squeeze columns as needed.
    foreach my $col (@$squeeze) {&squeeze_value($rows,$col);}

    # Begin element.
    print $cgi->start_Tr;
    #print $cgi->td({-valign=>'top'},$cgi->b($label));

    # Output the tag (label) in a table by itself.
    #NL 25Aug2004: (to produce bigger subsection labels for Marker report)
    if ( ($class eq 'marker') &&
         ($element eq 'name') &&
         ($label eq 'Probe' || $label eq 'Gene' || $label eq 'Locus'))    {
      # (bigger label) 
	print $cgi->td($cgi->table({-style=>'font-size: 15px;'},$cgi->Tr($cgi->td($cgi->b($label)))));
    }
    #end replacement
    else {
	# default, for nearly all labels
#      print $cgi->td($cgi->table($cgi->Tr($cgi->td($cgi->b($label)))));
	print $cgi->td;
	print $cgi->table;
	print $cgi->start_Tr;
	print $cgi->td($cgi->b($label));
	print $cgi->end_Tr;
	print $cgi->end_table;
    }
    # Cell 2 of the outermost table contains the table of element values.
    print $cgi->td;
#    print $cgi->table({-style=>'width:80% !important;'});
    print $cgi->table;
    # Truncate element value rows for show/hide.
    if ($rowcount > $showmax &&
	(!&cgi_check_multivalue($cgi,'show',$element) && !&cgi_check_multivalue($cgi,'show','all'))) {
	@$rows = @{$rows}[0..($hideview-1)];
    }
    # "Hide" row
    if ($rowcount > $showmax &&
	(&cgi_check_multivalue($cgi,'show',$element) && !&cgi_check_multivalue($cgi,'show','all'))) {
	my @showvals = $cgi->param('show');
	my $showvals = &array_remove_item([@showvals],$element);
	my $hideurl = &get_self_url($cgi,{'show'=>$showvals});
	my $hidelink = $cgi->i($cgi->a({-href=>$hideurl},"Hide all but $hideview of $rowcount"));
	print $cgi->td({-colspan=>scalar(@$cells)},'[ '.$hidelink.' ]');
    }

    # Print element value rows for this $label.
    foreach my $row (@$rows) {
	print $cgi->start_Tr;
	foreach my $cell (@$cells) {
	    # Handle special columns first.
	    if ($cell eq 'reference_id') {
		# complete reference
		print $cgi->td({-colspan=>scalar(@$cells)},&get_complete_reference($cgi,$dbh,$row->{'reference_id'}));
	    } 
	    elsif ($cell eq 'url') {
		# url link with description as link text if available
		print $cgi->td;
		print $cgi->a({-href=>$row->{'url'}},
			      $row->{'description'} ?
			      $cgi->escapeHTML($row->{'description'}) :
			      $cgi->escapeHTML($row->{'url'})
		    );
	    } 
	    elsif ($cell =~ /_link$/) {
		# Link to another database record.
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
		    print $cgi->td($cgi->a({-href=>sprintf("$cgiurlpath/report.cgi?class=$class;name=%s",&geturlstring($row->{$name}))}, $cgi->escapeHTML($row->{$name})));
		} 
	    } 
	    elsif ($cell =~ /_html$/) {
		# Don't escape HTML.
		my ($col) = ($cell =~ /^(.*)_html$/);
		if (length($row->{$col}) <= $cellwrap) {
		    # nowrap
#		    print $cgi->td({-style=>'white-space:nowrap'},$row->{$col});
		    print $cgi->td($row->{$col});
		} else {
		    # just print it
		    print $cgi->td($row->{$col});
		}
	    } 
	    else {
		# The non-special, default case, plain text.  Escape HTML.
		if (length($row->{$cell}) <= $cellwrap) {
		    # nowrap
#		    print $cgi->td({-style=>'white-space:nowrap'},$cgi->escapeHTML($row->{$cell}));
		    print $cgi->td($cgi->escapeHTML($row->{$cell}));
		} 
		else {
		    # just print it
		    print $cgi->td($cgi->escapeHTML($row->{$cell}));
		}
	    }
	}
    }
    print $cgi->end_td;print "\n";
    print $cgi->end_Tr;print "\n";
    # "Show all" row
    if ($rowcount > $showmax &&
	(!&cgi_check_multivalue($cgi,'show',$element) && !&cgi_check_multivalue($cgi,'show','all'))) {
	my @showvals = $cgi->param('show');
	push(@showvals,$element);
	my $showurl = &get_self_url($cgi,{'show'=>[@showvals]});
	#NL,04Oct2004my $showlink = $cgi->a({-href=>$showurl},"Show all $rowcount");
	my $showlink = $cgi->i($cgi->a({-href=>$showurl},"Show all $rowcount"));
	print $cgi->Tr($cgi->td({-colspan=>scalar(@$cells)},'[ '.$showlink.' ]'));
	print $cgi->end_Tr;print "\n";
#	print '<div>[ '.$showlink." ]</div>\n";
    }
    print $cgi->end_Tr;print "\n";
    print $cgi->end_table;
    # end element
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

