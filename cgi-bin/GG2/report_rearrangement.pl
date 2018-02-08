#!/usr/bin/perl

# NLui, 29Apr2004

# print rearrangement report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'rearrangement',
	       'Rearrangement',
	       qq{
		   select name 
		   from rearrangement
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# correctname,othername,referencegermplasm,remark,variant removed from schema
# found,absent,mutagen,phenotype,dosageeffects(haploinsufficiency) removed from schema
# qualifier removed from schema

# OK location (colleague)
&print_element(
	       $cgi,
	       $dbh,
	       'location',
	       'Location',
	       qq{
		   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name
                   from colleague
                    inner join rearrangement on colleague.id = rearrangement.location_colleagueid
                   where rearrangement.id = $id
		   },
	       ['colleague_link'],
	       []
	       );    

# author,date removed from schema
# OK type
&print_element(
               $cgi,
               $dbh,
               'type',
               'Type',
               qq{
                   select
                    type
                   from rearrangementtype
                   where rearrangementid = $id
                   },
               ['type'],
               []
               );


# OK map (mapposition unnec -- to be shown on map)
#&print_element(
#	       $cgi,
#	       $dbh,
#	       'map',
#	       'Map',
#	       qq{
#		   select
#                    distinct map.id as map_id,
#                    map.name as map_name
#                   from map
#                    inner join maprearrangement on map.id = maprearrangement.mapid
#                   where maprearrangement.rearrangementid = $id
#		   },
#	       ['map_link'],
#	       []
#	       ); 

# map (2)
{
    my $sql = qq{
                   select distinct
                       map.id as map_id,
                       map.name as map_name
                       from maprearrangement
                       inner join map on maprearrangement.mapid = map.id
                       where maprearrangement.rearrangementid = $id
                       order by map.name
                 };
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $map = $sth->fetchall_arrayref({});
    foreach my $mp (@$map) {
        $mp->{'map'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map;rearrangementid=$id;name=".&geturlstring($mp->{'map_name'}),-target=>'_blank'},$mp->{'map_name'});
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

# proximal/distalbreakpoint removed from schema
# OK proximalmarker
&print_element(
	       $cgi,
	       $dbh,
	       'proximalmarker',
	       'Proximal Marker',
	       qq{
		   select
                    locus.id as locus_id,
                    locus.name as locus_name
                   from locus
                    inner join rearrangementnearbymarker on locus.id = rearrangementnearbymarker.locusid
                   where rearrangementnearbymarker.rearrangementid = $id
                    and rearrangementnearbymarker.type = 'Proximal_marker'
		   },
	       ['locus_link'],
	       []
	       );    
	       
# OK contains (Locus)
&print_element(
	       $cgi,
	       $dbh,
	       'contains',
	       'Contains',
	       qq{
		   select
                    locus.id as locus_id,
                    locus.name as locus_name
                   from locus
                    inner join rearrangementcontainslocus on locus.id = rearrangementcontainslocus.locusid
                   where rearrangementcontainslocus.rearrangementid = $id
                    and type = 'Contains'
		   },
	       ['locus_link'],
	       []
	       ); 
	          	     
# OK distalmarker
&print_element(
	       $cgi,
	       $dbh,
	       'distalmarker',
	       'Distal Marker',
	       qq{
		   select
                    locus.id as locus_id,
                    locus.name as locus_name
                   from locus
                    inner join rearrangementnearbymarker on locus.id = rearrangementnearbymarker.locusid
                   where rearrangementnearbymarker.rearrangementid = $id
                    and rearrangementnearbymarker.type = 'Distal_marker'
		   },
	       ['locus_link'],
	       []
	       );    

# OK doesnotcontain (Locus)
&print_element(
	       $cgi,
	       $dbh,
	       'doesnotcontain',
	       'Does Not Contain',
	       qq{
		   select
                    locus.id as locus_id,
                    locus.name as locus_name
                   from locus
                    inner join rearrangementcontainslocus on locus.id = rearrangementcontainslocus.locusid
                   where rearrangementcontainslocus.rearrangementid = $id
                    and type = 'Does_not_contain'
		   },
	       ['locus_link'],
	       []
	       ); 
	          
# 2point,3point,Df_dup,insitu removed from schema

# OK germplasm
&print_element(
	       $cgi,
	       $dbh,
	       'germplasm',
	       'Germplasm',
	       qq{
		   select
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from germplasm
                    inner join rearrangementgermplasm on germplasm.id = rearrangementgermplasm.germplasmid
                   where rearrangementgermplasm.rearrangementid = $id
		   },
	       ['germplasm_link'],
	       []
	       );    

# OK reference
&print_element(
	       $cgi,
	       $dbh,
	       'reference',
	       'Reference',
	       qq{
		   select
		    reference.id as reference_id
		   from rearrangementreference
		    inner join reference on rearrangementreference.referenceid = reference.id
		   where rearrangementreference.rearrangementid = $id
                    order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );  

1;
