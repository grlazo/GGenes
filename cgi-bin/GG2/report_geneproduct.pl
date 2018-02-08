#!/usr/bin/perl

# NLui, 3May2004

# print geneproduct report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'geneproduct',
	       'Gene Product',
	       qq{
		   select name 
		   from geneproduct 
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# othername, type, function, RNA_type, UDB_number removed from schema

# OK ecnumber
&print_element(
	       $cgi,
	       $dbh,
	       'ecnumber',
	       'EC Number',
	       qq{
		   select ecnumber 
		   from geneproduct 
		   where id = $id
		   },
	       ['ecnumber'],
	       []
	       );

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
                    inner join genegeneproduct on gene.id = genegeneproduct.geneid
                   where genegeneproduct.geneproductid = $id
		   },
	       ['gene_link'],
	       []
	       );    

# geneclass removed from schema
# OK allele 
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
                    inner join geneproductallele on allele.id = geneproductallele.alleleid
                   where geneproductallele.geneproductid = $id
		   },
	       ['allele_link'],
	       []
	       );    

# species "Species[0]: removed from schema per DaveM
# species Species[1] removed from schema

# OK germplasm
&print_element(
	       $cgi,
	       $dbh,
	       'germplasm',
	       'Germplasm',
	       qq{
		   select
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name,
                    reference.id as reference_id
                   from germplasm
                    inner join geneproductgermplasm on germplasm.id = geneproductgermplasm.germplasmid
                    left join reference on geneproductgermplasm.referenceid = reference.id
                   where geneproductgermplasm.geneproductid = $id
                    order by germplasm.name,reference.year
		   },
	       ['germplasm_link','reference_id'],
	       []
	       );    

# germplasm Germplasm[2] removed from schema
# tissue,organelle,membrane_associated,pathway,substrate_specificity removed from schema
# ph_optimum,temp_optimum,regulation,ancillary_enzyme,catalytic_mechanism removed from schema	       
# prosthetic_group,isozymes,native_mr,3d_structure,purification removed from schema
# isoelectric_point,biochemistry,remarks removed from schema

# OK reference
&print_element(
               $cgi,
               $dbh,
               'reference',
               'Reference',
               qq{
                   select
                    referenceid as reference_id
                   from geneproductreference
                       where geneproductid = $id
                   # need inner join if do "order by"    
                   #  and 0 instances of COUNT reference > 1
                 },
               ['reference_id'],
               []
               );

# contact removed from schema

# OK sequence
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
                    inner join geneproductsequence on sequence.id = geneproductsequence.sequenceid
                   where geneproductsequence.geneproductid = $id
		   },
	       ['sequence_link'],
	       []
	       );    

1;
