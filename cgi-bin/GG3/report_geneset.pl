#!/usr/bin/perl

# NLui, 26Apr2004

# print geneset report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'geneset',
	       'Gene Set',
	       qq{
		   select name 
		   from geneset 
		   where id = $id
		   },
	       ['name'],
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
		   from genesetreference
		    inner join reference on genesetreference.referenceid = reference.id
		   where genesetreference.genesetid = $id
                    order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );     

# abbreviation removed from schema
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
                    inner join geneset on geneclass.id = geneset.geneclassid
                   where geneset.id = $id
		   },
	       ['geneclass_link'],
	       []
	       );  

# characteraffected removed from schema

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
                   where orthologousgeneset_genesetid = $id
		   },
	       ['gene_link'],
	       []
	       );    

# OK comment
&print_element(
	       $cgi,
	       $dbh,
	       'comment',
	       'Comment',
	       qq{
		   select 
		    remark 
		   from genesetremark 
		   where genesetid = $id
		   },
	       ['remark'],
	       []
	       );

# OK numberedreference
&print_element(
               $cgi,
               $dbh,
               'numberedreference',
               'Wheat Gene Catalog Reference',
               qq{
                   select
                    reference.id as reference_id,
                    genesetwgcreference.number
                   from genesetwgcreference
                    inner join reference on genesetwgcreference.referenceid = reference.id
                   where genesetwgcreference.genesetid = $id
                    order by reference.year desc
                   },
               ['number','reference_id'],
               []
               );

1;
