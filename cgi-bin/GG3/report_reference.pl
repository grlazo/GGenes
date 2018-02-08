#!/usr/bin/perl

# NLui, 29Oct2004

# print reference report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'name',
	       'Reference',
	       qq{
		   select name 
		   from reference 
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
		   from reference 
		   where id = $id
		   },
	       ['title'],
	       []
	       );
	       
# OK journal
	&print_element(
	       $cgi,
	       $dbh,
	       'journal',
	       'Journal',
	       qq{
		   select
		    journal.id as journal_id,
    		    journal.name as journal_name
		   from reference 
		    inner join journal on reference.journalid = journal.id
		   where reference.id = $id
		   },
	       ['journal_link'],
	       []
	       );       

# OK publisher
&print_element(
	       $cgi,
	       $dbh,
	       'publisher',
	       'Publisher',
	       qq{
		   select publisher 
		   from reference 
		   where id = $id
		   },
	       ['publisher'],
	       []
	       );

# OK series
&print_element(
	       $cgi,
	       $dbh,
	       'series',
	       'Series',
	       qq{
		   select 
		    remark as series
		   from referenceremark
		   where referenceid = $id
		    and type = 'Series'
		   },
	       ['series'],
	       []
	       );

# OK containedin
	&print_element(
	       $cgi,
	       $dbh,
	       'containedin',
	       'Contained in',
	       qq{
		   select
		    b.id as reference_id
		   from reference as a, reference as b
		   where a.containedin_referenceid = b.id 
		                          and a.id = $id
		   },
	       ['reference_id'],
	       []
	       );       

# OK year
&print_element(
	       $cgi,
	       $dbh,
	       'year',
	       'Year',
	       qq{
		   select year 
		   from reference 
		   where id = $id
		   },
	       ['year'],
	       []
	       );
# OK volume
&print_element(
	       $cgi,
	       $dbh,
	       'volume',
	       'Volume',
	       qq{
		   select volume 
		   from reference 
		   where id = $id
		   },
	       ['volume'],
	       []
	       );

# OK pages
&print_element(
	       $cgi,
	       $dbh,
	       'pages',
	       'Pages',
	       qq{
		   select pages 
		   from reference 
		   where id = $id
		   },
	       ['pages'],
	       []
	       );	      

# OK remark
&print_element(
	       $cgi,
	       $dbh,
	       'remark',
	       'Remark',
	       qq{
		   select 
		    remark
		   from referenceremark
		   where referenceid = $id
		    and type = 'Remark'
		   },
	       ['remark'],
	       []
	       );

# OK author
	&print_element(
	       $cgi,
	       $dbh,
	       'author',
	       'Author',
	       qq{
		   select
		    author.id as author_id,
    		    author.name as author_name
                   from referenceauthor 
                    inner join author on referenceauthor.authorid = author.id
                   where referenceauthor.referenceid = $id
		   },
	       ['author_link'],
	       []
	       );       

# OK editor
	&print_element(
	       $cgi,
	       $dbh,
	       'editor',
	       'Editor',
	       qq{
		   select
		    author.id as author_id,
    		    author.name as author_name
                   from referenceeditor 
                    inner join author on referenceeditor.authorid = author.id
                   where referenceeditor.referenceid = $id
		   },
	       ['author_link'],
	       []
	       );       

# OK type
&print_element(
	       $cgi,
	       $dbh,
	       'type',
	       'Type',
	       qq{
		   select 
		    remark as type
		   from referenceremark
		   where referenceid = $id
		    and type = 'Type'
		   },
	       ['type'],
	       []
	       );


# OK language
&print_element(
	       $cgi,
	       $dbh,
	       'language',
	       'Language',
	       qq{
		   select 
		    remark as language
		   from referenceremark
		   where referenceid = $id
		    and type = 'Language'
		   },
	       ['language'],
	       []
	       );

# OK abstract
&print_element(
	       $cgi,
	       $dbh,
	       'abstract',
	       'Abstract',
	       qq{
		   select abstract 
		   from reference 
		   where id = $id
		   },
	       ['abstract'],
	       []
	       );
	       
