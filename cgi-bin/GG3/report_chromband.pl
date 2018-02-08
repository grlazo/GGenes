#!/usr/bin/perl

# NLui, 29Apr2004

# print chromband report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'chromband',
	       'Chrom Band',
	       qq{
		   select name 
		   from chromband
		   where id = $id
		   },
	       ['name'],
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
                    type
                   from chrombandtype
                   where chrombandid = $id
                   },
               ['type'],
               []
               );

# drawing removed from schema

# OK map (mapposition unnec -- to be shown on map)
&print_element(
	       $cgi,
	       $dbh,
	       'map',
	       'Map',
	       qq{
		   select
                    distinct 
                    map.id as map_id,
                    map.name as map_name
                   from map
                    inner join mapchromband on map.id = mapchromband.mapid
                   where mapchromband.chrombandid = $id
		   },
	       ['map_link'],
	       []
	       ); 

# contains, containedin, containsbreakpoint,doesnotcontainbreakpoint removed from schema
# locusinside,positivepoolprobe removed from schema

# OK reference
&print_element(
	       $cgi,
	       $dbh,
	       'reference',
	       'Reference',
	       qq{
		   select
		    reference.id as reference_id
		   from chrombandreference
		    inner join reference on chrombandreference.referenceid = reference.id
		   where chrombandreference.chrombandid = $id
                    order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );  


1;
