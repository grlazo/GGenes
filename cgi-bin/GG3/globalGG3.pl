#!/data2/local/bin/perl

# global variables and subs
# require from other scripts

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

#our $db = "graingenes_myisam";
our $db = "graingenes";
our $user = "guest";
our $pass = "p0o9i8u7";
our $dsn = "DBI:mysql:$db";
our $cmapserver = "https://wheat.pw.usda.gov/cgi-bin/cmap";	#NL 29Oct2004
our $gbrowseserver = "https://wheat.pw.usda.gov/cgi-bin/gbrowse";	#NL 29Oct2004
our $cgisyspath = "/www/cgi-bin/GG3";
our $cgiurlpath = "/cgi-bin/GG3";
our $dbimagepath = "/dbs_images/graingenes";
our $webimagepath = "/graingenes/images";
our $html_include_basepath = '/www/htdocs/GG3.old/templates';
#our $html_include_header = "$html_include_basepath/header.tmpl";
#our $html_include_basepath = '/www/htdocs/GG3';
our $html_include_header = "$html_include_basepath/GG3_header.tmpl";
our $html_include_footer = "$html_include_basepath/footer.tmpl";
our $classes = {
		     'allele'=>'Allele',
		     'contigset'=>'Assembly',
		     'author'=>'Author',
		     'bin'=>'Bin',
		     'breakpoint'=>'Breakpoint',
		     'breakpointinterval'=>'Breakpoint Interval',
		     'chromband'=>'Chromosome Band',
		     'colleague'=>'Colleague',
		     'collection'=>'Collection',
		     'dna'=>'DNA',
		     'environment'=>'Environment',
                     'gel'=>'Gel',
		     'gene'=>'Gene',
		     'geneclass'=>'Gene Class',
		     'geneproduct'=>'Gene Product',
		     'geneset'=>'Gene Set',
		     'germplasm'=>'Germplasm',
		     'help'=>'Help',
		     'image'=>'Image',
		     'isolate'=>'Isolate',
		     'journal'=>'Journal',
                     'keyword'=>'Keyword',
		     'library'=>'Library',
		     'locus'=>'Locus',
		     'map'=>'Map',
		     'mapdata'=>'Map Data',
		     'marker'=>'Marker', # pseudoclass of gene+probe+locus 
		     'pathology'=>'Pathology',
		     'peptide'=>'Peptide',
		     'polymorphism'=>'Polymorphism',
		     'probe'=>'Probe',
		     'protein'=>'Protein',
		     'qtl'=>'QTL',
		     'rearrangement'=>'Rearrangement',
		     'reference'=>'Reference',
		     'restrictionenzyme'=>'Restriction Enzyme',
		     'sequence'=>'Sequence',
		     'source'=>'Source',
		     'species'=>'Species',
		     'trait'=>'Trait',
		     'traitscore'=>'Trait Score',
		     'traitstudy'=>'Trait Study',
		     'twopointdata'=>'Two Point Data'
               };
our $browseclasses = {
		     'allele'=>'Allele',
		     'contigset'=>'Assembly',
		     'author'=>'Author',
		     #'breakpoint'=>'Breakpoint',
		     #'breakpointinterval'=>'Breakpoint Interval',
		     #'chromband'=>'Chromosome Band',
		     'colleague'=>'Colleague',
		     'collection'=>'Collection',
		     #'dna'=>'DNA',
		     #'environment'=>'Environment',
                     #'gel'=>'Gel',
		     'gene'=>'Gene',
		     'geneclass'=>'Gene Class',
		     'geneproduct'=>'Gene Product',
		     #'geneset'=>'Gene Set',
		     'germplasm'=>'Germplasm',
		     #'help'=>'Help',
		     'image'=>'Image',
		     #'isolate'=>'Isolate',
		     'journal'=>'Journal',
                     'keyword'=>'Keyword',
		     'library'=>'Library',
		     'locus'=>'Locus',
		     'map'=>'Map',
		     'mapdata'=>'Map Data',
		     'marker'=>'Marker', # pseudoclass of gene+probe+locus 
		     'pathology'=>'Pathology',
		     #'peptide'=>'Peptide',
		     'polymorphism'=>'Polymorphism',
		     'probe'=>'Probe',
		     'protein'=>'Protein',
		     'qtl'=>'QTL',
		     'rearrangement'=>'Rearrangement',
		     'reference'=>'Reference',
		     #'restrictionenzyme'=>'Restriction Enzyme',
		     'sequence'=>'Sequence',
		     #'source'=>'Source',
		     'species'=>'Species',
		     'trait'=>'Trait',
		     #'traitscore'=>'Trait Score',
		     'traitstudy'=>'Trait Study',
		     'twopointdata'=>'Two Point Data'
		     };

