#!/usr/bin/perl

# created NLui, 29Apr2004
# modified DDH 040517
# NL 25Aug2004 to add "_blank" as target for map link
 
# print qtl report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'qtl',
	       'QTL',
	       qq{
		   select name 
		   from qtl 
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# OK traitaffected
	&print_element(
	       $cgi,
	       $dbh,
	       'traitaffected',
	       'Trait Affected',
	       qq{
		   select
                    trait.id as trait_id,
                    trait.name as trait_name
                   from trait
                    inner join qtl on trait.id = qtl.traitaffected_traitid
                   where qtl.id = $id
		   },
	       ['trait_link'],
	       []
	       );     

# OK synonym
&print_element(
	       $cgi,
	       $dbh,
	       'synonym',
	       'Synonym',
	       qq{
		   select
		    qtl.id as qtl_id,
		    qtlsynonym.name as qtl_name
                   from qtlsynonym
		   inner join qtl on qtl.name = qtlsynonym.name
		   where qtlsynonym.qtlid = $id
		   and qtlsynonym.type = 'Synonym'
		   },
	       ['qtl_link'],
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
		   inner join qtl on traitaffected_traitid = traitontology.traitid
		   where qtl.id = $id
		   },
	       ['accession','url','remark'],
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
                   from geneclass
                    inner join qtlgeneclass on geneclass.id = qtlgeneclass.geneclassid
                   where qtlgeneclass.qtlid = $id
		   },
	       ['geneclass_link'],
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
                   from traitstudy
                    inner join qtltraitstudy on traitstudy.id = qtltraitstudy.traitstudyid
                   where qtltraitstudy.qtlid = $id
		   },
	       ['traitstudy_link'],
	       []
	       );     
	       
# OK map & mapposition
#	&print_element(
#	       $cgi,
#	       $dbh,
#	       'map',
#	       'Map',
#	       qq{
#		   select
#                    map.id as map_id,
#                    map.name as map_name
#                   from map
#                    inner join mapqtl on map.id = mapqtl.mapid
#                   where mapqtl.qtlid = $id
#		   },
#	       ['map_link']
#	       );	       

# map (2)
{
    my $sql = qq{
                   select distinct
                       map.id as map_id,
                       map.name as map_name
                       from mapqtl
                       inner join map on mapqtl.mapid = map.id
                       where mapqtl.qtlid = $id
                       order by map.name
                 };
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $map = $sth->fetchall_arrayref({});
    foreach my $mp (@$map) {
        #$mp->{'map'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map;id=$mp->{'map_id'};qtlid=$id"},$mp->{'map_name'});
        $mp->{'map'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=map;qtlid=$id;name=".&geturlstring($mp->{'map_name'}),-target=>'_blank'},$mp->{'map_name'});
        delete $mp->{'map_id'};
        delete $mp->{'map_name'};
    }
    &print_element(
                   $cgi,
                   $dbh,
                   'map',
                   'Map',
                   $map,
                   ['map_html'],
                   []
                   );
}

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
                   from mapdata
                    inner join qtlmapdata on mapdata.id = qtlmapdata.mapdataid
                   where qtlmapdata.qtlid = $id
		   },
	       ['mapdata_link'],
	       []
	       );     


# bin
	&print_element(
	       $cgi,
	       $dbh,
	       'bin',
	       'Bin',
	       qq{
		   select
                    bin.id as bin_id,
                    bin.name as bin_name
                   from bin
                    inner join binqtl on bin.id = binqtl.binid
                   where binqtl.qtlid = $id
		   },
	       ['bin_link'],
	       []
	       );     


# OK chromosomearm
# dem 22mar06: changed label from "Chromosome Arm" to Chromosome
&print_element(
	       $cgi,
	       $dbh,
	       'chromosomearm',
	       'Chromosome',
	       qq{
		   select chromosomearm 
		   from qtl 
		   where id = $id
		   },
	       ['chromosomearm'],
	       []
	       );


# OK associatedgene
	&print_element(
	       $cgi,
	       $dbh,
	       'associatedgene',
	       'Associated Gene',
	       qq{
		   select
                    gene.id as gene_id,
                    gene.name as gene_name
                   from gene
                    inner join qtlassociatedgene on gene.id = qtlassociatedgene.geneid
                   where qtlassociatedgene.qtlid = $id
		   },
	       ['gene_link'],
	       []
	       );     

# OK nearestmarker
	&print_element(
	       $cgi,
	       $dbh,
	       'nearestmarker',
	       'Nearest Marker',
	       qq{
		   select
                    locus.id as locus_id,
                    locus.name as locus_name
                   from locus
                    inner join qtl on locus.id = qtl.nearestmarker_locusid
                   where qtl.id = $id
		   },
	       ['locus_link'],
	       []
	       );    

# OK significancelevel
	&print_element(
	       $cgi,
	       $dbh,
	       'significancelevel',
	       'Significance Level',
	       qq{
		   select
                    significancelevel
                   from qtl
                   where id = $id
		   },
	       ['significancelevel'],
	       []
	       );  

# OK significantmarker
	&print_element(
	       $cgi,
	       $dbh,
	       'significantmarker',
	       'Positive Significant Marker',
	       qq{
		   select
                    locus.id as locus_id,
                    locus.name as locus_name
                   from locus
                    inner join qtlsignificantmarker on locus.id = qtlsignificantmarker.locusid
                   where qtlsignificantmarker.qtlid = $id
		   },
	       ['locus_link'],
	       []
	       );

# nonsignificantmarker (removed from schema)

