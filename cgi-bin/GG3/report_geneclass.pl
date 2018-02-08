#!/usr/bin/perl

# NLui, 26Apr2004

# print geneclass report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'geneclass',
	       'Gene Class',
	       qq{
		   select name 
		   from geneclass 
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
		   from geneclassreference
		    inner join reference on geneclassreference.referenceid = reference.id
		   where geneclassreference.geneclassid = $id
                    order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );     

# OK url
&print_element(
	       $cgi,
	       $dbh,
	       'url',
	       'URL',
	       qq{
		   select
		    url as description,
		    url as url,
		    urldescription as comments
                   from geneclass
                   where id = $id
                    and url is not null  #this shouldn't be necessary!
		   },
	       ['url','comments'],
	       []
	       ); 
	       
# OK abbreviation
		&print_element(
	       $cgi,
	       $dbh,
	       'abbreviation',
	       'Abbreviation',
	       qq{
		   select
		    abbreviation
                   from geneclass
                   where id = $id
		   },
	       ['abbreviation'],
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
                    geneclass.id as geneclass_id,
                    geneclass.name as geneclass_name
                   from geneclass
                    inner join geneclassseealso on geneclass.id = geneclassseealso.seealso_geneclassid
                   where geneclassseealso.geneclassid = $id
		   },
	       ['geneclass_link'],
	       []
	       ); 

# OK characteraffected
&print_element(
	       $cgi,
	       $dbh,
	       'characteraffected',
	       'Character affected',
	       qq{
		   select
                    trait.id as trait_id,
                    trait.name as trait_name
                   from trait
                    inner join geneclasstraitaffected on trait.id = geneclasstraitaffected.traitid
                   where geneclasstraitaffected.geneclassid = $id
		   },
	       ['trait_link'],
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
                    pathology.id as pathology_id,
                    pathology.name as pathology_name
                   from pathology
                    inner join geneclasspathology on pathology.id = geneclasspathology.pathologyid
                   where geneclasspathology.geneclassid = $id
		   },
	       ['pathology_link'],
	       []
	       );    
	       
# OK orthologousgeneset
	&print_element(
	       $cgi,
	       $dbh,
	       'orthologousgeneset',
	       'Orthologous Gene Set ',
	       qq{
		   select
                    geneset.id as geneset_id,
                    geneset.name as geneset_name
                   from geneset
                    inner join geneclass on geneset.geneclassid = geneclass.id
                   where geneclass.id = $id
		   },
	       ['geneset_link'],
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
                    inner join genegeneclass on gene.id = genegeneclass.geneid
                    inner join geneclass on genegeneclass.geneclassid = geneclass.id
                   where geneclass.id = $id
		   },
	       ['gene_link'],
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
                    qtl.id as qtl_id,
                    qtl.name as qtl_name
                   from qtl
                    inner join qtlgeneclass on qtl.id = qtlgeneclass.qtlid
                   where qtlgeneclass.geneclassid = $id
		   },
	       ['qtl_link'],
	       []
	       );    

# geneproduct removed from schema
# OK locus
	&print_element(
	       $cgi,
	       $dbh,
	       'locus',
	       'Locus ',
	       qq{
		   select distinct
                    locus.id as locus_id,
                    locus.name as locus_name
                   from locus
                    inner join locusassociatedgene on locus.id = locusassociatedgene.locusid
                    inner join gene on locusassociatedgene.geneid = gene.id
                    inner join genegeneclass on gene.id = genegeneclass.geneid
                    inner join geneclass on genegeneclass.geneclassid = geneclass.id
                   where geneclass.id = $id
		   },
	       ['locus_link'],
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
                    probe.id as probe_id,
                    probe.name as probe_name
                   from probe
                    inner join geneclassclone on probe.id = geneclassclone.probeid
                   where geneclassclone.geneclassid = $id
		   },
	       ['probe_link'],
	       []
	       );   

# OK sequence
	&print_element(
	       $cgi,
	       $dbh,
	       'sequence',
	       'Sequence',
	       qq{
		   select
                    id as sequence_id,
                    name as sequence_name
                   from sequence
                   where geneclassid = $id
		   },
	       ['sequence_link'],
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
		   from geneclassremark 
		   where geneclassid = $id
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
                    geneclasswgcreference.number
                   from geneclasswgcreference
                    inner join reference on geneclasswgcreference.referenceid = reference.id
                   where geneclasswgcreference.geneclassid = $id
                    order by reference.year desc
                   },
               ['number','reference_id'],
               []
               );

1;
