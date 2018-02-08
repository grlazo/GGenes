#!/usr/bin/perl

# NLui, 5May2004

# print breakpointinterval report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'breakpointinterval',
	       'Breakpoint Interval',
	       qq{
		   select name 
		   from breakpointinterval
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# correctname,othername removed from schema

# OK mapdata
&print_element(
	       $cgi,
	       $dbh,
	       'mapdata',
	       'Map Data',
	       qq{
		   select
                    distinct mapdata.id as mapdata_id,
                    mapdata.name as mapdata_name
                   from mapdata
                    inner join map on mapdata.id = map.mapdataid
                    inner join mapbreakpointinterval on map.id = mapbreakpointinterval.mapid
                    inner join breakpointinterval on mapbreakpointinterval.breakpointintervalid = breakpointinterval.id
                   where breakpointinterval.id = $id
		   },
	       ['mapdata_link'],
	       []
	       );    
	       
# linkagedata "removed from schema" (actually incorp'd in mapdata)

# OK map (mapposition unnec -- to be shown on map)
&print_element(
	       $cgi,
	       $dbh,
	       'map',
	       'Map',
	       qq{
		   select
                    distinct map.id as map_id,
                    map.name as map_name
                   from map
                    inner join mapbreakpointinterval on map.id = mapbreakpointinterval.mapid
                   where mapbreakpointinterval.breakpointintervalid = $id
		   },
	       ['map_link'],
	       []
	       );    
	       
# OK proximalbreakpoint
&print_element(
	       $cgi,
	       $dbh,
	       'proximalbreakpoint',
	       'Proximal Breakpoint',
	       qq{
		   select
                    breakpoint.id as breakpoint_id,
                    breakpoint.name as breakpoint_name
                   from breakpoint
                    inner join breakpointintervalnearbybreakpoint on breakpoint.id = breakpointintervalnearbybreakpoint.breakpointid
                   where breakpointintervalnearbybreakpoint.breakpointintervalid = $id
                    and type = 'Proximal_breakpoint'
		   },
	       ['breakpoint_link'],
	       []
	       );    

# OK distalbreakpoint
&print_element(
	       $cgi,
	       $dbh,
	       'distalbreakpoint',
	       'Distal Breakpoint',
	       qq{
		   select
                    breakpoint.id as breakpoint_id,
                    breakpoint.name as breakpoint_name
                   from breakpoint
                    inner join breakpointintervalnearbybreakpoint on breakpoint.id = breakpointintervalnearbybreakpoint.breakpointid
                   where breakpointintervalnearbybreakpoint.breakpointintervalid = $id
                    and type = 'Distal_breakpoint'
		   },
	       ['breakpoint_link'],
	       []
	       );    

# OK (for old loci) contains (Locus)
&print_element(
	       $cgi,
	       $dbh,
	       'locus',
	       'Contains Locus',
	       qq{
		   select
                    locus.id as locus_id,
                    locus.name as locus_name
                   from locus
                    inner join breakpointintervalcontainslocus on locus.id = breakpointintervalcontainslocus.locusid
                   where breakpointintervalcontainslocus.breakpointintervalid = $id
		   },
	       ['locus_link'],
	       []
	       );    	       

# doesnotcontain removed per DaveM
# OK referencestocks
&print_element(
	       $cgi,
	       $dbh,
	       'referencestocks',
	       'Reference Stocks',
	       qq{
		   select
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from germplasm
                    inner join breakpointinterval on germplasm.id = breakpointinterval.referencestock_germplasmid
                   where breakpointinterval.id = $id
		   },
	       ['germplasm_link'],
	       []
	       );    
	       
# phenotype removed from schema

# OK reference
&print_element(
	       $cgi,
	       $dbh,
	       'reference',
	       'Reference',
	       qq{
		   select
		    reference.id as reference_id
		   from breakpointintervalreference
		    inner join reference on breakpointintervalreference.referenceid = reference.id
		   where breakpointintervalreference.breakpointintervalid = $id
                    order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );  

# OK location (colleague)
&print_element(
	       $cgi,
	       $dbh,
	       'location',
	       'Location',
	       qq{
		   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name
                   from colleague
                    inner join breakpointinterval on colleague.id = breakpointinterval.location_colleagueid
                   where breakpointinterval.id = $id
		   },
	       ['colleague_link'],
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
		   from breakpointintervalremark 
		   where breakpointintervalid = $id
		   },
	       ['remark'],
	       []
	       );

1;
