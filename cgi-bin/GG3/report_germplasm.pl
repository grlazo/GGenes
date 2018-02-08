#!/usr/bin/perl

# DDH 040408
# NL 13Aug2004 to fix synonym -- s/b 'type' only in $squeeze
# NL 16Aug2004 to fix gene/geneproduct -- use genegermplasm/geneproductgermplasm tables
# NL 20Aug2004 to add GRIN accession link to collection_and_id
# NL 04Oct2004 to italicize GRIN link
# NL 29Oct2004 to break germplasmremark(10 and germplasmspecies(3) out to accommodate comment.cgi's need for explicit labels
# NL 23Dec2004 to add germplasmpolymorphism

# print germplasm report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# name
&print_element(
	       $cgi,
	       $dbh,
	       'name',
	       'Germplasm',
	       qq{
		   select name from germplasm where id = $id
		   },
	       ['name'],
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
                    germplasmsynonym.type,
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from germplasmsynonym
                    inner join germplasm on germplasmsynonym.name = germplasm.name collate latin1_bin
                   where germplasmsynonym.germplasmid = $id
                    order by germplasmsynonym.type,germplasm.name
		   },
	       ['type','germplasm_link'],
	       #['type','germplasm_link']
	       ['type']
	       );

# species - removed 29Oct2004 NL and replaced with individual calls for Donor_species, Species, Subspecies
# print separate elements for each type
# use type as element and label
#{
#    my $types = $dbh->selectcol_arrayref("select distinct type from germplasmspecies where germplasmid = $id order by type");
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
#				       species.id as species_id,
#				       species.name as species_name
#				       from germplasmspecies
#				       inner join species on germplasmspecies.speciesid = species.id
#				       where germplasmspecies.germplasmid = %s and germplasmspecies.type = %s
#				       order by species.name
#				  },$id,$dbh->quote($type)
#			       ),
#		       ['species_link'],
#		       []
#		       );
#    }
#}

# ok species
&print_element(
	       $cgi,
	       $dbh,
	       'species',
	       'Species',
	       qq{
		   select
		    species.id as species_id,
		    species.name as species_name
		   from germplasmspecies
		    inner join species on germplasmspecies.speciesid = species.id
		   where germplasmspecies.germplasmid = $id
		    and germplasmspecies.type = 'Species'
    	 	   order by species.name		   
    	 	 },
	       ['species_link'],
	       []
	       );

# ok subspecies
&print_element(
	       $cgi,
	       $dbh,
	       'subspecies',
	       'Subspecies',
	       qq{
		   select
		    species.id as species_id,
		    species.name as species_name
		   from germplasmspecies
		    inner join species on germplasmspecies.speciesid = species.id
		   where germplasmspecies.germplasmid = $id
		    and germplasmspecies.type = 'Subspecies'
    	 	   order by species.name		   
    	 	 },
	       ['species_link'],
	       []
	       );

# ok donorspecies
&print_element(
	       $cgi,
	       $dbh,
	       'donorspecies',
	       'Donor Species',
	       qq{
		   select
		    species.id as species_id,
		    species.name as species_name
		   from germplasmspecies
		    inner join species on germplasmspecies.speciesid = species.id
		   where germplasmspecies.germplasmid = $id
		    and germplasmspecies.type = 'Donor_species'
    	 	   order by species.name		   
    	 	 },
	       ['species_link'],
	       []
	       );

# type
&print_element(
	       $cgi,
	       $dbh,
	       'type',
	       'Type',
	       qq{
		   select type from germplasmtype where germplasmid = $id order by type
		   },
	       ['type'],
	       []
	       );

# primarycollection
&print_element(
	       $cgi,
	       $dbh,
	       'primarycollection',
	       'Primary Collection',
	       qq{
		   select
		   collection.id as collection_id,
		   collection.name as collection_name
		   from germplasm
		   inner join collection on germplasm.primarycollection_collectionid = collection.id
		   where germplasm.id = $id
		   },
	       ['collection_link'],
	       []
	       );

