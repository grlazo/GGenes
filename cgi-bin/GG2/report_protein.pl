#!/usr/bin/perl

# NLui, 6May2004

# NL 27Aug2004 to revise query for DNA homology to use sequence instead of proteinblasthits
#                  but proteinblasthits much faster
# NL 27Aug2004 revised Database query to change target to _blank

# print protein report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'protein',
	       'Protein',
	       qq{
		   select name 
		   from protein
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# OK title
&print_element(
	       $cgi,
	       $dbh,
	       'title',
	       'Title',
	       qq{
		   select title 
		   from protein
		   where id = $id
		   },
	       ['title'],
	       []
	       );


# OK peptide
{
  my $sql = qq{
                   select
                    peptide.sequence as pep
                   from peptide
                    inner join protein on peptide.id = protein.peptideid
                   where protein.id = $id
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

# OK database  (only GenBank)
{
  my $sql = qq{
               select
                accession
               from proteinexternaldb
               where proteinid = $id
              };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $extdb = $sth->fetchall_arrayref({});
  if ($extdb->[0]->{'accession'})
  {
    $extdb->[0]->{'extdb'} = $cgi->a({href=>"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=search&db=Protein&term=".$extdb->[0]->{'accession'}."&doptcmdl=GenPept",-target=>'_blank'},'Data at GenBank');
    delete($extdb->[0]->{'accession'});
  
    &print_element(
               $cgi,
               $dbh,
               'Database',
               'Database',
               $extdb,
               ['extdb_html'],
               []
               );
  } 
#&print_element(
#               $cgi,
#               $dbh,
#               'database',
#               'Database',
#               qq{
#                   select
#                    concat("http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=search&db=Protein&term=",accession,"&doptcmdl=GenPept") as url,
#                    name as description
#                   from proteinexternaldb
#                   where proteinid = $id
#                   },
#               ['url'],
#               []
#               );
}

# OK fromdatabase
&print_element(
	       $cgi,
	       $dbh,
	       'fromdatabase',
	       'From Database',
	       qq{
		   select 
		    fromdatabase 
		   from protein
		   where id = $id
		   },
	       ['fromdatabase'],
	       []
	       );

# OK-BUT correspondingdna (5/5/04:  need to turn into actual sequence, not link)
&print_element(
               $cgi,
               $dbh,
               'correspondingdna',
               'Corresponding DNA',
               qq{
                   select
                    sequence.id as sequence_id,
                    sequence.name as sequence_name
                   from sequence
                    inner join protein
                     on sequence.id = protein.correspondingsequence_sequenceid
                   where protein.id = $id
                   },
               ['sequence_link'],
               []
               );

# OK-BUT dnahomol (accession column s/b accession_sequenceid?)
&print_element(
              $cgi,
               $dbh,
               'dnahomol',
               'DNA Homology',
               qq{
                   select
                    sequence.id as sequence_id,
                    sequence.name as sequence_name
                   from sequence
                    inner join proteinblasthits
                     on sequence.id = proteinblasthits.accession
                   where proteinblasthits.proteinid = $id
                   order by sequence.name
                   },
               ['sequence_link'],
               []
               );

# OK dnahomol (query using sequence.bestpep_proteinid [1M records] takes longer than one using proteinblasthits.accession [688 records])
#&print_element(
#               $cgi,
#               $dbh,
#               'dnahomol',
#               'DNA Homology',
#               qq{
#                   select
#                    sequence.id as sequence_id,
#                    sequence.name as sequence_name
#                   from sequence
#                    inner join protein
#                     on sequence.bestpep_proteinid = protein.id
#                   where protein.id = $id
#                   },
#               ['sequence_link'],
#               []
#               );

# pephomol removed from schema

1;