sub cgi_valid_class {
    # check for a valid value for class param
    # return valid class or undef
    # use global $classes
    my $cgi = shift;
    my $class = $cgi->param('class');
    if ($class) {
        foreach my $cl (keys(%$classes)) {
            if ($cl eq $class) {
                return $class;
            }
        }
    }
    $cgi->param(-name=>'class',-value=>undef);
    return undef;
}

sub valid_class {
    # see if a class is valid
    # return 0/1
    # use global $classes
    my $class = shift;
    if ($class) {
        foreach my $cl (keys(%$classes)) {
            if ($cl eq $class) {
                return 1;
            }
        }
    }
    return 0;
}

sub cgi_valid_query {
    # check for a valid value for query param
    # return valid value or undef
    my $cgi = shift;
    my $query = $cgi->param('query');
    if ( !$query ||
	 $query =~ /^\s+$/ ) {
	$cgi->param(-name=>'query',-value=>undef);
	return undef;
    } else {
	return $query;
    }
}

sub valid_query {
    # see if a query is valid
    # return 0/1
    my $query = shift;
    if ( !$query ||
	 $query =~ /^\s+$/ ) {
	return 0;
    }
    return 1;
}

sub cgi_valid_begin {
    # check for a valid value for begin param
    # return/set valid value
    my $cgi = shift;
    my $recordcount = shift;
    my $recordview = shift;
    my $begin = $cgi->param('begin');
    if ( !$begin ||
	 $begin !~ /^\d+$/ ||
	 $begin <= 1 ||
	 $begin > $recordcount ||
	 (($begin-1) % $recordview) != 0 ) {
	$cgi->param(-name=>'begin',-value=>1);
	return 1;
    } else {
	return $begin;
    }
}

sub cgi_valid_id {
    # check for a valid value for id param
    # return/set valid id or undef
    my $cgi = shift;
    my $dbh = shift;
    my $class = shift;
    return undef unless $class;
    my $id = $cgi->param('id');
    if ($id && $id =~ /^\d+$/) {
	my ($count) = $dbh->selectrow_array(sprintf("select count(*) from %s where id = %s",$class,$id));
	return $id if $count;
    }
    $cgi->param(-name=>'id',-value=>undef);
    return undef;
}

sub cgi_valid_name {
    # check for a valid value for name param
    # return/set valid id or undef
    my $cgi = shift;
    my $dbh = shift;
    my $class = shift;
    return undef unless $class;
    my $name = $cgi->param('name');
    if ($name) {
#NL24Sep2004(to solve Locus Glu1 vs GLU1 problem:	my ($count) = $dbh->selectrow_array(sprintf("select count(*) from %s where name = %s",$class,$dbh->quote($name)));
	my ($count) = $dbh->selectrow_array(sprintf("select count(*) from %s where name = %s collate latin1_bin",$class,$dbh->quote($name)));
	return $name if $count;
    }
    $cgi->param(-name=>'name',-value=>undef);
    return undef;
}

sub print_include {
    # print an include file
    my $file = shift;
    open(FILE,$file) or return 0;
    print while (<FILE>);
    close(FILE);
    return 1;
}

sub print_header {
    # print the document header
    my $file = shift;
    my $title = shift;
    print q{
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
};
    if ($title) {print "<title>$title</title>\n";}
    else {print "<title>GrainGenes 3.0</title>\n";}
    open(FILE,$file) or return 0;
    print while (<FILE>);
    close(FILE);
    return 1;
}

sub array_remove_item {
    # remove an item from a flat array
    my $list = shift;
    my $rmitem = shift;
    my $newlist = [];
    if (!defined($list)) {
	return undef;
    } elsif (defined($list) && scalar(@$list) == 0) {
	return [()];
    } else {
	foreach my $item (@$list) {
	    push(@$newlist,$item) unless $item eq $rmitem;
	}
	return $newlist;
    }
}

