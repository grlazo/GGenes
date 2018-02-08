#!/usr/bin/perl

# NLui, 27Oct2004
# REMEMBER to update report_marker.pl when any changes made to report_probe.pl

# print probe report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# ok name
#&print_element(
#	       $cgi,
#	       $dbh,
#	       'probe',
#	       'Probe',
#	       qq{
#		   select name 
#		   from probe 
#		   where id = $id
#		   },
#	       ['name'],
#	       []
#	       );

{
    my $sql = "select 
                name as marker_name
               from marker
               where probeid = $id";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $probe = $sth->fetchall_arrayref({});


    if ( $probe->[0]->{'marker_name'})
    {
#      $probe->[0]->{'probe'} = $cgi->escapeHTML($probe->[0]->{'marker_name'}).'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=marker&name=".$probe->[0]->{'marker_name'},-target=>'_blank'},'Marker Report').' ]';
      $probe->[0]->{'probe'} = $cgi->escapeHTML($probe->[0]->{'marker_name'}).'&nbsp;&nbsp;'.'[ '.$cgi->i($cgi->a({-href=>"$cgiurlpath/report.cgi?class=marker&name=".&geturlstring($probe->[0]->{'marker_name'}),-target=>'_blank'},'Marker Report')).' ]';
      delete($probe->[0]->{'marker_name'});
      &print_element(
                   $cgi,
                   $dbh,
                   'name',
                   'Probe',
                   $probe,
                   ['probe_html'],
                   []
                   );
    }
    else   # not in marker table -- just print the probe name w/o Marker Report link
    {
      &print_element(
                   $cgi,
                   $dbh,
                   'name',
                   'Probe',
  	          qq{
		   select name from probe where id = $id
		   },                   
                   ['name'],
                   []
                   );
    } # end if 
}

# ok locus
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
                   where locusprobe.probeid = $id
                    #unnec: order by locus.name
                   },
               ['locus_link'],
               []
               );

# ok synonym (othername, pleasesee, synonym)
# ?  synonym (no instances of probe with a "synonym")
# ok othername (but longer-named alias split in half when there's a referenceid)
# ok pleasesee
# ok referenceid
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
                   where probesynonym.probeid = $id
                    order by probesynonym.type,probe.name
                   },
               ['type','probe_link','reference_id'],
               ['type']
               );

# ok relatedprobe
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
                   where proberelatedprobe.probeid = $id
                    #order by probe_name
                   },
               ['probe_link'],
               []
               );
               
# ok note about relatedprobe (unable to pass successfully in same call to sub & show distinct)
#unnec{
#unnec    my $sql = "select 
#unnec                helpremark.remark
#unnec               from help
#unnec                inner join helpremark on help.id = helpremark.helpid
#unnec                inner join proberelatedprobe on helpremark.helpid = proberelatedprobe.helpid
#unnec               where proberelatedprobe.probeid = $id";
#unnec    my $sth = $dbh->prepare($sql); $sth->execute;
#unnec    my $help = $sth->fetchall_arrayref({});
   
#unnec  if ( $help->[0]->{'remark'} )
#unnec  {
#unnec    delete($help->[0]->{'remark'});
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
                   where proberelatedprobe.probeid = $id
                   },
               ['name','remark'],
               []
               );
#unnec  }               
#unnec}
               
# ok similarprobes
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
                   where probecluster.probeid = $id
                    #unnec: order by probe_name
                   },
               ['probe_link'],
               []
               );

