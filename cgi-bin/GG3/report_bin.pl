#!/usr/bin/perl

# report_bin, dem 6jan06

# print bin report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'bin',
	       'Bin',
	       qq{
		   select name 
		   from bin
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# OK locus
&print_element(
	       $cgi,
	       $dbh,
	       'locus',
	       'Locus',
	       qq{
		   select
                    locus.id as locus_id,
                    locus.name as locus_name
                   from binlocus
                    inner join locus on locus.id = binlocus.locusid
                   where binlocus.binid = $id
		   },
	       ['locus_link'],
	       []
	       );    

# OK binlocus
&print_element(
	       $cgi,
	       $dbh,
	       'binlocus',
	       'Binlocus',
	       qq{
		   select
                    locus.id as locus_id,
                    locus.name as locus_name
                   from binbinlocus
                    inner join locus on locus.id = binbinlocus.locusid
                   where binbinlocus.binid = $id
		   },
	       ['locus_link'],
	       []
	       );    

# qtl
&print_element(
	       $cgi,
	       $dbh,
	       'qtl',
	       'QTL',
	       qq{
		   select
                    qtl.id as qtl_id,
                    qtl.name as qtl_name
                   from binqtl
                    inner join qtl on qtl.id = binqtl.qtlid
                   where binqtl.binid = $id
		   },
	       ['qtl_link'],
	       []
	       );    

# datasource
&print_element(
               $cgi,
               $dbh,
               'datasource',
               'Data Source',
               qq{
                   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name,
                    bindatasource.date
                   from bindatasource 
                    inner join colleague on colleague.id = bindatasource.colleagueid
                   where bindatasource.binid = $id
                   },
               ['colleague_link','date'],
               []
               );

# map 
{
    my $sql = qq{
                   select distinct
                       map.id as map_id,
                       map.name as map_name
                       from mapbin
                       inner join map on mapbin.mapid = map.id
                       where mapbin.binid = $id
                       order by map.name
                 };
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $map = $sth->fetchall_arrayref({});
    foreach my $mp (@$map) {
	# see if this map exists in cmap before making it a link
	my ($cmapname) = $dbh->selectrow_array(sprintf("select map_name from cmap_map where map_name = %s",$dbh->quote($mp->{'map_name'})));
	if ($cmapname) {
	    $mp->{'map'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map;locusid=$id;name=".&geturlstring($mp->{'map_name'}),-target=>'_blank'},$mp->{'map_name'});
	} else {
	    $mp->{'map'} = $cgi->escapeHTML($mp->{'map_name'});
	}
	delete $mp->{'map_id'};
	delete $mp->{'map_name'};
    }
    &print_element(
                   $cgi,
                   $dbh,
                   'map',
                   'Map',
                   $map,
                   ['map_html'],
                   []
                   );
}

	       
1;