sub cgi_check_multivalue {
    # see if a value is contained in a multivalue cgi parameter
    my $cgi = shift;
    my $param = shift;
    my $value = shift;
    return undef if (!$param || !$value || !$cgi->param($param));
    my @values = $cgi->param($param);
    foreach $val (@values) {if ($val eq $value) {return 1;}}
    return 0;
}

sub cgi_cgiurlpath {
    # determine directory where scripts are located
    my $cgi = shift;
    my $script = $cgi->url(-relative=>1);
    my $scriptpath = $cgi->url(-absolute=>1);
    $scriptpath =~ s/\/$script$//;
    return $scriptpath;
}

sub get_complete_reference {
    # generate complete html reference
    # use global $cgiurlpath
    my $cgi = shift;
    my $dbh = shift;
    my $refid = shift;
    return undef unless $refid;
    my $htmlref = undef;
    # pull out reference information
    my $ref = $dbh->selectrow_hashref("select * from reference where id = $refid");
    my $refjournal;
    if ($ref->{'journalid'}) {
	# a journal article
	$refjournal = $dbh->selectrow_hashref(
					      qq{
						  select journal.id,journal.name from reference
						      inner join journal on reference.journalid = journal.id
						      where reference.id = $refid
						  }
					      );
    } elsif ($ref->{'containedin_referenceid'}) {
	# a book maybe?
	$refjournal = $dbh->selectrow_hashref(
					      qq{
						  select id,title as name from reference
						      where id = $ref->{'containedin_referenceid'}
					        }
					      );
    }
    my $refauthors = $dbh->selectall_arrayref(
					      qq{
						 select author.id,author.name from referenceauthor
						 inner join author on referenceauthor.authorid = author.id
						 where referenceauthor.referenceid = $refid
					         },
					      {'Slice'=>{}}
					      );
    # assemble complete reference
    #$htmlref .= $cgi->start_table({-cellpadding=>2,-cellspacing=>0,-class=>'main',-style=>'font-size: smaller;'});
    $htmlref .= $cgi->start_table({-cellpadding=>2,-cellspacing=>0,-class=>'main',-style=>'font-size: 11px;'});
    $htmlref .= $cgi->start_Tr;
    $htmlref .= $cgi->td({-valign=>'top'},$cgi->a({-href=>"$cgiurlpath/report.cgi?class=reference;id=$ref->{'id'}"},$cgi->img({-src=>"$webimagepath/book_icon.jpg",-border=>0,-alt=>'Reference'})));
    $htmlref .= $cgi->start_td({-valign=>'top'});
    # add author(s)
    if (scalar(@$refauthors) == 1) {
	$htmlref .= $cgi->b($cgi->escapeHTML($refauthors->[0]->{'name'})) . ' ';
	#$htmlref .= $cgi->a({-href=>"$cgiurlpath/report.cgi?class=author;id=$refauthors->[0]->{'id'}"},
	#		    $cgi->escapeHTML($refauthors->[0]->{'name'}));
	#$htmlref .= ' ';
    } elsif (scalar(@$refauthors) == 2) {	# NL 29Nov2004
	$htmlref .= $cgi->b($cgi->escapeHTML($refauthors->[0]->{'name'})) . ' and ';
	$htmlref .= $cgi->b($cgi->escapeHTML($refauthors->[1]->{'name'})) . ' ';
#    } elsif (scalar(@$refauthors) > 1) {
    } elsif (scalar(@$refauthors) > 2) {
	$htmlref .= $cgi->b($cgi->escapeHTML($refauthors->[0]->{'name'})) . ' et al. ';
	#$htmlref .= $cgi->a({-href=>"$cgiurlpath/report.cgi?class=author;id=$refauthors->[0]->{'id'}"},
	#		    $cgi->escapeHTML($refauthors->[0]->{'name'}));
	#$htmlref .= ' et al. ';
    }
    # add year
    if ($ref->{'year'}) {
	$htmlref .= '(' . $cgi->escapeHTML($ref->{'year'}) . ')';
	$htmlref .= ' ';
    }
    # add title or name (code)
    if ($ref->{'title'}) {
	$htmlref .= $cgi->escapeHTML($ref->{'title'}) . ' ';
	#$htmlref .= $cgi->a({-href=>"$cgiurlpath/report.cgi?class=reference;id=$ref->{'id'}"},
	#		    $cgi->escapeHTML($ref->{'title'}));
	#$htmlref .= ' ';
    } else {
	$htmlref .= $cgi->escapeHTML($ref->{'name'}) . ' ';
	#$htmlref .= $cgi->a({-href=>"$cgiurlpath/report.cgi?class=reference;id=$ref->{'id'}"},
	#		    $cgi->escapeHTML($ref->{'name'}));
	#$htmlref .= ' ';
    }
    # add journal
    if ($refjournal->{'name'}) {
	$htmlref .= $cgi->b($cgi->escapeHTML($refjournal->{'name'})) . ' ';
	#$htmlref .= $cgi->a({-href=>"$cgiurlpath/report.cgi?class=journal;id=$refjournal->{'id'}"},
	#		    $cgi->b($cgi->escapeHTML($refjournal->{'name'})));
	#$htmlref .= ' ';
    }
    # add volume
    if ($ref->{'volume'}) {
	$htmlref .= $cgi->escapeHTML($ref->{'volume'});
	$htmlref .= ':';
    }
    # add pages
    if ($ref->{'pages'}) {
	$htmlref .= $cgi->escapeHTML($ref->{'pages'});
    }
    # remove any unnecessary trailing characters
    $htmlref =~ s/[ :]$//;
    # add period if necessary
    $htmlref .= '.' unless ($htmlref =~ /\.$/);
    $htmlref .= $cgi->end_td;
    $htmlref .= $cgi->end_Tr;
    $htmlref .= $cgi->end_table;
    # return small
    #return $cgi->small($htmlref);
    return $htmlref;
}

