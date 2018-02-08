#!/usr/bin/perl

# NLui, 29Apr2004

# print isolate report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'isolate',
	       'Isolate',
	       qq{
		   select name 
		   from isolate 
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# synonym removed from shema
# OK type
&print_element(
	       $cgi,
	       $dbh,
	       'type',
	       'Type',
	       qq{
		   select 
		    type 
		   from isolatetype 
		   where isolateid = $id
		   },
	       ['type'],
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
                    inner join isolate
                     on species.id = isolate.speciesid
                   where isolate.id = $id
                   },
               ['species_link'],
               []
               );

# collector removed from schema
# latitute, longitude removed from schema
# OK country
&print_element(
	       $cgi,
	       $dbh,
	       'country',
	       'Country',
	       qq{
		   select 
		    country
		   from isolate 
		   where id = $id
		   },
	       ['country'],
	       []
	       );
# OK characteristic
&print_element(
	       $cgi,
	       $dbh,
	       'characteristic',
	       'Characteristic',
	       qq{
	           select
		    remark
                    from isolateremark
                   where isolateid = $id
                    and type = 'Characteristic'
		   },
	       ['remark'],
	       []
	       );

# avirulene removed from schema
# OK note
&print_element(
	       $cgi,
	       $dbh,
	       'note',
	       'Note',
	       qq{
	           select
		    remark
                    from isolateremark
                   where isolateid = $id
                    and type = 'Note'
		   },
	       ['remark'],
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
		   from isolatereference
		    inner join reference on isolatereference.referenceid = reference.id
		   where isolatereference.isolateid = $id
                    order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );       
# datasource removed from schema
# reactiontohostgenes & reactiontohostgermplasm removed from schema

1;