# OK collection (w/o GRIN)
&print_element(
	       $cgi,
	       $dbh,
	       'collection',
	       'Collection',
	       qq{
		   select
		   collection.id as collection_id,
		   collection.name as collection_name,
		   germplasm.id as germplasm_id,
		   germplasm.name as germplasm_name
		   from germplasmcollection
		   inner join collection on germplasmcollection.collectionid = collection.id
		     -- not GRIN / Barley
		     and collection.name != 'USDA/ARS/NSGC'
		     and collection.name != 'BGC Okayama'
		     and collection.name != 'NSGC BCC'
		   left join germplasm on germplasmcollection.collectiongermplasm_germplasmid = germplasm.id
		   where germplasmcollection.germplasmid = $id
		   order by collection.name,germplasm.name
		   },
	       ['collection_link','germplasm_link'],
	       []
	       );

# collection (USDA/ARS/NSGC)
#{
#  my $sql = qq{
#		   select
#		    germplasm.name as germplasm_name
#		   from germplasmcollection
#		    inner join collection on germplasmcollection.collectionid = collection.id
#		     and collection.name = 'USDA/ARS/NSGC'
#		    left join germplasm on germplasmcollection.collectiongermplasm_germplasmid = germplasm.id
#		   where germplasmcollection.germplasmid = $id
#             };		   
#  my $sth = $dbh->prepare($sql); $sth->execute;
#  my $germplasm = $sth->fetchall_arrayref({});
#  my $gp = $germplasm->[0]->{'germplasm_name'};
#  # add space between prefix and number
#  $gp =~ s/([a-zA-Z]+)([0-9]+)/$1 $2/;
#  delete($germplasm->[0]->{'germplasm_name'});

#&print_element(
#	       $cgi,
#	       $dbh,
#	       'collection',
#	       'Collection',
#	       qq{
#		   select
#		    collection.id as collection_id,
#		    collection.name as collection_name,
#		    germplasm.id as germplasm_id,
#		    germplasm.name as germplasm_name,
#		    concat("http://www.ars-grin.gov/cgi-bin/npgs/html/acc_search.pl?accid=","$gp","&inactive=Yes") as url,
#		    "Data at GRIN" as description
#		   from germplasmcollection
#		    inner join collection on germplasmcollection.collectionid = collection.id
#		     and collection.name = 'USDA/ARS/NSGC'
#		    left join germplasm on germplasmcollection.collectiongermplasm_germplasmid = germplasm.id
#		   where germplasmcollection.germplasmid = $id
#		   order by collection.name,germplasm.name
#		   },
#	       ['collection_link','germplasm_link','url'],
#	       []
#	       );
#}

