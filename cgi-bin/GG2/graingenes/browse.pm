# $Id: browse.pm,v 1.1 2005/08/26 16:38:10 mnemchuk Exp mnemchuk $
package graingenes::browse;

use strict;
use warnings;

use base ("graingenes");
#our @ISA = ("graingenes");

our $recordview = 50; # number of records to view at once
our $columns = 5; # number of columns in record table
our $rows = 10; # number of rows in record table
our $tablewidth = 800; # width of record table
our $recordlimit = 50000; # if below, use names in name pager drop-down
                          # if above, use numbers in name pager drop-down
our $namelength = 30; # maximum name length in name pager drop-down
our $menumax = 200; # maximum number of menu items in name pager drop-down
our $cellwidth = sprintf("%d",$tablewidth/$columns); # width of record table columns
#my $cellwidth = sprintf("%d%%",100/$columns); # width of record table columns

our $classes = {
    'allele'=>'Allele',
    'author'=>'Author',
    #'breakpoint'=>'Breakpoint',
    #'breakpointinterval'=>'Breakpoint Interval',
    #'chromband'=>'Chromosome Band',
    'colleague'=>'Colleague',
    #'collection'=>'Collection',
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
    'library'=>'Library',
    'locus'=>'Locus',
    'map'=>'Map',
    'mapdata'=>'Map Data',
    'marker'=>'Marker', # pseudoclass of gene+probe
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
    'twopointdata'=>'2 Point Data'
};

sub new {
    my $class = shift;
    $class = ref($class) || $class;
    my $self = $class->SUPER::new || return undef;
    $self->{'PAGERECORDS'} = undef;
    $self->{'BEGINNAMES'} = undef;
    $self->{'CLASSCOUNT'} = undef;
    $self->{'QUERYSQL'} = undef;
    bless ($self, $class);
    return $self;
}

sub get_class {
    my $self = shift;
    my $cgi = $self->{'CGI'};
    my $class = $cgi->param('class');
    if (!defined($class)) {
	return undef;
    } elsif ($class eq '' || $class =~ /^\s+$/) {
	$cgi->delete('class');
	return undef;
    } elsif ($classes->{$class}) {
	return $class;
    } else {
	$cgi->delete('class');
	return undef;
    }
}

sub get_query {
    my $self = shift;
    my $cgi = $self->{'CGI'};
    my $query = $cgi->param('query');
    if (!defined($query)) {
	return undef;
    } elsif ($query eq '' || $query =~ /^\s+$/) {
	$cgi->delete('query');
	return undef;
    } else {
	$query =~ s/^\s+//;
	$query =~ s/\s+$//;
	$cgi->param(-name=>'query',-value=>$query);
	return $query;
    }
}

sub get_begin {
    my $self = shift;
    my $cgi = $self->{'CGI'};
    my $begin = $cgi->param('begin');
    if (
	!defined($begin) ||
	$begin == 0 ||
	$begin eq '' ||
	$begin =~ /^\s+$/ ||
	$begin !~ /^\d+$/ ||
	(($begin-1) % $recordview) != 0
	) {
        $cgi->param(-name=>'begin',-value=>1);
	return 1;
    } else {
	return $begin;
    }
}

sub count_classes {
    # count records for browseable classes
    my $self = shift;
    #return $self->{'CLASSCOUNT'} if defined($self->{'CLASSCOUNT'});
    my $cgi = $self->{'CGI'};
    my $class = $cgi->param('class');
    my $classcount = {};
    if (!$class) {
        foreach my $cl (sort(keys(%$classes))) {
            if (my $ct = $self->count_class($cl)) {
		$classcount->{$cl} = $ct;
            }
        }
    } else {
        if (my $ct = $self->count_class($class)) {
	    $classcount->{$class} = $ct;
        }
    }
    $self->{'CLASSCOUNT'} = $classcount;
    return $classcount;
}

sub count_class {
    # count records for a class
    my $self = shift;
    my $class = shift;
    return undef unless $class;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    my $query = $cgi->param('query');
    my $sql = "select count(*) from $class";
    if ($query) {$sql .= sprintf(" where name like %s",$dbh->quote($self->get_query_for_sql));}
    my ($ct) = $dbh->selectrow_array($sql);
    return $ct;
}

