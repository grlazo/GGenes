#!/usr/bin/perl

# NLui, 26Apr2004
# Modified 040522

# print species report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'species',
	       'Species',
	       qq{
		   select name 
		   from species 
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# OK correctname
	&print_element(
	       $cgi,
	       $dbh,
	       'correctname',
	       'Correct Name',
	       qq{
		   select
                    b.id as species_id,
                    b.name as species_name
                   from species as a, 
                    species as b,
                    speciessynonym
                   where b.name = speciessynonym.name
                    and speciessynonym.speciesid = a.id
                    and a.id = $id
                    and speciessynonym.type = 'Correct_Name'
		   },
	       ['species_link'],
	       []
	       );      
	      
# OK fullname
&print_element(
	       $cgi,
	       $dbh,
	       'fullname',
	       'Full Name',
	       qq{
		   select name as fullname
		   from speciessynonym 
		   where type = 'Full_Name' and speciesid = $id
		   },
	       ['fullname'],
	       []
	       );

# OK genus      
&print_element(
	       $cgi,
	       $dbh,
	       'genus',
	       'Genus',
	       qq{
		   select genus 
		   from species 
		   where id = $id
		   },
	       ['genus'],
	       []
	       );

# OK speciesepithet
&print_element(
	       $cgi,
	       $dbh,
	       'speciesepithet',
	       'Species Epithet',
	       qq{
		   select species as speciesepithet
		   from species 
		   where id = $id
		   },
	       ['speciesepithet'],
	       []
	       );

# OK variety
&print_element(
	       $cgi,
	       $dbh,
	       'variety',
	       'Variety',
	       qq{
		   select variety
                   from speciesvariety 
                   where speciesid = $id
		   },
	       ['variety'],
	       []
	       );
	       
# OK authority    
&print_element(
	       $cgi,
	       $dbh,
	       'authority',
	       'Authority',
	       qq{
		   select authority from species where id = $id
		   },
	       ['authority'],
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
                    b.id as species_id,
                    b.name as species_name
                   from species as a, 
                    species as b,
                    speciessynonym
                   where b.name = speciessynonym.name
                    and speciessynonym.speciesid = a.id
                    and a.id = $id
                    and speciessynonym.type = 'Synonym'
		   },
	       ['species_link'],
	       []
	       );       

# OK commonname	       
&print_element(
	       $cgi,
	       $dbh,
	       'commonname',
	       'Common Name',
	       qq{
		   select name as commonname
                  from speciessynonym  
                  where type = 'Common_Name' 
                   and speciesid = $id
		   },
	       ['commonname'],
	       []
	       );

# OK genome
&print_element(
	       $cgi,
	       $dbh,
	       'genome',
	       'Genome',
	       qq{
		   select genome from species where id = $id
		   },
	       ['genome'],
	       []
	       );
	      
# OK comment (haploid chromosome number)
&print_element(
	       $cgi,
	       $dbh,
	       'haploid',
	       'Haploid Chromosome Number',
	       qq{
	           select
		    remark as haploid
                    from speciesremark
                   where speciesid = $id
		   },
	       ['haploid'],
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
                    mapdataspecies.mapdataid as mapdata_id,
                    mapdata.name as mapdata_name
                   from mapdataspecies
                    inner join mapdata on mapdataspecies.mapdataid = mapdata.id
                   where mapdataspecies.speciesid = $id
		   order by mapdata.name
		   },
	       ['mapdata_link'],
	       []
	       );       

# OK disease
	&print_element(
	       $cgi,
	       $dbh,
	       'disease',
	       'Disease',
	       qq{
		   select
                    pathologyhostspecies.pathologyid as pathology_id,
                    pathology.name as pathology_name
                   from pathologyhostspecies
                    inner join pathology on pathologyhostspecies.pathologyid = pathology.id
                   where pathologyhostspecies.speciesid = $id
		   order by pathology.name
 		   },
	       ['pathology_link'],
	       []
	       );       

# OK causes
	&print_element(
	       $cgi,
	       $dbh,
	       'causes',
	       'Causes',
	       qq{
		   select
                    pathologycausalorganism.pathologyid as pathology_id,
                    pathology.name as pathology_name
                   from pathologycausalorganism
                    inner join pathology on pathologycausalorganism.pathologyid = pathology.id
                   where pathologycausalorganism.speciesid = $id
		   order by pathology.name
 		   },
	       ['pathology_link'],
	       []
	       );       

# OK vectorof
	&print_element(
	       $cgi,
	       $dbh,
	       'vectorof',
	       'Vector of',
	       qq{
		   select
                    pathologyvector.pathologyid as pathology_id,
                    pathology.name as pathology_name
                   from pathologyvector
                    inner join pathology on pathologyvector.pathologyid = pathology.id
                   where pathologyvector.speciesid = $id
		   order by pathology.name
 		   },
	       ['pathology_link'],
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
		   from speciesreference
		    inner join reference on speciesreference.referenceid = reference.id
		   where speciesreference.speciesid = $id
                    order by reference.year desc
		   },
	       ['reference_id'],
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
		   from speciesimage 
		    inner join image on speciesimage.imageid = image.id
		   where speciesimage.speciesid = $id
		    order by image.name
		   },
	       ['image_link'],
	       []
	       );       

# OK dnalibrary
	&print_element(
	       $cgi,
	       $dbh,
	       'dnalibrary',
	       'DNA Library',
	       qq{
		   select
                    id as library_id,
                    name as library_name
                   from library
                   where speciesid = $id
		   order by library.name
 		   },
	       ['library_link'],
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
                    id as twopointdata_id,
                    name as twopointdata_name
                   from twopointdata
                   where speciesid = $id
		   order by name
 		   },
	       ['twopointdata_link'],
	       []
	       );       

# OK collection
	&print_element(
	       $cgi,
	       $dbh,
	       'collection',
	       'Collection',
	       qq{
		   select
                    collectionspecies.collectionid as collection_id,
                    collection.name as collection_name
                   from collectionspecies
                    inner join collection on collectionspecies.collectionid = collection.id
                   where collectionspecies.speciesid = $id
		   order by collection.name
 		   },
	       ['collection_link'],
	       []
	       );       

# OK germplasm ( too many for cross-reference to be useful?) 
	&print_element(
	       $cgi,
	       $dbh,
	       'germplasm',
	       'Germplasm',
	       qq{
		   select
                    germplasmspecies.germplasmid as germplasm_id,
                    germplasm.name as germplasm_name
                   from germplasmspecies
                    inner join germplasm on germplasmspecies.germplasmid = germplasm.id
                   where germplasmspecies.speciesid = $id
		   order by germplasm.name
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
                    id as isolate_id,
                    name as isolate_name
                   from isolate
                   where speciesid = $id
		   order by isolate.name
		   },
	       ['isolate_link'],
	       []
	       );       

# OK polymorphism
	&print_element(
	       $cgi,
	       $dbh,
	       'polymorphism',
	       'Polymorphism',
	       qq{
		   select distinct
                    polymorphism.id as polymorphism_id,
                    polymorphism.name as polymorphism_name
                   from polymorphismvalue
                    inner join polymorphism on polymorphismvalue.polymorphismid = polymorphism.id
                   where polymorphismvalue.speciesid = $id
		   order by polymorphism.name
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
                    probesourcespecies.probeid as probe_id,
                    probe.name as probe_name
                   from probesourcespecies
                    inner join probe on probesourcespecies.probeid = probe.id
                   where probesourcespecies.speciesid = $id
		   order by probe.name
		   },
	       ['probe_link'],
	       []
	       );       

1;
