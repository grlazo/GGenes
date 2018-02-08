#!/usr/bin/perl
# NLui, 27Oct2004

# print sequence report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'sequence',
	       'Sequence',
	       qq{
		   select name 
		   from sequence 
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
		       from locus
		       inner join sequence on locus.sequenceid = sequence.id
		       where sequence.id = $id
		   },
	       ['locus_link'],
	       []
	       );

# OK length
&print_element(
	       $cgi,
	       $dbh,
	       'length',
	       'Length',
	       qq{
		   select length, unit
		   from sequencelength 
		   where sequenceid = $id
		   },
	       ['length','unit'],
	       []
	       );

# OK (via sequence->protein->peptide, in model/schema, but no direct data)
{
  my $sql = qq{
                   select
                    peptide.sequence as pep
                   from peptide
                    inner join protein on peptide.id = protein.peptideid
                    inner join sequence on protein.correspondingsequence_sequenceid = sequence.id
                   where sequence.id = $id
                   };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $pep = $sth->fetchall_arrayref({});
  foreach my $p (@$pep) {
        $p->{'pep'} = $cgi->pre($cgi->escapeHTML($p->{'pep'}));
  }                
  &print_element(
               $cgi,
               $dbh,
               'pep',
               'Peptide',
               $pep,
               ['pep_html'],
               []
               );              
}

# OK contigset
&print_element(
	       $cgi,
	       $dbh,
	       'contigset',
	       'Contigset',
	       qq{
		   select distinct
		     contigset.id as contigset_id,
		     contigset.name as contigset_name
		   from sequencecontig
		     inner join contigset on contigset.id = sequencecontig.contigsetid
		   where sequencecontig.contig_sequenceid = $id
		   },
	       ['contigset_link'],
	       []
	       );

# OK contig
&print_element(
	       $cgi,
	       $dbh,
	       'contig',
	       'Contig',
	       qq{
		   select distinct
		     sequenceid as sequence_id,
		     sequence.name as sequence_name
		   from sequencecontig
		     inner join sequence on sequence.id = sequencecontig.contig_sequenceid
		   where sequencecontig.sequenceid = $id
		   },
	       ['sequence_link'],
	       []
	       );

#  contigmembers
&print_element(
	       $cgi,
	       $dbh,
	       'contigmembers',
	       'Contig Members',
	       qq{
		   select
		     sequenceid as sequence_id,
		     sequence.name as sequence_name
		   from sequencecontig
		     inner join sequence on sequence.id = sequencecontig.sequenceid
		   where sequencecontig.contig_sequenceid = $id
		   },
	       ['sequence_link'],
	       []
	       );


	       
# contigset, contigmembers, contig, singletonin removed from schema

# OK tracefile	       
# removed per netmtg 9Jun2004
#&print_element(
#	       $cgi,
#	       $dbh,
#	       'tracefile',
#	       'Tracefile',
#	       qq{
#		   select 
#		    tracefile
#		   from sequence 
#		   where id = $id
#		   },
#	       ['tracefile'],
#	       []
#	       );
	       	       
# OK tracefile - Part 2
# OK test for 'find sequence NOT tracefile'
{
    my $sql = "select tracefile from sequence where id = $id";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $trace = $sth->fetchall_arrayref({});
   
  if ( $trace->[0]->{'tracefile'} )
  {
    delete($trace->[0]->{'tracefile'});
    my $sql = "select name from sequence where id = $id";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $trace = $sth->fetchall_arrayref({});
#        $trace->[0]->{'trace'} = '[ '.$cgi->a({-href=>"http://wheat.pw.usda.gov/genome/sequence/Genbank/".$trace->[0]->{'name'}.".gz",-target=>'_blank'},'Download').' ]';
#        $trace->[1]->{'trace'} = '[ '.$cgi->a({-href=>"http://wheat.pw.usda.gov/cgi-bin/west/genbank/trace.cgi?filename=".$trace->[0]->{'name'}.".gz",-target=>'_blank'},'View').' ]';
        $trace->[0]->{'trace'} = '[ '.$cgi->i($cgi->a({-href=>"http://wheat.pw.usda.gov/genome/sequence/Genbank/".$trace->[0]->{'name'}.".gz",-target=>'_blank'},'Download')).' ]';
        $trace->[1]->{'trace'} = '[ '.$cgi->i($cgi->a({-href=>"http://wheat.pw.usda.gov/cgi-bin/west/genbank/trace.cgi?filename=".$trace->[0]->{'name'}.".gz",-target=>'_blank'},'View')).' ]';

        delete($trace->[0]->{'name'});

    &print_element(
                   $cgi,
                   $dbh,
                   'tracefile',
                   'Tracefile ',
                   $trace,
                   ['trace_html'],
                   []
                   );
  }
}