sub get_page_records {
    # get id and name for a page of records
    # return ref to array of hash refs, keys: id, name
    my $self = shift;
    return $self->{'PAGERECORDS'} if defined($self->{'PAGERECORDS'});
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    my $class = $cgi->param('class');
    my $query = $cgi->param('query');
    my $begin = $cgi->param('begin');
    return undef unless $class;
    return undef unless $begin;
    my $recordcount = $self->{'CLASSCOUNT'}->{$class};
    return undef unless $recordcount;
    if ($begin > $recordcount) {
	$begin = 1;
	$cgi->param(-name=>'begin',-value=>1);
    }
    my $pagerecords = undef;
    my $sql = "select id,name from $class";
    # add where clause
    if ($query) {$sql .= sprintf(" where name like %s",$dbh->quote($self->get_query_for_sql));}
    $sql .= " order by name";
    # add limit clause
    if ($recordcount > $recordview) {
	$sql .= sprintf(" limit %s,%s",
			$begin-1,
			((($begin-1)+$recordview) > $recordcount) ? ($recordcount-($begin-1)) : $recordview);
    }
    $pagerecords = $dbh->selectall_arrayref($sql,{'Slice'=>{}});
    $self->{'PAGERECORDS'} = $pagerecords;
    return $pagerecords;
}

sub get_begin_names {
    # get begin number and name of records for name drop-down pager
    # return hash ref: begin => name
    my $self = shift;
    return $self->{'BEGINNAMES'} if defined($self->{'BEGINNAMES'});
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    my $class = $cgi->param('class');
    my $query = $cgi->param('query');
    return undef unless $class;
    my $beginnames = undef;
    my $sql = "select name from $class";
    # add where clause
    if ($query) {$sql .= sprintf(" where name like %s",$dbh->quote($self->get_query_for_sql));}
    $sql .= " order by name";

#     my $records = $dbh->selectall_arrayref($sql,{'Slice'=>{}});
#     my $recordcount = scalar(@$records);
#     for (my $i = 1; $i <= $recordcount; $i = $i+$recordview) {
# 	my $name = $records->[$i-1]->{'name'};
# 	if (length($name) > $namelength) {
# 	    $name = substr($name,0,$namelength);
# 	}
# 	$name .= '...';
# 	$beginnames->{$i} = $name;
#     }

    my $ctr = 0;
    my $sth = $dbh->prepare($sql); $sth->execute;
    while (my ($name) = $sth->fetchrow_array) {
	$ctr++;
	if (($ctr-1) % $recordview == 0) {
	    if (length($name) > $namelength) {
		$name = substr($name,0,$namelength);
	    }
	    $name .= '...';
	    $beginnames->{$ctr} = $name;
	}
    }
    $sth->finish;

    $self->{'BEGINNAMES'} = $beginnames;
    return $beginnames;
}

sub get_query_for_sql {
    my $self = shift;
    #return $self->{'QUERYSQL'} if defined($self->{'QUERYSQL'});
    my $cgi = $self->{'CGI'};
    my $querysql = $cgi->param('query');
    return undef unless $querysql;
    # escape %
    $querysql =~ s/([^\\]|^)\%/$1\\%/g;
    # escape _
    $querysql =~ s/([^\\]|^)_/$1\\_/g;
    # change * wildcard to % wildcard
    $querysql =~ s/([^\\]|^)\*/$1\%/g;
    # escape '
    #$querysql =~ s/'/\\'/g;
    $self->{'QUERYSQL'} = $querysql;
    return $querysql;
}

