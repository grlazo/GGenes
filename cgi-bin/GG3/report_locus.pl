#!/usr/bin/perl

# DDH 040412
# REMEMBER to update report_marker.pl when any changes made to report_locus.pl
# NL 13Aug2004 to fix $squeeze (s/b 'type' only)
# NL 20Aug2004 to add Marker Report link
# NL 25Aug2004 to add "_blank" as target for map link
# NL 27Aug2004 to add Homology
# NL 30Aug2004 to change linkedqtl from  qtl.nearestmarker_locusid to locus.linkedqtl_qtlid
# NL 09Sep2004 to add 'Show Nearby Loci'
# NL 17Sep2004 confirmed with DEM that scoringdata should be removed
# NL 27Sep2004 to change remark to hyperlink if remark =~ /untamo.net/
# NL 29Sep2004 to add locusbgsphoto
# NL 30Sep2004 to revise candidategene to reflect candidategene_geneid = null
# NL 04Oct2004 to add GBrowser link
# NL 18Oct2004 to remove duplicate values in homology (added 'distinct')
# NL 28Oct2004 removed cmap_map reference as all maps in GG-mySQL in cmap, per DEM
# NL 29Oct2004 to replace rye URL with $gbrowseserver per DEM
# NL 08Nov2004 added cmap_map reference back, as Sommers' not yet in cmap.

 
# print locus report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# name
#&print_element(
#	       $cgi,
#	       $dbh,
#	       'name',
#	       'Locus',
#	       qq{
#		   select name from locus where id = $id
#		   },
#	       ['name'],
#	       []
#	       );

# name & marker report link
{
    my $sql = "select 
                name as marker_name
               from marker
               where locusid = $id";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $locus = $sth->fetchall_arrayref({});
    
    # in case there are ever loci that aren't markers
    if ( $locus->[0]->{'marker_name'} )
    { 
      #$locus->[0]->{'locus'} = $cgi->escapeHTML($locus->[0]->{'marker_name'}).'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=marker&name=".$locus->[0]->{'marker_name'},-target=>'_blank'},'Marker Report').' ]';
      $locus->[0]->{'locus'} = $cgi->escapeHTML($locus->[0]->{'marker_name'}).'&nbsp;&nbsp;'.'[ '.$cgi->i($cgi->a({-href=>"$cgiurlpath/report.cgi?class=marker&name=".&geturlstring($locus->[0]->{'marker_name'})},'Marker Report')).' ]';
      delete($locus->[0]->{'marker_name'});
    
      &print_element(
                   $cgi,
                   $dbh,
                   'name',
                   'Locus',
                   $locus,
                   ['locus_html'],
                   []
                   );
    }
}

# type
&print_element(
	       $cgi,
	       $dbh,
	       'type',
	       'Type',
	       qq{
		   select type from locustype where locusid = $id order by type
		   },
	       ['type'],
	       []
	       );

# synonym
&print_element(
	       $cgi,
	       $dbh,
	       'synonym',
	       'Synonym',
	       qq{
                   select
                    locussynonym.type,
                    locus.id as locus_id,
                    locus.name as locus_name,
                    locussynonym.referenceid as reference_id
                   from locussynonym
                    inner join locus on locussynonym.name = locus.name collate latin1_bin
                   where locussynonym.locusid = $id
                    order by locussynonym.type,locus.name
		   },
	       ['type','locus_link','reference_id'],
	       #['type','locus_link']
	       ['type']
	       );

# chromosome
&print_element(
	       $cgi,
	       $dbh,
	       'chromosome',
	       'Chromosome',
	       qq{
		   select
		       chromosome
		       from locuschromosome
		       where locusid = $id
		       order by chromosome
		   },
	       ['chromosome'],
	       []
	       );

# chromosomearm
&print_element(
	       $cgi,
	       $dbh,
	       'chromosomearm',
	       'Chromosome Arm',
	       qq{
		   select
		       chromosomearm
		       from locuschromosomearm
		       where locusid = $id
		       order by chromosomearm
		   },
	       ['chromosomearm'],
	       []
	       );

# map
#&print_element(
#	       $cgi,
#	       $dbh,
#	       'map',
#	       'Map',
#	       qq{
#		   select distinct
#		       map.id as map_id,
#		       map.name as map_name
#		       -- maplocus.begin,
#		       -- maplocus.end,
#		       -- maplocus.beginerror
#		       from maplocus
#		       inner join map on maplocus.mapid = map.id
#		       where maplocus.locusid = $id
#		       order by map.name
#		   },
#	       #['map_link','begin','end','error'],
#	       ['map_link'],
#	       []
#	       );