sub cgi_get_popngo {
# return self-contained pop-n-go navigation form
# don't use this within another form
my $cgi = shift;
my $param = shift; # param name to control
                   # this can't be a javascript reserved word
my $remove = shift; # 0/1 remove all other params from url
my $values = shift; # array ref of values to use in the menu
my $defaultvalue = shift; # default menu value
my $labels = shift; # hash ref of value labels
my $url = undef;
my $js = undef;
my $popngo = undef;
if ($remove) {
    $url = $cgi->url();
    $url .= "?$param=";
} else {
    my $oldval = $cgi->param($param);
    $cgi->delete($param);
    $url = $cgi->self_url;
    $url .= ";$param=";
    $cgi->param(-name=>$param,-value=>$oldval);
}
$js = <<JS;
<!--
function go${param}(${param}) {
    url = '$url' + $param.options[$param.selectedIndex].value;
    window.location = url;
}
// -->
JS
$popngo = $cgi->script({-language=>'javascript'},$js);
$popngo .= $cgi->start_form(-method=>undef,-action=>undef,-enctype=>undef);
$popngo .= $cgi->popup_menu(-name=>$param,
			    -values=>$values,
			    -default=>$defaultvalue,
			    -labels=>$labels,
			    -onChange=>"go${param}(this.form.${param})"
			    );
$popngo .= $cgi->endform;
return $popngo;
}

sub get_self_url {
    # get a self_url() with optionally changed parameter values
    # if new parameter value is an array ref assume a multivalued param
    my $cgi = shift;
    my $newparams = shift; # hash ref of params to change
    my $savedparams = {}; # hash ref of previous params
    my $self_url = undef;
    # save existing values for params to be changed
    foreach my $param (keys %$newparams) {
	my @values = $cgi->param($param);
	if (!@values) {
	    $savedparams->{$param} = undef;
	} elsif (scalar(@values) == 1) {
	    $savedparams->{$param} = $values[0];
	} elsif (scalar(@values) > 1) {
	    $savedparams->{$param} = [@values];
	}
    }
    # set values for changed params
    foreach my $param (keys %$newparams) {
	if (!defined($newparams->{$param}) || (ref($newparams->{$param}) eq 'ARRAY' && @{$newparams->{$param}} == 0)) {
	    $cgi->delete($param);
	} elsif (ref($newparams->{$param}) eq 'ARRAY') {
	    $cgi->param(-name=>$param,-values=>$newparams->{$param});
	} else {
	    $cgi->param(-name=>$param,-value=>$newparams->{$param});
	}
    }
    # get self_url
    $self_url = $cgi->self_url;
    # restore original values for changed params
    foreach my $param (keys %$newparams) {
	my $values = $savedparams->{$param};
	if (!defined($values)) {
	    $cgi->delete($param);
	} elsif (ref($values) eq 'ARRAY') {
	    $cgi->param(-name=>$param,-values=>$values);
	} else {
	    $cgi->param(-name=>$param,-value=>$values);
	}
    }
    # return self_url
    return $self_url;
}

