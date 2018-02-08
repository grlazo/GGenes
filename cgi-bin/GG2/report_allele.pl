#!/usr/bin/perl

# DDH 040416
# Synonym: rev. NLui 24Jun2004 
# Remark:  rev. NLui 28Oct2004 (labels need to be specified for comment.cgi's Fields)

# print allele report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# name
&print_element(
	       $cgi,
	       $dbh,
	       'name',
	       'Allele',
	       qq{
		   select name from allele where id = $id
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
		    type,
		    allele.id as allele_id,
		    allele.name as allele_name,
   	            allelesynonym.referenceid as reference_id
		   from allelesynonym
		    inner join allele on allelesynonym.name = allele.name collate latin1_bin
		   where allelesynonym.alleleid = $id
		    order by type,allele.name
		   },
	       ['type','allele_link','reference_id'],
	       #['type','allele_link']
	       ['type']
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
		       from allelereference
		       inner join reference on allelereference.referenceid = reference.id
		       where allelereference.alleleid = $id
		       order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );

# componentallele
&print_element(
	       $cgi,
	       $dbh,
	       'componentallele',
	       'Component Allele',
	       qq{
		   select
		       allele.id as allele_id,
		       allele.name as allele_name
		       from allelecomponentallele
		       inner join allele on allelecomponentallele.componentallele_alleleid = allele.id
		       where allelecomponentallele.alleleid = $id
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
		   select
		       gene.id as gene_id,
		       gene.name as gene_name
		       from allelegene
		       inner join gene on allelegene.geneid = gene.id
		       where allelegene.alleleid = $id
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
		   select
		       geneproduct.id as geneproduct_id,
		       geneproduct.name as geneproduct_name
		       from allelegeneproduct
		       inner join geneproduct on allelegeneproduct.geneproductid = geneproduct.id
		       where allelegeneproduct.alleleid = $id
		       order by geneproduct.name
		   },
	       ['geneproduct_link'],
	       []
	       );

# germplasm
&print_element(
	       $cgi,
	       $dbh,
	       'germplasm',
	       'Germplasm',
	       qq{
		   select
		       allelegermplasm.type,
		       germplasm.id as germplasm_id,
		       germplasm.name as germplasm_name,
		       reference.id as reference_id
		       from allelegermplasm
		       inner join germplasm on allelegermplasm.germplasmid = germplasm.id
		       left join reference on allelegermplasm.referenceid = reference.id
		       where allelegermplasm.alleleid = $id
		       order by allelegermplasm.type,germplasm.name
		   },
	       ['type','germplasm_link','reference_id'],
	       ['type']
	       );

# ok comment
&print_element(
	       $cgi,
	       $dbh,
	       'comment',
	       'Comment',
	       qq{
		   select
		    remark as comment
		   from alleleremark
		    where alleleid = $id
		     and type = 'Comment'
		   },
	       ['comment'],
	       []
	       );
	       
# remark (NL 28Oct2004:  See 'comment' and 'interactions'
# print separate elements for each type
# use type as element and label
#{
#    my $types = $dbh->selectcol_arrayref("select distinct type from alleleremark where alleleid = $id order by type");
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
#				       from alleleremark
#				       where alleleid = %s and type = %s
#				  },$id,$dbh->quote($type)
#			       ),
#		       ['remark'],
#		       []
#		       );
#   }
#}

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
		       from allelepathology
		       inner join pathology on allelepathology.pathologyid = pathology.id
		       where allelepathology.alleleid = $id
		       order by pathology.name
		   },
	       ['pathology_link'],
	       []
	       );

# phenotype
&print_element(
	       $cgi,
	       $dbh,
	       'phenotype',
	       'Phenotype',
	       qq{
		   select
		       phenotype
		       from allelephenotype
		       where alleleid = $id
		   },
	       ['phenotype'],
	       []
	       );

# property
&print_element(
	       $cgi,
	       $dbh,
	       'property',
	       'Property',
	       qq{
		   select
		       property
		       from alleleproperty
		       where alleleid = $id
		   },
	       ['property'],
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
		       from alleleimage
		       inner join image on alleleimage.imageid = image.id
		       where alleleimage.alleleid = $id
		       order by image.name
		   },
	       ['image_link'],
	       []
	       );

# ok interactions
&print_element(
	       $cgi,
	       $dbh,
	       'interactions',
	       'Interactions',
	       qq{
		   select
		    remark as interactions
		   from alleleremark
		    where alleleid = $id
		     and type = 'Interactions'
		   },
	       ['interactions'],
	       []
	       );
	       
# probe
&print_element(
	       $cgi,
	       $dbh,
	       'probe',
	       'Probe',
	       qq{
		   select distinct
		       probe.id as probe_id,
		       probe.name as probe_name
		       from allelegene
		       inner join geneclone on allelegene.geneid = geneclone.geneid
		       inner join probe on geneclone.probeid = probe.id
		       where allelegene.alleleid = $id
		       order by probe.name
		   },
	       ['probe_link'],
	       []
	       );

# wgcreference
&print_element(
	       $cgi,
	       $dbh,
	       'wgcreference',
	       'Wheat Gene Catalog Reference',
	       qq{
		   select
		       reference.id as reference_id,
		       allelewgcreference.number
		       from allelewgcreference
		       inner join reference on allelewgcreference.referenceid = reference.id
		       where allelewgcreference.alleleid = $id
		       order by reference.year desc
		   },
	       ['number','reference_id'],
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
		       alleledatasource.date
		       from alleledatasource
		       inner join colleague on alleledatasource.colleagueid = colleague.id
		       where alleledatasource.alleleid = $id
		       order by colleague.name
		   },
	       ['colleague_link','date'],
	       []
	       );

# infosource
&print_element(
	       $cgi,
	       $dbh,
	       'infosource',
	       'Info Source',
	       qq{
		   select
		       reference.id as reference_id
		       from alleleinfosource
		       inner join reference on alleleinfosource.referenceid = reference.id
		       where alleleinfosource.alleleid = $id
		   },
	       ['reference_id'],
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
		       alleledatacurator.date
		       from alleledatacurator
		       inner join colleague on alleledatacurator.colleagueid = colleague.id
		       where alleledatacurator.alleleid = $id
		       order by colleague.name
		   },
	       ['colleague_link','date'],
	       []
	       );

1;
