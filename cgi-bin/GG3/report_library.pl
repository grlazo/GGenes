#!/usr/bin/perl

# NLui, 22Apr2004

# print library report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'library',
	       'Library',
	       qq{
		   select name 
		   from library 
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# OK type	 
&print_element(
	       $cgi,
	       $dbh,
	       'type',
	       'Type',
	       qq{
		   select type 
		   from librarytype
		   where libraryid = $id
		   },
	       ['type'],
	       []
	       );

# OK source (Colleague)
&print_element(
	       $cgi,
	       $dbh,
	       'source',
	       'Source',
	       qq{
		   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name
                   from colleague
                    inner join library on colleague.id = library.source_colleagueid
                   where library.id = $id
		   },
	       ['colleague_link'],
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
                    inner join library on species.id = library.speciesid
                   where library.id = $id
		   },
	       ['species_link'],
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
                    inner join library on germplasm.id = library.germplasmid
                   where library.id = $id
		   },
	       ['germplasm_link'],
	       []
	       );    
	       
# OK developmentalstage
&print_element(
	       $cgi,
	       $dbh,
	       'developmentalstage',
	       'Developmental Stage',
	       qq{
		   select developmentalstage 
		   from library 
		   where id = $id
		   },
	       ['developmentalstage'],
	       []
	       );
	       
# OK tissue	       
&print_element(
	       $cgi,
	       $dbh,
	       'tissue',
	       'Tissue',
	       qq{
		   select tissue 
		   from library 
		   where id = $id
		   },
	       ['tissue'],
	       []
	       );
	       	       
# OK treatment
&print_element(
	       $cgi,
	       $dbh,
	       'treatment',
	       'Treatment',
	       qq{
		   select treatment 
		   from library 
		   where id = $id
		   },
	       ['treatment'],
	       []
	       );

# chromosome
&print_element(
	       $cgi,
	       $dbh,
	       'chromosome',
	       'Chromosome',
	       qq{
		   select chromosome
		   from library 
		   where id = $id
		   },
	       ['chromosome'],
	       []
	       );

# OK vector
&print_element(
	       $cgi,
	       $dbh,
	       'vector',
	       'Vector',
	       qq{
		   select vector 
		   from library 
		   where id = $id
		   },
	       ['vector'],
	       []
	       );
	       
# OK cloningsite
&print_element(
	       $cgi,
	       $dbh,
	       'cloningsite',
	       'Cloning Site',
	       qq{
		   select cloningsite 
		   from library 
		   where id = $id
		   },
	       ['cloningsite'],
	       []
	       );

# OK sequencingprimers
&print_element(
	       $cgi,
	       $dbh,
	       'sequencingprimers',
	       'Sequencing Primers',
	       qq{
		   select sequencingprimers 
		   from library 
		   where id = $id
		   },
	       ['sequencingprimers'],
	       []
	       );

# clonecount
&print_element(
	       $cgi,
	       $dbh,
	       'clonecount',
	       'Clones',
	       qq{
		   select clonecount
		   from library 
		   where id = $id
		   },
	       ['clonecount'],
	       []
	       );

# clonesize
&print_element(
	       $cgi,
	       $dbh,
	       'clonesize',
	       'Clone size',
	       qq{
		   select clonesize
		   from library 
		   where id = $id
		   },
	       ['clonesize'],
	       []
	       );

# coverage
&print_element(
	       $cgi,
	       $dbh,
	       'coverage',
	       'Coverage',
	       qq{
		   select coverage
		   from library 
		   where id = $id
		   },
	       ['coverage'],
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
		   from library
		    inner join reference on library.referenceid = reference.id
		   where library.id = $id
		   },
	       ['reference_id'],
	       []
	       );
	       
# wwwpage
&print_element(
	       $cgi,
	       $dbh,
	       'wwwpage',
	       'Web Page',
	       qq{
		   select 
		       wwwpage as url
		   from library 
		   where id = $id
		   },
	       ['url'],
	       []
	       );

# OK remark
&print_element(
	       $cgi,
	       $dbh,
	       'remark',
	       'Remark',
	       qq{
		   select remark 
		   from library 
		   where id = $id
		   },
	       ['remark'],
	       []
	       );

# datasource (Colleague)
&print_element(
	       $cgi,
	       $dbh,
	       'datasource',
	       'Data Source',
	       qq{
		   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name,
		    librarydatasource.date
                   from librarydatasource
                    inner join colleague on colleague.id = librarydatasource.colleagueid
                   where librarydatasource.libraryid = $id
		   },
	       ['colleague_link','date'],
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
                    inner join library on probe.dnalibrary_libraryid = library.id
                   where library.id = $id
		   },
	       ['probe_link'],
	       []
	       );    
# OK sequence (takes a long time to load if lotta 'em)
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
                    inner join library on sequence.libraryid = library.id
                   where library.id = $id
		   },
	       ['sequence_link'],
	       []
	       );    

1;