# rerun probeexternaldb LATER (DaveM) - HYPERLINKS being added -- externaldb 
#  data still bad 4/19/04; 4/21: pages 1, 8-9 of 10 still bad
# ok/but see comments above: externaldb
# dem 27feb06: ok externaldb Sequence (ddbj,embl,genbank) 
{
  my $sql = qq{
               select
                accession
               from probeexternaldb
               where probeid = $id
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

# OK externaldb (Germinate)
{
  my $sql = qq{
               select
                accession
               from probeexternaldb
               where probeid = $id
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

# OK externaldb (PLEXdb)
{
  my $sql = qq{
               select
                accession
               from probeexternaldb
               where probeid = $id
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

# externaldb (Wheat_SNP)
{
    my $sql = qq{
               select
                accession
               from probeexternaldb
               where probeid = $id
                and name = 'Wheat_SNP'
	    };
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $extdb = $sth->fetchall_arrayref({});
    if ($extdb->[0]->{'accession'})
    {
	$extdb->[0]->{'extdb'} = $cgi->a({href=>"http://probes.pw.usda.gov:8080/snpworld/Search",-target=>'_blank'},$extdb->[0]->{'accession'});
#	$extdb->[0]->{'extdb'} = $cgi->a({href=>"http://probes.pw.usda.gov:8080/snpworld/Search",-target=>'_blank'},"Wheat_SNP");
	delete($extdb->[0]->{'accession'});
    &print_element(
               $cgi,
               $dbh,
               'externaldb',
               'Data at Wheat_SNP',
               $extdb,
               ['extdb_html'],
               []
		   );
    }
}


# ok reference
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
		   where probereference.probeid = $id
		    order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );    

# ok generalremark (can't use special remark code because types spread thruout report)
	&print_element(
	       $cgi,
	       $dbh,
	       'generalremark',
	       'General Remarks',
	       qq{
		   select
                    remark as generalremark
                   from proberemark
                   where probeid = $id
                    and type = 'General_remark'
		   },
	       ['generalremark'],
	       []
	       );

# ok type
&print_element(
               $cgi,
               $dbh,
               'type',
               'Type',
               qq{
                   select
                    type
                   from probetype
                   where probeid = $id
                   },
               ['type'],
               []
               );

# ok pcrprimers (complete pair)
&print_element(
               $cgi,
               $dbh,
               'pcrprimers',
               'PCR primers',
               qq{
                   select
                    concat(primeronesequence,"<br>",primertwosequence) as pair
                   from probeprimer
                   where probeid = $id
                    and type = 'PCR_primers'
                    and primertwosequence is not null
                   },
               ['pair_html'],
               []
               );

# ok pcrprimers (just one sequence)              
&print_element(
               $cgi,
               $dbh,
               'pcrprimers',
               'PCR primers',
               qq{
                   select
                    primeronesequence
                   from probeprimer
                   where probeid = $id
                    and type = 'PCR_primers'
                    and primertwosequence is null
                   },
               ['primeronesequence'],
               []
               );                              
             
# ok aflpprimers (complete pair)
&print_element(
               $cgi,
               $dbh,
               'aflpprimers',
               'AFLP primers',
               qq{
                   select
                    concat(primeronesequence,"<br>",primertwosequence) as pair
                   from probeprimer
                   where probeid = $id
                    and type = 'AFLP_primers'
                    and primertwosequence is not null
                   },
               ['pair_html'],
               []
               );
               
# ok aflpprimers (just one sequence)
&print_element(
               $cgi,
               $dbh,
               'aflpprimers',
               'AFLP primers',
               qq{
                   select
                    primeronesequence
                   from probeprimer
                   where probeid = $id
                    and type = 'AFLP_primers'
                    and primertwosequence is null
                   },
               ['primeronesequence'],
               []
               );
               
# ok stsprimers (pair)
&print_element(
               $cgi,
               $dbh,
               'stsprimers',
               'STS primers',
               qq{
                   select
                    concat(primeronesequence,"<br>",primertwosequence) as pair
                   from probeprimer
                   where probeid = $id
                    and type = 'STS_primers'
                   },
               ['pair_html'],
               []
               );
               

# ok stssize (can't use special remark code because PCR_size further down in report)
&print_element(
               $cgi,
               $dbh,
               'stssize',
               'STS size',
               qq{
                   select
                    distinct size
                   from probeprimer
                   where probeid = $id
                    and sizetype = 'STS_size'
                   },
               ['size'],
               []
               );

# ok ssrsize 
&print_element(
               $cgi,
               $dbh,
               'ssrsize',
               'SSR size',
               qq{
                   select
                    distinct size
                   from probeprimer
                   where probeid = $id
                    and sizetype = 'SSR_size'
                   },
               ['size'],
               []
               );

# ok amplificationconditions
	&print_element(
	       $cgi,
	       $dbh,
	       'amplificationconditions',
	       'Amplification Conditions',
	       qq{
		   select
                    distinct ampconditions as amplificationconditions
                   from probeprimer
                   where probeprimer.probeid = $id
		   },
	       ['amplificationconditions'],
	       []
	       );     
	       
# ok specificity
	&print_element(
	       $cgi,
	       $dbh,
	       'specificity',
	       'Specificity',
	       qq{
		   select
                    remark as specificity
                   from proberemark
                   where probeid = $id
                    and type = 'Specificity'
		   },
	       ['specificity'],
	       []
	       );     

# ok sequence
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
                  where sequenceprobe.probeid = $id
                   },
               ['sequence_link'],
               []
               );

# barleyrating removed from schema

# ok copynumber
	&print_element(
	       $cgi,
	       $dbh,
	       'copynumber',
	       'Copy Number',
	       qq{
		   select
                    remark as copynumber
                   from proberemark
                   where probeid = $id
                    and type = 'Copy_number'
		   },
	       ['copynumber'],
	       []
	       );     
	       
# ok background
	&print_element(
	       $cgi,
	       $dbh,
	       'background',
	       'Background',
	       qq{
		   select
                    remark as background
                   from proberemark
                   where probeid = $id
                    and type = 'Background'
		   },
	       ['background'],
	       []
	       );     

# ok wheatpolymorphism link (text only is automatic if restrictionenzymeid NULL)
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
                   where probewheatpolymorphism.probeid = $id
		   },
	       ['restrictionenzyme_link','polymorphism'],
	       []
	       );

# barleypolymorphism removed from schema

# ok crosshybridizesto
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
                   where probehybridizesto.probeid = $id
		   },
	       ['species_link','quality'],
	       []
	       );    

