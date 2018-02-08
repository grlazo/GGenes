#!/usr/bin/perl

# DDH 040324
# NL modif's to include all associated genes, probes, loci 27Sep2004
# NL 30Sep2004:  probes in locusprobe, genes in genelocus and genechromosome, all loci
# NL 06Oct2004:  implemented as new marker report

# last updated 29Oct2004 NL

# print gene report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

##################### GENE
## GENE subreport
my $genemarkerid = $dbh->selectrow_array("select geneid from marker where id = $id");
if ($genemarkerid)
{
  # OK name (gene)
  &print_element(
	       $cgi,
	       $dbh,
	       'name',
	       'Gene',
	       qq{
		   select 
                    gene.id as gene_id,
                    gene.name as gene_name
                   from gene
                   where gene.id = $genemarkerid
		   },
	       ['gene_link'],
	       []
	       );

  # okay fullname (gene)
  &print_element(
               $cgi,
               $dbh,
               'fullname',
               'Full Name',
               qq{
                   select 
                    gene.fullname 
                   from gene 
                   where gene.id = $genemarkerid
                   },
               ['fullname'],
               []
               );

  # OK synonym (gene)
  &print_element(
	       $cgi,
	       $dbh,
	       'synonym',
	       'Synonym',
	       qq{
                   select
                    genesynonym.type,
                    gene.id as gene_id,
                    gene.name as gene_name,
                    genesynonym.referenceid as reference_id
                   from genesynonym
                    inner join gene on genesynonym.name = gene.name collate latin1_bin
                   where genesynonym.geneid = $genemarkerid
                    order by genesynonym.type,gene.name
		   },
	       ['type','gene_link','reference_id'],
	       ['type']
	       );

  # OK geneclass (gene)
  &print_element(
	       $cgi,
	       $dbh,
	       'geneclass',
	       'Gene Class',
	       qq{
		   select
  	            geneclass.id as geneclass_id,
		    geneclass.name as geneclass_name
		   from genegeneclass
		    inner join geneclass on genegeneclass.geneclassid = geneclass.id
		    inner join gene on genegeneclass.geneid = gene.id
                   where gene.id = $genemarkerid
		    order by geneclass.name
		   },
	       ['geneclass_link'],
	       []
	       );

  # okay orthologousgeneset (gene)
  &print_element(
               $cgi,
               $dbh,
               'orthologousgeneset',
               'Orthologous Gene Set',
               qq{
                   select
                    geneset.id as geneset_id,
                    geneset.name as geneset_name
                   from gene
                    inner join geneset on gene.orthologousgeneset_genesetid = geneset.id
                    inner join marker on gene.id = marker.geneid
                     and marker.geneid is not null
                   where gene.id = $genemarkerid
                   },
               ['geneset_link'],
               []
               );

  # OK allele (gene)
  &print_element(
	       $cgi,
	       $dbh,
	       'allele',
	       'Allele',
	       qq{
		   select
		    allele.id as allele_id,
		    allele.name as allele_name
		   from allelegene
		    inner join allele on allelegene.alleleid = allele.id
                   where allelegene.geneid = $genemarkerid
		   order by allele.name
		   },
	       ['allele_link'],
	       []
	       );

  # OK pathology (gene only)
  &print_element(
	       $cgi,
	       $dbh,
	       'pathology',
	       'Pathology',
	       qq{
		   select
		    pathology.id as pathology_id,
		    pathology.name as pathology_name
		   from genepathology
		    inner join pathology on genepathology.pathologyid = pathology.id
                   where genepathology.geneid = $genemarkerid
		   order by pathology.name
		   },
	       ['pathology_link'],
	       []
	       );

  # okay for locus; locus (gene)
  # unable to ck for howmapped as all values null 19Aug2004 NL
  &print_element(
               $cgi,
               $dbh,
               'locus',
               'Locus',
               qq{
                   select
                    locus.id as locus_id,
                    locus.name as locus_name
                   from locusassociatedgene
                    inner join locus on locusassociatedgene.locusid = locus.id
                   where locusassociatedgene.geneid = $genemarkerid
                   order by locus.name
                   },
               ['locus_link'],
               []
               );

  # okay candidatelocus (gene)
  &print_element(
	       $cgi,
	       $dbh,
	       'candidatelocus',
	       'Candidate Locus',
	       qq{
		   select
		    locus.id as locus_id,
		    locus.name as locus_name
  	           from genecandidatelocus
		    inner join locus on genecandidatelocus.candidatelocus_locusid = locus.id
                   where genecandidatelocus.geneid = $genemarkerid
		   order by locus.name
		   },
	       ['locus_link'],
	       []
	       );

  # okay reference (gene)
  &print_element(
               $cgi,
               $dbh,
               'reference',
               'Reference',
               qq{
                   select
                    reference.id as reference_id
                   from genereference
                    inner join reference on genereference.referenceid = reference.id
                   where genereference.geneid = $genemarkerid
                   order by reference.year desc
                   },
               ['reference_id'],
               []
               );

  # okay url (gene)
  &print_element(
               $cgi,
               $dbh,
               'url',
               'URL',
               qq{
                   select
                    geneurl.url,
                    geneurl.description
                   from geneurl
                   where geneurl.geneid = $genemarkerid
                   },
               ['url'],
               []
               );

  # OK qtl associated with gene (gene)
  &print_element(
	       $cgi,
	       $dbh,
	       'qtl',
	       'QTL Associated with Gene',
	       qq{
		   select
		    qtl.id as qtl_id,
		    qtl.name as qtl_name
		   from qtlassociatedgene
		    inner join qtl on qtlassociatedgene.qtlid = qtl.id
                   where qtlassociatedgene.geneid = $genemarkerid
		   order by qtl.name
		   },
	       ['qtl_link'],
	       []
	       );
               
  # okay geneproduct (gene)
  &print_element(
               $cgi,
               $dbh,
               'geneproduct',
               'Gene Product',
               qq{
                   select
                    geneproduct.id as geneproduct_id,
                    geneproduct.name as geneproduct_name
                   from genegeneproduct
                    inner join geneproduct on genegeneproduct.geneproductid = geneproduct.id
                   where genegeneproduct.geneid = $genemarkerid
                   order by geneproduct.name
                   },
               ['geneproduct_link'],
               []
               );

  # OK chromosome (gene)
  &print_element(
	       $cgi,
	       $dbh,
	       'chromosome',
	       'Chromosome',
	       qq{
		   select
  	            genechromosome.chromosome,
                    reference.id as reference_id
		   from genechromosome
                    left join reference on genechromosome.referenceid = reference.id	     
                   where genechromosome.geneid = $genemarkerid
		   order by genechromosome.chromosome
		   },
	       ['chromosome','reference_id'],
	       ['chromosome']
	       );

  # OK chromosomearm (gene) can't show chromosomearm on same line because of Cartesian product
  &print_element(
	       $cgi,
	       $dbh,
	       'chromosomearm',
	       'Chromosome Arm',
	       qq{
		   select
		    genechromosomearm.chromosomearm,
                    reference.id as reference_id
		   from genechromosomearm
		    left join reference on genechromosomearm.referenceid = reference.id
                   where genechromosomearm.geneid = $genemarkerid
		   order by genechromosomearm.chromosomearm
		   },
	       ['chromosomearm','reference_id'],
	       ['chromosomearm']
	       );

  # OK germplasm (gene)
  &print_element(
	       $cgi,
	       $dbh,
	       'germplasm',
	       'Germplasm',
	       qq{
		   select
		    genegermplasm.type,
		    germplasm.id as germplasm_id,
		    germplasm.name as germplasm_name,
		    reference.id as reference_id
		   from genegermplasm
		    inner join germplasm on genegermplasm.germplasmid = germplasm.id
		    left join reference on genegermplasm.referenceid = reference.id
                   where genegermplasm.geneid = $genemarkerid
		   order by genegermplasm.type,germplasm.name
		   },
	       ['type','germplasm_link','reference_id'],
	       ['type']
	       );

   ### ok origin (gene)
   &print_element(
	       $cgi,
	       $dbh,
	       'origin',
	       'Origin',
	       qq{
		   select
  	            remark as origin
		   from generemark
		   where geneid = $genemarkerid
		    and type = 'Origin'
		   },
	       ['origin'],
	       []
	       );
	       
   # ok comment (gene)
   &print_element(
	       $cgi,
	       $dbh,
	       'comment',
	       'Comment',
	       qq{
		   select
  	            remark as comment
		   from generemark
		   where geneid = $genemarkerid
		    and type = 'Comment'
		   },
	       ['comment'],
	       []
	       );
	       
  # okay clone (gene)
  &print_element(
               $cgi,
               $dbh,
               'clone',
               'Clone',
               qq{
                   select
                    probe.id as probe_id,
                    probe.name as probe_name
                   from geneclone
                    inner join probe on geneclone.probeid = probe.id
                   where geneclone.geneid = $genemarkerid
                   order by probe.name
                   },
               ['probe_link'],
               []
               );

  # okay sequence (gene)
  &print_element(
               $cgi,
               $dbh,
               'sequence',
               'Sequence',
               qq{
                   select
                    sequence.id as sequence_id,
                    sequence.name as sequence_name
                   from genesequence
                    inner join sequence on genesequence.sequenceid = sequence.id
                   where genesequence.geneid = $genemarkerid
                   order by sequence.name
                   },
               ['sequence_link'],
               []
               );

  # OK image (gene)
  &print_element(
	       $cgi,
	       $dbh,
	       'image',
	       'Image',
	       qq{
		   select
		    image.id as image_id,
		    image.name as image_name
		   from geneimage
		    inner join image on geneimage.imageid = image.id
		   where geneimage.geneid = $genemarkerid
		   order by image.name
		   },
	       ['image_link'],
	       []
	       );

  # okay bgsphoto (gene)
  {
    my $sql = "select 
                genebgsphoto.name 
               from genebgsphoto
               where genebgsphoto.geneid = $genemarkerid";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $name = $sth->fetchall_arrayref({});

    if ($name)
    {
      foreach my $n (@$name)
      {
#        $n->{'name'} = $cgi->escapeHTML($n->{'name'}).'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"http://ace.untamo.net/cgi-bin/ace/tree/default?name=".$n->{'name'}."&class=Image",-target=>'_blank'},'BGS Database').' ]';
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
  } # end bgsphoto

  # okay twopointdata (gene)
  &print_element(
               $cgi,
               $dbh,
               'twopointdata',
               '2 Point Data',
               qq{
                   select
                    twopointdata.id as twopointdata_id,
                    twopointdata.name as twopointdata_name
                   from genetwopointdata
                    inner join twopointdata on genetwopointdata.twopointdataid = twopointdata.id
                   where genetwopointdata.geneid = $genemarkerid
                   order by twopointdata.name
                   },
               ['twopointdata_link'],
               []
               );


  # OK wgcreference (gene)
  &print_element(
	       $cgi,
	       $dbh,
	       'wgcreference',
	       'Wheat Gene Catalog Reference',
	       qq{
		   select
		    reference.id as reference_id,
		    genewgcreference.number
		   from genewgcreference
		    inner join reference on genewgcreference.referenceid = reference.id
		   where genewgcreference.geneid = $genemarkerid
		   order by reference.year desc
		   },
	       ['number','reference_id'],
	       []
	       );

  # okay datasource (gene)
  &print_element(
               $cgi,
               $dbh,
               'datasource',
               'Data Source',
               qq{
                   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name,
                    genedatasource.date
                   from genedatasource
                    inner join colleague on genedatasource.colleagueid = colleague.id
                   where genedatasource.geneid = $genemarkerid
                   order by colleague.name
                   },
               ['colleague_link','date'],
               []
               );

  # OK infosource (gene)
  &print_element(
	       $cgi,
	       $dbh,
	       'infosource',
	       'Info Source',
	       qq{
		   select
		    reference.id as reference_id
		   from geneinfosource
		    inner join reference on geneinfosource.referenceid = reference.id
		   where geneinfosource.geneid = $genemarkerid
		   },
	       ['reference_id'],
	       []
	       );
	       
  # OK datacurator (gene)
  &print_element(
	       $cgi,
	       $dbh,
	       'datacurator',
	       'Data Curator',
	       qq{
		   select
		    colleague.id as colleague_id,
		    colleague.name as colleague_name,
		    genedatacurator.date
		   from genedatacurator
		    inner join colleague on genedatacurator.colleagueid = colleague.id
		   where genedatacurator.geneid = $genemarkerid
		   order by colleague.name
		   },
	       ['colleague_link','date'],
	       []
	       );
} # end GENE subreport (if $genemarker)

##################### GENE
# OK loci associated with genes (genelocus->locus report)
{
  my $loci = $dbh->selectcol_arrayref("select 
                                        distinct 
                                        locusassociatedgene.locusid
                                       from locusassociatedgene
                                        inner join marker on locusassociatedgene.geneid = marker.geneid
                                         and marker.geneid is not null
                                         and locusassociatedgene.locusid is not null
                                         -- don't repeat locus report  
                                         and ((marker.locusid is null) ||
                                              (marker.locusid is not null) && (marker.locusid != locusassociatedgene.locusid))
                                        where marker.id = $id");
  @$loci = sort @$loci;
  foreach my $locus (@$loci)
  {
    ## print locus report
    ### print separator
    my $separator = ();
    $separator->[0]->{'separator'} = $cgi->br($cgi->hr({-size=>"3",-width=>"300px", -align=>left}));
    &print_element(
                   $cgi,
                   $dbh,
                   'separator',
                   ' ',
                   $separator,
                   ['separator_html'],
                   []
                   );
    
    ### name (gene's locus)
            &print_element(
                   $cgi,
                   $dbh,
                   'name',
                   'Locus Associated with Gene',
                   qq{
                       select
                        id as locus_id,
                        name as locus_name 
                       from locus
                       where id = $locus
                     },
                   ['locus_link'],
                   []
                   );

    ### type
            &print_element(
                   $cgi,
                   $dbh,
                   'type',
                  'Type',
                  qq{
                     select type from locustype where locusid = $locus order by type
                   },
                  ['type'],
                  []
                  );
                       
    ### synonym
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
                   where locussynonym.locusid = $locus
                    order by locussynonym.type,locus.name
		   },
	       ['type','locus_link','reference_id'],
	       ['type']
	       );

    ### chromosome
    &print_element(
	       $cgi,
	       $dbh,
	       'chromosome',
	       'Chromosome',
	       qq{
		   select
		       chromosome
		       from locuschromosome
		       where locusid = $locus
		       order by chromosome
		   },
	       ['chromosome'],
	       []
	       );

    ### chromosomearm
    &print_element(
	       $cgi,
	       $dbh,
	       'chromosomearm',
	       'Chromosome Arm',
	       qq{
		   select
		       chromosomearm
		       from locuschromosomearm
		       where locusid = $locus
		       order by chromosomearm
		   },
	       ['chromosomearm'],
	       []
	       );


    ### map (2)
    {
        my $sql = qq{
		   select distinct
		       map.id as map_id,
		       map.name as map_name,
		       maplocus.begin as begin
		       from maplocus
		       inner join map on maplocus.mapid = map.id
		       where maplocus.locusid = $locus
		       order by map.name
                 };
        my $sth = $dbh->prepare($sql); $sth->execute;
        my $map = $sth->fetchall_arrayref({});
        foreach my $mp (@$map) {
	    ### see if this map exists in cmap before making it a link
#
	    my ($cmapname) = $dbh->selectrow_array(sprintf("select map_name from cmap_map where map_name = %s",$dbh->quote($mp->{'map_name'})));
#
	    if ($cmapname) {
	        ###$mp->{'map'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map;id=$mp->{'map_id'};locusid=$locus"},$mp->{'map_name'});
	        $mp->{'map'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map;locusid=$locus;name=".&geturlstring($mp->{'map_name'}),-target=>'_blank'},$mp->{'map_name'});
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

    ### nearbyloci
    {
        my $sql = "select 
    	        distinct
                name
               from locus
                inner join maplocus on locus.id = maplocus.locusid
               where locus.id = $locus";
        my $sth = $dbh->prepare($sql); $sth->execute;
        my $locus = $sth->fetchall_arrayref({});
        $locus->[0]->{'locus'} = $cgi->i($cgi->big('[ ')).$cgi->a({-href=>"$cgiurlpath/quickquery.cgi?query=nearbyloci&arg1=".$locus->[0]->{'name'}."&arg2=10",-target=>'_blank'},$cgi->i($cgi->big('Show Nearby Loci'))).$cgi->i($cgi->big(' ]'));

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

    ### inqtl
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
		       where qtlsignificantmarker.locusid = $locus
		       order by qtl.name
		   },
	       ['qtl_link'],
	       []
	       );

    ### rearrangement
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
		       where locusinsegment.locusid = $locus
		       order by locusinsegment.type
		   },
	       ['type','rearrangement_link'],
	       ['type']
	       );

    ### breakpointinterval
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
		       where locusininterval.locusid = $locus
		   },
	       ['breakpointinterval_link'],
	       []
	       );

    ### mapdata (and gbrowser link)
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
	         where locus.id = $locus
	         order by mapdata.name,mapdatalocus.howmapped};

     my $sth = $dbh->prepare($sql); $sth->execute;
     my $data = $sth->fetchall_arrayref({});

     if ( $data )
     {
      foreach my $m (@$data)
      {
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
         $m->{'data'}.'&nbsp;&nbsp;'.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=probe&name=".&geturlstring($m->{'probe_name'})},$m->{'probe_name'});
         delete($m->{'probe_id'});
         delete($m->{'probe_name'});
       }

       if ( $m->{'gene_id'} )   
       {
         $m->{'data'} =
         $m->{'data'}.'&nbsp;&nbsp;'.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=gene&name=".&geturlstring($m->{'gene_name'})},$m->{'gene_name'});
         delete($m->{'gene_id'});
         delete($m->{'gene_name'});
       }
     
       # add gbrowse link
       # No such loci: WheatPhysicalESTMaps if map is "Chinese_Spring_Deletion_*" mapdata "Wheat, Physical, EST"
       # OK GrainMaps if map is "Ta-Synthetic/Opata-1A" mapdata "Wheat, Synthetic x Opata"
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
     } # end if $data
    } # end mapdata

    ### twopointdata
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
		       where locustwopointdata.locusid = $locus
		       order by twopointdata.name
		   },
	       ['twopointdata_link'],
	       []
	       );

    ### species
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
		       where locusspecies.locusid = $locus
		       order by species.name
		   },
	       ['species_link'],
	       []
	       );

    ### probe
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
		       where locusprobe.locusid = $locus
		       order by probe.name
		   },
	       ['probe_link','reference_id'],
	       []
	       );

    ### linkedqtl 
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
		        ###inner join qtl on locus.id = qtl.nearestmarker_locusid
		       where locus.id = $locus
		   },
	       ['qtl_link'],
	       []
	       );

    ### associatedgene
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
		       where locusassociatedgene.locusid = $locus
		       order by gene.name
		   },
	       ['gene_link'],
	       []
	       );

    ### candidategene
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
		       where locus.id = $locus
		   },
	       ['gene_link'],
	       []
	       );

    ### OK homology
    &print_element(
	       $cgi,
	       $dbh,
	       'homology',
	       'Homology',
	       qq{
		   select distinct
		    protein.id as protein_id,
		    protein.name as protein_name,
		    concat("e-value: ",sequence.bestpepevalue) as evalue,
		    protein.title
		   from locus
		    inner join locusprobe on locus.id = locusprobe.locusid
		    inner join sequenceprobe on locusprobe.probeid = sequenceprobe.probeid
		    inner join sequence on sequenceprobe.sequenceid = sequence.id
		    inner join protein on sequence.bestpep_proteinid = protein.id
   	           where locus.id = $locus
		   },
	       ['protein_link','evalue','title'],
	       []
	       );
	       
    ### geneclass
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
		       where locusassociatedgene.locusid = $locus
		       order by geneclass.name
		   },
	       ['geneclass_link'],
	       []
	       );

    ### image
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
		       where locusimage.locusid = $locus
		       order by image.name
		   },
	       ['image_link'],
	       []
	       );

    ### OK bgsphoto
    {
        my $sql = "select 
                    name 
                   from locusbgsphoto
                   where locusid = $locus";
        my $sth = $dbh->prepare($sql); $sth->execute;
        my $name = $sth->fetchall_arrayref({});
    
        if ($name)
        {
          foreach my $n (@$name)
          {
#            $n->{'name'} = $cgi->escapeHTML($n->{'name'}).'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"http://ace.untamo.net/cgi-bin/ace/tree/default?name=".$n->{'name'}."&class=Image",-target=>'_blank'},'BGS Database').' ]';
            $n->{'name'} = $cgi->escapeHTML($n->{'name'}).'&nbsp;&nbsp;'.'[ '.$cgi->i($cgi->a({-href=>"http://ace.untamo.net/cgi-bin/ace/tree/default?name=".$n->{'name'}."&class=Image",-target=>'_blank'},'BGS Database')).' ]';

          } ### end foreach      
      
          &print_element(
                   $cgi,
                   $dbh,
                   'name',
                   'BGS Photo',
                   $name,
                   ['name_html'],
                   []
                   );
        } ### end if
    }

    ### reference
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
		       where locusreference.locusid = $locus
		       order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );

    ### datasource
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
		       where locusdatasource.locusid = $locus
		       order by colleague.name
		   },
	       ['colleague_link','date'],
	       []
	       );

    ### remark (27Sep2004, NL, to hyperlink untamo.net URLs) 
    {
       my $sql = "select remark from locusremark where locusid = $locus";
       my $sth = $dbh->prepare($sql); $sth->execute;
       my $remark = $sth->fetchall_arrayref({});

       foreach my $rem (@$remark) 
       {
         if ( $rem->{'remark'} =~ /^(.*)(http\S+)\s*(.*)$/is )
         {
           $rem->{'remark'} = $1.$cgi->a({-href=>$2,-target=>'_blank'},$2).$3;
         } ### else do nothing with string        
       } ### end foreach

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

    ### possibleorthologs
    &print_element(
	       $cgi,
	       $dbh,
	       'possibleorthologs',
	       'Possible Orthologs',
	       qq{
		   select
		       a.id as locus_id,
		       a.name as locus_name
		       from locus as a
		       inner join locus as b on a.locusorthologygroupid = b.locusorthologygroupid and a.locusorthologygroupid is not null
		       where a.id != b.id and b.id = $locus
		   },
	       ['locus_link'],
	       []
	       );
  } # end foreach
} # end loci associated with genes
##################### GENE
# OK candidatelocus for gene (candidatelocus->to get locus report)
{
  my $loci = $dbh->selectcol_arrayref("select 
  					distinct 
  					genecandidatelocus.candidatelocus_locusid
  				       from genecandidatelocus 
  				        inner join marker on genecandidatelocus.geneid = marker.geneid
  				         and marker.geneid is not null
  				         and genecandidatelocus.candidatelocus_locusid is not null
  				         -- don't repeat locus report  
					 and ((marker.locusid is null) ||
					      (marker.locusid is not null) && (marker.locusid != genecandidatelocus.candidatelocus_locusid))
  				        where marker.id = $id");
  @$loci = sort @$loci;
  foreach my $locus (@$loci)
  {
    ## print locus report
    ### print separator
    my $separator = ();
    $separator->[0]->{'separator'} = $cgi->br($cgi->hr({-size=>"3",-width=>"300px", -align=>left}));
    &print_element(
                   $cgi,
                   $dbh,
                   'separator',
                   ' ',
                   $separator,
                   ['separator_html'],
                   []
                   );
    
    ### name (probe's locus)
            &print_element(
                   $cgi,
                   $dbh,
                   'name',
                   'Locus Candidate for Gene',
                   qq{
                       select
                        id as locus_id,
                        name as locus_name 
                       from locus
                       where id = $locus
                     },
                   ['locus_link'],
                   []
                   );

    ### type
            &print_element(
                   $cgi,
                   $dbh,
                   'type',
                  'Type',
                  qq{
                     select type from locustype where locusid = $locus order by type
                   },
                  ['type'],
                  []
                  );
                       
    ### synonym
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
                   where locussynonym.locusid = $locus
                    order by locussynonym.type,locus.name
		   },
	       ['type','locus_link','reference_id'],
	       ['type']
	       );

    ### chromosome
    &print_element(
	       $cgi,
	       $dbh,
	       'chromosome',
	       'Chromosome',
	       qq{
		   select
		       chromosome
		       from locuschromosome
		       where locusid = $locus
		       order by chromosome
		   },
	       ['chromosome'],
	       []
	       );

    ### chromosomearm
    &print_element(
	       $cgi,
	       $dbh,
	       'chromosomearm',
	       'Chromosome Arm',
	       qq{
		   select
		       chromosomearm
		       from locuschromosomearm
		       where locusid = $locus
		       order by chromosomearm
		   },
	       ['chromosomearm'],
	       []
	       );


    ### map (2)
    {
        my $sql = qq{
		   select distinct
		       map.id as map_id,
		       map.name as map_name,
		       maplocus.begin as begin
		       from maplocus
		       inner join map on maplocus.mapid = map.id
		       where maplocus.locusid = $locus
		       order by map.name
                 };
        my $sth = $dbh->prepare($sql); $sth->execute;
        my $map = $sth->fetchall_arrayref({});
        foreach my $mp (@$map) {
	    ### see if this map exists in cmap before making it a link
#
	    my ($cmapname) = $dbh->selectrow_array(sprintf("select map_name from cmap_map where map_name = %s",$dbh->quote($mp->{'map_name'})));
#
	    if ($cmapname) {
	        ###$mp->{'map'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map;id=$mp->{'map_id'};locusid=$locus"},$mp->{'map_name'});
	        $mp->{'map'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map;locusid=$locus;name=".&geturlstring($mp->{'map_name'}),-target=>'_blank'},$mp->{'map_name'});
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

    ### nearbyloci
    {
        my $sql = "select 
    	        distinct
                name
               from locus
                inner join maplocus on locus.id = maplocus.locusid
               where locus.id = $locus";
        my $sth = $dbh->prepare($sql); $sth->execute;
        my $locus = $sth->fetchall_arrayref({});
        $locus->[0]->{'locus'} = $cgi->i($cgi->big('[ ')).$cgi->a({-href=>"$cgiurlpath/quickquery.cgi?query=nearbyloci&arg1=".$locus->[0]->{'name'}."&arg2=10",-target=>'_blank'},$cgi->i($cgi->big('Show Nearby Loci'))).$cgi->i($cgi->big(' ]'));

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

    ### inqtl
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
		       where qtlsignificantmarker.locusid = $locus
		       order by qtl.name
		   },
	       ['qtl_link'],
	       []
	       );

    ### rearrangement
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
		       where locusinsegment.locusid = $locus
		       order by locusinsegment.type
		   },
	       ['type','rearrangement_link'],
	       ['type']
	       );

    ### breakpointinterval
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
		       where locusininterval.locusid = $locus
		   },
	       ['breakpointinterval_link'],
	       []
	       );

    ### mapdata (and gbrowser link)
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
	         where locus.id = $locus
	         order by mapdata.name,mapdatalocus.howmapped};

     my $sth = $dbh->prepare($sql); $sth->execute;
     my $data = $sth->fetchall_arrayref({});

     if ( $data )
     {
      foreach my $m (@$data)
      {
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
         $m->{'data'}.'&nbsp;&nbsp;'.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=probe&name=".&geturlstring($m->{'probe_name'})},$m->{'probe_name'});
         delete($m->{'probe_id'});
         delete($m->{'probe_name'});
       }

       if ( $m->{'gene_id'} )   
       {
         $m->{'data'} =
         $m->{'data'}.'&nbsp;&nbsp;'.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=gene&name=".&geturlstring($m->{'gene_name'})},$m->{'gene_name'});
         delete($m->{'gene_id'});
         delete($m->{'gene_name'});
       }
     
       # add gbrowse link
       # No such loci: WheatPhysicalESTMaps if map is "Chinese_Spring_Deletion_*" mapdata "Wheat, Physical, EST"
       # OK GrainMaps if map is "Ta-Synthetic/Opata-1A" mapdata "Wheat, Synthetic x Opata"
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
     } # end if $data
    } # end mapdata

    ### twopointdata
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
		       where locustwopointdata.locusid = $locus
		       order by twopointdata.name
		   },
	       ['twopointdata_link'],
	       []
	       );

    ### species
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
		       where locusspecies.locusid = $locus
		       order by species.name
		   },
	       ['species_link'],
	       []
	       );

    ### probe
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
		       where locusprobe.locusid = $locus
		       order by probe.name
		   },
	       ['probe_link','reference_id'],
	       []
	       );

    ### linkedqtl 
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
		        ###inner join qtl on locus.id = qtl.nearestmarker_locusid
		       where locus.id = $locus
		   },
	       ['qtl_link'],
	       []
	       );

    ### associatedgene
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
		       where locusassociatedgene.locusid = $locus
		       order by gene.name
		   },
	       ['gene_link'],
	       []
	       );

    ### candidategene
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
		       where locus.id = $locus
		   },
	       ['gene_link'],
	       []
	       );

    ### OK homology
    &print_element(
	       $cgi,
	       $dbh,
	       'homology',
	       'Homology',
	       qq{
		   select distinct
		    protein.id as protein_id,
		    protein.name as protein_name,
		    concat("e-value: ",sequence.bestpepevalue) as evalue,
		    protein.title
		   from locus
		    inner join locusprobe on locus.id = locusprobe.locusid
		    inner join sequenceprobe on locusprobe.probeid = sequenceprobe.probeid
		    inner join sequence on sequenceprobe.sequenceid = sequence.id
		    inner join protein on sequence.bestpep_proteinid = protein.id
   	           where locus.id = $locus
		   },
	       ['protein_link','evalue','title'],
	       []
	       );
	       
    ### geneclass
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
		       where locusassociatedgene.locusid = $locus
		       order by geneclass.name
		   },
	       ['geneclass_link'],
	       []
	       );

    ### image
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
		       where locusimage.locusid = $locus
		       order by image.name
		   },
	       ['image_link'],
	       []
	       );

    ### OK bgsphoto
    {
        my $sql = "select 
                    name 
                   from locusbgsphoto
                   where locusid = $locus";
        my $sth = $dbh->prepare($sql); $sth->execute;
        my $name = $sth->fetchall_arrayref({});
    
        if ($name)
        {
          foreach my $n (@$name)
          {
#            $n->{'name'} = $cgi->escapeHTML($n->{'name'}).'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"http://ace.untamo.net/cgi-bin/ace/tree/default?name=".$n->{'name'}."&class=Image",-target=>'_blank'},'BGS Database').' ]';
            $n->{'name'} = $cgi->escapeHTML($n->{'name'}).'&nbsp;&nbsp;'.'[ '.$cgi->i($cgi->a({-href=>"http://ace.untamo.net/cgi-bin/ace/tree/default?name=".$n->{'name'}."&class=Image",-target=>'_blank'},'BGS Database')).' ]';
          } ### end foreach      
      
          &print_element(
                   $cgi,
                   $dbh,
                   'name',
                   'BGS Photo',
                   $name,
                   ['name_html'],
                   []
                   );
        } ### end if
    }

    ### reference
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
		       where locusreference.locusid = $locus
		       order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );

    ### datasource
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
		       where locusdatasource.locusid = $locus
		       order by colleague.name
		   },
	       ['colleague_link','date'],
	       []
	       );

    ### remark (27Sep2004, NL, to hyperlink untamo.net URLs) 
    {
       my $sql = "select remark from locusremark where locusid = $locus";
       my $sth = $dbh->prepare($sql); $sth->execute;
       my $remark = $sth->fetchall_arrayref({});

       foreach my $rem (@$remark) 
       {
         if ( $rem->{'remark'} =~ /^(.*)(http\S+)\s*(.*)$/is )
         {
           $rem->{'remark'} = $1.$cgi->a({-href=>$2,-target=>'_blank'},$2).$3;
         } ### else do nothing with string        
       } ### end foreach

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

    ### possibleorthologs
    &print_element(
	       $cgi,
	       $dbh,
	       'possibleorthologs',
	       'Possible Orthologs',
	       qq{
		   select
		       a.id as locus_id,
		       a.name as locus_name
		       from locus as a
		       inner join locus as b on a.locusorthologygroupid = b.locusorthologygroupid and a.locusorthologygroupid is not null
		       where a.id != b.id and b.id = $locus
		   },
	       ['locus_link'],
	       []
	       );
  } # end foreach
} # end candidatelocus for gene (to get locus report)
##################### 
# add space between sections if there's a GENE section (and a LOCUS -or- PROBE section)
{
  my $sql = "select 
              geneid 
             from marker 
             where id = $id
              and geneid is not null
              and (locusid is not null or probeid is not null)";
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $separator = $sth->fetchall_arrayref({});

  if ($separator->[0]->{'geneid'})
  {
    $separator->[0]->{'separator'} = $cgi->br($cgi->hr({-size=>"3",-width=>"500px", -align=>left}));
    delete($separator->[0]->{'geneid'});
    
    &print_element(
                   $cgi,
                   $dbh,
                   'separator',
                   ' ',
                   $separator,
                   ['separator_html'],
                   []
                   );
  } # end if
}
##################### LOCUS
## LOCUS subreport
my $locusmarkerid = $dbh->selectrow_array("select locusid from marker where id = $id");
if ($locusmarkerid)
{
  # OK locus
  &print_element(
	       $cgi,
	       $dbh,
	       'name',
	       'Locus',
	       qq{
		   select 
                    locus.id as locus_id,
                    locus.name as locus_name
                   from locus
                   where locus.id = $locusmarkerid
		   },
	       ['locus_link'],
	       []
	       );

  # OK type (locus)
  &print_element(
	       $cgi,
	       $dbh,
	       'type',
	       'Type',
	       qq{
		   select 
		    locustype.type 
		   from locustype
                   where locustype.locusid = $locusmarkerid
		   order by locustype.type
		   },
	       ['type'],
	       []
	       );

  # OK synonym (locus)
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
                   where locussynonym.locusid = $locusmarkerid
                    order by locussynonym.type,locus.name
                   },
               ['type','locus_link','reference_id'],
               ['type']
               );

  # OK chromosome from locus (locus)
  &print_element(
	       $cgi,
	       $dbh,
	       'chromosome',
	       'Chromosome',
	       qq{
		   select
		    distinct
		    locuschromosome.chromosome
		   from locuschromosome
		   where locuschromosome.locusid = $locusmarkerid
		   order by locuschromosome.chromosome
		   },
	       ['chromosome'],
	       []
	       );

  # OK chromosomearm (locus) can't show on same line as chromosome because of Cartesian product
  &print_element(
	       $cgi,
	       $dbh,
	       'chromosomearm',
	       'Chromosome Arm',
	       qq{
		   select
		    locuschromosomearm.chromosomearm
		   from locuschromosomearm
		   where locuschromosomearm.locusid = $locusmarkerid
		   order by locuschromosomearm.chromosomearm
		   },
	       ['chromosomearm'],
	       []
	       );

  # OK map (2) (locus)
  {
    my $sql = qq{
		   select 
		    distinct
		    map.id as map_id,
		    map.name as map_name,
                    maplocus.begin as begin,
                    maplocus.locusid as locus_id
		   from maplocus
		    inner join map on maplocus.mapid = map.id
		   where maplocus.locusid = $locusmarkerid
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
	    #$mp->{'map'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map;id=$mp->{'map_id'};locusid=$id",-target=>'_blank'},$mp->{'map_name'});
	    $mp->{'map'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map;locusid=$mp->{'locus_id'};name=".&geturlstring($mp->{'map_name'}),-target=>'_blank'},$mp->{'map_name'});
#
	} else {
#
	    $mp->{'map'} = $cgi->escapeHTML($mp->{'map_name'});
#
	}
	delete $mp->{'map_id'};
	delete $mp->{'map_name'};
	delete $mp->{'locus_id'};
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
    my $sql = "select distinct
                locus.name as locus_name
               from locus
                inner join maplocus on locus.id = maplocus.locusid
               where locus.id = $locusmarkerid";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $locus = $sth->fetchall_arrayref({});
    $locus->[0]->{'locus'} = $cgi->i($cgi->big('[ ')).$cgi->a({-href=>"$cgiurlpath/quickquery.cgi?query=nearbyloci&arg1=".$locus->[0]->{'locus_name'}."&arg2=10",-target=>'_blank'},$cgi->i($cgi->big('Show Nearby Loci'))).$cgi->i($cgi->big(' ]'));

    if ($locus->[0]->{'locus_name'})
    {
      delete($locus->[0]->{'locus_name'});
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

  # OK inqtl (associated with locus)
  &print_element(
	       $cgi,
	       $dbh,
	       'inqtl',
	       'QTL with Locus Marker',
	       qq{
		   select 
		    distinct
		    qtl.id as qtl_id,
  	            qtl.name as qtl_name
		   from qtlsignificantmarker
		    inner join qtl on qtlsignificantmarker.qtlid = qtl.id
		   where qtlsignificantmarker.locusid = $locusmarkerid
		   order by qtl.name
		   },
	       ['qtl_link'],
	       []
	       );

  # okay rearrangement (locus)
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
                   where locusinsegment.locusid = $locusmarkerid
                   order by locusinsegment.type
                   },
               ['type','rearrangement_link'],
               ['type']
               );

  # okay breakpointinterval (locus)
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
                   where locusininterval.locusid = $locusmarkerid
                   },
               ['breakpointinterval_link'],
               []
               );

  # OK mapdata (locus)
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
	         where locus.id = $locusmarkerid
	         order by mapdata.name,mapdatalocus.howmapped};

     my $sth = $dbh->prepare($sql); $sth->execute;
     my $data = $sth->fetchall_arrayref({});

     if ( $data )
     {
      foreach my $m (@$data)
      {
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
         $m->{'data'}.'&nbsp;&nbsp;'.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=probe&name=".&geturlstring($m->{'probe_name'})},$m->{'probe_name'});
         delete($m->{'probe_id'});
         delete($m->{'probe_name'});
       }

       if ( $m->{'gene_id'} )   
       {
         $m->{'data'} =
         $m->{'data'}.'&nbsp;&nbsp;'.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=gene&name=".&geturlstring($m->{'gene_name'})},$m->{'gene_name'});
         delete($m->{'gene_id'});
         delete($m->{'gene_name'});
       }
     
       # add gbrowse link
       # No such loci: WheatPhysicalESTMaps if map is "Chinese_Spring_Deletion_*" mapdata "Wheat, Physical, EST"
       # OK GrainMaps if map is "Ta-Synthetic/Opata-1A" mapdata "Wheat, Synthetic x Opata"
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
     } # end if $data
    } # end mapdata

  # OK twopointdata (locus)
  &print_element(
	       $cgi,
	       $dbh,
	       'twopointdata',
	       '2 Point Data',
	       qq{
		   select
		    twopointdata.id as twopointdata_id,
		    twopointdata.name as twopointdata_name,
		    concat("Distance: ",twopointdata.distance," cM") as distance
		   from locustwopointdata
		    inner join twopointdata on locustwopointdata.twopointdataid = twopointdata.id
		   where locustwopointdata.locusid = $locusmarkerid
		   order by twopointdata.name
		   },
	       ['twopointdata_link','distance'],
	       []
	       );

  # okay species (locus)
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
                   where locusspecies.locusid = $locusmarkerid
                   order by species.name
                   },
               ['species_link'],
               []
               );

  # okay probe (locus)
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
                   where locusprobe.locusid = $locusmarkerid
                   order by probe.name
                   },
               ['probe_link','reference_id'],
               []
               );

  # OK linkedqtl (locus)
  &print_element(
	       $cgi,
	       $dbh,
	       'linkedqtl',
	       'QTL Linked with Locus',
	       qq{
		   select 
		    distinct
		    qtl.id as qtl_id,
		    qtl.name as qtl_name
		   from locus
		    inner join qtl on locus.linkedqtl_qtlid = qtl.id
		   where locus.id = $locusmarkerid
		   },
	       ['qtl_link'],
	       []
	       );

  # okay associatedgene (locus)
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
                   where locusassociatedgene.locusid = $locusmarkerid
                   order by gene.name
                   },
               ['gene_link'],
               []
               );

  # okay candidategene (locus)
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
                   where locus.id = $locusmarkerid
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
		   select distinct
		    protein.id as protein_id,
		    protein.name as protein_name,
		    concat("e-value: ",sequence.bestpepevalue) as evalue,
		    protein.title
		   from locus
		    inner join locusprobe on locus.id = locusprobe.locusid
		    inner join sequenceprobe on locusprobe.probeid = sequenceprobe.probeid
		    inner join sequence on sequenceprobe.sequenceid = sequence.id
		    inner join protein on sequence.bestpep_proteinid = protein.id
                   where locus.id = $locusmarkerid
		   },
	       ['protein_link','evalue','title'],
	       []
	       );
	       
  # okay geneclass (locus)
  &print_element(
               $cgi,
               $dbh,
               'geneclass',
               'Gene Class',
               qq{
                   select 
                    distinct
                    geneclass.id as geneclass_id,
                    geneclass.name as geneclass_name
                   from locusassociatedgene
                    inner join genegeneclass on locusassociatedgene.geneid = genegeneclass.geneid
                    inner join geneclass on genegeneclass.geneclassid = geneclass.id
                   where locusassociatedgene.locusid = $locusmarkerid
                   order by geneclass.name
                   },
               ['geneclass_link'],
               []
               );

  # OK image (locus)
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
                   where locusimage.locusid = $locusmarkerid
                    order by image.name
                   },
               ['image_link'],
               []
               );

  # okay bgsphoto (locus)
  {
    my $sql = "select 
                locusbgsphoto.name 
               from locusbgsphoto
               where locusbgsphoto.locusid = $locusmarkerid";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $name = $sth->fetchall_arrayref({});
    
    if ($name)
    {
      foreach my $n (@$name)
      {
#        $n->{'name'} = $cgi->escapeHTML($n->{'name'}).'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"http://ace.untamo.net/cgi-bin/ace/tree/default?name=".$n->{'name'}."&class=Image",-target=>'_blank'},'BGS Database').' ]';
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

  # okay reference (locus)
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
                   where locusreference.locusid = $locusmarkerid
                   order by reference.year desc
                   },
               ['reference_id'],
               []
               );

  # okay datasource (locus)
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
                   where locusdatasource.locusid = $locusmarkerid
                   order by colleague.name
                   },
               ['colleague_link','date'],
               []
               );

  # OK remark (locus) (updated 27Sep2004)
  {
   my $sql = "select 
               remark 
              from locusremark
              where locusremark.locusid = $locusmarkerid";
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

  # OK possibleorthologs (locus)
  &print_element(
	       $cgi,
	       $dbh,
	       'possibleorthologs',
	       'Possible Orthologs',
	       qq{
		   select
		    a.id as locus_id,
		    a.name as locus_name
		   from locus as a
		    inner join locus as b on a.locusorthologygroupid = b.locusorthologygroupid 
		     and a.locusorthologygroupid is not null
		   where a.id != b.id 
		    and b.id = $locusmarkerid
		   },
	       ['locus_link'],
	       []
	       );
} # end LOCUS subreport (if $locusmarkerid	       
################### LOCUS
# OK probes associated with loci
{
  my $probes = $dbh->selectcol_arrayref("select 
  					distinct 
  					locusprobe.probeid
  				       from locusprobe 
  				        inner join marker on locusprobe.locusid = marker.locusid
  				         and marker.locusid is not null
  				         and locusprobe.probeid is not null
  				        -- don't repeat probe report  
  				        and ((marker.probeid is null) ||
					     (marker.probeid is not null) && (marker.probeid != locusprobe.probeid))
  				        where marker.id = $id");
  @$probes = sort @$probes;
  foreach my $probe (@$probes)
  {
    ## print probe report
    ### print separator
    my $separator = ();
    $separator->[0]->{'separator'} = $cgi->br($cgi->hr({-size=>"3",-width=>"300px", -align=>left}));
    &print_element(
                   $cgi,
                   $dbh,
                   'separator',
                   ' ',
                   $separator,
                   ['separator_html'],
                   []
                   );
    
    ### name (locus's associated probe)
            &print_element(
                       $cgi,
                       $dbh,
                       'name',
                       'Probe for Locus',
                       qq{
                           select
                            id as probe_id,
                            name as probe_name
                           from probe
                           where id = $probe
                           },
                       ['probe_link'],
                       []
                       );

    ### locus (locus's associated probe's associated locus
         &print_element(
               $cgi,
               $dbh,
               'locus',
               'Locus',
               qq{
                   select distinct
                    locus.id as locus_id,
                    locus.name as locus_name
                   from locus
                    inner join locusprobe
                     on locus.id = locusprobe.locusid
                   where locusprobe.probeid = $probe
                   },
               ['locus_link'],
               []
               );
   ### synonym
       &print_element(
               $cgi,
               $dbh,
               'synonym',
               'Synonym',
               qq{
                   select
                    type,
		    probe.id as probe_id,
                    probe.name as probe_name,
                    probesynonym.referenceid as reference_id
                   from probe 
                    inner join probesynonym on probe.name = probesynonym.name
                   where probesynonym.probeid = $probe
                    order by probesynonym.type,probe.name

                   },
               ['type','probe_link','reference_id'],
               ['type']
               );
               
   ### ok relatedprobe
   &print_element(
                  $cgi,
                  $dbh,
                  'relatedprobe',
                  'Related Probe',
                  qq{
                      select
                       probe.id as probe_id,
                       probe.name as probe_name
                      from probe
                       inner join proberelatedprobe 
                        on proberelatedprobe.relatedprobe_probeid = probe.id
                      where proberelatedprobe.probeid = $probe
                       ###order by probe_name
                      },
                  ['probe_link'],
                  []
                  );

   ### ok note about relatedprobe (unable to pass successfully in same call to sub & show distinct)
       &print_element(
                  $cgi,
                  $dbh,
                  'relatedprobenote',
                  ' ',
                  qq{
                      select
                       distinct concat(help.name,": ") as name,
                       ###distinct 
                       helpremark.remark
                      from help
                       inner join helpremark on help.id = helpremark.helpid
                       inner join proberelatedprobe on helpremark.helpid = proberelatedprobe.helpid
                      where proberelatedprobe.probeid = $probe
                      },
                  ['name','remark'],
                  []
                  );
                  
   ### ok similarprobes
   &print_element(
                  $cgi,
                  $dbh,
                  'similarprobes',
                  'Similar Probes',
                  qq{
                      select
                       probe.id as probe_id,
                       probe.name as probe_name
                      from probe
                       inner join probecluster 
                        on probecluster.name = probe.name
                      where probecluster.probeid = $probe
                       ###unnec: order by probe_name
                      },
                  ['probe_link'],
                  []
                  );
   
   ### probeexternaldb 
   {
     my $sql = qq{
                  select
                   accession
                  from probeexternaldb
                  where probeid = $probe
		  and name = 'Sequence'
                 };
     my $sth = $dbh->prepare($sql); $sth->execute;
     my $extdb = $sth->fetchall_arrayref({});
     if ($extdb->[0]->{'accession'})
     {
       $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://getentry.ddbj.nig.ac.jp/cgi-bin/get_entry.pl?".$extdb->[0]->{'accession'},-target=>'_blank'},'DDBJ');
       $extdb->[1]->{'extdb'} = $cgi->a({href=>"http://srs.ebi.ac.uk/srs6bin/cgi-bin/wgetz?-e+[embl-acc:".$extdb->[0]->{'accession'}."]",-target=>'_blank'},'EMBL');
       $extdb->[2]->{'extdb'} = $cgi->a({href=>"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Search&db=Nucleotide&doptcmdl=GenBank&term=".$extdb->[0]->{'accession'},-target=>'_blank'},'GenBank');
       delete($extdb->[0]->{'accession'});
     
       &print_element(
                  $cgi,
                  $dbh,
                  'externaldb',
                  'External Databases',
                  $extdb,
                  ['extdb_html'],
                  []
                  );
     } 
   }               
   
  # OK externaldb (Germinate) (probe)
  {
    my $sql = qq{
		 select
		  accession
		 from probeexternaldb
		 where probeexternaldb.probeid = $probe
		 and name = 'BarleySNP'
		};
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $extdb = $sth->fetchall_arrayref({});
    if ($extdb->[0]->{'accession'})
    {
      $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://germinate.scri.ac.uk/cgi-bin/barley_snpdb/display_contig.cgi?contig=".$extdb->[0]->{'accession'},-target=>'_blank'},$extdb->[0]->{'accession'});
      delete($extdb->[0]->{'accession'});
      &print_element(
		 $cgi,
		 $dbh,
		 'externaldb',
		 'Data at Germinate',
		 $extdb,
		 ['extdb_html'],
		 []
		 );
    } 
  }

  # OK externaldb (PLEXdb) (probe)
  {
    my $sql = qq{
		 select
		  accession
		 from probeexternaldb
		 where probeexternaldb.probeid = $probe
		 and name = 'PlantGDB'
		};
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $extdb = $sth->fetchall_arrayref({});
    if ($extdb->[0]->{'accession'})
    {
      $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://www.plexdb.org/modules.php?name=PD_probeset&page=annotation.php&genechip=Barley&exemplar=".$extdb->[0]->{'accession'},-target=>'_blank'},$extdb->[0]->{'accession'});
      delete($extdb->[0]->{'accession'});
      &print_element(
		 $cgi,
		 $dbh,
		 'externaldb',
		 'Data at PLEXdb',
		 $extdb,
		 ['extdb_html'],
		 []
		 );
    } 
  }



   ### ok reference
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'reference',
   	       'Reference',
   	       qq{
   		   select
   		    reference.id as reference_id
   		   from probereference
   		    inner join reference on probereference.referenceid = reference.id
   		   where probereference.probeid = $probe
   		    order by reference.year desc
   		   },
   	       ['reference_id'],
   	       []
   	       );    
   
   ### ok generalremark (can't use special remark code because types spread thruout report)
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'generalremark',
   	       'General Remarks',
   	       qq{
   		   select
                       remark as generalremark
                      from proberemark
                      where probeid = $probe
                       and type = 'General_remark'
   		   },
   	       ['generalremark'],
   	       []
   	       );
   
   ### ok type
   &print_element(
                  $cgi,
                  $dbh,
                  'type',
                  'Type',
                  qq{
                      select
                       type
                      from probetype
                      where probeid = $probe
                      },
                  ['type'],
                  []
                  );
   
   ### ok pcrprimers (complete pair)
   &print_element(
                  $cgi,
                  $dbh,
                  'pcrprimers',
                  'PCR primers',
                  qq{
                      select
                       concat(primeronesequence,"<br>",primertwosequence) as pair
                      from probeprimer
                      where probeid = $probe
                       and type = 'PCR_primers'
                       and primertwosequence is not null
                      },
                  ['pair_html'],
                  []
                  );
   
   ### ok pcrprimers (just one sequence)              
   &print_element(
                  $cgi,
                  $dbh,
                  'pcrprimers',
                  'PCR primers',
                  qq{
                      select
                       primeronesequence
                      from probeprimer
                      where probeid = $probe
                       and type = 'PCR_primers'
                       and primertwosequence is null
                      },
                  ['primeronesequence'],
                  []
                  );                              
                
   ### ok aflpprimers (complete pair)
   &print_element(
                  $cgi,
                  $dbh,
                  'aflpprimers',
                  'AFLP primers',
                  qq{
                      select
                       concat(primeronesequence,"<br>",primertwosequence) as pair
                      from probeprimer
                      where probeid = $probe
                       and type = 'AFLP_primers'
                       and primertwosequence is not null
                      },
                  ['pair_html'],
                  []
                  );
                  
   ### ok aflpprimers (just one sequence)
   &print_element(
                  $cgi,
                  $dbh,
                  'aflpprimers',
                  'AFLP primers',
                  qq{
                      select
                       primeronesequence
                      from probeprimer
                      where probeid = $probe
                       and type = 'AFLP_primers'
                       and primertwosequence is null
                      },
                  ['primeronesequence'],
                  []
                  );
                  
   ### ok stsprimers (pair)
   &print_element(
                  $cgi,
                  $dbh,
                  'stsprimers',
                  'STS primers',
                  qq{
                      select
                       concat(primeronesequence,"<br>",primertwosequence) as pair
                      from probeprimer
                      where probeid = $probe
                       and type = 'STS_primers'
                      },
                  ['pair_html'],
                  []
                  );
                  
   
   ### ok stssize (can't use special remark code because PCR_size further down in report)
   &print_element(
                  $cgi,
                  $dbh,
                  'stssize',
                  'STS size',
                  qq{
                      select
                       distinct size
                      from probeprimer
                      where probeid = $probe
                       and sizetype = 'STS_size'
                      },
                  ['size'],
                  []
                  );
   
   ### ok ssrsize 
   &print_element(
                  $cgi,
                  $dbh,
                  'ssrsize',
                  'SSR size',
                  qq{
                      select
                       distinct size
                      from probeprimer
                      where probeid = $probe
                       and sizetype = 'SSR_size'
                      },
                  ['size'],
                  []
                  );
   
   ### ok amplificationconditions
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'amplificationconditions',
   	       'Amplification Conditions',
   	       qq{
   		   select
                       distinct ampconditions as amplificationconditions
                      from probeprimer
                      where probeprimer.probeid = $probe
   		   },
   	       ['amplificationconditions'],
   	       []
   	       );     
   	       
   ### ok specificity
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'specificity',
   	       'Specificity',
   	       qq{
   		   select
                       remark as specificity
                      from proberemark
                      where probeid = $probe
                       and type = 'Specificity'
   		   },
   	       ['specificity'],
   	       []
   	       );     
   
   ### ok sequence
   &print_element(
                  $cgi,
                  $dbh,
                  'sequence',
                  'Sequence',
                  qq{
                     select
                      sequence.id as sequence_id,
                      sequence.name as sequence_name
                     from sequence
                      inner join sequenceprobe on sequence.id = sequenceprobe.sequenceid
                     where sequenceprobe.probeid = $probe
                      },
                  ['sequence_link'],
                  []
                  );
   
   ### ok copynumber
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'copynumber',
   	       'Copy Number',
   	       qq{
   		   select
                       remark as copynumber
                      from proberemark
                      where probeid = $probe
                       and type = 'Copy_number'
   		   },
   	       ['copynumber'],
   	       []
   	       );     
   	       
   ### ok background
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'background',
   	       'Background',
   	       qq{
   		   select
                       remark as background
                      from proberemark
                      where probeid = $probe
                       and type = 'Background'
   		   },
   	       ['background'],
   	       []
   	       );     
   
   ### ok wheatpolymorphism link (text only is automatic if restrictionenzymeid NULL)
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'wheatpolymorphism',
   	       'Degree of Polymorphism',
   	       qq{
   		   select
   		    restrictionenzyme.id as restrictionenzyme_id,
   		    restrictionenzyme.name as restrictionenzyme_name,
   		    probewheatpolymorphism.polymorphism
                      from restrictionenzyme
                       inner join probewheatpolymorphism on restrictionenzyme.id = probewheatpolymorphism.restrictionenzymeid
                      where probewheatpolymorphism.probeid = $probe
   		   },
   	       ['restrictionenzyme_link','polymorphism'],
   	       []
   	       );
   
   ### ok crosshybridizesto
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'crosshybridizesto',
   	       'Cross hybridizes to',
   	       qq{
   		   select
                       species.id as species_id,
                       species.name as species_name,
                       probehybridizesto.quality
                      from species
                       inner join probehybridizesto on species.id = probehybridizesto.speciesid
                      where probehybridizesto.probeid = $probe
   		   },
   	       ['species_link','quality'],
   	       []
   	       );    
   
   ### ok polymorphism
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'polymorphism',
   	       'Polymorphism',
   	       qq{
   		   select
                       polymorphism.id as polymorphism_id,
                       polymorphism.name as polymorphism_name,
                       probepolymorphism.summaryscore
                      from polymorphism
                       inner join probepolymorphism on polymorphism.id = probepolymorphism.polymorphismid
                      where probepolymorphism.probeid = $probe
   		   },
   	       ['polymorphism_link','summaryscore'],
   	       []
   	       );    	       
   
   ### ok gel
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'gel',
   	       'Gel',
   	       qq{
   		   select
                       gel.id as gel_id,
                       gel.name as gel_name
                      from gel
                       inner join probe on gel.id = probe.gelid
                      where probe.id = $probe
   		   },
   	       ['gel_link'],
   	       []
   	       );    	
   
   ### ok linkagegroup
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'linkagegroup',
   	       'Linkage Group',
   	       qq{
   		   select
                       ###distinct 
                       remark as linkagegroup
                      from proberemark
                      where probeid = $probe
                       and type = 'Linkage_Group'
   		   },
   	       ['linkagegroup'],
   	       []
   	       );  
   
   ### ok dnalibrary
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'dnalibrary',
   	       'DNA Library',
   	       qq{
   		   select
                       library.id as library_id,
                       library.name as library_name
                      from library
                       inner join probe on library.id = probe.dnalibrary_libraryid
                      where probe.id = $probe
   		   },
   	       ['library_link'],
   	       []
   	       );    	
   
   
   ### ok insertenzyme
   
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'insertenzyme',
   	       'Insert Enzyme',
   	       qq{
   		   select
                       restrictionenzyme.id as restrictionenzyme_id,
                       restrictionenzyme.name as restrictionenzyme_name
                      from restrictionenzyme
                       inner join probeinsertenzyme on restrictionenzyme.id = probeinsertenzyme.restrictionenzymeid
                      where probeinsertenzyme.probeid = $probe
   		   },
   	       ['restrictionenzyme_link'],
   	       []
   	       ); 
   	          
   ### ok sourcegeneclass
   &print_element(
                  $cgi,
                  $dbh,
                  'sourcegeneclass',
                  'Source Gene Class',
                  qq{
                     select
                      geneclass.id as geneclass_id,
                      geneclass.name as geneclass_name
                     from geneclass
                      inner join geneclassclone on geneclass.id = geneclassclone.geneclassid
                      inner join probe on geneclassclone.probeid = probe.id
                     where probe.id = $probe
                      },
                  ['geneclass_link'],
                  []
                  );
   
   ### ok sourcegene
   &print_element(
                  $cgi,
                  $dbh,
                  'sourcegene',
                  'Source Gene',
                  qq{
                     select
                      gene.id as gene_id,
                      gene.name as gene_name
                     from gene
                      inner join geneclone on gene.id = geneclone.geneid
                      inner join probe on geneclone.probeid = probe.id
                     where probe.id = $probe
                      },
                  ['gene_link'],
                  []
                  );
   
   ### ok sourceallele
   &print_element(
                  $cgi,
                  $dbh,
                  'sourceallele',
                  'Source Allele',
                  qq{
                     select
                      allele.id as allele_id,
                      allele.name as allele_name
                     from allele
                      inner join allelegene on allele.id = allelegene.alleleid
                      inner join geneclone on allelegene.geneid = geneclone.geneid
                      inner join probe on geneclone.probeid = probe.id
                     where probe.id = $probe
                      },
                  ['allele_link'],
                  []
                  );
   
   ### ok sourcespecies
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'sourcespecies',
   	       'Source Species',
   	       qq{
   		   select
                       species.id as species_id,
                       species.name as species_name
                      from species
                       inner join probesourcespecies on species.id = probesourcespecies.speciesid
                      where probesourcespecies.probeid = $probe
   		   },
   	       ['species_link'],
   	       []
   	       );    
   
   ### ok sourcegermplasm
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'sourcegermplasm',
   	       'Source Germplasm',
   	       qq{
   		   select
                       germplasm.id as germplasm_id,
                       germplasm.name as germplasm_name
                      from germplasm
                       inner join probe on germplasm.id = probe.sourcegermplasm_germplasmid
                      where probe.id = $probe
   		   },
   	       ['germplasm_link'],
   	       []
   	       );    
   
   ### ok sourcetissue
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'sourcetissue',
   	       'Source Tissue',
   	       qq{
   		   select
                       remark as sourcetissue
                      from proberemark
                      where probeid = $probe
                       and type = 'Source_tissue'
   		   },
   	       ['sourcetissue'],
   	       []
   	       );     
   	       
   ### ok dnaorigin
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'dnaorigin',
   	       'DNA Origin',
   	       qq{
   		   select
                       remark as dnaorigin
                      from proberemark
                      where probeid = $probe
                       and type = 'DNA_Origin'
   		   },
   	       ['dnaorigin'],
   	       []
   	       );  
   
   ### ok insertsize
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'insertsize',
   	       'Insert Size',
   	       qq{
   		   select
                       insertsize
                      from probeinsertsize
                      where probeid = $probe
   		   },
   	       ['insertsize'],
   	       []
   	       );  
   
   ### ok pcrsize
   &print_element(
                  $cgi,
                  $dbh,
                  'pcrsize',
                  'PCR size',
                  qq{
                      select
                       size
                      from probeprimer
                      where probeid = $probe
                       and sizetype = 'PCR_size'
                      },
                  ['size'],
                  []
                  );
   
   ### ok vector
   &print_element(
                  $cgi,
                  $dbh,
                  'vector',
                  'Clone Vector',
                  qq{
                      select
                       vector
                      from probevector
                      where probeid = $probe
                      },
                  ['vector'],
                  []
                  );
   
   ### ok vectorenzyme
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'vectorenzyme',
   	       'Vector Enzyme',
   	       qq{
   		   select
                       restrictionenzyme.id as restrictionenzyme_id,
                       restrictionenzyme.name as restrictionenzyme_name
                      from restrictionenzyme
                       inner join probe on restrictionenzyme.id = probe.vectorenzyme_restrictionenzymeid
                      where probe.id = $probe
   		   },
   	       ['restrictionenzyme_link'],
   	       []
   	       );    
   
   ### ok excisionenzyme
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'excisionenzyme',
   	       'Excision Enzyme',
   	       qq{
   		   select
                       restrictionenzyme.id as restrictionenzyme_id,
                       restrictionenzyme.name as restrictionenzyme_name
                      from restrictionenzyme
                       inner join probeexcisionenzyme on restrictionenzyme.id = probeexcisionenzyme.restrictionenzymeid
                      where probeexcisionenzyme.probeid = $probe
   		   },
   	       ['restrictionenzyme_link'],
   	       []
   	       );    
   
   ### ok vectorpcrprimers
   &print_element(
                  $cgi,
                  $dbh,
                  'vectorpcrprimers',
                  'Vector PCR primers',
                  qq{
                      select
                       vectorpcrprimers
                      from probevectorpcrprimers
                      where probeid = $probe
                      },
                  ['vectorpcrprimers'],
                  []
                  );
   
   ### ok vectoramplification
   &print_element(
                  $cgi,
                  $dbh,
                  'vectoramplification',
                  'Vector Amplification',
                  qq{
                      select
                       vectoramplification
                      from probe
                      where probe.id = $probe
                      },
                  ['vectoramplification'],
                  []
                  );
   
   ### ok bacterialstrain
   &print_element(
                  $cgi,
                  $dbh,
                  'bacterialstrain',
                  'Bacterial Strain',
                  qq{
                      select
                       bacterialstrain
                      from probe
                      where probe.id = $probe
                      },
                  ['bacterialstrain'],
                  []
                  );
   
   ### ok antibiotic
   &print_element(
                  $cgi,
                  $dbh,
                  'antibiotic',
                  'Antibiotic',
                  qq{
                      select
                       antibiotic
                      from probe
                      where probe.id = $probe
                      },
                  ['antibiotic'],
                  []
                  );
   
   ### ok subclonedin (based on subcloneof)
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'subclonein',
   	       'Subcloned in',
   	       qq{
   		   select
                       b.id as probe_id,
                       b.name as probe_name
                      from probe as a
                       inner join probe as b on a.id = b.subcloneof_probeid
                      where a.id = $probe
   		   },
   	       ['probe_link'],
   	       []
   	       );   
   
   ### ok subcloneof
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'subcloneof',
   	       'Subclone of',
   	       qq{
   		   select
                       a.id as probe_id,
                       a.name as probe_name
                      from probe as a
                       inner join probe as b on a.id = b.subcloneof_probeid
                      where b.id = $probe
   		   },
   	       ['probe_link'],
   	       []
   	       );   
   
   ### ok location
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'location',
   	       'Clone Location',
   	       qq{
   		   select
                       colleague.id as colleague_id,
                       colleague.name as colleague_name
                      from colleague
                       inner join probelocation on colleague.id = probelocation.colleagueid
                      where probelocation.probeid = $probe
   		   },
   	       ['colleague_link'],
   	       []
   	       );  
   
   ### ok authority
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'authority',
   	       'Clone Authority',
   	       qq{
   		   select
                       colleague.id as colleague_id,
                       colleague.name as colleague_name
                      from colleague
                       inner join probeauthority on colleague.id = probeauthority.colleagueid
                      where probeauthority.probeid = $probe
   		   },
   	       ['colleague_link'],
   	       []
   	       );  
   
   ### ok image
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'image',
   	       'Image',
   	       qq{
   		   select
   		    image.id as image_id,
       		    image.name as image_name
   		   from probeimage 
   		    inner join image on probeimage.imageid = image.id
   		   where probeimage.probeid = $probe
   		    ###unnec: order by image.name
   		   },
   	       ['image_link'],
   	       []
   	       ); 
   
   ### ok datasource
   &print_element(
                  $cgi,
                  $dbh,
                  'datasource',
                  'Data Source',
                  qq{
                      select
                       colleague.id as colleague_id,
                       colleague.name as colleague_name,
                       probedatasource.date
                      from probedatasource 
                       inner join colleague on colleague.id = probedatasource.colleagueid
                      where probedatasource.probeid = $probe
                      },
                  ['colleague_link','date'],
                  []
                  );
   
   ### ok informationsource
   	&print_element(
   	       $cgi,
   	       $dbh,
   	       'informationsource',
   	       'Information Source',
   	       qq{
   		   select
   		    reference.id as reference_id
   		   from probeinfosource
   		    inner join reference on probeinfosource.referenceid = reference.id
   		   where probeinfosource.probeid = $probe
   		   },
   	       ['reference_id'],
   	       []
   	       );    
   
   ### ok note (longtext from preformattext table)
   {
     my $sql = qq{
   	           select
                       preformattext.preformattext as note
                       from preformattext
                       inner join probenote on preformattext.id = probenote.preformattextid
                      where probenote.probeid = $probe
   		   };
     my $sth = $dbh->prepare($sql); $sth->execute;
     my $note = $sth->fetchall_arrayref({});
     foreach my $n (@$note) {
       	$n->{'note'} = $cgi->pre($cgi->escapeHTML($n->{'note'}));
     }		   
     &print_element(
   	       $cgi,
   	       $dbh,
   	       'note',
   	       'Note',
   	       $note,
   	       ['note_html'],
   	       []
   	       );	       
   }
   
  } # end foreach probe
} # end probes associated with loci
################ LOCUS
# OK genes associated with loci (locusassociatedgene->gene report)
{
  my $genes = $dbh->selectcol_arrayref("select 
  					distinct 
  					locusassociatedgene.geneid
  				       from locusassociatedgene 
  				        inner join marker on locusassociatedgene.locusid = marker.locusid
  				         and marker.locusid is not null
  				         and locusassociatedgene.geneid is not null
  				         -- don't repeat gene report
  				         and ((marker.geneid is null) ||
					      (marker.geneid is not null) && (marker.geneid != locusassociatedgene.geneid))
  				       where marker.id = $id");
  @$genes = sort @$genes;
  foreach my $gene (@$genes)
  {
    ## print gene report
    ### print separator
    my $separator = ();
    $separator->[0]->{'separator'} = $cgi->br($cgi->hr({-size=>"3",-width=>"300px", -align=>left}));
    &print_element(
                   $cgi,
                   $dbh,
                   'separator',
                   ' ',
                   $separator,
                   ['separator_html'],
                   []
                   );
    
    ### name (locus's associated gene)
            &print_element(
                       $cgi,
                       $dbh,
                       'name',
                       'Gene Associated with Locus',
                       qq{
                           select
                            id as gene_id,
                            name as gene_name
                           from gene
                           where id = $gene
                           },
                       ['gene_link'],
                       []
                       );

    ### fullname
         &print_element(
               $cgi,
               $dbh,
               'fullname',
               'Full Name',
               qq{
                   select fullname from gene where id = $gene
                   },
               ['fullname'],
               []
               );
   ### synonym
       &print_element(
               $cgi,
               $dbh,
               'synonym',
               'Synonym',
               qq{
                   select
                    type,
                    gene.id as gene_id,
                    gene.name as gene_name,
                    genesynonym.referenceid as reference_id
                   from genesynonym
                    inner join gene on genesynonym.name = gene.name collate latin1_bin
                   where genesynonym.geneid = $gene
                    order by genesynonym.type,gene.name
                   },
               ['type','gene_link','reference_id'],
               ['type']
               );
               
                       
   ### geneclass
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'geneclass',
   	       'Gene Class',
   	       qq{
   		   select
   		       geneclass.id as geneclass_id,
   		       geneclass.name as geneclass_name
   		       from genegeneclass
   		       inner join geneclass on genegeneclass.geneclassid = geneclass.id
   		       where genegeneclass.geneid = $gene
   		       order by geneclass.name
   		   },
   	       ['geneclass_link'],
   	       []
   	       );
   
   ### orthologousgeneset
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'orthologousgeneset',
   	       'Orthologous Gene Set',
   	       qq{
   		   select
   		       geneset.id as geneset_id,
   		       geneset.name as geneset_name
   		       from gene
   		       inner join geneset on gene.orthologousgeneset_genesetid = geneset.id
   		       where gene.id = $gene
   		   },
   	       ['geneset_link'],
   	       []
   	       );
   
   ### allele
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'allele',
   	       'Allele',
   	       qq{
   		   select
   		       allele.id as allele_id,
   		       allele.name as allele_name
   		       from allelegene
   		       inner join allele on allelegene.alleleid = allele.id
   		       where allelegene.geneid = $gene
   		       order by allele.name
   		   },
   	       ['allele_link'],
   	       []
   	       );
   
   ### pathology
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'pathology',
   	       'Pathology',
   	       qq{
   		   select
   		       pathology.id as pathology_id,
   		       pathology.name as pathology_name
   		       from genepathology
   		       inner join pathology on genepathology.pathologyid = pathology.id
   		       where genepathology.geneid = $gene
   		       order by pathology.name
   		   },
   	       ['pathology_link'],
   	       []
   	       );
   
   ### locus
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'locus',
   	       'Locus',
   	       qq{
   		   select
   		       locus.id as locus_id,
   		       locus.name as locus_name
   		       from locusassociatedgene
   		       inner join locus on locusassociatedgene.locusid = locus.id
   		       where locusassociatedgene.geneid = $gene
   		       order by locus.name
   		   },
   	       ['locus_link'],
   	       []
   	       );
   
   ### OK candidatelocus
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'candidatelocus',
   	       'Candidate Locus',
   	       qq{
   		   select
   		    locus.id as locus_id,
   		    locus.name as locus_name
     	           from genecandidatelocus
   		    inner join locus on genecandidatelocus.candidatelocus_locusid = locus.id
    	           where genecandidatelocus.geneid = $gene
   		   order by locus.name
   		   },
   	       ['locus_link'],
   	       []
   	       );
   
   ### reference
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'reference',
   	       'Reference',
   	       qq{
   		   select
   		       reference.id as reference_id
   		       from genereference
   		       inner join reference on genereference.referenceid = reference.id
   		       where genereference.geneid = $gene
   		       order by reference.year desc
   		   },
   	       ['reference_id'],
   	       []
   	       );
   
   ### url
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'url',
   	       'URL',
   	       qq{
   		   select
   		       url,
   		       description
   		       from geneurl
   		       where geneurl.geneid = $gene
   		   },
   	       ['url'],
   	       []
   	       );
   
   ### qtl
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'qtl',
   	       'QTL',
   	       qq{
   		   select
   		       qtl.id as qtl_id,
   		       qtl.name as qtl_name
   		       from qtlassociatedgene
   		       inner join qtl on qtlassociatedgene.qtlid = qtl.id
   		       where qtlassociatedgene.geneid = $gene
   		       order by qtl.name
   		   },
   	       ['qtl_link'],
   	       []
   	       );
   
   ### geneproduct
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'geneproduct',
   	       'Gene Product',
   	       qq{
   		   select
   		       geneproduct.id as geneproduct_id,
   		       geneproduct.name as geneproduct_name
   		       from genegeneproduct
   		       inner join geneproduct on genegeneproduct.geneproductid = geneproduct.id
   		       where genegeneproduct.geneid = $gene
   		       order by geneproduct.name
   		   },
   	       ['geneproduct_link'],
   	       []
   	       );
   
   ### chromosome
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'chromosome',
   	       'Chromosome',
   	       qq{
   		   select
   		       genechromosome.chromosome,
   		       reference.id as reference_id
   		       from genechromosome
   		       left join reference on genechromosome.referenceid = reference.id
   		       where genechromosome.geneid = $gene
   		       order by genechromosome.chromosome
   		   },
   	       ['chromosome','reference_id'],
   	       ['chromosome']
   	       );
   
   ### chromosomearm
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'chromosomearm',
   	       'Chromosome Arm',
   	       qq{
   		   select
   		       genechromosomearm.chromosomearm,
   		       reference.id as reference_id
   		       from genechromosomearm
   		       left join reference on genechromosomearm.referenceid = reference.id
   		       where genechromosomearm.geneid = $gene
   		       order by genechromosomearm.chromosomearm
   		   },
   	       ['chromosomearm','reference_id'],
   	       ['chromosomearm']
   	       );
   
   ### germplasm
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'germplasm',
   	       'Germplasm',
   	       qq{
   		   select
   		       genegermplasm.type,
   		       germplasm.id as germplasm_id,
   		       germplasm.name as germplasm_name,
   		       reference.id as reference_id
   		       from genegermplasm
   		       inner join germplasm on genegermplasm.germplasmid = germplasm.id
   		       left join reference on genegermplasm.referenceid = reference.id
   		       where genegermplasm.geneid = $gene
   		       order by genegermplasm.type,germplasm.name
   		   },
   	       ['type','germplasm_link','reference_id'],
   	       ###['type','germplasm_name']
   	       ['type']
   	       );
   
   ### ok origin
   &print_element(
	       $cgi,
	       $dbh,
	       'origin',
	       'Origin',
	       qq{
		   select
  	            remark as origin
		   from generemark
		   where geneid = $gene
		    and type = 'Origin'
		   },
	       ['origin'],
	       []
	       );
	       
   ### ok comment
   &print_element(
	       $cgi,
	       $dbh,
	       'comment',
	       'Comment',
	       qq{
		   select
  	            remark as comment
		   from generemark
		   where geneid = $gene
		    and type = 'Comment'
		   },
	       ['comment'],
	       []
	       );
   
   ### clone
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'clone',
   	       'Clone',
   	       qq{
   		   select
   		       probe.id as probe_id,
   		       probe.name as probe_name
   		       from geneclone
   		       inner join probe on geneclone.probeid = probe.id
   		       where geneclone.geneid = $gene
   		       order by probe.name
   		   },
   	       ['probe_link'],
   	       []
   	       );
   
   ### sequence
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'sequence',
   	       'Sequence',
   	       qq{
   		   select
   		       sequence.id as sequence_id,
   		       sequence.name as sequence_name
   		       from genesequence
   		       inner join sequence on genesequence.sequenceid = sequence.id
   		       where genesequence.geneid = $gene
   		       order by sequence.name
   		   },
   	       ['sequence_link'],
   	       []
   	       );
   
   ### image
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'image',
   	       'Image',
   	       qq{
   		   select
   		       image.id as image_id,
   		       image.name as image_name
   		       from geneimage
   		       inner join image on geneimage.imageid = image.id
   		       where geneimage.geneid = $gene
   		       order by image.name
   		   },
   	       ['image_link'],
   	       []
   	       );
   
   ### OK bgsphoto
   {
       my $sql = "select 
                   name 
                  from genebgsphoto
                  where geneid = $gene";
       my $sth = $dbh->prepare($sql); $sth->execute;
       my $name = $sth->fetchall_arrayref({});
       
       if ( $name )
       {  
         foreach my $n (@$name)
         {
#           $n->{'name'} = $cgi->escapeHTML($n->{'name'}).'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"http://ace.untamo.net/cgi-bin/ace/tree/default?name=".$n->{'name'}."&class=Image",-target=>'_blank'},'BGS Database').' ]';
           $n->{'name'} = $cgi->escapeHTML($n->{'name'}).'&nbsp;&nbsp;'.'[ '.$cgi->i($cgi->a({-href=>"http://ace.untamo.net/cgi-bin/ace/tree/default?name=".$n->{'name'}."&class=Image",-target=>'_blank'},'BGS Database')).' ]';
         } ### end foreach
         &print_element(
                      $cgi,
                      $dbh,
                      'name',
                      'BGS Photo',
                      $name,
                      ['name_html'],
                      []
                      );
   
       } ### end if
   }
   
   ### twopointdata
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'twopointdata',
   	       '2 Point Data',
   	       qq{
   		   select
   		       twopointdata.id as twopointdata_id,
   		       twopointdata.name as twopointdata_name
   		       from genetwopointdata
   		       inner join twopointdata on genetwopointdata.twopointdataid = twopointdata.id
   		       where genetwopointdata.geneid = $gene
   		       order by twopointdata.name
   		   },
   	       ['twopointdata_link'],
   	       []
   	       );
   
   ### wgcreference
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'wgcreference',
   	       'Wheat Gene Catalog Reference',
   	       qq{
   		   select
   		       reference.id as reference_id,
   		       genewgcreference.number
   		       from genewgcreference
   		       inner join reference on genewgcreference.referenceid = reference.id
   		       where genewgcreference.geneid = $gene
   		       order by reference.year desc
   		   },
   	       ['number','reference_id'],
   	       []
   	       );
   
   ### datasource
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'datasource',
   	       'Data Source',
   	       qq{
   		   select
   		       colleague.id as colleague_id,
   		       colleague.name as colleague_name,
   		       genedatasource.date
   		       from genedatasource
   		       inner join colleague on genedatasource.colleagueid = colleague.id
   		       where genedatasource.geneid = $gene
   		       order by colleague.name
   		   },
   	       ['colleague_link','date'],
   	       []
   	       );
   
   ### infosource
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'infosource',
   	       'Info Source',
   	       qq{
   		   select
   		       reference.id as reference_id
   		       from geneinfosource
   		       inner join reference on geneinfosource.referenceid = reference.id
   		       where geneinfosource.geneid = $gene
   		   },
   	       ['reference_id'],
   	       []
   	       );
   
   ### datacurator
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'datacurator',
   	       'Data Curator',
   	       qq{
   		   select
   		       colleague.id as colleague_id,
   		       colleague.name as colleague_name,
   		       genedatacurator.date
   		       from genedatacurator
   		       inner join colleague on genedatacurator.colleagueid = colleague.id
   		       where genedatacurator.geneid = $gene
   		       order by colleague.name
   		   },
   	       ['colleague_link','date'],
   	       []
   	       );
   
  } # end foreach associated gene
} # end genes associated with loci
##################### LOCUS
# OK candidategene for locus (candidategene-->to get gene report)
{
  my $genes = $dbh->selectcol_arrayref("select 
  					distinct 
  					locus.candidategene_geneid
  				       from locus 
  				        inner join marker on locus.id = marker.locusid
  				         and marker.locusid is not null
  				         and locus.candidategene_geneid is not null
  				         -- don't repeat gene report
  				         and ((marker.geneid is null) ||
					      (marker.geneid is not null) && (marker.geneid != locus.candidategene_geneid))
  				       where marker.id = $id");
  @$genes = sort @$genes;
  foreach my $gene (@$genes)
  {
    ## print gene report
    ### print separator
    my $separator = ();
    $separator->[0]->{'separator'} = $cgi->br($cgi->hr({-size=>"3",-width=>"300px", -align=>left}));
    &print_element(
                   $cgi,
                   $dbh,
                   'separator',
                   ' ',
                   $separator,
                   ['separator_html'],
                   []
                   );
    
    ### name (locus's associated gene)
            &print_element(
                       $cgi,
                       $dbh,
                       'name',
                       'Gene Candidate for Locus',
                       qq{
                           select
                            id as gene_id,
                            name as gene_name
                           from gene
                           where id = $gene
                           },
                       ['gene_link'],
                       []
                       );

    ### fullname
         &print_element(
               $cgi,
               $dbh,
               'fullname',
               'Full Name',
               qq{
                   select fullname from gene where id = $gene
                   },
               ['fullname'],
               []
               );
   ### synonym
       &print_element(
               $cgi,
               $dbh,
               'synonym',
               'Synonym',
               qq{
                   select
                    type,
                    gene.id as gene_id,
                    gene.name as gene_name,
                    genesynonym.referenceid as reference_id
                   from genesynonym
                    inner join gene on genesynonym.name = gene.name collate latin1_bin
                   where genesynonym.geneid = $gene
                    order by genesynonym.type,gene.name
                   },
               ['type','gene_link','reference_id'],
               ['type']
               );
               
                       
   ### geneclass
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'geneclass',
   	       'Gene Class',
   	       qq{
   		   select
   		       geneclass.id as geneclass_id,
   		       geneclass.name as geneclass_name
   		       from genegeneclass
   		       inner join geneclass on genegeneclass.geneclassid = geneclass.id
   		       where genegeneclass.geneid = $gene
   		       order by geneclass.name
   		   },
   	       ['geneclass_link'],
   	       []
   	       );
   
   ### orthologousgeneset
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'orthologousgeneset',
   	       'Orthologous Gene Set',
   	       qq{
   		   select
   		       geneset.id as geneset_id,
   		       geneset.name as geneset_name
   		       from gene
   		       inner join geneset on gene.orthologousgeneset_genesetid = geneset.id
   		       where gene.id = $gene
   		   },
   	       ['geneset_link'],
   	       []
   	       );
   
   ### allele
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'allele',
   	       'Allele',
   	       qq{
   		   select
   		       allele.id as allele_id,
   		       allele.name as allele_name
   		       from allelegene
   		       inner join allele on allelegene.alleleid = allele.id
   		       where allelegene.geneid = $gene
   		       order by allele.name
   		   },
   	       ['allele_link'],
   	       []
   	       );
   
   ### pathology
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'pathology',
   	       'Pathology',
   	       qq{
   		   select
   		       pathology.id as pathology_id,
   		       pathology.name as pathology_name
   		       from genepathology
   		       inner join pathology on genepathology.pathologyid = pathology.id
   		       where genepathology.geneid = $gene
   		       order by pathology.name
   		   },
   	       ['pathology_link'],
   	       []
   	       );
   
   ### locus
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'locus',
   	       'Locus',
   	       qq{
   		   select
   		       locus.id as locus_id,
   		       locus.name as locus_name
   		       from locusassociatedgene
   		       inner join locus on locusassociatedgene.locusid = locus.id
   		       where locusassociatedgene.geneid = $gene
   		       order by locus.name
   		   },
   	       ['locus_link','howmapped'],
   	       []
   	       );
   
   ### OK candidatelocus
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'candidatelocus',
   	       'Candidate Locus',
   	       qq{
   		   select
   		    locus.id as locus_id,
   		    locus.name as locus_name
     	           from genecandidatelocus
   		    inner join locus on genecandidatelocus.candidatelocus_locusid = locus.id
    	           where genecandidatelocus.geneid = $gene
   		   order by locus.name
   		   },
   	       ['locus_link'],
   	       []
   	       );
   
   ### reference
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'reference',
   	       'Reference',
   	       qq{
   		   select
   		       reference.id as reference_id
   		       from genereference
   		       inner join reference on genereference.referenceid = reference.id
   		       where genereference.geneid = $gene
   		       order by reference.year desc
   		   },
   	       ['reference_id'],
   	       []
   	       );
   
   ### url
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'url',
   	       'URL',
   	       qq{
   		   select
   		       url,
   		       description
   		       from geneurl
   		       where geneurl.geneid = $gene
   		   },
   	       ['url'],
   	       []
   	       );
   
   ### qtl
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'qtl',
   	       'QTL',
   	       qq{
   		   select
   		       qtl.id as qtl_id,
   		       qtl.name as qtl_name
   		       from qtlassociatedgene
   		       inner join qtl on qtlassociatedgene.qtlid = qtl.id
   		       where qtlassociatedgene.geneid = $gene
   		       order by qtl.name
   		   },
   	       ['qtl_link'],
   	       []
   	       );
   
   ### geneproduct
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'geneproduct',
   	       'Gene Product',
   	       qq{
   		   select
   		       geneproduct.id as geneproduct_id,
   		       geneproduct.name as geneproduct_name
   		       from genegeneproduct
   		       inner join geneproduct on genegeneproduct.geneproductid = geneproduct.id
   		       where genegeneproduct.geneid = $gene
   		       order by geneproduct.name
   		   },
   	       ['geneproduct_link'],
   	       []
   	       );
   
   ### chromosome
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'chromosome',
   	       'Chromosome',
   	       qq{
   		   select
   		       genechromosome.chromosome,
   		       reference.id as reference_id
   		       from genechromosome
   		       left join reference on genechromosome.referenceid = reference.id
   		       where genechromosome.geneid = $gene
   		       order by genechromosome.chromosome
   		   },
   	       ['chromosome','reference_id'],
   	       ['chromosome']
   	       );
   
   ### chromosomearm
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'chromosomearm',
   	       'Chromosome Arm',
   	       qq{
   		   select
   		       genechromosomearm.chromosomearm,
   		       reference.id as reference_id
   		       from genechromosomearm
   		       left join reference on genechromosomearm.referenceid = reference.id
   		       where genechromosomearm.geneid = $gene
   		       order by genechromosomearm.chromosomearm
   		   },
   	       ['chromosomearm','reference_id'],
   	       ['chromosomearm']
   	       );
   
   ### germplasm
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'germplasm',
   	       'Germplasm',
   	       qq{
   		   select
   		       genegermplasm.type,
   		       germplasm.id as germplasm_id,
   		       germplasm.name as germplasm_name,
   		       reference.id as reference_id
   		       from genegermplasm
   		       inner join germplasm on genegermplasm.germplasmid = germplasm.id
   		       left join reference on genegermplasm.referenceid = reference.id
   		       where genegermplasm.geneid = $gene
   		       order by genegermplasm.type,germplasm.name
   		   },
   	       ['type','germplasm_link','reference_id'],
   	       ###['type','germplasm_name']
   	       ['type']
   	       );
   
   ### ok origin
   &print_element(
	       $cgi,
	       $dbh,
	       'origin',
	       'Origin',
	       qq{
		   select
  	            remark as origin
		   from generemark
		   where geneid = $gene
		    and type = 'Origin'
		   },
	       ['origin'],
	       []
	       );

   ### ok comment
   &print_element(
	       $cgi,
	       $dbh,
	       'comment',
	       'Comment',
	       qq{
		   select
  	            remark as comment
		   from generemark
		   where geneid = $gene
		    and type = 'Comment'
		   },
	       ['comment'],
	       []
	       );
   
   ### clone
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'clone',
   	       'Clone',
   	       qq{
   		   select
   		       probe.id as probe_id,
   		       probe.name as probe_name
   		       from geneclone
   		       inner join probe on geneclone.probeid = probe.id
   		       where geneclone.geneid = $gene
   		       order by probe.name
   		   },
   	       ['probe_link'],
   	       []
   	       );
   
   ### sequence
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'sequence',
   	       'Sequence',
   	       qq{
   		   select
   		       sequence.id as sequence_id,
   		       sequence.name as sequence_name
   		       from genesequence
   		       inner join sequence on genesequence.sequenceid = sequence.id
   		       where genesequence.geneid = $gene
   		       order by sequence.name
   		   },
   	       ['sequence_link'],
   	       []
   	       );
   
   ### image
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'image',
   	       'Image',
   	       qq{
   		   select
   		       image.id as image_id,
   		       image.name as image_name
   		       from geneimage
   		       inner join image on geneimage.imageid = image.id
   		       where geneimage.geneid = $gene
   		       order by image.name
   		   },
   	       ['image_link'],
   	       []
   	       );
   
   ### OK bgsphoto
   {
       my $sql = "select 
                   name 
                  from genebgsphoto
                  where geneid = $gene";
       my $sth = $dbh->prepare($sql); $sth->execute;
       my $name = $sth->fetchall_arrayref({});
       
       if ( $name )
       {  
         foreach my $n (@$name)
         {
#           $n->{'name'} = $cgi->escapeHTML($n->{'name'}).'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"http://ace.untamo.net/cgi-bin/ace/tree/default?name=".$n->{'name'}."&class=Image",-target=>'_blank'},'BGS Database').' ]';
           $n->{'name'} = $cgi->escapeHTML($n->{'name'}).'&nbsp;&nbsp;'.'[ '.$cgi->i($cgi->a({-href=>"http://ace.untamo.net/cgi-bin/ace/tree/default?name=".$n->{'name'}."&class=Image",-target=>'_blank'},'BGS Database')).' ]';
         } ### end foreach
         &print_element(
                      $cgi,
                      $dbh,
                      'name',
                      'BGS Photo',
                      $name,
                      ['name_html'],
                      []
                      );
   
       } ### end if
   }
   
   ### twopointdata
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'twopointdata',
   	       '2 Point Data',
   	       qq{
   		   select
   		       twopointdata.id as twopointdata_id,
   		       twopointdata.name as twopointdata_name
   		       from genetwopointdata
   		       inner join twopointdata on genetwopointdata.twopointdataid = twopointdata.id
   		       where genetwopointdata.geneid = $gene
   		       order by twopointdata.name
   		   },
   	       ['twopointdata_link'],
   	       []
   	       );
   
   ### wgcreference
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'wgcreference',
   	       'Wheat Gene Catalog Reference',
   	       qq{
   		   select
   		       reference.id as reference_id,
   		       genewgcreference.number
   		       from genewgcreference
   		       inner join reference on genewgcreference.referenceid = reference.id
   		       where genewgcreference.geneid = $gene
   		       order by reference.year desc
   		   },
   	       ['number','reference_id'],
   	       []
   	       );
   
   ### datasource
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'datasource',
   	       'Data Source',
   	       qq{
   		   select
   		       colleague.id as colleague_id,
   		       colleague.name as colleague_name,
   		       genedatasource.date
   		       from genedatasource
   		       inner join colleague on genedatasource.colleagueid = colleague.id
   		       where genedatasource.geneid = $gene
   		       order by colleague.name
   		   },
   	       ['colleague_link','date'],
   	       []
   	       );
   
   ### infosource
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'infosource',
   	       'Info Source',
   	       qq{
   		   select
   		       reference.id as reference_id
   		       from geneinfosource
   		       inner join reference on geneinfosource.referenceid = reference.id
   		       where geneinfosource.geneid = $gene
   		   },
   	       ['reference_id'],
   	       []
   	       );
   
   ### datacurator
   &print_element(
   	       $cgi,
   	       $dbh,
   	       'datacurator',
   	       'Data Curator',
   	       qq{
   		   select
   		       colleague.id as colleague_id,
   		       colleague.name as colleague_name,
   		       genedatacurator.date
   		       from genedatacurator
   		       inner join colleague on genedatacurator.colleagueid = colleague.id
   		       where genedatacurator.geneid = $gene
   		       order by colleague.name
   		   },
   	       ['colleague_link','date'],
   	       []
   	       );
   
  } # end foreach
} # end candidategene for locus (to get gene report)
#####################
# add space between sections if there's a LOCUS section (and a PROBE section)
{
  my $sql = "select locusid from marker where id = $id and locusid is not null and probeid is not null";
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $separator = $sth->fetchall_arrayref({});

  if ($separator->[0]->{'locusid'})
  {
    $separator->[0]->{'separator'} = $cgi->br($cgi->hr({-size=>"3",-width=>"500px", -align=>left}));
    #$separator->[0]->{'separator'} = $cgi->p('&nbsp;');
    #$separator->[0]->{'separator'} = $cgi->p($cgi->hr({-size=>"3",-width=>"500px", -align=>left}));
    delete($separator->[0]->{'locusid'});
    
    &print_element(
                   $cgi,
                   $dbh,
                   'separator',
                   ' ',
                   $separator,
                   ['separator_html'],
                   []
                   );
  } # end if
}

