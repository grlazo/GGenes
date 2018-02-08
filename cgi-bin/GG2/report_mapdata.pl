#!/usr/bin/perl

# NLui, 29Oct2004

# print mapdata report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'mapdata',
	       'Map Data',
	       qq{
		   select name 
		   from mapdata 
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# OK map
{
    my $sql = qq{
    		   select
    		    mapdata.name as mapdata_name,
                    map.id as map_id,
                    map.name as map_name
                   from map
                    inner join mapdata on map.mapdataid = mapdata.id
                   where mapdata.id = $id
                    order by map.name
                 };

    my $sth = $dbh->prepare($sql); $sth->execute;
    my $data = $sth->fetchall_arrayref({});

    if ( $data )
    {
      foreach my $m (@$data)
      {
       #$m->{'data'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map&id=".$m->{'map_id'}},$m->{'map_name'});
       # 08Nov2004 added code to fork to escapeHTML if map not in cmap yet
	my ($cmapname) = $dbh->selectrow_array(sprintf("select map_name from cmap_map where map_name = %s",$dbh->quote($m->{'map_name'})));
	if ($cmapname) {
           $m->{'data'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map&name=".&geturlstring($m->{'map_name'}),-target=>'_blank'},$m->{'map_name'});
	} else {
	    $m->{'data'} = $cgi->escapeHTML($m->{'map_name'});
	}

        delete($m->{'map_id'});

        # add gbrowse link
        if ( $m->{'mapdata_name'} eq 'Wheat, Physical, EST' )
        {
          $m->{'data'} =
          #$m->{'data'}.'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"http://rye.pw.usda.gov/cgi-bin/gbrowse/WheatPhysicalESTMaps?name="."$m->{'map_name'}",-target=>'_blank'},'GBrowser').' ]';
          #NL 29Oct2004 to replace rye URL "http://rye.pw.usda.gov/cgi-bin/gbrowse" with $gbrowseserver per DEM
          $m->{'data'}.'&nbsp;&nbsp;'.'[ '.$cgi->i($cgi->a({-href=>"$gbrowseserver/WheatPhysicalESTMaps?name="."$m->{'map_name'}",-target=>'_blank'},'GBrowser')).' ]';
          delete($m->{'mapdata_name'});
        }
        elsif ( $m->{'mapdata_name'} eq 'Wheat, Synthetic x Opata' )
        {
          $m->{'data'} =
          #$m->{'data'}.'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"http://rye.pw.usda.gov/cgi-bin/gbrowse/GrainMaps?name="."$m->{'map_name'}",-target=>'_blank'},'GBrowser').' ]';
          #NL 29Oct2004 to replace rye URL "http://rye.pw.usda.gov/cgi-bin/gbrowse" with $gbrowseserver per DEM
          $m->{'data'}.'&nbsp;&nbsp;'.'[ '.$cgi->i($cgi->a({-href=>"$gbrowseserver/GrainMaps?name="."$m->{'map_name'}",-target=>'_blank'},'GBrowser')).' ]';
          delete($m->{'mapdata_name'});
        }      
        delete($m->{'map_name'});

      } # end foreach $m
      
      &print_element(
	       $cgi,
	       $dbh,
	       'map',
	       'Map',
	       $data,
	       ['data_html'],
	       []
	       ); 

     } # end if    
}
# OK externaldb - NCBI

	&print_element(
	       $cgi,
	       $dbh,
	       'externaldb',
	       'External Databases',
	       qq{
		   select
		    concat("http://www.ncbi.nlm.nih.gov/mapview/maps.cgi?org=",accession) as url,
                    name as description
                   from mapdataexternaldb
                   where mapdataid = $id
                     and name = 'NCBI'
		   },
	       ['url'],
	       []
	       ); 
	       
# externaldb - NCBI Sequence Read Archive, SRA

	&print_element(
	       $cgi,
	       $dbh,
	       'externaldb',
	       'NCBI Sequence Read Archive',
	       qq{
		   select
		    concat("http://www.ncbi.nlm.nih.gov/sra/",accession) as url,
                    accession as description
                   from mapdataexternaldb
                   where mapdataid = $id
                     and name = 'SRA'
		   },
	       ['url'],
	       []
	       ); 
	       
# OK externaldb - Gramene

	&print_element(
	       $cgi,
	       $dbh,
	       'externaldb',
	       'External Databases',
	       qq{
		   select
		    concat("http://www.gramene.org/db/cmap/map_set_info?map_set_aid=",accession) as url,
                    name as description
                   from mapdataexternaldb
                   where mapdataid = $id
                     and name = 'Gramene'
		   },
	       ['url'],
	       []
	       ); 

# OK species
	&print_element(
	       $cgi,
	       $dbh,
	       'species',
	       'Species',
	       qq{
		   select
                    species.id as species_id,
                    species.name as species_name
                   from species
                    inner join mapdataspecies on species.id = mapdataspecies.speciesid
                   where mapdataspecies.mapdataid = $id
		   },
	       ['species_link'],
	       []
	       );    

# OK femaleparent (Germplasm)
&print_element(
	       $cgi,
	       $dbh,
	       'femaleparent',
	       'Female Parent',
	       qq{
		   select
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from germplasm
                    inner join mapdata on germplasm.id = mapdata.femaleparent_germplasmid
                   where mapdata.id = $id
		   },
	       ['germplasm_link'],
	       []
	       );    

# OK maleparent
&print_element(
	       $cgi,
	       $dbh,
	       'maleparent',
	       'Male Parent',
	       qq{
		   select
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from germplasm
                    inner join mapdata on germplasm.id = mapdata.maleparent_germplasmid
                   where mapdata.id = $id
		   },
	       ['germplasm_link'],
	       []
	       );   
	       
# OK parent
&print_element(
	       $cgi,
	       $dbh,
	       'parent',
	       'Parent',
	       qq{
		   select
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from germplasm
                    inner join mapdataparent on germplasm.id = mapdataparent.germplasmid
                   where mapdataparent.mapdataid = $id
		   },
	       ['germplasm_link'],
	       []
	       );

# OK type
&print_element(
	       $cgi,
	       $dbh,
	       'type',
	       'Type',
	       qq{
		   select
		    type
		   from mapdatatype
                    inner join mapdata on mapdatatype.mapdataid = mapdata.id
                   where mapdatatype.mapdataid = $id
		   },
	       ['type'],
	       []
	       );    

# OK mapunits
&print_element(
	       $cgi,
	       $dbh,
	       'mapunits',
	       'Map Units',
	       qq{
		   select
		    remark
		   from mapdataremark
                   where mapdataid = $id
                    and type = 'Map_units'
		   },
	       ['remark'],
	       []
	       ); 

# OK location - chromosome
&print_element(
	       $cgi,
	       $dbh,
	       'chromosome',
	       'Chromosome',
	       qq{
		   select
		    chromosome
		   from mapdatalocation
                   where mapdatalocation.mapdataid = $id
		   },
	       ['chromosome'],
	       []
	       ); 
	       
# OK location - chromosomearm
&print_element(
	       $cgi,
	       $dbh,
	       'chromosomearm',
	       'Chromosome Arm',
	       qq{
		   select
		    chromosomearm
		   from mapdatalocation
                   where mapdatalocation.mapdataid = $id
		   },
	       ['chromosomearm'],
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
		   from mapdatareference
		    inner join reference on mapdatareference.referenceid = reference.id
		   where mapdatareference.mapdataid = $id
                    order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );     

# OK url
	&print_element(
	       $cgi,
	       $dbh,
	       'url',
	       'URL',
	       qq{
		   select
		    url as description,
		    url as url,
		    description as comments
                   from mapdataurl
                   where mapdataid = $id
		   },
	       ['url','comments'],
	       []
	       ); 

# OK contact
	&print_element(
	       $cgi,
	       $dbh,
	       'contact',
	       'Contact',
	       qq{
		   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name
                   from colleague
                    inner join mapdatacontact on colleague.id = mapdatacontact.colleagueid
                   where mapdatacontact.mapdataid = $id
		   },
	       ['colleague_link'],
	       []
	       );

# OK remarks
&print_element(
	       $cgi,
	       $dbh,
	       'remarks',
	       'Remarks',
	       qq{
		   select
		    remark
		   from mapdataremark
                   where mapdataid = $id
                    and type = 'Remarks'
		   },
	       ['remark'],
	       []
	       ); 

# OK datacurated
	&print_element(
	       $cgi,
	       $dbh,
	       'datacurated',
	       'Data Curator',
	       qq{
		   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name,
                    mapdatadatacurator.date
                   from colleague
                    inner join mapdatadatacurator on colleague.id = mapdatadatacurator.colleagueid
                   where mapdatadatacurator.mapdataid = $id
		   },
	       ['colleague_link','date'],
	       []
	       );    

# OK image
	&print_element(
	       $cgi,
	       $dbh,
	       'image',
	       'Image',
	       qq{
		   select
		    image.id as image_id,
    		    image.name as image_name
		   from mapdataimage 
		    inner join image on mapdataimage.imageid = image.id
		   where mapdataimage.mapdataid = $id
		    order by image.name
		   },
	       ['image_link'],
	       []
	       );   
	       
# OK traitstudy
	&print_element(
	       $cgi,
	       $dbh,
	       'traitstudy',
	       'Trait Study',
	       qq{
		   select
                    traitstudy.id as traitstudy_id,
                    traitstudy.name as traitstudy_name
                   from traitstudy
                    inner join mapdata on traitstudy.mapdataid = mapdata.id
                   where mapdata.id = $id
		   },
	       ['traitstudy_link'],
	       []
	       ); 	       
	       
# OK qtl
	&print_element(
	       $cgi,
	       $dbh,
	       'qtl',
	       'QTL',
	       qq{
		   select
                    qtl.id as qtl_id,
                    qtl.name as qtl_name
                   from qtl
                    inner join qtlmapdata on qtl.id = qtlmapdata.qtlid
                    inner join mapdata on qtlmapdata.mapdataid = mapdata.id
                   where mapdata.id = $id
		   },
	       ['qtl_link'],
	       []
	       ); 	  

# twopoint removed from schema
# OK locus 
	&print_element(
	       $cgi,
	       $dbh,
	       'locus',
	       'Locus',
	       qq{
		   select
                    locus.id as locus_id,
                    locus.name as locus_name,
                    mapdatalocus.scoringdata,
                    mapdatalocus.howmapped,    
                    probe.id as probe_id,
                    probe.name as probe_name,  
                    gene.id as gene_id,
                    gene.name as gene_name   
                   from locus
                    inner join mapdatalocus on locus.id = mapdatalocus.locusid
                    left join probe on mapdatalocus.howmapped_probeid = probe.id 
                    left join gene on mapdatalocus.howmapped_geneid = gene.id
                   where mapdatalocus.mapdataid = $id
                    order by locus_name
		   },
	       ['locus_link','scoringdata','howmapped','probe_link','gene_link'],
	       []
	       );    	       

# OK breakpoint
       &print_element(
               $cgi,
               $dbh,
               'breakpoint',
               'Breakpoint',
               qq{
                   select
                    breakpoint.id as breakpoint_id,
                    breakpoint.name as breakpoint_name
                   from breakpoint
                    inner join mapbreakpoint on breakpoint.id = mapbreakpoint.breakpointid
                    inner join map on mapbreakpoint.mapid = map.id
                    inner join mapdata on map.mapdataid = mapdata.id
                   where mapdata.id = $id
                   },
               ['breakpoint_link'],
               []
               );       

# OK breakpointinterval (not visible in all ACEDB maps)
       &print_element(
               $cgi,
               $dbh,
               'breakpointinterval',
               'Breakpoint Interval',
               qq{
                   select
                    distinct breakpointinterval.id as breakpointinterval_id,
                    breakpointinterval.name as breakpointinterval_name
                   from breakpointinterval
                    inner join mapbreakpointinterval on breakpointinterval.id = mapbreakpointinterval.breakpointintervalid
                    inner join map on mapbreakpointinterval.mapid = map.id
                    inner join mapdata on map.mapdataid = mapdata.id
                   where mapdata.id = $id
                   },
               ['breakpointinterval_link'],
               []
               );       

1;