# map (2)
{
    my $sql = qq{
		   select distinct
		       map.id as map_id,
		       map.name as map_name,
		       maplocus.begin as begin
		       from maplocus
		       inner join map on maplocus.mapid = map.id
		       where maplocus.locusid = $id
		       order by map.name
                 };
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $map = $sth->fetchall_arrayref({});
    foreach my $mp (@$map) {
	# see if this map exists in cmap before making it a link
#
	my ($cmapname) = $dbh->selectrow_array(sprintf("select map_name from cmap_map where map_name = %s",$dbh->quote($mp->{'map_name'})));
#
	if ($cmapname) {
	    #$mp->{'map'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map;id=$mp->{'map_id'};locusid=$id"},$mp->{'map_name'});
	    $mp->{'map'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map;locusid=$id;name=".&geturlstring($mp->{'map_name'}),-target=>'_blank'},$mp->{'map_name'});
#
	} else {
#
	    $mp->{'map'} = $cgi->escapeHTML($mp->{'map_name'});
#
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
                   ['map_html','begin'],
                   []
                   );
}

# nearbyloci
{
    my $sql = "select 
    	        distinct
                name
               from locus
                inner join maplocus on locus.id = maplocus.locusid
               where locus.id = $id";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $locus = $sth->fetchall_arrayref({});
    $locus->[0]->{'locus'} = $cgi->i($cgi->big('[ ')).$cgi->a({-href=>"$cgiurlpath/quickquery.cgi?query=nearbyloci&arg1=".$locus->[0]->{'name'}."&arg2=10"},$cgi->i($cgi->big('Show Nearby Loci'))).$cgi->i($cgi->big(' ]'));

    if ($locus->[0]->{'name'})
    {
      delete($locus->[0]->{'name'});
      &print_element(
               $cgi,
               $dbh,
               'nearbyloci',
               ' ',
               $locus,
               ['locus_html'],
               []
               );
    }
}

# bin
&print_element(
	       $cgi,
	       $dbh,
	       'bin',
	       'Bin',
	       qq{
		   select
		       bin.id as bin_id,
		       bin.name as bin_name
		       from binlocus
		       inner join bin on binlocus.binid = bin.id
		       where binlocus.locusid = $id
		       order by bin.name
		   },
	       ['bin_link'],
	       []
	       );

# binlocus
&print_element(
	       $cgi,
	       $dbh,
	       'binlocus',
	       'Binlocus in',
	       qq{
		   select
		       bin.id as bin_id,
		       bin.name as bin_name
		       from binbinlocus
		       inner join bin on binbinlocus.binid = bin.id
		       where binbinlocus.locusid = $id
		       order by bin.name
		   },
	       ['bin_link'],
	       []
	       );

# inqtl
&print_element(
	       $cgi,
	       $dbh,
	       'inqtl',
	       'In QTL',
	       qq{
		   select distinct
		       qtl.id as qtl_id,
		       qtl.name as qtl_name
		       from qtlsignificantmarker
		       inner join qtl on qtlsignificantmarker.qtlid = qtl.id
		       where qtlsignificantmarker.locusid = $id
		       order by qtl.name
		   },
	       ['qtl_link'],
	       []
	       );

# rearrangement
&print_element(
	       $cgi,
	       $dbh,
	       'rearrangement',
	       'Rearrangement',
	       qq{
		   select
		       locusinsegment.type,
		       rearrangement.id as rearrangement_id,
		       rearrangement.name as rearrangement_name
		       from locusinsegment
		       inner join rearrangement on locusinsegment.rearrangementid = rearrangement.id
		       where locusinsegment.locusid = $id
		       order by locusinsegment.type
		   },
	       ['type','rearrangement_link'],
	       ['type']
	       );

# breakpointinterval
&print_element(
	       $cgi,
	       $dbh,
	       'breakpointinterval',
	       'Breakpoint Interval',
	       qq{
		   select
		       breakpointinterval.id as breakpointinterval_id,
		       breakpointinterval.name as breakpointinterval_name
		       from locusininterval
		       inner join breakpointinterval on locusininterval.breakpointintervalid = breakpointinterval.id
		       where locusininterval.locusid = $id
		   },
	       ['breakpointinterval_link'],
	       []
	       );

# mapdata  (and gbrowser link)
{
    my $sql = qq{select distinct
                  locus.name as locus_name,
		  mapdata.id as mapdata_id,
		  mapdata.name as mapdata_name,
		  mapdatalocus.howmapped,
		  probe.id as probe_id,
		  probe.name as probe_name,
		  gene.id as gene_id,
		  gene.name as gene_name
	         from locus
	          inner join mapdatalocus on locus.id = mapdatalocus.locusid
	          inner join mapdata on mapdatalocus.mapdataid = mapdata.id
	          left join probe on mapdatalocus.howmapped_probeid = probe.id
	          left join gene on mapdatalocus.howmapped_geneid = gene.id
	         where locus.id = $id
	         order by mapdata.name,mapdatalocus.howmapped};

    my $sth = $dbh->prepare($sql); $sth->execute;
    my $data = $sth->fetchall_arrayref({});

   if ( $data )
   {
    foreach my $m (@$data)
    {
# dem 28mar05: Get by name instead of by id.
#     $m->{'data'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=mapdata&id=".$m->{'mapdata_id'}},$m->{'mapdata_name'});
     $m->{'data'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=mapdata&name=".&geturlstring($m->{'mapdata_name'})},$m->{'mapdata_name'});
     delete($m->{'mapdata_id'});

     if ( $m->{'howmapped'} )
     {
       $m->{'data'} =
        $m->{'data'}.'&nbsp;&nbsp;'.$cgi->escapeHTML($m->{'howmapped'});
       delete( $m->{'howmapped'} );
     }   

     if ( $m->{'probe_id'} )   
     {
       $m->{'data'} =
# dem 28mar05: Get by name instead of by id.
#        $m->{'data'}.'&nbsp;&nbsp;'.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=probe&id=".$m->{'probe_id'}},$m->{'probe_name'});
        $m->{'data'}.'&nbsp;&nbsp;'.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=probe&name=".&geturlstring($m->{'probe_name'})},$m->{'probe_name'});
       delete($m->{'probe_id'});
       delete($m->{'probe_name'});

     }

     if ( $m->{'gene_id'} )   
     {
       $m->{'data'} =
# dem 28mar05: Get by name instead of by id.
#        $m->{'data'}.'&nbsp;&nbsp;'.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=gene&id=".$m->{'gene_id'}},$m->{'gene_name'});
        $m->{'data'}.'&nbsp;&nbsp;'.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=gene&name=".&geturlstring($m->{'gene_name'})},$m->{'gene_name'});
       delete($m->{'gene_id'});
       delete($m->{'gene_name'});

     }
     
     # add gbrowse link
     # No such loci: WheatPhysicalESTMaps if map is "Chinese_Spring_Deletion_*" mapdata "Wheat, Physical, EST"
     # OK GrainMaps if map is "Ta-Synthetic/Opata-1A" mapdata "Wheat, Synthetic x Opata"
#     if ( $m->{'mapdata_name'} eq 'Wheat, Physical, EST' )
#     {
#       $m->{'data'} =
#       $m->{'data'}.'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"http://rye.pw.usda.gov/cgi-bin/gbrowse/WheatPhysicalESTMaps?name="."$m->{'locus_name'}",-target=>'_blank'},'GBrowser').' ]';
#       delete($m->{'locus_name'});
#       delete($m->{'mapdata_name'});
#     }
#     elsif ( $m->{'mapdata_name'} eq 'Wheat, Synthetic x Opata' )
     if ( $m->{'mapdata_name'} eq 'Wheat, Synthetic x Opata' )
     {
       $m->{'data'} =
       #$m->{'data'}.'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"http://rye.pw.usda.gov/cgi-bin/gbrowse/GrainMaps?name="."$m->{'locus_name'}",-target=>'_blank'},'GBrowser').' ]';
       $m->{'data'}.'&nbsp;&nbsp;'.'[ '.$cgi->i($cgi->a({-href=>"$gbrowseserver/GrainMaps?name="."$m->{'locus_name'}",-target=>'_blank'},'GBrowser')).' ]';
       delete($m->{'locus_name'});
       delete($m->{'mapdata_name'});
     }      

   } # end foreach
     &print_element(
	       $cgi,
	       $dbh,
	       'mapdata',
	       'Map Data',
	       $data,
	       ['data_html'],
	       []
	       );
   } # end if
}

# twopointdata
&print_element(
	       $cgi,
	       $dbh,
	       'twopointdata',
	       '2 Point Data',
	       qq{
		   select
		       twopointdata.id as twopointdata_id,
		       twopointdata.name as twopointdata_name
		       from locustwopointdata
		       inner join twopointdata on locustwopointdata.twopointdataid = twopointdata.id
		       where locustwopointdata.locusid = $id
		       order by twopointdata.name
		   },
	       ['twopointdata_link'],
	       []
	       );

# species
&print_element(
	       $cgi,
	       $dbh,
	       'species',
	       'Species',
	       qq{
		   select
		       species.id as species_id,
		       species.name as species_name
		       from locusspecies
		       inner join species on locusspecies.speciesid = species.id
		       where locusspecies.locusid = $id
		       order by species.name
		   },
	       ['species_link'],
	       []
	       );

# sequence
&print_element(
	       $cgi,
	       $dbh,
	       'sequence',
	       'Sequence',
	       qq{
		   select
		       sequence.id as sequence_id,
		       sequence.name as sequence_name
		       from locus
		       inner join sequence on locus.sequenceid = sequence.id
		       where locus.id = $id
		   },
	       ['sequence_link'],
	       []
	       );

# probe
&print_element(
	       $cgi,
	       $dbh,
	       'probe',
	       'Probe',
	       qq{
		   select
		       probe.id as probe_id,
		       probe.name as probe_name,
		       locusprobe.referenceid as reference_id
		       from locusprobe
		       inner join probe on locusprobe.probeid = probe.id
		       where locusprobe.locusid = $id
		       order by probe.name
		   },
	       ['probe_link','reference_id'],
	       []
	       );

# linkedqtl 
&print_element(
	       $cgi,
	       $dbh,
	       'linkedqtl',
	       'Linked QTL',
	       qq{
		   select distinct
		       qtl.id as qtl_id,
		       qtl.name as qtl_name
		       from locus
                        inner join qtl on locus.linkedqtl_qtlid = qtl.id
		        #inner join qtl on locus.id = qtl.nearestmarker_locusid
		       where locus.id = $id
		   },
	       ['qtl_link'],
	       []
	       );

# associatedgene
&print_element(
	       $cgi,
	       $dbh,
	       'associatedgene',
	       'Associated Gene',
	       qq{
		   select
		       gene.id as gene_id,
		       gene.name as gene_name
		       from locusassociatedgene
		       inner join gene on locusassociatedgene.geneid = gene.id
		       where locusassociatedgene.locusid = $id
		       order by gene.name
		   },
	       ['gene_link'],
	       []
	       );

# candidategene
&print_element(
	       $cgi,
	       $dbh,
	       'candidategene',
	       'Candidate Gene',
	       qq{
		   select
		       gene.id as gene_id,
		       gene.name as gene_name
		       from locus
		       inner join gene on locus.candidategene_geneid = gene.id
                        and locus.candidategene_geneid is not null
		       where locus.id = $id
		   },
	       ['gene_link'],
	       []
	       );

# OK homology
&print_element(
	       $cgi,
	       $dbh,
	       'homology',
	       'Homology',
	       qq{
		   select
		    distinct
                    protein.id as protein_id,
		    protein.name as protein_name,
		    concat("e-value: ",sequence.bestpepevalue) as evalue,
		    protein.title
		   from locus
		    inner join locusprobe on locus.id = locusprobe.locusid
		    inner join sequenceprobe on locusprobe.probeid = sequenceprobe.probeid
		    inner join sequence on sequenceprobe.sequenceid = sequence.id
		    inner join protein on sequence.bestpep_proteinid = protein.id
   	           where locus.id = $id
		   },
	       ['protein_link','evalue','title'],
	       []
	       );
	       
# geneclass
&print_element(
	       $cgi,
	       $dbh,
	       'geneclass',
	       'Gene Class',
	       qq{
		   select distinct
		       geneclass.id as geneclass_id,
		       geneclass.name as geneclass_name
		       from locusassociatedgene
		       inner join genegeneclass on locusassociatedgene.geneid = genegeneclass.geneid
		       inner join geneclass on genegeneclass.geneclassid = geneclass.id
		       where locusassociatedgene.locusid = $id
		       order by geneclass.name
		   },
	       ['geneclass_link'],
	       []
	       );

# image
&print_element(
	       $cgi,
	       $dbh,
	       'image',
	       'Image',
	       qq{
		   select
		       image.id as image_id,
		       image.name as image_name
		       from locusimage
		       inner join image on locusimage.imageid = image.id
		       where locusimage.locusid = $id
		       order by image.name
		   },
	       ['image_link'],
	       []
	       );

# OK bgsphoto
{
    my $sql = "select 
                name 
               from locusbgsphoto
               where locusid = $id";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $name = $sth->fetchall_arrayref({});
    
    if ($name)
    {
      foreach my $n (@$name)
      {
        #$n->{'name'} = $cgi->escapeHTML($n->{'name'}).'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"http://ace.untamo.net/cgi-bin/ace/tree/default?name=".$n->{'name'}."&class=Image",-target=>'_blank'},'BGS Database').' ]';
        $n->{'name'} = $cgi->escapeHTML($n->{'name'}).'&nbsp;&nbsp;'.'[ '.$cgi->i($cgi->a({-href=>"http://ace.untamo.net/cgi-bin/ace/tree/default?name=".$n->{'name'}."&class=Image",-target=>'_blank'},'BGS Database')).' ]';
      } # end foreach      
      
      &print_element(
                   $cgi,
                   $dbh,
                   'name',
                   'BGS Photo',
                   $name,
                   ['name_html'],
                   []
                   );
    } # end if
}

# reference
&print_element(
	       $cgi,
	       $dbh,
	       'reference',
	       'Reference',
	       qq{
		   select
		       reference.id as reference_id
		       from locusreference
		       inner join reference on locusreference.referenceid = reference.id
		       where locusreference.locusid = $id
		       order by reference.year desc
		   },
	       ['reference_id'],
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
		       locusdatasource.date
		       from locusdatasource
		       inner join colleague on locusdatasource.colleagueid = colleague.id
		       where locusdatasource.locusid = $id
		       order by colleague.name
		   },
	       ['colleague_link','date'],
	       []
	       );

# remark
# print separate elements for each type
# use type as element and label
#{
#    my $types = $dbh->selectcol_arrayref("select distinct type from locusremark where locusid = $id order by type");
#    foreach my $type (@$types) {
#	my $element = lc($type); $element =~ s/ /_/g;
#	my $label = $type; $label =~ s/_/ /g;
#	&print_element(
#		       $cgi,
#		       $dbh,
#		       $element,
#		       $label,
#		       sprintf(qq{
#			           select
#				       remark
#				       from locusremark
#				       where locusid = %s and type = %s
#				  },$id,$dbh->quote($type)
#			       ),
#		       ['remark'],
#		       []
#		       );
#    }
#}

# remark (27Sep2004, NL, to hyperlink untamo.net URLs) 
{
   my $sql = "select remark from locusremark where locusid = $id";
   my $sth = $dbh->prepare($sql); $sth->execute;
   my $remark = $sth->fetchall_arrayref({});

   foreach my $rem (@$remark) 
   {
     if ( $rem->{'remark'} =~ /^(.*)(http\S+)\s*(.*)$/is )
     {
       $rem->{'remark'} = $1.$cgi->a({-href=>$2,-target=>'_blank'},$2).$3;
     } # else do nothing with string        
   } # end foreach

    &print_element(
		       $cgi,
		       $dbh,
		       'remark',
		       'Remark',
                       $remark,
		       ['remark_html'],
		       []
		       );
}

# candidateorthologygroup
#&print_element(
#	       $cgi,
#	       $dbh,
#	       'candidateorthologygroup',
#	       'Candidate Orthology Group',
#	       qq{
#		   select
#		       locusorthologygroup.name
#		       from locus
#		       inner join locusorthologygroup on locus.locusorthologygroupid = locusorthologygroup.id
#		       where locus.id = $id
#		   },
#	       ['name'],
#	       []
#	       );

# possibleorthologs
&print_element(
	       $cgi,
	       $dbh,
	       'possibleorthologs',
	       'Possible Orthologs',
#	       qq{
#		   select
#		       a.id as locus_id,
#		       a.name as locus_name
#		       from locus as a
#		       inner join locus as b on a.locusorthologygroupid = b.locusorthologygroupid and a.locusorthologygroupid is not null
#		       where a.id != b.id and b.id = $id
#		   },
	       qq{
		   select
                       locusorthologygroup.name as locusorthologygroup_name,
		       a.id as locus_id,
		       a.name as locus_name
		       from locus as a
		       inner join locusorthologygroup on a.locusorthologygroupid = locusorthologygroup.id
		       inner join locus as b on a.locusorthologygroupid = b.locusorthologygroupid and a.locusorthologygroupid is not null
		       where a.id != b.id and b.id = $id
		   },
	       ['locusorthologygroup_name','locus_link'],
	       ['locusorthologygroup_name']
	       );

1;
