#!/usr/bin/perl

# NLui, 18Oct2004

# print polymorphism report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# ok name
&print_element(
	       $cgi,
	       $dbh,
	       'polymorphism',
	       'Polymorphism',
	       qq{
		   select name 
		   from polymorphism 
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# ok probe
&print_element(
	       $cgi,
	       $dbh,
	       'probe',
	       'Probe',
	       qq{
		   select
                    probe.id as probe_id,
                    probe.name as probe_name
                   from probe
                    inner join polymorphism on probe.id = polymorphism.probeid
                   where polymorphism.id = $id
		   },
	       ['probe_link'],
	       []
	       );    
	       
# ok enzyme 
&print_element(
	       $cgi,
	       $dbh,
	       'restrictionenzyme',
	       'Enzyme',
	       qq{
		   select
                    restrictionenzyme.id as restrictionenzyme_id,
                    restrictionenzyme.name as restrictionenzyme_name
                   from restrictionenzyme
                    inner join polymorphism on restrictionenzyme.id = polymorphism.restrictionenzymeid
                   where polymorphism.id = $id
		   },
	       ['restrictionenzyme_link'],
	       []
	       );
	          
# TABLE removed from schema

# ok size (gel,size,intensity,germplasm)
&print_element(
	       $cgi,
	       $dbh,
	       'size',
	       'Size',
	       qq{
		   select
                    distinct
                    gel.id as gel_id,
                    gel.name as gel_name,
                    concat(polymorphismsize.size," Kb") as size,
                    concat("Intensity: ",polymorphismsize.intensity) as intensity,
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from gel
                    inner join polymorphismsize on gel.id = polymorphismsize.gelid
                    left join germplasm on polymorphismsize.germplasmid = germplasm.id
                   where polymorphismsize.polymorphismid = $id
                    order by gel.name, polymorphismsize.size desc, polymorphismsize.intensity, germplasm.name
		   },
	       ['gel_link','size','intensity','germplasm_link'],
	       []
	       );

# ok value (species,allele,germplasm)
&print_element(
	       $cgi,
	       $dbh,
	       'value',
	       'Value',
	       qq{
		   select
                    #distinct 
                    species.id as species_id,
                    species.name as species_name,
                    polymorphismvalue.allele,
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from species
                    inner join polymorphismvalue on species.id = polymorphismvalue.speciesid
                    left join germplasm on polymorphismvalue.germplasmid = germplasm.id
                   where polymorphismvalue.polymorphismid = $id
		   },
	       ['species_link','allele','germplasm_link'],
	       []
	       );

# ok bandsize
&print_element(
	       $cgi,
	       $dbh,
	       'bandsize',
	       'Band Size',
	       qq{
		   select bandsize 
		   from polymorphism 
		   where id = $id
		   },
	       ['bandsize'],
	       []
	       );


# ok pattern
&print_element(
	       $cgi,
	       $dbh,
	       'pattern',
	       'Pattern',
	       qq{
		   select polymorphismpattern.pattern,
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from germplasm
                    inner join polymorphismpattern on germplasm.id = polymorphismpattern.germplasmid
		   where polymorphismpattern.polymorphismid = $id
		   },
	       ['pattern','germplasm_link'],
	       []
	       );

# ok germplasm
&print_element(
	       $cgi,
	       $dbh,
	       'germplasm',
	       'Germplasm',
	       qq{
		   select
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from germplasm
                    inner join polymorphismgermplasm on germplasm.id = polymorphismgermplasm.germplasmid
                   where polymorphismgermplasm.polymorphismid = $id
		   },
	       ['germplasm_link'],
	       []
	       );    

# ok image 
	&print_element(
	       $cgi,
	       $dbh,
	       'image',
	       'Image',
	       qq{
		   select
		    image.id as image_id,
    		    image.name as image_name
		   from polymorphismimage 
		    inner join image on polymorphismimage.imageid = image.id
		   where polymorphismimage.polymorphismid = $id
		    order by image.name
		   },
	       ['image_link'],
	       []
	       );       
	       
# ok remarks
&print_element(
	       $cgi,
	       $dbh,
	       'remarks',
	       'Remarks',
	       qq{
	           select
		    remark 
                    from polymorphismremark
                   where polymorphismid = $id
		   },
	       ['remark'],
	       []
	       );	       


# ok reference
&print_element(
	       $cgi,
	       $dbh,
	       'reference',
	       'Reference',
	       qq{
		   select
		    reference.id as reference_id
		   from polymorphismreference
		    inner join reference on polymorphismreference.referenceid = reference.id
		   where polymorphismreference.polymorphismid = $id
                    order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );       

# ok datasource
        &print_element(
               $cgi,
               $dbh,
               'datasource',
               'Data Source',
               qq{
                   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name,
                    polymorphismdatasource.date
                   from colleague
                    inner join polymorphismdatasource on colleague.id = polymorphismdatasource.colleagueid
                   where polymorphismdatasource.polymorphismid = $id
                   },
               ['colleague_link','date'],
               []
               );    

1;