# dem 19oct05: Map_Label only appears on ACEDB maps, not CMap.
## OK maplabel
#&print_element(
#	       $cgi,
#	       $dbh,
#	       'maplabel',
#	       'Map Label',
#	       qq{
#		   select maplabel 
#		   from qtl 
#		   where id = $id
#		   },
#	       ['maplabel'],
#	       []
#	       );
	       
# ? lodpeaklocation (no objects w/this tag)
	&print_element(
	       $cgi,
	       $dbh,
	       'lodpeaklocation',
	       'LOD Peak Location',
	       qq{
		   select
                    locus.id as locus_id,
                    locus.name as locus_name
                   from locus
                    inner join qtllodpeaklocation on locus.id = qtllodpeaklocation.locusid
                   where qtllodpeaklocation.qtlid = $id
		   },
	       ['locus_link'],
	       []
	       );    

# OK lodpeakheight
&print_element(
               $cgi,
               $dbh,
               'lodpeakheight',
               'LOD Peak Height',
               qq{
                   select
                    distinct lodpeakheight
                   from qtlenvironment
                   where qtlid = $id
                    #order by qtlenvironment.lodpeakheight
                   },
               ['lodpeakheight','environment_link'],
               ['lodpeakheight']
               );

# OK lodthreshold
&print_element(
               $cgi,
               $dbh,
               'lodthreshold',
               'LOD Threshold',
               qq{
                   select
                    distinct lodthreshold
                   from qtlenvironment
                   where qtlid = $id
                    #order by qtlenvironment.lodthreshold
                   },
               ['lodthreshold','environment_link'],
               ['lodthreshold']
               );

# OK phenotypicrsq
&print_element(
               $cgi,
               $dbh,
               'phenotypicrsq',
               'Phenotypic R2',
               qq{
                   select
                    distinct phenotypicrsq
                   from qtlenvironment
                   where qtlid = $id
                   },
               ['phenotypicrsq','environment_link'],
               ['phenotypicrsq']
               );

# OK geneticrsq
&print_element(
               $cgi,
               $dbh,
               'geneticrsq',
               'Genetic R2',
               qq{
                   select
                    distinct geneticrsq
                   from qtlenvironment
                   where qtlid = $id
                   },
               ['geneticrsq']
               );

# OK allelesubstitutioneffect
&print_element(
               $cgi,
               $dbh,
               'allelesubstitutioneffect',
               'Effect of Allele Substitution',
               qq{
                   select
                    distinct allelesubstitutioneffect
                   from qtlenvironment
                   where qtlenvironment.qtlid = $id
                   },
               ['allelesubstitutioneffect'],
               []
               );

# additivitydominanceratio (removed from schema)

# OK higherscoringallelefrom
&print_element(
               $cgi,
               $dbh,
               'higherscoringallelefrom',
               'Higher Scoring Allele from',
               qq{
                   select
                    distinct germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from germplasm
                    inner join qtlenvironment
                     on qtlenvironment.higherscoringallelefrom_germplasmid = germplasm.id
                   where qtlenvironment.qtlid = $id
                    #order by germplasm.name
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
                    inner join qtlspecies on species.id = qtlspecies.speciesid
                   where qtlspecies.qtlid = $id
		   },
	       ['species_link'],
	       []
	       );     
	       
# OK parent
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
                    inner join germplasmqtl on germplasm.id = germplasmqtl.germplasmid
                   where germplasmqtl.qtlid = $id
		   },
	       ['germplasm_link'],
	       []
	       );

# OK interactions
&print_element(
	       $cgi,
	       $dbh,
	       'interactions',
	       'Interactions',
	       qq{
	           select
		    remark as interactions
                    from qtlremark
                   where qtlid = $id
                    and type = 'Interactions'
		   },
	       ['interactions'],
	       []
	       );


# OK qtlsignificancebyenvironment
&print_element(
               $cgi,
               $dbh,
               'significancebyenvironment',
               'Significance x Environment',
               qq{
                   select
                    distinct environment.id as environment_id,
                    environment.name as environment_name
                   from environment
                    inner join qtlsignificancebyenvironment
                     on environment.id = qtlsignificancebyenvironment.environmentid
                   where qtlsignificancebyenvironment.qtlid = $id
                    #order by environment.name
                   },
               ['environment_link'],
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
                    from qtlremark
                   where qtlremark.qtlid = $id
                    and qtlremark.type = 'Comment'
		   },
	       ['remark'],
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
		   from qtlimage 
		    inner join image on qtlimage.imageid = image.id
		   where qtlimage.qtlid = $id
		    order by image.name
		   },
	       ['image_link'],
	       []
	       );       

# OK environment
	&print_element(
	       $cgi,
	       $dbh,
	       'environment',
	       'Environment',
	       qq{
		   select
                    distinct environment.id as environment_id,
                    environment.name as environment_name
                   from environment
                    inner join qtlenvironment on environment.id = qtlenvironment.environmentid
                   where qtlenvironment.qtlid = $id
		   },
	       ['environment_link'],
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
		   from qtlreference
		    inner join reference on qtlreference.referenceid = reference.id
		   where qtlreference.qtlid = $id
                    order by reference.year desc
		   },
	       ['reference_id'],
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
		       qtldatasource.date
		       from qtldatasource
		       inner join colleague on qtldatasource.colleagueid = colleague.id
		       where qtldatasource.qtlid = $id
		       order by colleague.name
		   },
	       ['colleague_link','date'],
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
		       qtldatacurator.date
		       from qtldatacurator
		       inner join colleague on qtldatacurator.colleagueid = colleague.id
		       where qtldatacurator.qtlid = $id
		       order by colleague.name
		   },
	       ['colleague_link','date'],
	       []
	       );


1;
