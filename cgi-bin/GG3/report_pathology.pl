#!/usr/bin/perl

# NLui, 26Apr2004

# print pathology report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'pathology',
	       'Pathology',
	       qq{
		   select name 
		   from pathology 
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# OK othername
	&print_element(
	       $cgi,
	       $dbh,
	       'othername',
	       'Other Name',
	       qq{
		   select
                    b.id as pathology_id,
                    b.name as pathology_name
                   from pathology as a, 
                    pathology as b,
                    pathologysynonym
                   where b.name = pathologysynonym.name
                    and pathologysynonym.pathologyid = a.id
                    and a.id = $id
                    #and pathologysynonym.type = 'Correct_Name'
		   },
	       ['pathology_link'],
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
		   from pathologytype
		   where pathologyid = $id
		   },
	       ['type'],
	       []
	       );

# OK hostspecies
&print_element(
	       $cgi,
	       $dbh,
	       'hostspecies',
	       'Host Species',
	       qq{
		   select
                    species.id as species_id,
                    species.name as species_name
                   from species
                    inner join pathologyhostspecies on species.id = pathologyhostspecies.speciesid
                   where pathologyhostspecies.pathologyid = $id
		   },
	       ['species_link'],
	       []
	       );    

# OK causalorganism
&print_element(
	       $cgi,
	       $dbh,
	       'causalorganism',
	       'Causal Organism',
	       qq{
		   select
                    species.id as species_id,
                    species.name as species_name
                   from species
                    inner join pathologycausalorganism on species.id = pathologycausalorganism.speciesid
                   where pathologycausalorganism.pathologyid = $id
		   },
	       ['species_link'],
	       []
	       );    

# OK vector
&print_element(
	       $cgi,
	       $dbh,
	       'vector',
	       'Vector',
	       qq{
		   select
                    species.id as species_id,
                    species.name as species_name
                   from species
                    inner join pathologyvector on species.id = pathologyvector.speciesid
                   where pathologyvector.pathologyid = $id
		   },
	       ['species_link'],
	       []
	       );    

# OK trait
	&print_element(
	       $cgi,
	       $dbh,
	       'trait',
	       'Trait',
	       qq{
		   select
                    trait.id as trait_id,
                    trait.name as trait_name
                   from trait
                    inner join pathology on trait.id = pathology.traitid
                   where pathology.id = $id
		   },
	       ['trait_link'],
	       []
	       );    

# OK evaluation
&print_element(
	       $cgi,
	       $dbh,
	       'evaluation',
	       'Evaluation',
	       qq{
		   select
                    traitstudy.id as traitstudy_id,
                    traitstudy.name as traitstudy_name
                   from traitstudy, pathology
                    where (traitstudy.traitid = pathology.traitid
                        or traitstudy.pathologyid = pathology.id)
                     and pathology.id = $id
		   },
	       ['traitstudy_link'],
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
                    inner join geneclasspathology on geneclass.id = geneclasspathology.geneclassid
                   where geneclasspathology.pathologyid = $id
		   },
	       ['geneclass_link'],
	       []
	       );    	            
	       
# OK resistancegene
&print_element(
	       $cgi,
	       $dbh,
	       'resistancegene',
	       'Resistance Gene',
	       qq{
		   select
                    gene.id as gene_id,
                    gene.name as gene_name
                   from gene
                    inner join genepathology on gene.id = genepathology.geneid
                   where genepathology.pathologyid = $id
		   },
	       ['gene_link'],
	       []
	       );    	       
	       
# OK resistantallele
&print_element(
	       $cgi,
	       $dbh,
	       'resistantallele',
	       'Resistant Allele',
	       qq{
		   select
                    allele.id as allele_id,
                    allele.name as allele_name
                   from allele
                    inner join allelepathology on allele.id = allelepathology.alleleid
                   where allelepathology.pathologyid = $id
		   },
	       ['allele_link'],
	       []
	       );    	       

# OK resistantline (Germplasm)
&print_element(
	       $cgi,
	       $dbh,
	       'resistantline',
	       'Resistant Line',
	       qq{
		   select
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from germplasm
                    inner join germplasmpathology on germplasm.id = germplasmpathology.germplasmid
                   where germplasmpathology.pathologyid = $id
		   },
	       ['germplasm_link'],
	       []
	       );    

# OK symptoms
&print_element(
	       $cgi,
	       $dbh,
	       'symptoms',
	       'Symptoms',
	       qq{
		   select symptoms 
		   from pathology 
		   where id = $id
		   },
	       ['symptoms'],
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
		   from pathologyimage 
		    inner join image on pathologyimage.imageid = image.id
		   where pathologyimage.pathologyid = $id
		    #order by image.name
		   },
	       ['image_link'],
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
		   from pathologyreference
		    inner join reference on pathologyreference.referenceid = reference.id
		   where pathologyreference.pathologyid = $id
                    order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );
	       
1;