# OK collection (USDA/ARS/NSGC or NSGC BCC)
{
  my $sql = qq{
		   select
		    collection.id as collection_id,
		    collection.name as collection_name,
		    germplasm.id as germplasm_id,
		    germplasm.name as germplasm_name
		   from germplasmcollection
		    inner join collection on germplasmcollection.collectionid = collection.id
		     and (collection.name = 'USDA/ARS/NSGC' or collection.name = 'NSGC BCC')
		    left join germplasm on germplasmcollection.collectiongermplasm_germplasmid = germplasm.id
		   where germplasmcollection.germplasmid = $id
		   order by collection.name,germplasm.name
              };

  my $sth = $dbh->prepare($sql); $sth->execute;
  my $collection = $sth->fetchall_arrayref({});

  my $grin_acc = $collection->[0]->{'germplasm_name'};
  # add space between prefix and number
  $grin_acc =~ s/([a-zA-Z]+)([0-9]+)/$1 $2/;

  $collection->[0]->{'collection'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=collection&name=".&geturlstring($collection->[0]->{'collection_name'})},$collection->[0]->{'collection_name'});
  delete($collection->[0]->{'collection_name'});
  $collection->[0]->{'collection'} = 
    $collection->[0]->{'collection'}.'&nbsp;&nbsp;'.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=germplasm&name=".&geturlstring($collection->[0]->{'germplasm_name'})},$collection->[0]->{'germplasm_name'});
  delete($collection->[0]->{'germplasm_id'});
  delete($collection->[0]->{'germplasm_name'});
  $collection->[0]->{'collection'}  =
    #$collection->[0]->{'collection'}.'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"http://www.ars-grin.gov/cgi-bin/npgs/html/acc_search.pl?accid="."$grin_acc"."&inactive=Yes",-target=>'_blank'},'Data at GRIN').' ]';
    $collection->[0]->{'collection'}.'&nbsp;&nbsp;'.'[ '.$cgi->i($cgi->a({-href=>"http://www.ars-grin.gov/cgi-bin/npgs/html/acc_search.pl?accid="."$grin_acc"."&inactive=Yes",-target=>'_blank'},'Data at GRIN')).' ]';

  if ( $collection->[0]->{'collection_id'} )
  {
    delete($collection->[0]->{'collection_id'});
    
    &print_element(
	       $cgi,
	       $dbh,
	       'collection',
	       'Collection',
	       $collection,
	       ['collection_html'],
	       []
	       );
  }	    
}

# OK collection (BGC Okayama)
{
  my $sql = qq{
		   select
  		    collection.id as collection_id,
		    collection.name as collection_name,
		    germplasm.id as germplasm_id,
		    germplasm.name as germplasm_name
		   from germplasmcollection
		    inner join collection on germplasmcollection.collectionid = collection.id
		     and collection.name = 'BGC Okayama'
		    left join germplasm on germplasmcollection.collectiongermplasm_germplasmid = germplasm.id
		   where germplasmcollection.germplasmid = $id
		   order by collection.name,germplasm.name
              };		   

  my $sth = $dbh->prepare($sql); $sth->execute;
  my $collection = $sth->fetchall_arrayref({});

  $collection->[0]->{'collection'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=collection&name=".&geturlstring($collection->[0]->{'collection_name'})},$collection->[0]->{'collection_name'});
  delete($collection->[0]->{'collection_name'});
  $collection->[0]->{'collection'} = 
    $collection->[0]->{'collection'}.'&nbsp;&nbsp;'.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=germplasm&name=".&geturlstring($collection->[0]->{'germplasm_name'})},$collection->[0]->{'germplasm_name'});
  delete($collection->[0]->{'germplasm_id'});
  $collection->[0]->{'collection'}  =
    $collection->[0]->{'collection'}.'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"http://www.shigen.nig.ac.jp/cgi-bin/barley/barley3.pl?rec=".$collection->[0]->{'germplasm_name'},-target=>'_blank'},'Data at Barley Database').' ]';
  delete($collection->[0]->{'germplasm_name'});

  if ( $collection->[0]->{'collection_id'} )
  {
    delete($collection->[0]->{'collection_id'});
    
    &print_element(
	       $cgi,
	       $dbh,
	       'collection',
	       'Collection',
	       $collection,
	       ['collection_html'],
	       []
	       );
  }	       
}

# OK collection (BGC Okayama)
#&print_element(
#	       $cgi,
#	       $dbh,
#	       'collection',
#	       'Collection',
#	       qq{
#		   select
#		    collection.id as collection_id,
#		    collection.name as collection_name,
#		    germplasm.id as germplasm_id,
#		    germplasm.name as germplasm_name,
#		    concat("http://www.shigen.nig.ac.jp/cgi-bin/barley/barley3.pl?rec=",germplasm.name) as url,
#		    "Data at Barley Database" as description
#		   from germplasmcollection
#		    inner join collection on germplasmcollection.collectionid = collection.id
#		     and collection.name = 'BGC Okayama'
#		    left join germplasm on germplasmcollection.collectiongermplasm_germplasmid = germplasm.id
#		   where germplasmcollection.germplasmid = $id
#		   order by collection.name,germplasm.name
#		   },
#	       ['collection_link','germplasm_link','url'],
#	       []
#	       );

# crossnumber
&print_element(
	       $cgi,
	       $dbh,
	       'crossnumber',
	       'Cross Number',
	       qq{
		   select crossnumber from germplasm where id = $id
		   },
	       ['crossnumber'],
	       []
	       );

# chromosomeconfiguration
&print_element(
	       $cgi,
	       $dbh,
	       'chromosomeconfiguration',
	       'Chromosome Configuration',
	       qq{
		   select chromosomeconfiguration from germplasm where id = $id
		   },
	       ['chromosomeconfiguration'],
	       []
	       );

# breakpoint
&print_element(
	       $cgi,
	       $dbh,
	       'breakpoint',
	       'Breakpoint',
	       qq{
		   select
		   breakpoint.id as breakpoint_id,
		   breakpoint.name as breakpoint_name
		   from germplasmbreakpoint
		   inner join breakpoint on germplasmbreakpoint.breakpointid = breakpoint.id
		   where germplasmbreakpoint.germplasmid = $id
		   order by breakpoint.name
		   },
	       ['breakpoint_link'],
	       []
	       );

# remark - NL 29Oct2004 replaced with ten individual calls dep. on germplasmremark type to accommodate comment.cgi
# print separate elements for each type
# use type as element and label
#{
#    my $types = $dbh->selectcol_arrayref("select distinct type from germplasmremark where germplasmid = $id order by type");
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
#				       from germplasmremark
#				       where germplasmid = %s and type = %s
#				  },$id,$dbh->quote($type)
#			       ),
#		       ['remark'],
#		       []
#		       );
#    }
#}

# ok pairingconfiguration
&print_element(
	       $cgi,
	       $dbh,
	       'pairingconfiguration',
	       'Pairing Configuration',
	       qq{
  		   select
  		    remark as pairingconfiguration
		   from germplasmremark
		   where germplasmid = $id
		    and type = 'Pairing_configuration'
		 },
	       ['pairingconfiguration'],
	       []
	       );	

# chromosomenumber
&print_element(
	       $cgi,
	       $dbh,
	       'chromosomenumber',
	       'Chromosome Number',
	       qq{
		   select chromosomenumber from germplasm where id = $id
		   },
	       ['chromosomenumber'],
	       []
	       );
	       
# ok pedigree
&print_element(
	       $cgi,
	       $dbh,
	       'pedigree',
	       'Pedigree',
	       qq{
  		   select
  		    remark as pedigree
		   from germplasmremark
		   where germplasmid = $id
		    and type = 'Pedigree'
		 },
	       ['pedigree'],
	       []
	       );		       

# selectionhistory
&print_element(
	       $cgi,
	       $dbh,
	       'selectionhistory',
	       'Selection History',
	       qq{
		   select
		   sh.id as germplasm_id,
		   sh.name as germplasm_name
		   from germplasm
		   inner join germplasm as sh on germplasm.selectionhistory_germplasmid = sh.id
		   where germplasm.id = $id
		   },
	       ['germplasm_link'],
	       []
	       );

# ok marketclass
&print_element(
	       $cgi,
	       $dbh,
	       'marketclass',
	       'Market Class',
	       qq{
  		   select
  		    remark as marketclass
		   from germplasmremark
		   where germplasmid = $id
		    and type = 'Market_class'
		 },
	       ['marketclass'],
	       []
	       );	
	       
# ok characteristic
&print_element(
	       $cgi,
	       $dbh,
	       'characteristic',
	       'Characteristic',
	       qq{
  		   select
  		    remark as characteristic
		   from germplasmremark
		   where germplasmid = $id
		    and type = 'Characteristic'
		 },
	       ['characteristic'],
	       []
	       );

# pathology
&print_element(
	       $cgi,
	       $dbh,
	       'pathology',
	       'Pathology',
	       qq{
		   select
		       pathology.id as pathology_id,
		       pathology.name as pathology_name
		       from germplasmpathology
		       inner join pathology on germplasmpathology.pathologyid = pathology.id
		       where germplasmpathology.germplasmid = $id
		       order by pathology.name
		   },
	       ['pathology_link'],
	       []
	       );

# allele
&print_element(
	       $cgi,
	       $dbh,
	       'allele',
	       'Allele',
	       qq{
		   select distinct
		       allele.id as allele_id,
		       allele.name as allele_name
		       from allelegermplasm
		       inner join allele on allelegermplasm.alleleid = allele.id
		       where allelegermplasm.germplasmid = $id
		       order by allele.name
		   },
	       ['allele_link'],
	       []
	       );

# gene
&print_element(
	       $cgi,
	       $dbh,
	       'gene',
	       'Gene',
	       qq{
		   select distinct
		       gene.id as gene_id,
		       gene.name as gene_name
                      from genegermplasm
                       inner join gene on genegermplasm.geneid = gene.id 
                      where genegermplasm.germplasmid = $id 
	#	       from allelegermplasm
	#	       inner join allelegene on allelegermplasm.alleleid = allelegene.alleleid
	#	       inner join gene on allelegene.geneid = gene.id
	#	       where allelegermplasm.germplasmid = $id
		       order by gene.name
		   },
	       ['gene_link'],
	       []
	       );

# geneproduct
&print_element(
	       $cgi,
	       $dbh,
	       'geneproduct',
	       'Gene Product',
	       qq{
		   select distinct
		       geneproduct.id as geneproduct_id,
		       geneproduct.name as geneproduct_name
		       from geneproduct
		       inner join geneproductgermplasm on geneproduct.id = geneproductgermplasm.geneproductid
		       where geneproductgermplasm.germplasmid = $id
		       order by geneproduct.name
		   },
	       ['geneproduct_link'],
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
		       rearrangement.id as rearrangement_id,
		       rearrangement.name as rearrangement_name
		       from germplasmrearrangement
		       inner join rearrangement on germplasmrearrangement.rearrangementid = rearrangement.id
		       where germplasmrearrangement.germplasmid = $id
		       order by rearrangement.name
		   },
	       ['rearrangement_link'],
	       []
	       );