# OK contains
	&print_element(
	       $cgi,
	       $dbh,
	       'contains',
	       'Contains',
	       qq{
		   select
		    a.id as reference_id
		   from reference as a, reference as b
		   where a.containedin_referenceid = b.id 
		                          and b.id = $id
		   },
	       ['reference_id'],
	       []
	       );       

# OK externaldb	       
&print_element(
	       $cgi,
	       $dbh,
	       'externaldb',
	       'External Databases',
	       qq{
		   select
		    url,
		    concat(name,":  ",accession) as description
		   from referenceexternaldb
                   where referenceexternaldb.referenceid = $id
		   },
	       ['url'],
	       []
	       );

### start "Refers_to" section

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
		   from allelereference 
                    inner join allele on allelereference.alleleid = allele.id
                   where allelereference.referenceid = $id
		   },
	       ['allele_link'],
	       []
	       );       

# OK breakpoint
	&print_element(
	       $cgi,
	       $dbh,
	       'breakpoint',
	       'Breakpoint',
	       qq{
		   select
		    breakpoint.id as breakpoint_id,
    		    breakpoint.name as breakpoint_name
		   from breakpointreference 
                    inner join breakpoint on breakpointreference.breakpointid = breakpoint.id
                   where breakpointreference.referenceid = $id
		   },
	       ['breakpoint_link'],
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
		   from genereference 
                    inner join gene on genereference.geneid = gene.id
                   where genereference.referenceid = $id
		   },
	       ['gene_link'],
	       []
	       );       

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
		   from geneclassreference 
                    inner join geneclass on geneclassreference.geneclassid = geneclass.id
                   where geneclassreference.referenceid = $id
		   },
	       ['geneclass_link'],
	       []
	       );       

# OK geneset
	&print_element(
	       $cgi,
	       $dbh,
	       'geneset',
	       'Gene Set',
	       qq{
		   select
		    geneset.id as geneset_id,
    		    geneset.name as geneset_name
		   from genesetreference 
                    inner join geneset on genesetreference.genesetid = geneset.id
                   where genesetreference.referenceid = $id
		   },
	       ['geneset_link'],
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
		   from germplasmreference 
                    inner join germplasm on germplasmreference.germplasmid = germplasm.id
                   where germplasmreference.referenceid = $id
		   },
	       ['germplasm_link'],
	       []
	       );       
	       
	       
# OK isolate
	&print_element(
	       $cgi,
	       $dbh,
	       'isolate',
	       'Isolate',
	       qq{
		   select
		    isolate.id as isolate_id,
    		    isolate.name as isolate_name
		   from isolatereference 
                    inner join isolate on isolatereference.isolateid = isolate.id
                   where isolatereference.referenceid = $id
		   },
	       ['isolate_link'],
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
		   from locusreference 
                    inner join locus on locusreference.locusid = locus.id
                   where locusreference.referenceid = $id
		   },
	       ['locus_link'],
	       []
	       );       

# OK mapdata
	&print_element(
	       $cgi,
	       $dbh,
	       'mapdata',
	       'Map Data',
	       qq{
		   select
		    mapdata.id as mapdata_id,
    		    mapdata.name as mapdata_name
		   from mapdatareference 
                    inner join mapdata on mapdatareference.mapdataid = mapdata.id
                   where mapdatareference.referenceid = $id
		   },
	       ['mapdata_link'],
	       []
	       );       

# OK polymorphism
&print_element(
	       $cgi,
	       $dbh,
	       'polymorphism',
	       'Polymorphism',
	       qq{
		   select
		    polymorphism.id as polymorphism_id,
    		    polymorphism.name as polymorphism_name
		   from polymorphismreference 
                    inner join polymorphism on polymorphismreference.polymorphismid = polymorphism.id
                   where polymorphismreference.referenceid = $id
		   },
	       ['polymorphism_link'],
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
		   from probereference 
                    inner join probe on probereference.probeid = probe.id
                   where probereference.referenceid = $id
		   },
	       ['probe_link'],
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
		   from qtlreference 
                    inner join qtl on qtlreference.qtlid = qtl.id
                   where qtlreference.referenceid = $id
		   },
	       ['qtl_link'],
	       []
	       );       