##################### PROBE
## PROBE subreport
my $probemarkerid = $dbh->selectrow_array("select probeid from marker where id = $id");
if ($probemarkerid)
{
  # OK name (probe)
  &print_element(
	       $cgi,
	       $dbh,
	       'name',
	       'Probe',
	       qq{
		   select 
                    probe.id as probe_id,
                    probe.name as probe_name
                   from probe
                   where probe.id = $probemarkerid
		   },
	       ['probe_link'],
	       []
	       );

  # OK locus (probe)
  &print_element(
               $cgi,
               $dbh,
               'locus',
               'Locus',
               qq{
                   select distinct
                    locus.id as locus_id,
                    locus.name as locus_name
                   from locus
                    inner join locusprobe on locus.id = locusprobe.locusid
                   where locusprobe.probeid = $probemarkerid
                 },
               ['locus_link'],
               []
               );

  # okay othername/referenceid (probe)
  &print_element(
               $cgi,
               $dbh,
               'synonym',
               'Synonym',
               qq{
                   select
                    probesynonym.type,
                    probe.id as probe_id,
                    probe.name as probe_name,
                    probesynonym.referenceid as reference_id
                   from probe 
                    inner join probesynonym on probe.name = probesynonym.name
                   where probesynonym.probeid = $probemarkerid
                    order by probesynonym.type, probe.name
                   },
               ['type','probe_link','reference_id'],
               ['type']
               );


  # okay relatedprobe (probe)
  &print_element(
               $cgi,
               $dbh,
               'relatedprobe',
               'Related Probe',
               qq{
                   select
                    probe.id as probe_id,
                    probe.name as probe_name
                   from probe
                    inner join proberelatedprobe 
                     on proberelatedprobe.relatedprobe_probeid = probe.id
                   where proberelatedprobe.probeid = $probemarkerid
                   },
               ['probe_link'],
               []
               );

  # okay note about relatedprobe (unable to pass successfully in same call to sub & show distinct) (probe)
  &print_element(
               $cgi,
               $dbh,
               'relatedprobenote',
               ' ',
               qq{
                   select
                    distinct concat(help.name,": ") as name,
                    #distinct 
                    helpremark.remark
                   from help
                    inner join helpremark on help.id = helpremark.helpid
                    inner join proberelatedprobe on helpremark.helpid = proberelatedprobe.helpid
                   where proberelatedprobe.probeid = $probemarkerid
                   },
               ['name','remark'],
               []
               );

  # okay similarprobes (probe)
  &print_element(
               $cgi,
               $dbh,
               'similarprobes',
               'Similar Probes',
               qq{
                   select
                    probe.id as probe_id,
                    probe.name as probe_name
                   from probe
                    inner join probecluster 
                     on probecluster.name = probe.name
                   where probecluster.probeid = $probemarkerid
                   },
               ['probe_link'],
               []
               );

  # okay. see comments on probe report: externaldb (probe)
  {
    my $sql = qq{
               select
                probeexternaldb.accession
               from probeexternaldb
               where probeexternaldb.probeid = $probemarkerid
               and name = 'Sequence'
              };
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $extdb = $sth->fetchall_arrayref({});
    if ($extdb->[0]->{'accession'})
    {
      $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://getentry.ddbj.nig.ac.jp/cgi-bin/get_entry.pl?".$extdb->[0]->
{'accession'},-target=>'_blank'},'DDBJ');
      $extdb->[1]->{'extdb'} = $cgi->a({href=>"http://srs.ebi.ac.uk/srs6bin/cgi-bin/wgetz?-e+[embl-acc:".$extdb->[
0]->{'accession'}."]",-target=>'_blank'},'EMBL');
      $extdb->[2]->{'extdb'} = $cgi->a({href=>"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Search&db=Nucleot
ide&doptcmdl=GenBank&term=".$extdb->[0]->{'accession'},-target=>'_blank'},'GenBank');
      delete($extdb->[0]->{'accession'});
  
      &print_element(
               $cgi,
               $dbh,
               'externaldb',
               'External Databases',
               $extdb,
               ['extdb_html'],
               []
               );
    } 
  }               

  # OK externaldb (Germinate) (probe)
  {
    my $sql = qq{
		 select
		  accession
		 from probeexternaldb
		 where probeexternaldb.probeid = $probemarkerid
		 and name = 'BarleySNP'
		};
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $extdb = $sth->fetchall_arrayref({});
    if ($extdb->[0]->{'accession'})
    {
      $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://germinate.scri.ac.uk/cgi-bin/barley_snpdb/display_contig.cgi?contig=".$extdb->[0]->{'accession'},-target=>'_blank'},$extdb->[0]->{'accession'});
      delete($extdb->[0]->{'accession'});
      &print_element(
		 $cgi,
		 $dbh,
		 'externaldb',
		 'Data at Germinate',
		 $extdb,
		 ['extdb_html'],
		 []
		 );
    } 
  }

  # OK externaldb (PLEXdb) (probe)
  {
    my $sql = qq{
		 select
		  accession
		 from probeexternaldb
		 where probeexternaldb.probeid = $probemarkerid
		 and name = 'PlantGDB'
		};
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $extdb = $sth->fetchall_arrayref({});
    if ($extdb->[0]->{'accession'})
    {
      $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://www.plexdb.org/modules.php?name=PD_probeset&page=annotation.php&genechip=Barley&exemplar=".$extdb->[0]->{'accession'},-target=>'_blank'},$extdb->[0]->{'accession'});
      delete($extdb->[0]->{'accession'});
      &print_element(
		 $cgi,
		 $dbh,
		 'externaldb',
		 'Data at PLEXdb',
		 $extdb,
		 ['extdb_html'],
		 []
		 );
    } 
  }


  # okay reference (probe)
        &print_element(
               $cgi,
               $dbh,
               'reference',
               'Reference',
               qq{
                   select
                    reference.id as reference_id
                   from probereference
                    inner join reference on probereference.referenceid = reference.id
                   where probereference.probeid = $probemarkerid
                    order by reference.year desc
                   },
               ['reference_id'],
               []
               );    

  # OK remark (probe)
        &print_element(
               $cgi,
               $dbh,
               'generalremark',
               'Remarks',
               qq{
                   select
                    remark as generalremark
                   from proberemark
                   where probeid = $probemarkerid
                    and type = 'General_remark'

                   },
               ['generalremark'],
               []
               );

  # OK type (probe)
  &print_element(
               $cgi,
               $dbh,
               'type',
               'Type',
               qq{
                   select
                    type
                   from probetype
                   where probeid = $probemarkerid
                   },
               ['type'],
               []
               );

  # OK pcrprimers (complete pair) (probe)
  &print_element(
               $cgi,
               $dbh,
               'pcrprimers',
               'PCR primers',
               qq{
                   select
                    concat(primeronesequence,"<br>",primertwosequence) as pair
                   from probeprimer
                   where probeid = $probemarkerid
                    and type = 'PCR_primers'
                    and primertwosequence is not null
                   },
               ['pair_html'],
               []
               );

  # OK pcrprimers (just one sequence) (probe)          
  &print_element(
               $cgi,
               $dbh,
               'pcrprimers',
               'PCR primers',
               qq{
                   select
                    primeronesequence
                   from probeprimer
                   where probeid = $probemarkerid
                    and type = 'PCR_primers'
                    and primertwosequence is null
                   },
               ['primeronesequence'],
               []
               );                              

  # OK aflpprimers (complete pair) (probe)
  &print_element(
               $cgi,
               $dbh,
               'aflpprimers',
               'AFLP primers',
               qq{
                   select
                    concat(primeronesequence,"<br>",primertwosequence) as pair
                   from probeprimer
                   where probeid = $probemarkerid
                    and type = 'AFLP_primers'
                    and primertwosequence is not null
                   },
               ['pair_html'],
               []
               );
               
  # OK aflpprimers (just one sequence) (probe)
  &print_element(
               $cgi,
               $dbh,
               'aflpprimers',
               'AFLP primers',
               qq{
                   select
                    primeronesequence
                   from probeprimer
                   where probeid = $probemarkerid
                    and type = 'AFLP_primers'
                    and primertwosequence is null
                   },
               ['primeronesequence'],
               []
               );

  # okay stsprimers (pair) (probe)
  &print_element(
               $cgi,
               $dbh,
               'stsprimers',
               'STS primers',
               qq{
                   select
                    concat(primeronesequence,"<br>",primertwosequence) as pair
                   from probeprimer
                   where probeid = $probemarkerid
                    and type = 'STS_primers'
                   },
               ['pair_html'],
               []
               );

  # okay stssize (can't use special remark code because PCR_size further down in report) (probe)
  &print_element(
               $cgi,
               $dbh,
               'stssize',
               'STS size',
               qq{
                   select
                    distinct size
                   from probeprimer
                   where probeid = $probemarkerid
                    and sizetype = 'STS_size'
                   },
               ['size'],
               []
               );

  # okay ssrsize (probe)
  &print_element(
               $cgi,
               $dbh,
               'ssrsize',
               'SSR size',
               qq{
                   select
                    distinct size
                   from probeprimer
                   where probeid = $probemarkerid
                    and sizetype = 'SSR_size'
                   },
               ['size'],
               []
               );

  # okay amplificationconditions (probe)
        &print_element(
               $cgi,
               $dbh,
               'amplificationconditions',
               'Amplification Conditions',
               qq{
                   select
                    distinct ampconditions as amplificationconditions
                   from probeprimer
                   where probeid = $probemarkerid
                   },
               ['amplificationconditions'],
               []
               );     
               
  # okay specificity (probe)
        &print_element(
               $cgi,
               $dbh,
               'specificity',
               'Specificity',
               qq{
                   select
                    remark as specificity
                   from proberemark
                   where probeid = $probemarkerid
                    and type = 'Specificity'
                   },
               ['specificity'],
               []
               );     

  # okay sequence (probe)
  &print_element(
               $cgi,
               $dbh,
               'sequence',
               'Sequence',
               qq{
                  select
                   sequence.id as sequence_id,
                   sequence.name as sequence_name
                  from sequence
                   inner join sequenceprobe on sequence.id = sequenceprobe.sequenceid
                  where sequenceprobe.probeid = $probemarkerid
                   },
               ['sequence_link'],
               []
               );

  # okay copynumber (probe)
        &print_element(
               $cgi,
               $dbh,
               'copynumber',
               'Copy Number',
               qq{
                   select
                    remark as copynumber
                   from proberemark
                   where probeid = $probemarkerid
                    and type = 'Copy_number'
                   },
               ['copynumber'],
               []
               );     

  # okay background (probe)
        &print_element(
               $cgi,
               $dbh,
               'background',
               'Background',
               qq{
                   select
                    remark as background
                   from proberemark
                   where probeid = $probemarkerid
                    and type = 'Background'
                   },
               ['background'],
               []
               );     

  # okay wheatpolymorphism link (probe)
        &print_element(
               $cgi,
               $dbh,
               'wheatpolymorphism',
               'Degree of Polymorphism',
               qq{
                   select
                    restrictionenzyme.id as restrictionenzyme_id,
                    restrictionenzyme.name as restrictionenzyme_name,
                    probewheatpolymorphism.polymorphism
                   from restrictionenzyme
                    inner join probewheatpolymorphism on restrictionenzyme.id = probewheatpolymorphism.restrictionenzymeid
                   where probewheatpolymorphism.probeid = $probemarkerid
                   },
               ['restrictionenzyme_link','polymorphism'],
               []
               );

  # okay crosshybridizesto (probe)
        &print_element(
               $cgi,
               $dbh,
               'crosshybridizesto',
               'Cross hybridizes to',
               qq{
                   select
                    species.id as species_id,
                    species.name as species_name,
                    probehybridizesto.quality
                   from species
                    inner join probehybridizesto on species.id = probehybridizesto.speciesid
                   where probehybridizesto.probeid = $probemarkerid
                   },
               ['species_link','quality'],
               []
               );    

  # OK polymorphism (probe)
	&print_element(
	       $cgi,
	       $dbh,
	       'polymorphism',
	       'Polymorphism',
	       qq{
		   select
                    polymorphism.id as polymorphism_id,
                    polymorphism.name as polymorphism_name,
                    probepolymorphism.summaryscore
                   from polymorphism
                    inner join probepolymorphism on polymorphism.id = probepolymorphism.polymorphismid
                   where probepolymorphism.probeid = $probemarkerid
		   },
	       ['polymorphism_link','summaryscore'],
	       []
	       );    	   

  # okay gel (probe)
        &print_element(
               $cgi,
               $dbh,
               'gel',
               'Gel',
               qq{
                   select
                    gel.id as gel_id,
                    gel.name as gel_name
                   from gel
                    inner join probe on gel.id = probe.gelid
                   where probe.id = $probemarkerid
                   },
               ['gel_link'],
               []
               );    

  # okay linkagegroup (probe)
        &print_element(
               $cgi,
               $dbh,
               'linkagegroup',
               'Linkage Group',
               qq{
                   select
                    remark as linkagegroup
                   from proberemark
                   where probeid = $probemarkerid
                    and type = 'Linkage_Group'
                   },
               ['linkagegroup'],
               []
               );  

  # okay dnalibrary (probe)
        &print_element(
               $cgi,
               $dbh,
               'dnalibrary',
               'DNA Library',
               qq{
                   select
                    library.id as library_id,
                    library.name as library_name
                   from library
                    inner join probe on library.id = probe.dnalibrary_libraryid
                   where probe.id = $probemarkerid
                   },
               ['library_link'],
               []
               );    

  # okay insertenzyme (probe)
        &print_element(
               $cgi,
               $dbh,
               'insertenzyme',
               'Insert Enzyme',
               qq{
                   select
                    restrictionenzyme.id as restrictionenzyme_id,
                    restrictionenzyme.name as restrictionenzyme_name
                   from restrictionenzyme
                    inner join probeinsertenzyme on restrictionenzyme.id = probeinsertenzyme.restrictionenzymeid
                   where probeinsertenzyme.probeid = $probemarkerid
                   },
               ['restrictionenzyme_link'],
               []
               ); 
	       
  # okay sourcegeneclass (probe)
  &print_element(
               $cgi,
               $dbh,
               'sourcegeneclass',
               'Source Gene Class',
               qq{
                  select
                   geneclass.id as geneclass_id,
                   geneclass.name as geneclass_name
                  from geneclass
                   inner join geneclassclone on geneclass.id = geneclassclone.geneclassid
                   inner join probe on geneclassclone.probeid = probe.id
                  where probe.id = $probemarkerid
                   },
               ['geneclass_link'],
               []
               );

  # okay sourcegene (probe)
  &print_element(
               $cgi,
               $dbh,
               'sourcegene',
               'Source Gene',
               qq{
                  select
                   gene.id as gene_id,
                   gene.name as gene_name
                  from gene
                   inner join geneclone on gene.id = geneclone.geneid
                   inner join probe on geneclone.probeid = probe.id
                  where probe.id = $probemarkerid
                   },
               ['gene_link'],
               []
               );

  # okay sourceallele (probe)
  &print_element(
               $cgi,
               $dbh,
               'sourceallele',
               'Source Allele',
               qq{
                  select
                   allele.id as allele_id,
                   allele.name as allele_name
                  from allele
                   inner join allelegene on allele.id = allelegene.alleleid
                   inner join geneclone on allelegene.geneid = geneclone.geneid
                   inner join probe on geneclone.probeid = probe.id
                  where probe.id = $probemarkerid
                   },
               ['allele_link'],
               []
               );

  # okay sourcespecies (probe)
        &print_element(
               $cgi,
               $dbh,
               'sourcespecies',
               'Source Species',
               qq{
                   select
                    species.id as species_id,
                    species.name as species_name
                   from species
                    inner join probesourcespecies on species.id = probesourcespecies.speciesid
                   where probesourcespecies.probeid = $probemarkerid
                   },
               ['species_link'],
               []
               );    

  # okay sourcegermplasm (probe)
        &print_element(
               $cgi,
               $dbh,
               'sourcegermplasm',
               'Source Germplasm',
               qq{
                   select
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from germplasm
                    inner join probe on germplasm.id = probe.sourcegermplasm_germplasmid
                   where probe.id = $probemarkerid
                   },
               ['germplasm_link'],
               []
               );    

  # okay sourcetissue (probe)
        &print_element(
               $cgi,
               $dbh,
               'sourcetissue',
               'Source Tissue',
               qq{
                   select
                    remark as sourcetissue
                   from proberemark
                   where probeid = $probemarkerid
                    and type = 'Source_tissue'
                   },
               ['sourcetissue'],
               []
               );     
               
  # okay dnaorigin (probe)
        &print_element(
               $cgi,
               $dbh,
               'dnaorigin',
               'DNA Origin',
               qq{
                   select
                    remark as dnaorigin
                   from proberemark
                   where probeid = $probemarkerid
                    and type = 'DNA_Origin'
                   },
               ['dnaorigin'],
               []
               );  

  # okay insertsize (probe)
        &print_element(
               $cgi,
               $dbh,
               'insertsize',
               'Insert Size',
               qq{
                   select
                    insertsize
                   from probeinsertsize
                   where probeid = $probemarkerid
                   },
               ['insertsize'],
               []
               );  

  # okay pcrsize (probe)
  &print_element(
               $cgi,
               $dbh,
               'pcrsize',
               'PCR size',
               qq{
                   select
                    size
                   from probeprimer
                   where probeid = $probemarkerid
                    and sizetype = 'PCR_size'
                   },
               ['size'],
               []
               );


  # OK vector (probe)
  &print_element(
               $cgi,
               $dbh,
               'vector',
               'Clone Vector',
               qq{
                   select
                    vector
                   from probevector
                   where probeid = $probemarkerid
                   },
               ['vector'],
               []
               );

  # okay vectorenzyme (probe)
        &print_element(
               $cgi,
               $dbh,
               'vectorenzyme',
               'Vector Enzyme',
               qq{
                   select
                    restrictionenzyme.id as restrictionenzyme_id,
                    restrictionenzyme.name as restrictionenzyme_name
                   from restrictionenzyme
                    inner join probe on restrictionenzyme.id = probe.vectorenzyme_restrictionenzymeid
                   where probe.id = $probemarkerid
                   },
               ['restrictionenzyme_link'],
               []
               );    

  # OK excisionenzyme (probe)
	&print_element(
	       $cgi,
	       $dbh,
	       'excisionenzyme',
	       'Excision Enzyme',
	       qq{
		   select
                    restrictionenzyme.id as restrictionenzyme_id,
                    restrictionenzyme.name as restrictionenzyme_name
                   from restrictionenzyme
                    inner join probeexcisionenzyme on restrictionenzyme.id = probeexcisionenzyme.restrictionenzymeid
                   where probeexcisionenzyme.probeid = $probemarkerid
		   },
	       ['restrictionenzyme_link'],
	       []
	       );    

  # okay vectorpcrprimers (probe)
  &print_element(
               $cgi,
               $dbh,
               'vectorpcrprimers',
               'Vector PCR primers',
               qq{
                   select
                    vectorpcrprimers
                   from probevectorpcrprimers
                   where probeid = $probemarkerid
                   },
               ['vectorpcrprimers'],
               []
               );

  # okay vectoramplification (probe)
  &print_element(
               $cgi,
               $dbh,
               'vectoramplification',
               'Vector Amplification',
               qq{
                   select
                    vectoramplification
                   from probe
                   where id = $probemarkerid
                   },
               ['vectoramplification'],
               []
               );

  # okay bacterialstrain (probe)
  &print_element(
               $cgi,
               $dbh,
               'bacterialstrain',
               'Bacterial Strain',
               qq{
                   select
                    bacterialstrain
                   from probe
                   where id = $probemarkerid
                   },
               ['bacterialstrain'],
               []
               );

  # okay antibiotic (probe)
  &print_element(
               $cgi,
               $dbh,
               'antibiotic',
               'Antibiotic',
               qq{
                   select
                    antibiotic
                   from probe
                   where id = $probemarkerid
                   },
               ['antibiotic'],
               []
               );

  # okay subclonedin (based on subcloneof) (probe)
        &print_element(
               $cgi,
               $dbh,
               'subclonein',
               'Subcloned in',
               qq{
                   select
                    b.id as probe_id,
                    b.name as probe_name
                   from probe as a
                    inner join probe as b on a.id = b.subcloneof_probeid
                   where a.id = $probemarkerid
                   },
               ['probe_link'],
               []
               );   

  # okay subcloneof (probe)
        &print_element(
               $cgi,
               $dbh,
               'subcloneof',
               'Subclone of',
               qq{
                   select
                    a.id as probe_id,
                    a.name as probe_name
                   from probe as a
                    inner join probe as b on a.id = b.subcloneof_probeid
                   where b.id = $probemarkerid
                   },
               ['probe_link'],
               []
               );   


  # OK clonelocation (probe)
	&print_element(
	       $cgi,
	       $dbh,
	       'clonelocation',
	       'Clone Location',
	       qq{
		   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name
                   from colleague
                    inner join probelocation on colleague.id = probelocation.colleagueid
                   where probelocation.probeid = $probemarkerid
		   },
	       ['colleague_link'],
	       []
	       );  

  # okay authority (probe)
        &print_element(
               $cgi,
               $dbh,
               'authority',
               'Clone Authority',
               qq{
                   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name
                   from colleague
                    inner join probeauthority on colleague.id = probeauthority.colleagueid
                   where probeauthority.probeid = $probemarkerid
                   },
               ['colleague_link'],
               []
               );  

  # OK image (probe)
	&print_element(
	       $cgi,
	       $dbh,
	       'image',
	       'Image',
	       qq{
		   select
		    image.id as image_id,
    		    image.name as image_name
		   from probeimage 
		    inner join image on probeimage.imageid = image.id
		   where probeimage.probeid = $probemarkerid
		   },
	       ['image_link'],
	       []
	       ); 

  # OK datasource (probe)
  &print_element(
               $cgi,
               $dbh,
               'datasource',
               'Data Source',
               qq{
                   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name,
                    probedatasource.date
                   from probedatasource 
                    inner join colleague on colleague.id = probedatasource.colleagueid
                   where probedatasource.probeid = $probemarkerid
                   },
               ['colleague_link','date'],
               []
               );

  # OK infosource (probe)
	&print_element(
	       $cgi,
	       $dbh,
	       'informationsource',
	       'Info Source',
	       qq{
		   select
		    reference.id as reference_id
		   from probeinfosource
		    inner join reference on probeinfosource.referenceid = reference.id
		   where probeinfosource.probeid = $probemarkerid
		   },
	       ['reference_id'],
	       []
	       );    

  # okay note (longtext from preformattext table) (probe)
  {
    my $sql = qq{
                   select
                    preformattext.preformattext as note
                   from preformattext
                    inner join probenote on preformattext.id = probenote.preformattextid
                   where probenote.probeid = $probemarkerid
                   };
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $note = $sth->fetchall_arrayref({});
    foreach my $n (@$note) {
        $n->{'note'} = $cgi->pre($cgi->escapeHTML($n->{'note'}));
    }                
    &print_element(
               $cgi,
               $dbh,
               'note',
               'Note',
               $note,
               ['note_html'],
               []
               );              
  } # end note
} # end PROBE subreport (if $probemarkerid)
############# PROBE
# OK loci linked to probe (locusprobe->locus report)
{
  my $loci = $dbh->selectcol_arrayref("select 
  					distinct 
  					locusprobe.locusid
  				       from locusprobe 
  				        inner join marker on locusprobe.probeid = marker.probeid
  				         and marker.probeid is not null
  				         and locusprobe.locusid is not null
  				         -- don't repeat locus report  
					 and ((marker.locusid is null) ||
					      (marker.locusid is not null) && (marker.locusid != locusprobe.locusid))
  				        where marker.id = $id");
  @$loci = sort @$loci;
  foreach my $locus (@$loci)
  {
    ## print locus report
    ### print separator
    my $separator = ();
    $separator->[0]->{'separator'} = $cgi->br($cgi->hr({-size=>"3",-width=>"300px", -align=>left}));
    &print_element(
                   $cgi,
                   $dbh,
                   'separator',
                   ' ',
                   $separator,
                   ['separator_html'],
                   []
                   );
    
    ### name (probe's locus)
            &print_element(
                   $cgi,
                   $dbh,
                   'name',
                   'Locus for Probe',
                   qq{
                       select
                        id as locus_id,
                        name as locus_name 
                       from locus
                       where id = $locus
                     },
                   ['locus_link'],
                   []
                   );

    ### type
            &print_element(
                   $cgi,
                   $dbh,
                   'type',
                  'Type',
                  qq{
                     select type from locustype where locusid = $locus order by type
                   },
                  ['type'],
                  []
                  );
                       
    ### synonym
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
                   where locussynonym.locusid = $locus
                    order by locussynonym.type,locus.name
		   },
	       ['type','locus_link','reference_id'],
	       ['type']
	       );

    ### chromosome
    &print_element(
	       $cgi,
	       $dbh,
	       'chromosome',
	       'Chromosome',
	       qq{
		   select
		       chromosome
		       from locuschromosome
		       where locusid = $locus
		       order by chromosome
		   },
	       ['chromosome'],
	       []
	       );

    ### chromosomearm
    &print_element(
	       $cgi,
	       $dbh,
	       'chromosomearm',
	       'Chromosome Arm',
	       qq{
		   select
		       chromosomearm
		       from locuschromosomearm
		       where locusid = $locus
		       order by chromosomearm
		   },
	       ['chromosomearm'],
	       []
	       );


    ### map (2)
    {
        my $sql = qq{
		   select distinct
		       map.id as map_id,
		       map.name as map_name,
		       maplocus.begin as begin
		       from maplocus
		       inner join map on maplocus.mapid = map.id
		       where maplocus.locusid = $locus
		       order by map.name
                 };
        my $sth = $dbh->prepare($sql); $sth->execute;
        my $map = $sth->fetchall_arrayref({});
        foreach my $mp (@$map) {
	    ### see if this map exists in cmap before making it a link
#
	    my ($cmapname) = $dbh->selectrow_array(sprintf("select map_name from cmap_map where map_name = %s",$dbh->quote($mp->{'map_name'})));
#
	    if ($cmapname) {
	        ###$mp->{'map'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map;id=$mp->{'map_id'};locusid=$locus"},$mp->{'map_name'});
	        $mp->{'map'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map;locusid=$locus;name=".&geturlstring($mp->{'map_name'}),-target=>'_blank'},$mp->{'map_name'});
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

    ### nearbyloci
    {
        my $sql = "select 
    	        distinct
                name
               from locus
                inner join maplocus on locus.id = maplocus.locusid
               where locus.id = $locus";
        my $sth = $dbh->prepare($sql); $sth->execute;
        my $locus = $sth->fetchall_arrayref({});
        $locus->[0]->{'locus'} = $cgi->i($cgi->big('[ ')).$cgi->a({-href=>"$cgiurlpath/quickquery.cgi?query=nearbyloci&arg1=".$locus->[0]->{'name'}."&arg2=10",-target=>'_blank'},$cgi->i($cgi->big('Show Nearby Loci'))).$cgi->i($cgi->big(' ]'));

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

    ### inqtl
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
		       where qtlsignificantmarker.locusid = $locus
		       order by qtl.name
		   },
	       ['qtl_link'],
	       []
	       );

    ### rearrangement
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
		       where locusinsegment.locusid = $locus
		       order by locusinsegment.type
		   },
	       ['type','rearrangement_link'],
	       ['type']
	       );

    ### breakpointinterval
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
		       where locusininterval.locusid = $locus
		   },
	       ['breakpointinterval_link'],
	       []
	       );

    ### mapdata (and gbrowser link)
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
	         where locus.id = $locus
	         order by mapdata.name,mapdatalocus.howmapped};

     my $sth = $dbh->prepare($sql); $sth->execute;
     my $data = $sth->fetchall_arrayref({});

     if ( $data )
     {
      foreach my $m (@$data)
      {
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
         $m->{'data'}.'&nbsp;&nbsp;'.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=probe&name=".&geturlstring($m->{'probe_name'})},$m->{'probe_name'});
         delete($m->{'probe_id'});
         delete($m->{'probe_name'});
       }

       if ( $m->{'gene_id'} )   
       {
         $m->{'data'} =
         $m->{'data'}.'&nbsp;&nbsp;'.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=gene&name=".&geturlstring($m->{'gene_name'})},$m->{'gene_name'});
         delete($m->{'gene_id'});
         delete($m->{'gene_name'});
       }
     
       # add gbrowse link
       # No such loci: WheatPhysicalESTMaps if map is "Chinese_Spring_Deletion_*" mapdata "Wheat, Physical, EST"
       # OK GrainMaps if map is "Ta-Synthetic/Opata-1A" mapdata "Wheat, Synthetic x Opata"
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
     } # end if $data
    } # end mapdata

    ### twopointdata
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
		       where locustwopointdata.locusid = $locus
		       order by twopointdata.name
		   },
	       ['twopointdata_link'],
	       []
	       );

    ### species
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
		       where locusspecies.locusid = $locus
		       order by species.name
		   },
	       ['species_link'],
	       []
	       );

    ### probe
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
		       where locusprobe.locusid = $locus
		       order by probe.name
		   },
	       ['probe_link','reference_id'],
	       []
	       );

    ### linkedqtl 
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
		        ###inner join qtl on locus.id = qtl.nearestmarker_locusid
		       where locus.id = $locus
		   },
	       ['qtl_link'],
	       []
	       );

    ### associatedgene
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
		       where locusassociatedgene.locusid = $locus
		       order by gene.name
		   },
	       ['gene_link'],
	       []
	       );

    ### candidategene
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
		       where locus.id = $locus
		   },
	       ['gene_link'],
	       []
	       );

    ### OK homology
    &print_element(
	       $cgi,
	       $dbh,
	       'homology',
	       'Homology',
	       qq{
		   select distinct 
		    protein.id as protein_id,
		    protein.name as protein_name,
		    concat("e-value: ",sequence.bestpepevalue) as evalue,
		    protein.title
		   from locus
		    inner join locusprobe on locus.id = locusprobe.locusid
		    inner join sequenceprobe on locusprobe.probeid = sequenceprobe.probeid
		    inner join sequence on sequenceprobe.sequenceid = sequence.id
		    inner join protein on sequence.bestpep_proteinid = protein.id
   	           where locus.id = $locus
		   },
	       ['protein_link','evalue','title'],
	       []
	       );
	       
    ### geneclass
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
		       where locusassociatedgene.locusid = $locus
		       order by geneclass.name
		   },
	       ['geneclass_link'],
	       []
	       );

    ### image
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
		       where locusimage.locusid = $locus
		       order by image.name
		   },
	       ['image_link'],
	       []
	       );

    ### OK bgsphoto
    {
        my $sql = "select 
                    name 
                   from locusbgsphoto
                   where locusid = $locus";
        my $sth = $dbh->prepare($sql); $sth->execute;
        my $name = $sth->fetchall_arrayref({});
    
        if ($name)
        {
          foreach my $n (@$name)
          {
#            $n->{'name'} = $cgi->escapeHTML($n->{'name'}).'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"http://ace.untamo.net/cgi-bin/ace/tree/default?name=".$n->{'name'}."&class=Image",-target=>'_blank'},'BGS Database').' ]';
            $n->{'name'} = $cgi->escapeHTML($n->{'name'}).'&nbsp;&nbsp;'.'[ '.$cgi->i($cgi->a({-href=>"http://ace.untamo.net/cgi-bin/ace/tree/default?name=".$n->{'name'}."&class=Image",-target=>'_blank'},'BGS Database')).' ]';
          } ### end foreach      
      
          &print_element(
                   $cgi,
                   $dbh,
                   'name',
                   'BGS Photo',
                   $name,
                   ['name_html'],
                   []
                   );
        } ### end if
    }

    ### reference
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
		       where locusreference.locusid = $locus
		       order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );

    ### datasource
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
		       where locusdatasource.locusid = $locus
		       order by colleague.name
		   },
	       ['colleague_link','date'],
	       []
	       );

    ### remark (27Sep2004, NL, to hyperlink untamo.net URLs) 
    {
       my $sql = "select remark from locusremark where locusid = $locus";
       my $sth = $dbh->prepare($sql); $sth->execute;
       my $remark = $sth->fetchall_arrayref({});

       foreach my $rem (@$remark) 
       {
         if ( $rem->{'remark'} =~ /^(.*)(http\S+)\s*(.*)$/is )
         {
           $rem->{'remark'} = $1.$cgi->a({-href=>$2,-target=>'_blank'},$2).$3;
         } ### else do nothing with string        
       } ### end foreach

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

    ### possibleorthologs
    &print_element(
	       $cgi,
	       $dbh,
	       'possibleorthologs',
	       'Possible Orthologs',
	       qq{
		   select
		       a.id as locus_id,
		       a.name as locus_name
		       from locus as a
		       inner join locus as b on a.locusorthologygroupid = b.locusorthologygroupid and a.locusorthologygroupid is not null
		       where a.id != b.id and b.id = $locus
		   },
	       ['locus_link'],
	       []
	       );
      } # end foreach
    } # end "loci linked to probe"

######## END

1;
