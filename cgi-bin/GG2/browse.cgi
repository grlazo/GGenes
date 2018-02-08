#!/usr/bin/perl -I/data/cgi-bin/graingenes

# browse.cgi

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

# browse/search graingenes classes by object names which link to reports
# NL 28Oct2004 removed cmap_map reference as all maps in GG-mySQL in cmap, per DEM
# NL  8Nov2004 put cmap_map lines back, as maps missing after Sommers' data put into ACEDB, but not cmap
 
# todo:
# "full string search" link for query* results
# split search terms
# restrict class list in form
# categorize class list in form
# X add pseudoclasses (i.e. marker)
# remove page popngo for >100k records

# cgi params:
# query = query string
# class = class name
#         invalid class names revert to all classes
# begin = number of first record to view
#         must be 1 or (multiple of $recordview)+1

use CGI qw(-no_xhtml);
use DBI;
use strict;
use warnings;

require "global.pl";
our ($user,$pass,$dsn,$cgiurlpath,$cgisyspath,$classes,$browseclasses,
     $html_include_header,$html_include_footer);

my $dbh = DBI->connect($dsn,$user,$pass);
my $cgi = new CGI;
my $recordview = 50; # number of records to view at once
my $columns = 5; # number of columns in record table
my $rows = 10; # number of rows in record table
my $tablewidth = 800; # width of record table
my $recordlimit = 50000; # if below, use names in pop-n-go navigation
                         # if above, use numbers in pop-n-go navigation
my $namelength = 30; # maximum name length in pop-n-go navigation
my $cellwidth = sprintf("%d",$tablewidth/$columns); # width of record table columns
#my $cellwidth = sprintf("%d%%",100/$columns); # width of record table columns
my $query = &cgi_valid_query($cgi);
my $class = &cgi_valid_class($cgi);
my $classcount = []; # ref to array of hash refs, keys: class, count

# DDH 2005-09-11
# read cache of total row counts for innodb
# use this in count_class() if no $query
my %classcounts;
open(CT,"$cgisyspath/class_counts");
while (<CT>) {
    my ($cl,$ct) = split(/\t/,$_);
    $classcounts{$cl} = $ct;
}
close(CT);

# populate $classcount
# add wildcards and redo if necessary
&count_classes($query,$class);
while (scalar(@$classcount) == 0) {
    if ($query !~ /([^\\]|^)\*$/) {
	# add trailing wildcard
	$query = $query . '*';
	$cgi->param(-name=>'query',-value=>$query);
	&count_classes($query,$class); next;
    } elsif ($query !~ /^([^\\]|)\*/) {
	# add leading wildcard
	$query = '*' . $query;
	$cgi->param(-name=>'query',-value=>$query);
	&count_classes($query,$class); next;
    } else {
	last;
    }
}