# OK rearrangement
	&print_element(
	       $cgi,
	       $dbh,
	       'rearrangement',
	       'Rearrangement',
	       qq{
		   select
		    rearrangement.id as rearrangement_id,
    		    rearrangement.name as rearrangement_name
		   from rearrangementreference 
                    inner join rearrangement on rearrangementreference.rearrangementid = rearrangement.id
                   where rearrangementreference.referenceid = $id
		   },
	       ['rearrangement_link'],
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
		    sequence.id as sequence_id,
    		    sequence.name as sequence_name
		   from sequencereference 
                    inner join sequence on sequencereference.sequenceid = sequence.id
                   where sequencereference.referenceid = $id
		   },
	       ['sequence_link'],
	       []
	       );       

# OK traitstudy
	&print_element(
	       $cgi,
	       $dbh,
	       'traitstudy',
	       'Trait Study',
	       qq{
		   select
		    traitstudy.id as traitstudy_id,
    		    traitstudy.name as traitstudy_name
		   from traitstudyreference 
                    inner join traitstudy on traitstudyreference.traitstudyid = traitstudy.id
                   where traitstudyreference.referenceid = $id
		   },
	       ['traitstudy_link'],
	       []
	       );       

# OK twopointdata
	&print_element(
	       $cgi,
	       $dbh,
	       'twopointdata',
	       '2 Point Data',
	       qq{
		   select
		    twopointdata.id as twopointdata_id,
    		    twopointdata.name as twopointdata_name
		   from twopointdatareference 
                    inner join twopointdata on twopointdatareference.twopointdataid = twopointdata.id
                   where twopointdatareference.referenceid = $id
		   },
	       ['twopointdata_link'],
	       []
	       );       
	       
### end "Refers_to" section

# OK keyword
	&print_element(
	       $cgi,
	       $dbh,
	       'keyword',
	       'Keyword',
	       qq{
		   select
		    keyword.id as keyword_id,
    		    keyword.name as keyword_name
		   from referencekeyword
		    inner join keyword on referencekeyword.keywordid = keyword.id
		   where referencekeyword.referenceid = $id
		    order by keyword.name
		   },
	       ['keyword_link'],
	       []
	       );       

# OK agricolacode
&print_element(
	       $cgi,
	       $dbh,
	       'agricolacode',
	       'Agricola Code',
	       qq{
		   select 
		    remark as agricolacode
		   from referenceremark
		   where referenceid = $id
		    and type = 'Agricola_Code'
		   },
	       ['agricolacode'],
	       []
	       );

# OK genecataloguenumber
&print_element(
	       $cgi,
	       $dbh,
	       'genecataloguenumber',
	       'Gene Catalogue Number',
	       qq{
		   select 
		    remark as genecataloguenumber
		   from referenceremark
		   where referenceid = $id
		    and type = 'Gene_Catalogue_Number'
		   },
	       ['genecataloguenumber'],
	       []
	       );
	       
# OK image	       
	&print_element(
	       $cgi,
	       $dbh,
	       'image',
	       'Image',
	       qq{
		   select
		    image.id as image_id,
    		    image.name as image_name
		   from referenceimage 
		    inner join image on referenceimage.imageid = image.id
		   where referenceimage.referenceid = $id
		    order by image.name
		   },
	       ['image_link'],
	       []
	       );       
	       
# OK citedin
	&print_element(
	       $cgi,
	       $dbh,
	       'citedin',
	       'Cited in',
	       qq{
		   select
		    b.id as reference_id
		   from reference as a 
		    inner join reference as b on a.citedin_referenceid = b.id
		   where a.id = $id
		   },
	       ['reference_id'],
	       []
	       );       

# OK summaryof
	&print_element(
	       $cgi,
	       $dbh,
	       'summaryof',
	       'Summary of',
	       qq{
		   select
		    a.id as reference_id
		   from reference as a 
		    inner join reference as b on a.summarizedin_referenceid = b.id
		   where b.id = $id
		   },
	       ['reference_id'],
	       []
	       );       

# OK summarizedin
	&print_element(
	       $cgi,
	       $dbh,
	       'summarizedin',
	       'Summarized in',
	       qq{
		   select
		    b.id as reference_id
		   from reference as a 
		    inner join reference as b on a.summarizedin_referenceid = b.id
		   where a.id = $id
		   },
	       ['reference_id'],
	       []
	       );       

1;
