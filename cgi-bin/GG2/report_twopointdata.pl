#!/usr/bin/perl

# NLui, 17Jun2004

# print twopointdata report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'twopointdata',
	       'Two Point Data',
	       qq{
		   select name 
		   from twopointdata 
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# OK locus1 
	&print_element(
	       $cgi,
	       $dbh,
	       'locus1',
	       'Locus 1',
	       qq{
		   select
                    locus.id as locus_id,
                    locus.name as locus_name
                   from locus
                    inner join twopointdata on locus.id = twopointdata.locusone_locusid
                   where twopointdata.id = $id
		   },
	       ['locus_link'],
	       []
	       );    
# OK locus2
	&print_element(
	       $cgi,
	       $dbh,
	       'locus2',
	       'Locus 2',
	       qq{
		   select
                    locus.id as locus_id,
                    locus.name as locus_name
                   from locus
                    inner join twopointdata on locus.id = twopointdata.locustwo_locusid
                   where twopointdata.id = $id
		   },
	       ['locus_link'],
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
                    inner join genetwopointdata on gene.id = genetwopointdata.geneid
                   where genetwopointdata.twopointdataid = $id
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
                   from genegeneclass
                    inner join genetwopointdata on gene.id = genetwopointdata.geneid
                    inner join geneclass on genegeneclass.geneclassid = geneclass.id
                    inner join gene on genegeneclass.geneid = gene.id
                   where genetwopointdata.twopointdataid = $id
		   },
	       ['geneclass_link'],
	       []
	       );    

# min removed from schema

# OK distance
&print_element(
	       $cgi,
	       $dbh,
	       'distance',
	       'Distance',
	       qq{
		   select distance 
		   from twopointdata 
		   where id = $id
		   },
	       ['distance'],
	       []
	       );

# max removed from schema

# OK error
&print_element(
	       $cgi,
	       $dbh,
	       'error',
	       'Error',
	       qq{
		   select error 
		   from twopointdata 
		   where id = $id
		   },
	       ['error'],
	       []
	       );

# OK distanceunits
&print_element(
	       $cgi,
	       $dbh,
	       'distanceunits',
	       'Distance Units',
	       qq{
		   select distanceunits 
		   from twopointdata 
		   where id = $id
		   },
	       ['distanceunits'],
	       []
	       );

# OK linkage
&print_element(
	       $cgi,
	       $dbh,
	       'linkage',
	       'Linkage',
	       qq{
		   select linkage 
		   from twopointdata 
		   where id = $id
		   },
	       ['linkage'],
	       []
	       );

# traitmarker 
&print_element(
	       $cgi,
	       $dbh,
	       'traitmarker',
	       'Trait marker',
	       qq{
		   select 
		    "Yes" as traitmarker 
		   from twopointdata 
		   where id = $id
		    and traitmarker = 1
		   },
	       ['traitmarker'],
	       []
	       );


# qtl removed from schema

# OK location - chromosome
&print_element(
	       $cgi,
	       $dbh,
	       'chromosome',
	       'Chromosome',
	       qq{
		   select 
		    chromosome 
		   from twopointdata 
		   where id = $id
		   },
	       ['chromosome'],
	       []
	       );

# OK location - chromosomearm
&print_element(
	       $cgi,
	       $dbh,
	       'chromosomearm',
	       'Chromosome Arm',
	       qq{
		   select 
		    chromosomearm 
		   from twopointdata 
		   where id = $id
		   },
	       ['chromosomearm'],
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
                    inner join twopointdata on species.id = twopointdata.speciesid
                   where twopointdata.id = $id
		   },
	       ['species_link'],
	       []
	       );    

# OK femaleparent (Germplasm)
&print_element(
	       $cgi,
	       $dbh,
	       'femaleparent',
	       'Female Parent',
	       qq{
		   select
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from germplasm
                    inner join twopointdata on germplasm.id = twopointdata.femaleparent_germplasmid
                   where twopointdata.id = $id
		   },
	       ['germplasm_link'],
	       []
	       );    

# OK maleparent (Germplasm)
&print_element(
	       $cgi,
	       $dbh,
	       'maleparent',
	       'Male Parent',
	       qq{
		   select
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from germplasm
                    inner join twopointdata on germplasm.id = twopointdata.maleparent_germplasmid
                   where twopointdata.id = $id
		   },
	       ['germplasm_link'],
	       []
	       );   
	       
# OK parent (Germplasm)
&print_element(
	       $cgi,
	       $dbh,
	       'parent',
	       'Parent',
	       qq{
		   select
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from germplasm
                    inner join twopointdataparent on germplasm.id = twopointdataparent.germplasmid
                   where twopointdataparent.twopointdataid = $id
		   },
	       ['germplasm_link'],
	       []
	       );
	       
# OK population
&print_element(
	       $cgi,
	       $dbh,
	       'population',
	       'Population',
	       qq{
		   select 
		    remark 
		   from twopointdataremark 
		   where twopointdataid = $id
		    and type = 'Population'
		   },
	       ['remark'],
	       []
	       );

# OK generation
&print_element(
	       $cgi,
	       $dbh,
	       'generation',
	       'Generation',
	       qq{
		   select 
		    remark 
		   from twopointdataremark 
		   where twopointdataid = $id
		    and type = 'Generation'
		   },
	       ['remark'],
	       []
	       );

# OK individuals
&print_element(
	       $cgi,
	       $dbh,
	       'individuals',
	       'Number of individuals',
	       qq{
		   select individuals 
		   from twopointdata 
		   where id = $id
		   },
	       ['individuals'],
	       []
	       );

# OK method
&print_element(
	       $cgi,
	       $dbh,
	       'method',
	       'Method',
	       qq{
		   select 
		    remark 
		   from twopointdataremark 
		   where twopointdataid = $id
		    and type = 'Method'
		   },
	       ['remark'],
	       []
	       );

# mapdata/linkagedata removed from schema

# OK contact
	&print_element(
	       $cgi,
	       $dbh,
	       'contact',
	       'Contact',
	       qq{
		   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name
                   from colleague
                    inner join twopointdata on colleague.id = twopointdata.contact_colleagueid
                   where twopointdata.id = $id
		   },
	       ['colleague_link'],
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
		   from twopointdatareference
		    inner join reference on twopointdatareference.referenceid = reference.id
		   where twopointdatareference.twopointdataid = $id
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
		    url as url,
                    url as description,
                    description as comments
                   from twopointdataurl
                   where twopointdataurl.twopointdataid = $id
		   },
	       ['url','comments'],
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
		   from twopointdataremark 
		   where twopointdataid = $id
		    and type = 'Remark'
		   },
	       ['remark'],
	       []
	       );

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
                    twopointdatadatasource.date
                   from colleague
                    inner join twopointdatadatasource on colleague.id = twopointdatadatasource.colleagueid
                   where twopointdatadatasource.twopointdataid = $id
		   },
	       ['colleague_link','date'],
	       []
	       );    

1;