# determine type of output based on $classcount
if (scalar(@$classcount) == 0) {
    # no results
    print $cgi->header;
    print $cgi->start_html(-title=>"GrainGenes Class Browser")
	  unless (-r $html_include_header && &print_header($html_include_header,"GrainGenes Class Browser"));
    print $cgi->h3("GrainGenes Class Browser");
    &print_form;
    print $cgi->p($cgi->hr);
# DLH Jan06 - added to show what classes results were not found in
#    print $cgi->p($cgi->b('No Results!'));
   if ($class){
    print $cgi->p($cgi->b('No Results in ' . $classes->{$class} . '!'));
   } else { print $cgi->p($cgi->b('No Results for all classes!'));}
    print $cgi->end_html
	  unless (-r $html_include_footer && &print_include($html_include_footer));
} elsif (scalar(@$classcount) == 1) {
    # only one class with results
    my $class = $classcount->[0]->{'class'};
    my $recordcount = $classcount->[0]->{'count'};
    my $begin = &cgi_valid_begin($cgi,$recordcount,$recordview);
    my $pagerecords = &get_class_ids($class,$query,$recordcount,$begin);
    my $rows = $rows;
    $rows = scalar(@$pagerecords) if (scalar(@$pagerecords) < $rows);
    if ($recordcount == 1) {
    #if (0) {
	# go directly to the report
	my $id = $pagerecords->[0]->{'id'};
	my $name = $pagerecords->[0]->{'name'};
	my $url = $cgi->url(-base => 1);
	# id in url
	#$url .= "$cgiurlpath/report.cgi?class=$class&id=$id";
	# name in url
	$url .= sprintf("$cgiurlpath/report.cgi?class=$class&name=%s",&geturlstring($name));
	print $cgi->redirect($url); exit;
    } else {
	# list record names as links to reports
	# begin html
	print $cgi->header;
	print $cgi->start_html(-title=>"GrainGenes Class Browser: $classes->{$class}")
	      unless (-r $html_include_header && &print_header($html_include_header,"GrainGenes Class Browser: $classes->{$class}"));
	#print $cgi->start_style({-type=>'text/css'}),"\nA {text-decoration: underline;}\n",$cgi->end_style;
	print $cgi->h3("GrainGenes Class Browser: $classes->{$class}");
	&print_form;
	print $cgi->p($cgi->hr);
	print $cgi->p($cgi->b('Results'),':&nbsp;',
		      sprintf("%s Record%s%s in Class %s",
			      $cgi->b($recordcount),
			      $recordcount == 1 ? "" : "s",
			      $query ? sprintf(" matching %s",$cgi->b($query)) : '',
			      $cgi->b($classes->{$class})
			      )
		      );
	# navigation links and pop-n-go navigation table
	if ($recordcount > $recordview) {	    
	    # begin table
	    print $cgi->start_p;
	    print $cgi->start_table({-border=>0});
	    # navigation links and range row
	    print $cgi->start_Tr,
	          # first page
	          $cgi->td({-align=>'center'},
			   sprintf("%s", ($begin > 1) ?
				   $cgi->a({href=>&get_self_url($cgi,{'begin'=>1})}, $cgi->img({-src => "/ggpages/images/doublebackarrow.gif", -border=>0})) : 
				   $cgi->img({-src => "/ggpages/images/doublebackarrow.gif", -border=>0})),
			   ),
		  # back one page
		  $cgi->td({-align=>'center'},
			   sprintf("%s", ($begin > 1) ?
				   $cgi->a({href=>&get_self_url($cgi,{'begin'=>$begin-$recordview})}, $cgi->img({-src => "/ggpages/images/backarrow.gif", -border=>0})) : 
				   $cgi->img({-src => "/ggpages/images/backarrow.gif", -border=>0})),
			   ),
	          # pages and records
	          $cgi->td({-align=>'center'},
				   '&nbsp;',
			   sprintf("Page %s of %s: records %s - %s",
				   $cgi->b(sprintf("%d",$begin/$recordview)+1),
				   $cgi->b(($recordcount%$recordview) ?
					   (sprintf("%d",$recordcount/$recordview)+1) :
					   (sprintf("%d",$recordcount/$recordview))),
				   $cgi->b($begin),
				   $cgi->b((($begin+$recordview-1) > $recordcount) ?
					   $recordcount :
					   ($begin+$recordview-1))),
				   '&nbsp;',
			   ),
	          # forward one page
	          $cgi->td({-align=>'center'},
			   sprintf("%s", ($recordcount > ($begin+$recordview-1)) ?
				   $cgi->a({href=>&get_self_url($cgi,{'begin'=>$begin+$recordview})}, $cgi->img({-src => "/ggpages/images/nextarrow.gif", -border=>0})) : $cgi->img({-src => "/ggpages/images/nextarrow.gif", -border=>0})),
			   ),
	          # last page
	          $cgi->td({-align=>'center'},
			   sprintf("%s",
				   ($recordcount > ($begin+$recordview-1)) ?
				   $cgi->a({href=>&get_self_url($cgi,{'begin'=>($recordcount%$recordview) ?
								               (sprintf("%d",($recordcount/$recordview))*$recordview+1) :
									       ((sprintf("%d",($recordcount/$recordview))-1)*$recordview+1)
									   })}, $cgi->img({-src => "/ggpages/images/doublenextarrow.gif", -border=>0})) :
				   $cgi->img({-src => "/ggpages/images/doublenextarrow.gif", -border=>0})),
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
	    if (!$query && -r "$class.begin") {
		open(FLAT,"$class.begin");
		while (<FLAT>) {
		    chomp;
		    my ($begin,$id,$name) = split(/\t/,$_);
		    if (length($name) > $namelength) {
			$name = substr($name,0,$namelength);
		    }
		    $name .= '...';
		    $beginlabels->{$begin} = $name;
		}
		close(FLAT);
	    } elsif ($recordcount <= $recordlimit) {
		# get_begin_names slow for lots of records
		$beginlabels = &get_begin_names($class,$query);
	    }
	    #print &cgi_get_popngo($cgi,'begin',0,$beginvalues,$begin,$beginlabels);
	    print $cgi->popup_menu(-style=>'border:1px solid gray;',
				   -name=>'begin',
				   -values=>$beginvalues,
				   -default=>undef,
				   -labels=>$beginlabels,
				   -onchange=>"location.href='".&get_self_url($cgi,{'begin'=>undef}).";begin="."'+this.options[this.selectedIndex].value;"
				   );
	    print $cgi->end_td;
	    print $cgi->td({-colspan=>2});
	    print $cgi->end_Tr;
	    # end table
	    print $cgi->end_table;
	    print $cgi->end_p;
	}

	# print the report links one per line
	#foreach my $i (1..scalar(@$pagerecords)) {
	#    print "$i: ";
	#    print $cgi->a({href=>"$cgiurlpath/report.cgi?class=$class;id=$pagerecords->[$i-1]->{'id'}"},$pagerecords->[$i-1]->{'name'});
	#    print $cgi->br;
	#}

	# print the report links in a table
	print $cgi->start_p;
	#print $cgi->start_table({-border=>0,-cellpadding=>3,-style=>'font-size: small;'});
	print $cgi->start_table({-border=>0,-cellpadding=>3,-class=>'main'});
	for (my $row=1; $row<=$rows; $row++) {
	    print $cgi->start_Tr;
	    foreach my $column (1..$columns) {
		my $pagerecord = (($column-1)*$rows)+$row;
		my $absoluterecord = $pagerecord+($begin-1);
		if ($pagerecord > scalar(@$pagerecords)) {
		    #print $cgi->td({-valign=>'top'},'&nbsp;');
		    print $cgi->td({-valign=>'top'},'&nbsp;');
		} else {
		    # absolute record number
		    #print $cgi->td({-valign=>'top'},$cgi->small($absoluterecord));
		    # report link
		    # if map class, ses if this map exists in cmap before making it a link
		    my $link = undef;
		    if ($class eq 'map') {
			my ($cmapname) = $dbh->selectrow_array(sprintf("select map_name from cmap_map where map_name = %s",$dbh->quote($pagerecords->[$pagerecord-1]->{'name'})));
			if ($cmapname) {
                            # use names in url
			    $link = $cgi->a({href=>sprintf("$cgiurlpath/report.cgi?class=$class;name=%s",&geturlstring($pagerecords->[$pagerecord-1]->{'name'}))},
			                    $pagerecords->[$pagerecord-1]->{'name'});
			} else {
			    $link = $cgi->escapeHTML($pagerecords->[$pagerecord-1]->{'name'});
			}
		    } else {
                        # use id's in url
			#$link = $cgi->a({href=>"$cgiurlpath/report.cgi?class=$class;id=$pagerecords->[$pagerecord-1]->{'id'}"},
					#$pagerecords->[$pagerecord-1]->{'name'});
                        # use names in url
                        $link = $cgi->a({href=>sprintf("$cgiurlpath/report.cgi?class=$class;query=%s;name=%s",
                                                       $query ? &geturlstring($query) : '',
                                                       &geturlstring($pagerecords->[$pagerecord-1]->{'name'})
                                                       )},
                                        $pagerecords->[$pagerecord-1]->{'name'});
		    }
		    print $cgi->td({-valign=>'top',-style=>'font-size: small;',-width=>$cellwidth}, $link);
		}
	    }
	    print $cgi->end_Tr;
	}
	print $cgi->end_table;
	print $cgi->end_p;

	# end html
	print $cgi->end_html unless (-r $html_include_footer && &print_include($html_include_footer));
    }
} elsif (scalar(@$classcount) > 1) {
    # more than one class with results
    # provide links to recall this script for each class
    my $totalcount = 0; foreach (@$classcount) {$totalcount += $_->{'count'}}
    print $cgi->header;
    print $cgi->start_html(-title=>"GrainGenes Class Browser")
	  unless (-r $html_include_header && &print_header($html_include_header,"GrainGenes Class Browser"));
    #print $cgi->start_style({-type=>'text/css'}),"\nA {text-decoration: underline;}\n",$cgi->end_style;
    print $cgi->h3("GrainGenes Class Browser");
    &print_form;
    print $cgi->p($cgi->hr);
    print $cgi->p($cgi->b('Results:&nbsp;'),
                  sprintf("%s Record%s%s in %s Classes",
			  $cgi->b($totalcount),
			  $totalcount == 1 ? "" : "s",
		          $query ? sprintf(" matching %s",$cgi->b($query)) : '',
			  $cgi->b(scalar(@$classcount))
			  )
		  );
    # print links one per row
    #foreach my $classcount (@$classcount) {
	#my $url = &get_self_url($cgi,{'class'=>$classcount->{'class'}});
	#my $link = sprintf("<b>%s</b> Records in Class <b>%s</b>",
	#		   $classcount->{'count'},
	#		   $classes->{$classcount->{'class'}}
	#		   );
	#print $cgi->a({href=>"$url"},$link);
	#print $cgi->br;
    #}
    # print links in a table
    #print $cgi->start_p, $cgi->start_table({-border=>0,-cellpadding=>0,-cellspacing=>0,-style=>'font-size: small;'});
    print $cgi->start_p, $cgi->start_table({-border=>0,-cellpadding=>0,-cellspacing=>0,-class=>'main'});
    print $cgi->Tr($cgi->td([$cgi->b($cgi->u('Class')),'&nbsp;&nbsp;&nbsp;',$cgi->b($cgi->u('Records'))]));
    foreach my $classcount (@$classcount) {
	my $url = &get_self_url($cgi,{'class'=>$classcount->{'class'}});
	print $cgi->start_Tr;
        print $cgi->td($cgi->a({href=>"$url"},$classes->{$classcount->{'class'}}));
        print $cgi->td('&nbsp;&nbsp;&nbsp;');
        print $cgi->td({-align=>'right'},$classcount->{'count'});
	print $cgi->end_Tr;
    }
    print $cgi->end_table, $cgi->end_p;
    print $cgi->end_html unless (-r $html_include_footer && &print_include($html_include_footer));
}

$dbh->disconnect;

###############

sub print_form {
    # use globals $cgi $query $class $classes $browseclasses
    my $rolodexlinks = undef;
    # assemble $rolodexlinks
    if ($class) {
	$rolodexlinks .= $cgi->a({href=>&get_self_url($cgi,{'query'=>undef,'begin'=>1})},(!$query ? $cgi->big($cgi->b('ALL')) : 'ALL'));
	$rolodexlinks .= '&nbsp;';
	foreach my $ltr ('a'..'z') {
	    $rolodexlinks .= $cgi->a({href=>&get_self_url($cgi,{'query'=>($ltr.'*'),'begin'=>1})},
				     (($query && $query =~ /^$ltr\*$/i) ? 
				      $cgi->big($cgi->b(uc($ltr))) : 
				      uc($ltr)));
	    $rolodexlinks .= '&nbsp;';
	}
    }
    print $cgi->start_table({-border=>0});
    # form row
    print $cgi->start_form;
    my %xxx = %$browseclasses;
    print $cgi->Tr(
		   $cgi->td($cgi->b('Query&nbsp;<small>(optional)</small>&nbsp;')),
		   $cgi->td($cgi->textfield(-name=>'query',-size=>25)),
		   $cgi->td($cgi->b('&nbsp;in&nbsp;Class&nbsp;')),
		   $cgi->td($cgi->popup_menu(-name=>'class',
					     # dem 8apr12: Sort by value rather than by key.
					     #-values=>['all',sort(keys(%$browseclasses))],
					     -values=>['all',sort {$xxx{$a} cmp $xxx{$b}} (keys(%$browseclasses))],
					     -default=>'all',
					     -labels=>{'all'=>'All',%$browseclasses})),
		   $cgi->td($cgi->submit(-value=>'GO'))
		   );
    # go back to first page when resubmitting the form
    print $cgi->hidden(-name=>'begin',-default=>1,-override=>1);
    print $cgi->endform;
    # rolodex row
    print $cgi->Tr(
		   #$cgi->td('&nbsp;'),
		   #$cgi->td({-align=>'center',-colspan=>5},$cgi->b('Rolodex:'),$rolodexlinks)
		   $cgi->td({-align=>'center',-colspan=>5},"$classes->{$class}: ",$rolodexlinks)
		   ) if $rolodexlinks;
    print $cgi->end_table;
}

#sub get_query_terms {
#    # split query string on whitespace
#    # return array ref of query terms
#    my $query = shift;
#    return 1;
#}

sub count_classes {
    # count records for classes
    # clear and populate $classcount
    # use globals $browseclasses $classcount
    my $query = shift;
    my $class = shift;
    $classcount = [] if @$classcount;
    if (!$class) {
	# dem 8apr12: Sort by value rather than by key.
	#foreach my $cl (sort(keys(%$browseclasses))) {
	my %xxx = %$browseclasses;
	foreach my $cl (sort {$xxx{$a} cmp $xxx{$b}} keys(%xxx)) {
	    if (my $ct = &count_class($query,$cl)) {
		push(@$classcount,{'class'=>$cl,'count'=>$ct});
	    }
	}
    } else {
	if (my $ct = &count_class($query,$class)) {
	    push(@$classcount,{'class'=>$class,'count'=>$ct});
	}
    }
}

sub count_class {
    # count records for a class
    # return number of records
    my $query = shift;
    my $class = shift;
    my $cmp = '=';
    if ($query) {
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
    }
    my $sql = "select count(*) from $class";
    if ($query) {
        if ($query ne '%') {
            $sql .= sprintf(" where name $cmp %s",$dbh->quote($query));
        }
        my ($ct) = $dbh->selectrow_array($sql);
        return $ct;
    } else {
        return $classcounts{$class};
    }
}

sub get_class_ids {
    # get id and name of records for a class
    # return ref to array of hash refs, keys: id, name
    my $class = shift;
    my $query = shift;
    my $recordcount = shift;
    my $begin = shift;
    my $cmp = '=';
    if ($query) {
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
    }
    my $sql = "select id,name from $class";
    # add where clause
    if ($query) {$sql .= sprintf(" where name $cmp %s",$dbh->quote($query));}
    $sql .= " order by name";
    #$sql .= " order by cast(name as unsigned)";
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
    # use globals $namelength $recordview
    my $class = shift;
    my $query = shift;
    my $beginnames = {};
    my $cmp = '=';
    if ($query) {
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
    }
    my $sql = "select name from $class";
    # add where clause
    if ($query) {$sql .= sprintf(" where name $cmp %s",$dbh->quote($query));}
    $sql .= " order by name";
    #$sql .= " order by cast(name as unsigned)";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $records = $sth->fetchall_arrayref({});
    my $recordcount = scalar(@$records);
    for (my $i = 1; $i <= $recordcount; $i = $i+$recordview) {
	my $name = $records->[$i-1]->{'name'};
	if (length($name) > $namelength) {
	    $name = substr($name,0,$namelength);
	}
	$name .= '...';
	#$beginnames->{$i} = "$i: $name";
	$beginnames->{$i} = $name;
    }
    return $beginnames;
}