# derivedfrom
&print_element(
	       $cgi,
	       $dbh,
	       'derivedfrom',
	       'Derived From',
	       qq{
		   select
		   df.id as germplasm_id,
		   df.name as germplasm_name
		   from germplasm
		   inner join germplasm as df on germplasm.derivedfrom_germplasmid = df.id
		   where germplasm.id = $id
		   },
	       ['germplasm_link'],
	       []
	       );

# chromosomedonor
&print_element(
	       $cgi,
	       $dbh,
	       'chromosomedonor',
	       'Chromosome Donor',
	       qq{
		   select chromosomedonor from germplasm where id = $id
		   },
	       ['chromosomedonor'],
	       []
	       );

# cytoplasm
&print_element(
	       $cgi,
	       $dbh,
	       'cytoplasm',
	       'Cytoplasm',
	       qq{
		   select cytoplasm from germplasm where id = $id
		   },
	       ['cytoplasm'],
	       []
	       );

# ok developedby
&print_element(
	       $cgi,
	       $dbh,
	       'developedby',
	       'Developed by',
	       qq{
  		   select
  		    remark as developedby
		   from germplasmremark
		   where germplasmid = $id
		    and type = 'Developed_by'
		 },
	       ['developedby'],
	       []
	       );

# ok developmentsite
&print_element(
	       $cgi,
	       $dbh,
	       'developmentsite',
	       'Development Site',
	       qq{
  		   select
  		    remark as developmentsite
		   from germplasmremark
		   where germplasmid = $id
		    and type = 'Development_site'
		 },
	       ['developmentsite'],
	       []
	       );	       	       