sub get_self_url_old {
    # generate a self url with optionally changed parameter values
    # avoids having to change a value with param() before calling self_url()
    # call with only one empty param for pop-n-go
    my $cgi = shift;
    my $newparams = shift; # hash ref of params to change, param => value
    my @params = $cgi->param();
    my $url = $cgi->url(-base=>1);
    $url .= $cgi->url(-absolute=>1);
    if (@params || %$newparams) {$url .= '?';}
    if (@params) {
	# add unchanged params
	foreach my $param (@params) {
	    next if exists($newparams->{$param});
	    $url .= sprintf("$param=%s;",$cgi->param($param));
	}
    }
    if (%$newparams) {
	# add changed params
	foreach my $newparam (keys %$newparams) {
	    $url .= sprintf("$newparam=%s;", $newparams->{$newparam} ? $newparams->{$newparam} : '');
	}
    }
    $url =~ s/;$//;
    return $url;
}

sub common_array_elements {
    # take a ref to an array of array refs
    # return an array ref of unique elements common to all of the passed array refs
    # return undef if array refs not passed
    # ignore empty arrays
    my $arrays = shift;
    my $arrayct = scalar(@$arrays);
    if (ref($arrays) ne 'ARRAY') {
	return undef;
    } elsif ($arrayct == 1 && ref($arrays->[0]) eq 'ARRAY') {
	return &unique_array_elements([$arrays->[0]]);
    } else {
	my @temparray = ();
	my @common = ();
	my $ct = 0;
	# check each array and put all elements into one array
	foreach my $ary (@$arrays) {
	    if (ref($ary) ne 'ARRAY') {
		return undef;
	    } else {
		#push(@temparray,@$ary) if @$ary;
		my $uniqary = &unique_array_elements([$ary]);
		push(@temparray,@$uniqary) if @$uniqary;
	    }
	}
	# sort all elements
	@temparray = sort @temparray;
	# save common elements
	foreach my $i (0..$#temparray) {
	    if ($i == 0) {$ct = 1; next;}
	    if ($temparray[$i] == $temparray[$i-1]) {$ct++;} else {$ct = 1;}
	    if ($ct == $arrayct) {push(@common,$temparray[$i]);}
	}
	return \@common;
    }
}

sub unique_array_elements {
    # take a ref to an array of array refs
    # return an array ref of unique elements present in all of the passed array refs
    # return undef if array refs not passed
    # ignore empty arrays
    my $arrays = shift;
    my $arrayct = scalar(@$arrays);
    if (ref($arrays) ne 'ARRAY') {
	return undef;
    } else {
	my @temparray = ();
	my @unique = ();
	# check each array and put all elements into one array
	foreach my $ary (@$arrays) {
	    if (ref($ary) ne 'ARRAY') {
		return undef;
	    } else {
		push(@temparray,@$ary) if @$ary;
	    }
	}
	# sort all elements
	@temparray = sort @temparray;
	# save unique elements
	foreach my $i (0..$#temparray) {
	    if ($i == 0) {push(@unique,$temparray[$i]); next;}
	    if ($temparray[$i] == $temparray[$i-1]) {next;} else {push(@unique,$temparray[$i]); next;}
	}
	return \@unique;
    }
}

sub geturlstring {
    # encode a string for a url
    # expects a string, returns a string
    my $text = shift;
    #$text =~ s/([^\r])\n/$1\r\n/g;
    # add comma to excluded charset as per DM 050203
    $text =~ s/([^a-z0-9_.!~*'() \-,])/sprintf "%%%02X", ord($1)/gei;
    #$text =~ s/([^a-z0-9_.!~*'() -])/sprintf "%%%02X", ord($1)/gei;
    $text =~ tr/ /+/;
    return $text;
}

1;