# OK source
&print_element(
	       $cgi,
	       $dbh,
	       'source',
	       'Structure From Source',
	       qq{
		   select
                    b.id as sequence_id,
                    b.name as sequence_name
                   from sequence as a 
                    inner join sequence as b on a.source_sequenceid = b.id
                   where a.id = $id
		   },
	       ['sequence_link'],
	       []
	       );    
	       
# OK sourceexons
&print_element(
	       $cgi,
	       $dbh,
	       'sourceexons',
	       'Source Exons',
	       qq{
		   select
		    begin,
		    end 
		   from sequenceexons 
		   where sequenceid = $id
		   },
	       ['begin','end'],
	       []
	       );	        

# OK subsequence
&print_element(
	       $cgi,
	       $dbh,
	       'subsequence',
	       'Subsequence',
	       qq{
		   select
		    sequence.id as sequence_id,
                    sequence.name as sequence_name,
                    sequencesubsequence.begin,
                    sequencesubsequence.end
                   from sequence 
                    inner join sequencesubsequence 
                     on sequencesubsequence.subsequence_sequenceid = sequence.id
                   where sequencesubsequence.sequenceid = $id		   
                 },
	       ['sequence_link','begin','end'],
	       []
	       );

# sequence (text) not in schema (207 data points) -- should be in dna field?
# dem 7jul05 Added.
# OK textsequence
{
    my $sql = qq{
	select
	    textsequence
	    from sequencetextsequence
	    where sequenceid = $id
	};
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $textseq = $sth->fetchall_arrayref({});
    foreach my $t (@$textseq) {
	# Insert a linebreak every 60 characters.
	$t->{'textsequence'} =~ s/(.{60})/$1\n/g;
	$t->{'textsequence'} = $cgi->pre($cgi->escapeHTML($t->{'textsequence'}));
    }
    &print_element(
		   $cgi,
		   $dbh,
		   'textsequence',
		   'Text sequence',
		   $textseq,
		   ['textsequence_html'],
		   []
		   );
}


# overlapright not in schema -- no data in ACEDB
# overlapleft not in schema -- no data in ACEDB

# OK externaldb (GBrowse)  [dem 6oct06]
{
  my $sql = qq{
               select
                accession
               from sequenceexternaldb
               where sequenceid = $id
                and name = 'GBrowse'
              };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $extdb = $sth->fetchall_arrayref({});
  if ($extdb->[0]->{'accession'})
  {
    $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://rye.pw.usda.gov/cgi-bin/gbrowse/MBovis/?name=".$extdb->[0]->{'accession'},-target=>'_blank'},'GBrowse');
    delete($extdb->[0]->{'accession'});
  
    &print_element(
               $cgi,
               $dbh,
               'externaldb',
               'View graphic',
               $extdb,
               ['extdb_html'],
               []
               );
  } 
}