# ok collectionsite
&print_element(
	       $cgi,
	       $dbh,
	       'collectionsite',
	       'Collection Site',
	       qq{
  		   select
  		    remark as collectionsite
		   from germplasmremark
		   where germplasmid = $id
		    and type = 'Collection_site'
		 },
	       ['collectionsite'],
	       []
	       );

# ok datecollected
&print_element(
	       $cgi,
	       $dbh,
	       'datecollected',
	       'Date Collected',
	       qq{
  		   select
  		    remark as datecollected
		   from germplasmremark
		   where germplasmid = $id
		    and type = 'Date_collected'
		 },
	       ['datecollected'],
	       []
	       );

# ok dateofrelease
&print_element(
	       $cgi,
	       $dbh,
	       'dateofrelease',
	       'Date of Release',
	       qq{
  		   select
  		    remark as dateofrelease
		   from germplasmremark
		   where germplasmid = $id
		    and type = 'Date_of_release'
		 },
	       ['dateofrelease'],
	       []
	       );
	       
# registrationnumber
&print_element(
	       $cgi,
	       $dbh,
	       'registrationnumber',
	       'Registration Number',
	       qq{
		   select registrationnumber from germplasm where id = $id
		   },
	       ['registrationnumber'],
	       []
	       );

# ok remark
&print_element(
	       $cgi,
	       $dbh,
	       'remark',
	       'Remark',
	       qq{
  		   select
  		    remark
		   from germplasmremark
		   where germplasmid = $id
		    and type = 'Remark'
		 },
	       ['remark'],
	       []
	       );
	       