sub print_form {
    my $self = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    my $class = $cgi->param('class');
    my $query = $cgi->param('query');
    my $rolodexlinks = undef;
    # assemble $rolodexlinks
    if ($class) {
	$rolodexlinks .= $cgi->a({-href=>$self->get_self_url({'query'=>undef,'begin'=>1})},(!$query ? $cgi->big($cgi->b('ALL')) : 'ALL'));
	$rolodexlinks .= '&nbsp;';
	foreach my $ltr ('a'..'z') {
	    $rolodexlinks .= $cgi->a({-href=>$self->get_self_url({'query'=>($ltr.'*'),'begin'=>1})},
				     (($query && $query =~ /^$ltr\*$/i) ? 
				      $cgi->big($cgi->b(uc($ltr))) : 
				      uc($ltr)));
	    $rolodexlinks .= '&nbsp;';
	}
    }
    print $cgi->start_table({-border=>0});
    # form row
    print $cgi->start_form(-name=>'browsef');
    print $cgi->Tr(
		   $cgi->td($cgi->b('Query&nbsp;<small>(optional)</small>&nbsp;')),
		   $cgi->td($cgi->textfield(-name=>'query',-id=>'mquery',-size=>25, -onkeyup=>'passSelected(event)')),
		   $cgi->td($cgi->b('&nbsp;in&nbsp;Class&nbsp;')),
		   $cgi->td($cgi->popup_menu(-name=>'class',id=>'class',
					     -values=>['all',sort(keys(%$classes))],
					     -default=>'all',
					     -onChange=>'classChanged(this)',
					     -labels=>{'all'=>'All',%$classes})),
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

sub print_pager {
    my $self = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    my $class = $cgi->param('class');
    return undef unless $class;
    my $query = $cgi->param('query');
    my $begin = $cgi->param('begin');
    my $recordcount = $self->{'CLASSCOUNT'}->{$class};
    return undef unless $recordcount;
    print $cgi->start_p;
    print $cgi->start_table({-border=>0});
    print $cgi->start_Tr;
    # first page
    print $cgi->td({-style=>'text-align: center;'},
		   '&nbsp;',
		   sprintf(
			   "%s",
			   ($begin > 1) ?
			   $cgi->a({href=>$self->get_self_url({'begin'=>1})},"|&lt;&lt;") :
			   "|&lt;&lt;"
			   ),
		   '&nbsp;'
		   );
    # back one page
    print $cgi->td({-style=>'text-align: center;'},
		   '&nbsp;',
		   sprintf(
			   "%s",
			   ($begin > 1) ?
			   $cgi->a({href=>$self->get_self_url({'begin'=>$begin-$recordview})},"&lt;&lt;") :
			   "&lt;&lt;"
			   ),
		   '&nbsp;'
		   );
    # pages and records
    print $cgi->td({-style=>'text-align: center;'},
		   '&nbsp;',
		   sprintf(
			   "[Page %s of %s: Records %s - %s of %s]",
# 			   $cgi->popup_menu(
# 					    -name=>'begin',
# 					    -values=>[grep {($_%$recordview) == 1} (1..$recordcount)],
# 					    -default=>1,
# 					    -labels=>{
# 						      map {
# 							   $_=>(sprintf("%d",$_/$recordview)+1)
# 							   } (grep {($_%$recordview) == 1} (1..$recordcount))
# 					              },
# 					    -onchange=>"location.href='".
# 					               $self->get_self_url({'begin'=>undef}).
# 					               ";begin=".
# 					               "'+this.options[this.selectedIndex].value;"
# 					    ),
			   $cgi->b(sprintf("%d",$begin/$recordview)+1),
			   $cgi->b(($recordcount%$recordview) ?
				   (sprintf("%d",$recordcount/$recordview)+1) :
				   (sprintf("%d",$recordcount/$recordview))),
			   $cgi->b($begin),
			   $cgi->b((($begin+$recordview-1) > $recordcount) ?
				   $recordcount :
				   ($begin+$recordview-1)),
			   $cgi->b($recordcount)
			   ),
		   '&nbsp;'
		   );
    # forward one page
    print $cgi->td({-style=>'text-align: center;'},
		   '&nbsp;',
		   sprintf(
			   "%s",
			   ($recordcount > ($begin+$recordview-1)) ?
			   $cgi->a({href=>$self->get_self_url({'begin'=>$begin+$recordview})},"&gt;&gt;") :
			   "&gt;&gt;"
			   ),
		   '&nbsp;'
		   );
    # last page
    print $cgi->td({-style=>'text-align: center;'},
		   '&nbsp;',
		   sprintf("%s",
			   ($recordcount > ($begin+$recordview-1)) ?
			   $cgi->a({href=>$self->get_self_url({'begin'=>
								   ($recordcount%$recordview) ?
								   (sprintf("%d",($recordcount/$recordview))*$recordview+1) :
								   ((sprintf("%d",($recordcount/$recordview))-1)*$recordview+1)
							      }
							)
				    },"&gt;&gt;|") :
			   "&gt;&gt;|"),
		   '&nbsp;'
		   );
    print $cgi->end_Tr;
    # name drop-down
    print $cgi->start_Tr;
    print $cgi->td({-colspan=>2});
    print $cgi->start_td({-style=>'text-align: center;'});
    my $beginvalues = [];
    my $beginlabels = {};
    my $pagefactor = 1;
    while (int($recordcount/$recordview)/$pagefactor > $menumax) {
	$pagefactor++;
    }
    for (my $i=1; $i<=$recordcount; $i=$i+($recordview*$pagefactor)) {
	push(@$beginvalues,$i);
# 	$beginlabels->{$i} = sprintf(
# 				     "%d ... %d",
# 				     $i,
# 				     ($i+($recordview-1)) < $recordcount ? ($i+($recordview-1)) : $recordcount
# 				     );
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
	$beginlabels = $self->get_begin_names;
    }
    print $cgi->popup_menu(
			   -name=>'begin',
			   -values=>$beginvalues,
			   -default=>undef,
			   -labels=>$beginlabels,
			   -onchange=>
			   "location.href='".
			   $self->get_self_url({'begin'=>undef}).
			   ";begin=".
			   "'+this.options[this.selectedIndex].value;"
			   );
    print $cgi->end_td;
    print $cgi->td({-colspan=>2});
    print $cgi->end_Tr;
    print $cgi->end_table;
    print $cgi->end_p;
}

1;