# OK externaldb & database (ddbj,embl,genbank)
{
  my $sql = qq{
               select
                accession
               from sequenceexternaldb
               where sequenceid = $id
                and name = 'GenBank'
              };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $extdb = $sth->fetchall_arrayref({});
  if ($extdb->[0]->{'accession'})
  {
    $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://www.ncbi.nlm.nih.gov/sites/entrez?db=nucest&term=".$extdb->[0]->{'accession'},-target=>'_blank'},'Data at GenBank');
    $extdb->[1]->{'extdb'} = $cgi->a({href=>"http://srs.ebi.ac.uk/srs6bin/cgi-bin/wgetz?-e+[embl-acc:".$extdb->[0]->{'accession'}."]",-target=>'_blank'},'Data at EMBL');
    $extdb->[2]->{'extdb'} = $cgi->a({href=>"http://getentry.ddbj.nig.ac.jp/cgi-bin/get_entry.pl?".$extdb->[0]->{'accession'},-target=>'_blank'},'Data at DDBJ');
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

# OK externaldb (TIGR)
{
  my $sql = qq{
               select
                accession
               from sequenceexternaldb
               where sequenceid = $id
                and name = 'TIGR_TC'
              };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $extdb = $sth->fetchall_arrayref({});
  if ($extdb->[0]->{'accession'})
  {
#    $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://compbio.dfci.harvard.edu/tgi/cgi-bin/tgi/tc_report.pl?tc=".$extdb->[0]->{'accession'}."&species=Wheat",-target=>'_blank'},'TIGR_TC');
    $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://compbio.dfci.harvard.edu/tgi/cgi-bin/tgi/tc_report.pl?tc=".$extdb->[0]->{'accession'}."&species=Wheat",-target=>'_blank'},$extdb->[0]->{'accession'});
    delete($extdb->[0]->{'accession'});
  
    &print_element(
               $cgi,
               $dbh,
               'externaldb',
               'TIGR Gene Index',
               $extdb,
               ['extdb_html'],
               []
               );
  } 
}

# externaldb (wEST mapped ESTs)
{
  my $sql = qq{
               select
                accession
               from sequenceexternaldb
               where sequenceid = $id
                and name = 'Map_position'
              };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $extdb = $sth->fetchall_arrayref({});
  if ($extdb->[0]->{'accession'})
  {
    $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://wheat.pw.usda.gov/cgi-bin/westsql/map_locus.cgi?t=estacc&q=".$extdb->[0]->{'accession'},-target=>'_blank'},$extdb->[0]->{'accession'});
    delete($extdb->[0]->{'accession'});
  
    &print_element(
               $cgi,
               $dbh,
               'externaldb',
               'wEST map position',
               $extdb,
               ['extdb_html'],
               []
               );
  } 
}

# OK externaldb (UniGene)
{
  my $sql = qq{
               select
                accession
               from sequenceexternaldb
               where sequenceid = $id
                and name = 'UniGene'
              };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $extdb = $sth->fetchall_arrayref({});
  if ($extdb->[0]->{'accession'})
  {
#    $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://www.ncbi.nlm.nih.gov/UniGene/clust.cgi?ORG=".substr($extdb->[0]->{'accession'},0,2)."&CID=".substr($extdb->[0]->{'accession'},3),-target=>'_blank'},'NCBI-UniGene');
    $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://www.ncbi.nlm.nih.gov/UniGene/clust.cgi?ORG=".substr($extdb->[0]->{'accession'},0,2)."&CID=".substr($extdb->[0]->{'accession'},3),-target=>'_blank'},$extdb->[0]->{'accession'});
    delete($extdb->[0]->{'accession'});
  
    &print_element(
               $cgi,
               $dbh,
               'externaldb',
               'NCBI UniGene',
               $extdb,
               ['extdb_html'],
               []
               );
  } 
} 

# OK externaldb (Gramene-Protein)
{
  my $sql = qq{
               select
                accession
               from sequenceexternaldb
               where sequenceid = $id
                and name = 'Gramene-Protein'
              };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $extdb = $sth->fetchall_arrayref({});
  if ($extdb->[0]->{'accession'})
  {
    $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://www.gramene.org/db/protein/protein_search?acc=".$extdb->[0]->{'accession'},-target=>'_blank'},'Gramene-Protein')."&nbsp;".$extdb->[0]->{'accession'};
    delete($extdb->[0]->{'accession'});
  
    &print_element(
               $cgi,
               $dbh,
               'externaldb',
               'Data at Gramene',
               $extdb,
               ['extdb_html'],
               []
               );
  } 
} 

# OK externaldb (BarleyBase) External_DB[0]
{
  my $sql = qq{
               select
                accession
               from sequenceexternaldb
               where sequenceid = $id
                and name = 'BarleyBase'
              };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $extdb = $sth->fetchall_arrayref({});
  if ($extdb->[0]->{'accession'})
  {
#    $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://www.plexdb.org/modules.php?name=PD_probeset&page=annotation.php&genechip=Barley&exemplar=".$extdb->[0]->{'accession'},-target=>'_blank'},'Probe annotation');
    $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://plexdb.org/modules/PD_probeset/annotation.php?genechip=Barley1&sequence_id=".$extdb->[0]->{'accession'},-target=>'_blank'},'Probe annotation');
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

# OK externaldb (WheatDB) External_DB[0], for Contigs
{
  my $sql = qq{
               select
                accession
               from sequenceexternaldb
               where sequenceid = $id
                and name = 'WheatDB'
              };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $extdb = $sth->fetchall_arrayref({});
  if ($extdb->[0]->{'accession'})
  {
      $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://wheatdb.ucdavis.edu:8080/wheatdb/Ctg?dbKey=wheatd11_04&ctgName=".$extdb->[0]->{'accession'},-target=>'_blank'},'BAC Contig');
    delete($extdb->[0]->{'accession'});
    &print_element(
               $cgi,
               $dbh,
               'externaldb',
               'Data at WheatDB',
               $extdb,
               ['extdb_html'],
               []
               );
  } 
} 

# OK externaldb (WheatDB_BAC) External_DB[0], for BAC clones.
{
  my $sql = qq{
               select
                accession
               from sequenceexternaldb
               where sequenceid = $id
                and name = 'WheatDB_BAC'
              };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $extdb = $sth->fetchall_arrayref({});
  if ($extdb->[0]->{'accession'})
  {
      $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://wheatdb.ucdavis.edu:8080/wheatdb/Clone?dbKey=wheatd11_04&cloneName=".$extdb->[0]->{'accession'},-target=>'_blank'},'BAC clone');
    delete($extdb->[0]->{'accession'});
    &print_element(
               $cgi,
               $dbh,
               'externaldb',
               'Data at WheatDB',
               $extdb,
               ['extdb_html'],
               []
               );
  } 
} 

# OK externaldb (wEST) External_DB[0], for NSF wheat EST contigs.
{
  my $sql = qq{
               select
                accession
               from sequenceexternaldb
               where sequenceid = $id
                and name = 'wEST'
              };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $extdb = $sth->fetchall_arrayref({});
  if ($extdb->[0]->{'accession'})
  {
      $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://wheat.pw.usda.gov/cgi-bin/westsql/contig.cgi?t=c&i=e&q=".$extdb->[0]->{'accession'},-target=>'_blank'},'Contig annotation');
    delete($extdb->[0]->{'accession'});
    &print_element(
               $cgi,
               $dbh,
               'externaldb',
               'Data at wEST',
               $extdb,
               ['extdb_html'],
               []
               );
  } 
} 

# OK externaldb (PLEXdb) External_DB[0], for Affy wheat chip probes.
{
  my $sql = qq{
               select
                accession
               from sequenceexternaldb
               where sequenceid = $id
                and name = 'PLEXdb'
              };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $extdb = $sth->fetchall_arrayref({});
  if ($extdb->[0]->{'accession'})
  {
#      $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://www.plexdb.org/modules.php?name=PD_probeset&page=annotation.php&genechip=Wheat&exemplar=".$extdb->[0]->{'accession'},-target=>'_blank'},'Probe annotation');
      $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://plexdb.org/modules/PD_probeset/annotation.php?genechip=Wheat&sequence_id=".$extdb->[0]->{'accession'},-target=>'_blank'},'Probe annotation');
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

# externaldb (EMBL): disregard EMBL per DaveM ( no link in ACEDB using Hv acc#, but ACEDB record has GBacc# and links to EMBL using that #)

# OK externaldb (UMN-Contig) (only one data point)
{
  my $sql = qq{
               select
                accession
               from sequenceexternaldb
               where sequenceid = $id
                and name = 'UMN-Contig'
              };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $extdb = $sth->fetchall_arrayref({});
  if ($extdb->[0]->{'accession'})
  {
    $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://web.ahc.umn.edu/cgi-bin/biodata2/contig?grant=wheat&contig=contig_dir34&sequence=".$extdb->[0]->{'accession'},-target=>'_blank'},'UMN');
    delete($extdb->[0]->{'accession'});
  
    &print_element(
               $cgi,
               $dbh,
               'externaldb',
               'Data at UMN',
               $extdb,
               ['extdb_html'],
               []
               );
  } 
} 
          
# dbxref not in schema (no data anyway)
# blasthits -- check with Hummel re columns
#   5 possible Blast_hits[0] values: Gramene, dbj, GenBank, embl, lcl
#   Gramene: http://www.graingenes.org/cgi-bin/ace/tree/graingenes?name=AA231678&class=Sequence


# dbremark  *** need 'type' column
&print_element(
	       $cgi,
	       $dbh,
	       'dbremark',
	       'DB Remark',
	       qq{
		   select distinct
		    remark
                   from sequenceexternaldb 
                   where sequenceid = $id
                  },
	       ['remark'],
	       []
	       );

# ecnumber *** need 'type' column for sequenceexternaldb
#  &print_element(
# 	       $cgi,
# 	       $dbh,
# 	       'ecnumber',
# 	       'EC Number',
# 	       qq{
# 		   select
# 		    remark
#                    from sequenceexternaldb 
#                    where sequenceid = $id
#      		   },
# 	       ['remark'],
# 	       []
# 	       );

# OK keyword
&print_element(
	       $cgi,
	       $dbh,
	       'keyword',
	       'Keyword',
	       qq{
		   select
		    remark
                   from sequenceremark 
                   where sequenceid = $id
                    and type = 'Keyword'
                   },
	       ['remark'],
	       []
	       );

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
                    inner join sequence on germplasm.id = sequence.germplasmid
                   where sequence.id = $id
		   },
	       ['germplasm_link'],
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
                    inner join sequencespecies on species.id = sequencespecies.speciesid
                   where sequencespecies.sequenceid = $id
		   },
	       ['species_link'],
	       []
	       );    

# OK cultivar
&print_element(
	       $cgi,
	       $dbh,
	       'cultivar',
	       'Cultivar',
	       qq{
		   select
		    remark
                   from sequenceremark 
                   where sequenceid = $id
                    and type = 'Cultivar'
                   },
	       ['remark'],
	       []
	       );

# OK chromosome
&print_element(
	       $cgi,
	       $dbh,
	       'chromosome',
	       'Chromosome',
	       qq{
		   select
		    remark
                   from sequenceremark 
                   where sequenceid = $id
                    and type = 'Chromosome'
                 },
	       ['remark'],
	       []
	       );
# OK clonelib
&print_element(
	       $cgi,
	       $dbh,
	       'clonelib',
	       'Clone Library',
	       qq{
		   select
		    remark
                   from sequenceremark 
                   where sequenceid = $id
                    and type = 'Clone_lib'
                 },
	       ['remark'],
	       []
	       );
# OK tissue
&print_element(
	       $cgi,
	       $dbh,
	       'tissue',
	       'Tissue',
	       qq{
		   select
		    remark
                   from sequenceremark 
                   where sequenceid = $id
                    and type = 'Tissue'
                 },
	       ['remark'],
	       []
	       );
# OK devstage
&print_element(
	       $cgi,
	       $dbh,
	       'devstage',
	       'Developmental Stage',
	       qq{
		   select
		    remark
                   from sequenceremark 
                   where sequenceid = $id
                    and type = 'Dev_stage'
                 },
	       ['remark'],
	       []
	       );
# sex removed from schema
# origin - length not in schema -- no notes
# date removed from schema

# OK datasource
&print_element(
               $cgi,
               $dbh,
               'datasource',
               'Data Source',
               qq{
                   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name,
                    sequencedatasource.date
                   from colleague
                    inner join sequencedatasource on colleague.id = sequencedatasource.colleagueid
                   where sequencedatasource.sequenceid = $id
                   },
               ['colleague_link','date'],
               []
               );    

# map not in schema -- no notes

# OK title
&print_element(
	       $cgi,
	       $dbh,
	       'title',
	       'Title',
	       qq{
		   select title 
		   from sequence 
		   where id = $id
		   },
	       ['title'],
	       []
	       );

# OK othername (& OK for nulls)
{
    my $sql = "select altname from sequence where id = $id";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $altname = $sth->fetchall_arrayref({});
  if ($altname->[0]->{'altname'})
  {
    $altname->[0]->{'altname'} = 
#    	$altname->[0]->{'altname'}.'&nbsp;&nbsp'.'[ '.$cgi->a({-href=>"http://wheat.pw.usda.gov/cgi-bin/ace/tree/wEST?class=Sequence&name=".$altname->[0]->{'altname'},-target=>'_blank'},'wEST-ACEDB').' ]';
    	$altname->[0]->{'altname'}.'&nbsp;&nbsp'.'[ '.$cgi->i($cgi->a({-href=>"http://wheat.pw.usda.gov/cgi-bin/ace/tree/wEST?class=Sequence&name=".$altname->[0]->{'altname'},-target=>'_blank'},'wEST-ACEDB')).' ]';
    $altname->[0]->{'altname'} = 
#        $altname->[0]->{'altname'}.'&nbsp;&nbsp'.'[ '.$cgi->a({-href=>"http://wheat.pw.usda.gov/cgi-bin/westsql/est_link.cgi?i=e&t=e&q=".$altname->[0]->{'altname'},-target=>'_blank'},'wEST-mySQL').' ]';
        $altname->[0]->{'altname'}.'&nbsp;&nbsp'.'[ '.$cgi->i($cgi->a({-href=>"http://wheat.pw.usda.gov/cgi-bin/westsql/est_link.cgi?i=e&t=e&q=".$altname->[0]->{'altname'},-target=>'_blank'},'wEST-mySQL')).' ]';
    &print_element(
                   $cgi,
                   $dbh,
                   'othername',
                   'Other Name',
                   $altname,
                   ['altname_html'],
                   []
                   );
  } # end if
}

# matchinggenomic not in schema -- no notes
# matching cDNA not in schema -- no notes
# OK correspondingprotein
&print_element(
	       $cgi,
	       $dbh,
	       'protein',
	       'Corresponding Protein',
	       qq{
		   select
                    protein.id as protein_id,
                    protein.name as protein_name
                   from protein
                    inner join sequence on protein.id = sequence.correspondingprotein_proteinid
                   where sequence.id = $id
		   },
	       ['protein_link'],
	       []
	       );    
	       

# OK strain
&print_element(
	       $cgi,
	       $dbh,
	       'strain',
	       'Strain',
	       qq{
		   select
		    remark
                   from sequenceremark 
                   where sequenceid = $id
                    and type = 'Strain'
                 },
	       ['remark'],
	       []
	       );

# OK dnalibrary
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
                    inner join sequence on library.id = sequence.libraryid
                   where sequence.id = $id
		   },
	       ['library_link'],
	       []
	       );    
	       
# OK clone
&print_element(
	       $cgi,
	       $dbh,
	       'clone',
	       'Clone',
	       qq{
		   select
		    remark
                   from sequenceremark 
                   where sequenceid = $id
                    and type = 'Clone'
                 },
	       ['remark'],
	       []
	       );
# OK probe
&print_element(
	       $cgi,
	       $dbh,
	       'probe',
	       'Probe',
	       qq{
		   select
                    probe.id as probe_id,
                    probe.name as probe_name
                   from probe
                    inner join sequenceprobe on probe.id = sequenceprobe.probeid
                   where sequenceprobe.sequenceid = $id
		   },
	       ['probe_link'],
	       []
	       );    
	       
# enzyme not in schema -- no notes

# OK gene
&print_element(
	       $cgi,
	       $dbh,
	       'gene',
	       'Gene',
	       qq{
		   select
                    gene.id as gene_id,
                    gene.name as gene_name
                   from gene
                    inner join genesequence on gene.id = genesequence.geneid
                   where genesequence.sequenceid = $id
		   },
	       ['gene_link'],
	       []
	       );    
	       
# relateddna not in schema -- no notes
# OK geneclass
&print_element(
	       $cgi,
	       $dbh,
	       'geneclass',
	       'Gene Class',
	       qq{
		   select
                    geneclass.id as geneclass_id,
                    geneclass.name as geneclass_name
                   from geneclass
                    inner join sequence on geneclass.id = sequence.geneclassid
                   where sequence.id = $id
		   },
	       ['geneclass_link'],
	       []
	       );    
	       
# OK geneproduct
&print_element(
	       $cgi,
	       $dbh,
	       'geneproduct',
	       'Gene Product',
	       qq{
		   select
                    geneproduct.id as geneproduct_id,
                    geneproduct.name as geneproduct_name
                   from geneproduct
                    inner join geneproductsequence on geneproduct.id = geneproductsequence.geneproductid
                   where geneproductsequence.sequenceid = $id
		   },
	       ['geneproduct_link'],
	       []
	       ); 
	       
# OK remark (*** better to use "special" remark code?)
&print_element(
	       $cgi,
	       $dbh,
	       'remark',
	       'Remark',
	       qq{
		   select
		    remark
                   from sequenceremark 
                   where sequenceid = $id
                    and type = 'Remark'
                 },
	       ['remark'],
	       []
	       );

# confidentialremark not in schema -- no notes
# briefidentification not in schema -- no notes

# OK reference
	&print_element(
	       $cgi,
	       $dbh,
	       'reference',
	       'Reference',
	       qq{
		   select
		    reference.id as reference_id
		   from sequencereference
		    inner join reference on sequencereference.referenceid = reference.id
		   where sequencereference.sequenceid = $id
		   },
	       ['reference_id'],
	       []
	       );
	       
# containscds (Has_CDS) not in schema -- no notes
# constainstranscript (Has_Transcript) not in schema -- no notes
# haspseudogene not in schema -- no notes
# hasstructuralrna not in schema -- no notes
# hastransposon not in schema -- no notes
# hassubsequence not in schema -- no notes
# hasothersubsequence not in schema -- no notes

# properties -- most of these are not in schema w/o notes
#          5prime_EST 
#           3prime_EST 
#           Pseudogene  
#           pseudo 
#           virion 
#           chloroplast 
#           mitochondrion 
#           germline 
#           macronuclear 
#           Transposon Text 
#           Genomic_canonical 

# OK sequencetype
&print_element(
	       $cgi,
	       $dbh,
	       'type',
	       'Type',
	       qq{
		   select 
		    type 
		   from sequencetype 
		   where sequenceid = $id
		   },
	       ['type'],
	       []
	       );

# rna, coding CDS, precursor, endnotfound, startnotfound not in schema

# OK codonstart
&print_element(
	       $cgi,
	       $dbh,
	       'codonstart',
	       'Codon Start',
	       qq{
		   select 
		    codonframe 
		   from sequence 
		   where id = $id
		   },
	       ['codonframe'],
	       []
	       );

# mRNA not in schema
# uRNA not in schema
# status not in schema
# matchtype not in schema
# assembly -- none of these are in schema
# assemblytags not in schema


# allele  (no data in this field for any sequence *** remove?)
&print_element(
	       $cgi,
	       $dbh,
	       'allele',
	       'Allele',
	       qq{
		   select
                    allele.id as allele_id,
                    allele.name as allele_name
                   from allele
                    inner join allelegene on allele.id = allelegene.alleleid
                    inner join genesequence on allelegene.geneid = genesequence.geneid
                   where genesequence.sequenceid = $id
		   },
	       ['allele_link'],
	       []
	       );    
	       
# OK emblfeature (OK except when remark is '000000')
&print_element(
	       $cgi,
	       $dbh,
	       'emblfeature',
	       'EMBL Feature',
	       qq{
		   select 
		    feature,
		    begin,
		    end, 
		    remark,
		    concat("Location: ",location) as location
		   from sequenceemblfeature
		   where sequenceid = $id

		   },
	       ['feature','begin','end','remark','location'],
	       []
	       );


# bestdna removed from schema
# OK bestpep (restored to schema 27Aug2004)
&print_element(
	       $cgi,
	       $dbh,
	       'bestpep',
	       'Best Peptide Homology',
	       qq{
		   select 
		    protein.id as protein_id,
		    protein.name as protein_name,
		    sequence.bestpepscore,
		    sequence.bestpepevalue
		   from sequence
		    inner join protein on sequence.bestpep_proteinid = protein.id
		   where sequence.id = $id
		   },
	       ['protein_link','bestpepscore','bestpepevalue'],
	       []
	       );
	       
# dnahomol
#    sequenceblasthits table -- needs to be revised
#    also: can't distinguish between DNA_homol, Pep_homol -- need "type" column
&print_element(
               $cgi,
               $dbh,
               'dnahomol',
               'DNA Homology',
               qq{
		   select distinct s2.id as sequence_id,
		   s2.name as sequence_name,
                   sequenceblasthits.title,
		   sequenceblasthits.score,
		   sequenceblasthits.evalue,
		   sequenceblasthits.dbname,
                   sequenceblasthits.blasttype
		       from sequence
		       join sequenceblasthits on sequenceblasthits.sequenceid=sequence.id
                       join sequence s2 on s2.name=sequenceblasthits.accession
                   where sequence.id = $id
	       },
               ['sequence_link', 'title', 'score', 'evalue', 'dbname', 'blasttype'],
               []
               );

# Dave's dnahomol, apr2012
&print_element(
               $cgi,
               $dbh,
               'daves_dnahomol',
               'BLAST, e-value',
               qq{
		   select distinct accession,
                   sequenceblasthits.title,
		   sequenceblasthits.evalue
		       from sequence
		       join sequenceblasthits on sequenceblasthits.sequenceid=sequence.id
                   where sequence.id = $id
                       and not sequenceblasthits.evalue is null
	       },
               ['evalue', 'accession', 'title'],
               []
               );

# pephomol -- use sequenceblasthits table -- needs to be revised

# method, pickmetocall,alignment removed from schema

# OK-BUT dna (sequence[text] issue pending)
{
  my $sql = qq{
                   select
                    dna.sequence as dna
                   from dna
                    inner join sequence on dna.id = sequence.dnaid
                   where sequence.id = $id
                   };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $dna = $sth->fetchall_arrayref({});
  foreach my $d (@$dna) {
     if ($d->{'dna'} !~ /\n/) {
        my $seq = $d->{'dna'};
        my $newseq;
        while ($seq) {
            my $sub = substr ($seq, 0, 50, "");
            $newseq .= "$sub\n";
        }
        $d->{'dna'} = $cgi->pre($cgi->escapeHTML($newseq));
     } else {
        $d->{'dna'} = $cgi->pre($cgi->escapeHTML($d->{'dna'}));
     }
  }
$blast = 'http://wheat.pw.usda.gov/blast_prep.php?sequence=';
  &print_element(
               $cgi,
               $dbh,
               'dna',
               'DNA',
               $dna,
               ['dna_html'],
               []
               );

# Do BLAST search only if the record has DNA.
  my $sql = qq{
                   select
                    dna.sequence as dna
                   from dna
                    inner join sequence on dna.id = sequence.dnaid
                   where sequence.id = $id
                   };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $dna = $sth->fetchall_arrayref({});
  if ($dna->[0]->{'dna'}) {
      my $sql = qq{
                   select name as link 
                   from sequence 
                   where id = $id
               };
      my $sth = $dbh->prepare($sql); $sth->execute;
      our $link = $sth->fetchall_arrayref({});
      foreach my $b (@$link) {
          my $blink = $b->{'link'};
          $b->{'link'} = '<a href="http://wheat.pw.usda.gov/blast_prep.php?sequence=' . $blink . '">BLAST Search</a>';
          
      }

   &print_element(
               $cgi,
               $dbh,
               'link',
               'BLAST',
               $link, # query
               ['link_html'],
               []
               );   
  } # end if ($dna->[0]->{'dna'})
}

       
1;