# ok polymorphism
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
                   where probepolymorphism.probeid = $id
		   },
	       ['polymorphism_link','summaryscore'],
	       []
	       );    	       

# ok gel
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
                   where probe.id = $id
		   },
	       ['gel_link'],
	       []
	       );    	

# ok linkagegroup
	&print_element(
	       $cgi,
	       $dbh,
	       'linkagegroup',
	       'Linkage Group',
	       qq{
		   select
                    #distinct 
                    remark as linkagegroup
                   from proberemark
                   where probeid = $id
                    and type = 'Linkage_Group'
		   },
	       ['linkagegroup'],
	       []
	       );  

# ok dnalibrary
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
                   where probe.id = $id
		   },
	       ['library_link'],
	       []
	       );    	


# ok insertenzyme (changed from 5' and 3' insert enzymes NL 27Oct2004)

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
                   where probeinsertenzyme.probeid = $id
		   },
	       ['restrictionenzyme_link'],
	       []
	       ); 

# ok sourcegeneclass
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
                  where probe.id = $id
                   },
               ['geneclass_link'],
               []
               );

# ok sourcegene
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
                  where probe.id = $id
                   },
               ['gene_link'],
               []
               );

# ok sourceallele
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
                  where probe.id = $id
                   },
               ['allele_link'],
               []
               );

# ok sourcespecies
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
                   where probesourcespecies.probeid = $id
		   },
	       ['species_link'],
	       []
	       );    

# ok sourcegermplasm
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
                   where probe.id = $id
		   },
	       ['germplasm_link'],
	       []
	       );    

# ok sourcetissue
	&print_element(
	       $cgi,
	       $dbh,
	       'sourcetissue',
	       'Source Tissue',
	       qq{
		   select
                    remark as sourcetissue
                   from proberemark
                   where probeid = $id
                    and type = 'Source_tissue'
		   },
	       ['sourcetissue'],
	       []
	       );     
	       
