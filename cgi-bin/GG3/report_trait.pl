#!/usr/bin/perl

# NLui, 26Apr2004

# print trait report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'trait',
	       'Trait',
	       qq{
		   select name 
		   from trait 
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# OK description
&print_element(
	       $cgi,
	       $dbh,
	       'description',
	       'Description',
	       qq{
		   select remark 
		   from traitremark 
		   where traitid = $id and type = 'Description'
		   },
	       ['remark'],
	       []
	       );


# OK seealso
	&print_element(
	       $cgi,
	       $dbh,
	       'seealso',
	       'See Also',
	       qq{
		   select
                    trait.id as trait_id,
                    trait.name as trait_name
                   from trait
                    inner join traitseealso on trait.id = traitseealso.seealso_traitid
                   where traitseealso.traitid = $id
		   },
	       ['trait_link'],
	       []
	       ); 

# OK ontology
# Edit 05.2017 Directed ontologies to Planteome -> Gramene has been archived
&print_element(
	       $cgi,
	       $dbh,
	       'ontology',
	       'Ontology',
	       qq{
		   select
		    accession,
		    "Planteome" as description,
		    concat("http://browser.planteome.org/amigo/term/",accession) as url,
		    remark
                   from traitontology
                   where traitontology.traitid = $id
		   },
	       ['accession','url','remark'],
	       []
	       ); 

# OK pathology
	&print_element(
	       $cgi,
	       $dbh,
	       'pathology',
	       'Pathology',
	       qq{
		   select
                    id as pathology_id,
                    name as pathology_name
                   from pathology
                   where traitid = $id
		   },
	       ['pathology_link'],
	       []
	       ); 

# OK affectedby
	&print_element(
	       $cgi,
	       $dbh,
	       'affectedby',
	       'Affected by',
	       qq{
		   select
                    geneclass.id as geneclass_id,
                    geneclass.name as geneclass_name
                   from geneclass
                    inner join geneclasstraitaffected on geneclass.id = geneclasstraitaffected.geneclassid
                   where geneclasstraitaffected.traitid = $id
		   },
	       ['geneclass_link'],
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
                    id as qtl_id,
                    name as qtl_name
                   from qtl
                   where traitaffected_traitid = $id
		   },
	       ['qtl_link'],
	       []
	       );   

# OK evaluation (Trait Study class)
	&print_element(
	       $cgi,
	       $dbh,
	       'evaluation',
	       'Evaluation',
	       qq{
		   select
                    id as traitstudy_id,
                    name as traitstudy_name
                   from traitstudy
                   where traitid = $id
		   },
	       ['traitstudy_link'],
	       []
	       );   

# remark
&print_element(
	       $cgi,
	       $dbh,
	       'remark',
	       'Remark',
	       qq{
		   select remark 
		   from traitremark 
		   where traitid = $id and type = 'Remark'
		   },
	       ['remark'],
	       []
	       );


1;
