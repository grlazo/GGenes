#!/usr/bin/perl

# NLui, 28Apr2004

# print breakpointreport elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'breakpoint',
	       'Breakpoint',
	       qq{
		   select name 
		   from breakpoint
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
                    inner join mapbreakpoint on map.id = mapbreakpoint.mapid
                    inner join breakpoint on mapbreakpoint.breakpointid = breakpoint.id
                   where breakpoint.id = $id
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
                    inner join mapbreakpoint on map.id = mapbreakpoint.mapid
                   where mapbreakpoint.breakpointid = $id
		   },
	       ['map_link'],
	       []
	       );    
	       
# inchromband,notinchromband removed from schema
# OK fractionlength[0]
&print_element(
	       $cgi,
	       $dbh,
	       'fractionlength',
	       'Fraction Length',
	       qq{
		   select fractionlength 
		   from breakpoint
		   where id = $id
		   },
	       ['fractionlength'],
	       []
	       );

# fractionlength[1] removed from schema
# OK (for older germplasm) germplasm
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
                    inner join germplasmbreakpoint on germplasm.id = germplasmbreakpoint.germplasmid
                   where germplasmbreakpoint.breakpointid = $id
		   },
	       ['germplasm_link'],
	       []
	       ); 
	       
# distaldeletionin removed from schema
# OK distalinterval
&print_element(
	       $cgi,
	       $dbh,
	       'distalinterval',
	       'Distal Interval',
	       qq{
		   select
                    breakpointinterval.id as breakpointinterval_id,
                    breakpointinterval.name as breakpointinterval_name
                   from breakpointinterval
                    inner join breakpointnearbyinterval on breakpointinterval.id = breakpointnearbyinterval.breakpointintervalid
                   where breakpointnearbyinterval.breakpointid = $id
                    and type = 'Distal_interval'
		   },
	       ['breakpointinterval_link'],
	       []
	       );    
	       
# OK proximalinterval
&print_element(
	       $cgi,
	       $dbh,
	       'proximalinterval',
	       'Proximal Interval',
	       qq{
		   select
                    breakpointinterval.id as breakpointinterval_id,
                    breakpointinterval.name as breakpointinterval_name
                   from breakpointinterval
                    inner join breakpointnearbyinterval on breakpointinterval.id = breakpointnearbyinterval.breakpointintervalid
                   where breakpointnearbyinterval.breakpointid = $id
                    and type = 'Proximal_interval'
		   },
	       ['breakpointinterval_link'],
	       []
	       );    

# distalrearrangement,proximalrearrangement removed from schema

# OK reference
&print_element(
	       $cgi,
	       $dbh,
	       'reference',
	       'Reference',
	       qq{
		   select
		    reference.id as reference_id
		   from breakpointreference
		    inner join reference on breakpointreference.referenceid = reference.id
		   where breakpointreference.breakpointid = $id
                    order by reference.year desc
		   },
	       ['reference_id'],
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
		   from breakpointremark 
		   where breakpointid = $id
		   },
	       ['remark'],
	       []
	       );

1;