# ok dnaorigin
	&print_element(
	       $cgi,
	       $dbh,
	       'dnaorigin',
	       'DNA Origin',
	       qq{
		   select
                    remark as dnaorigin
                   from proberemark
                   where probeid = $id
                    and type = 'DNA_Origin'
		   },
	       ['dnaorigin'],
	       []
	       );  

# ok insertsize
	&print_element(
	       $cgi,
	       $dbh,
	       'insertsize',
	       'Insert Size',
	       qq{
		   select
                    insertsize
                   from probeinsertsize
                   where probeid = $id
		   },
	       ['insertsize'],
	       []
	       );  

# ok pcrsize
&print_element(
               $cgi,
               $dbh,
               'pcrsize',
               'PCR size',
               qq{
                   select
                    size
                   from probeprimer
                   where probeid = $id
                    and sizetype = 'PCR_size'
                   },
               ['size'],
               []
               );

# ok vector
&print_element(
               $cgi,
               $dbh,
               'vector',
               'Clone Vector',
               qq{
                   select
                    vector
                   from probevector
                   where probeid = $id
                   },
               ['vector'],
               []
               );

# ok vectorenzyme
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
                   where probe.id = $id
		   },
	       ['restrictionenzyme_link'],
	       []
	       );    

# ok excisionenzyme (changed from 5' and 3' excision enzymes NL 27Oct2004)
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
                   where probeexcisionenzyme.probeid = $id
		   },
	       ['restrictionenzyme_link'],
	       []
	       );    

# ok vectorpcrprimers
&print_element(
               $cgi,
               $dbh,
               'vectorpcrprimers',
               'Vector PCR primers',
               qq{
                   select
                    vectorpcrprimers
                   from probevectorpcrprimers
                   where probeid = $id
                   },
               ['vectorpcrprimers'],
               []
               );

# ok vectoramplification
&print_element(
               $cgi,
               $dbh,
               'vectoramplification',
               'Vector Amplification',
               qq{
                   select
                    vectoramplification
                   from probe
                   where probe.id = $id
                   },
               ['vectoramplification'],
               []
               );

# ok bacterialstrain
&print_element(
               $cgi,
               $dbh,
               'bacterialstrain',
               'Bacterial Strain',
               qq{
                   select
                    bacterialstrain
                   from probe
                   where probe.id = $id
                   },
               ['bacterialstrain'],
               []
               );

# ok antibiotic
&print_element(
               $cgi,
               $dbh,
               'antibiotic',
               'Antibiotic',
               qq{
                   select
                    antibiotic
                   from probe
                   where probe.id = $id
                   },
               ['antibiotic'],
               []
               );

# ok subclonedin (based on subcloneof)
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
                   where a.id = $id
		   },
	       ['probe_link'],
	       []
	       );   

# ok subcloneof
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
                   where b.id = $id
		   },
	       ['probe_link'],
	       []
	       );   

# ok location
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
                   where probelocation.probeid = $id
		   },
	       ['colleague_link'],
	       []
	       );  

# ok authority
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
                   where probeauthority.probeid = $id
		   },
	       ['colleague_link'],
	       []
	       );  

# inpool removed from schema
# gridded removed from schema
# hybridizesto removed from schema
# positiveprobe removed from schema
# postivepoolprobe removed from schema
# ok image
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
		   where probeimage.probeid = $id
		    #unnec: order by image.name
		   },
	       ['image_link'],
	       []
	       ); 

# ok datasource
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
                   where probedatasource.probeid = $id
                   },
               ['colleague_link','date'],
               []
               );

# ok informationsource
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
		   where probeinfosource.probeid = $id
		   },
	       ['reference_id'],
	       []
	       );    

# ok note (longtext from preformattext table)
{
  my $sql = qq{
	           select
                    preformattext.preformattext as note
                    from preformattext
                    inner join probenote on preformattext.id = probenote.preformattextid
                   where probenote.probeid = $id
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

1;