# OK polymorphism
{
    # get polymorphismid
    my $sql = "select
                distinct 
                polymorphismid 
               from germplasmpolymorphism
               where germplasmid = $id";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $polymorphism = $sth->fetchall_arrayref({});
    
    # get present-bandsizes and absent-bandsizes
    if ($polymorphism)
    {
      foreach my $p (@$polymorphism)	
      {
        # get polymorphism name
        my ($polyname) = $dbh->selectrow_array(sprintf("select name 
                                                        from polymorphism
                                                        where id = %s",$p->{'polymorphismid'}));

        # start output string
        $p->{'polymorphism'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=polymorphism;name=".&geturlstring($polyname)},$polyname);
        
        # present bands
        my $sql = sprintf(qq{
                             select
                              presence,
                              bandsize 
                             from germplasmpolymorphism
                             where germplasmid = $id
                              and polymorphismid = %s
                              and presence = 'Present'
                            },$p->{'polymorphismid'}
                         );
        my $sth = $dbh->prepare($sql); $sth->execute;
        my $present = $sth->fetchall_arrayref({});
        
        if ($present->[0]->{'presence'}) 	# some polymorphisms without this data
        {
          $p->{'polymorphism'} .= '<br>Present:';
        }
        
        foreach my $b (@$present)
        {
          $p->{'polymorphism'} .= '&nbsp;&nbsp;'.$cgi->escapeHTML($b->{'bandsize'});
          delete($b->{'bandsize'});
        } # end foreach $b present
        
	# absent bands
        my $sql = sprintf(qq{select
                              presence,
                              bandsize 
                             from germplasmpolymorphism
                             where germplasmid = $id
                              and polymorphismid = %s
                              and presence = 'Absent'
                            },$p->{'polymorphismid'}
                         );
        my $sth = $dbh->prepare($sql); $sth->execute;
        my $absent = $sth->fetchall_arrayref({});

        if ($absent->[0]->{'presence'}) 
        {
          $p->{'polymorphism'} .= '<br>Absent:';
        }

        foreach my $b (@$absent)
        {
	  $p->{'polymorphism'} .= '&nbsp;&nbsp;'.$cgi->escapeHTML($b->{'bandsize'});
          delete($b->{'bandsize'});
        } # end foreach $b absent   
        delete($p->{'polymorphismid'});
      } # end foreach $p

      &print_element(
                   $cgi,
                   $dbh,
                   'polymorphism',
                   'Polymorphism',
                   $polymorphism,
                   ['polymorphism_html'],
                   []
                   );
    } # end if polymorphismid
} # end polymorphism

# OK traitdescription
{
    # get traitstudyid
    my $sql = "select
                distinct 
                germplasmtraitdescription.traitstudyid as traitstudy_id,
                traitstudy.name as traitstudy_name
               from germplasmtraitdescription
                inner join traitstudy on germplasmtraitdescription.traitstudyid = traitstudy.id
               where germplasmid = $id
                order by traitstudy.name";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $traitdescription = $sth->fetchall_arrayref({});
    
    if ($traitdescription)
    {
      foreach my $t (@$traitdescription)	
      { 
        $t->{'traitdescription'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=traitstudy;name=".&geturlstring($t->{'traitstudy_name'})},$t->{'traitstudy_name'});
        
        my $sql = sprintf(qq{
                             select 
                              score,
                              interpretation
                             from germplasmtraitdescription
                             where germplasmid = $id
                              and traitstudyid = %s
                            },$t->{'traitstudy_id'}
                         );
        my $sth = $dbh->prepare($sql); $sth->execute;
        my $value = $sth->fetchall_arrayref({});
        
	if ($value)
        { 
          foreach my $v (@$value)
          {
            $t->{'traitdescription'} .= '<br>'.$cgi->escapeHTML($v->{'score'}).'&nbsp;&nbsp;&nbsp;'.$cgi->escapeHTML($v->{'interpretation'});
            delete($v->{'score'});
            delete($v->{'interpretation'});
          } # end foreach trait value
        } # end if value
        delete($t->{'traitstudy_id'});
        delete($t->{'traitstudy_name'});
      } # end foreach traitdescription
          &print_element(
                   $cgi,
                   $dbh,
                   'traitdescription',
                   'Trait Description',
                   $traitdescription,
                   ['traitdescription_html'],
                   []
                   );
    } # end if traitdescription
} # end traitdescription 

# OK traitscore
&print_element(
	       $cgi,
	       $dbh,
	       'traitscore',
	       'Trait Score',
	       qq{
		   select
		    traitstudy.id as traitstudy_id,
		    traitstudy.name as traitstudy_name,
		    germplasmtraitscore.score,
		    germplasmtraitscore.units
		   from germplasmtraitscore
 	            inner join traitstudy on germplasmtraitscore.traitstudyid = traitstudy.id
		   where germplasmtraitscore.germplasmid = $id
		       order by traitstudy.name
		   },
	       ['traitstudy_link','score','units'],
	       []
	       );
	       
# reference
&print_element(
	       $cgi,
	       $dbh,
	       'reference',
	       'Reference',
	       qq{
		   select
		       reference.id as reference_id
		       from germplasmreference
		       inner join reference on germplasmreference.referenceid = reference.id
		       where germplasmreference.germplasmid = $id
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
		       germplasmdatasource.date
		       from germplasmdatasource
		       inner join colleague on germplasmdatasource.colleagueid = colleague.id
		       where germplasmdatasource.germplasmid = $id
		       order by colleague.name
		   },
	       ['colleague_link','date'],
	       []
	       );

# datacurator
&print_element(
	       $cgi,
	       $dbh,
	       'datacurator',
	       'Data Curator',
	       qq{
		   select
		       colleague.id as colleague_id,
		       colleague.name as colleague_name,
		       germplasmdatacurator.date
		       from germplasmdatacurator
		       inner join colleague on germplasmdatacurator.colleagueid = colleague.id
		       where germplasmdatacurator.germplasmid = $id
		       order by colleague.name
		   },
	       ['colleague_link','date'],
	       []
	       );

# mapdata
&print_element(
	       $cgi,
	       $dbh,
	       'mapdata',
	       'Map Data',
	       qq{
		   select
		       mapdata.id as mapdata_id,
		       mapdata.name as mapdata_name
		       from germplasmmapdata
		       inner join mapdata on germplasmmapdata.mapdataid = mapdata.id
		       where germplasmmapdata.germplasmid = $id
		       order by mapdata.name
		   },
	       ['mapdata_link'],
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
		       from germplasmqtl
		       inner join qtl on germplasmqtl.qtlid = qtl.id
		       where germplasmqtl.germplasmid = $id
		       order by qtl.name
		   },
	       ['qtl_link'],
	       []
	       );

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
		       from germplasmtwopointdata
		       inner join twopointdata on germplasmtwopointdata.twopointdataid = twopointdata.id
		       where germplasmtwopointdata.germplasmid = $id
		       order by twopointdata.name
		   },
	       ['twopointdata_link'],
	       []
	       );

# library
&print_element(
	       $cgi,
	       $dbh,
	       'library',
	       'Library',
	       qq{
		   select
		       library.id as library_id,
		       library.name as library_name
		       from germplasmlibrary
		       inner join library on germplasmlibrary.libraryid = library.id
		       where germplasmlibrary.germplasmid = $id
		       order by library.name
		   },
	       ['library_link'],
	       []
	       );

# traitstudy
&print_element(
	       $cgi,
	       $dbh,
	       'traitstudy',
	       'Trait Study',
	       qq{
		   select
		       traitstudy.id as traitstudy_id,
		       traitstudy.name as traitstudy_name
		       from germplasmtraitstudy
		       inner join traitstudy on germplasmtraitstudy.traitstudyid = traitstudy.id
		       where germplasmtraitstudy.germplasmid = $id
		       order by traitstudy.name
		   },
	       ['traitstudy_link'],
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
		       from germplasmimage
		       inner join image on germplasmimage.imageid = image.id
		       where germplasmimage.germplasmid = $id
		       order by image.name
		   },
	       ['image_link'],
	       []
	       );

# OK traitscores
&print_element(
	       $cgi,
	       $dbh,
	       'traitscore',
	       'Trait Scores',
	       qq{
		   select
		    traitscore.id as traitscore_id,
		    traitscore.name as traitscore_name
		   from germplasmtraitscores
 	            inner join traitscore on germplasmtraitscores.traitscoreid = traitscore.id
		   where germplasmtraitscores.germplasmid = $id
		       order by traitscore.name
		   },
	       ['traitscore_link'],
	       []
	       );	       

1;
