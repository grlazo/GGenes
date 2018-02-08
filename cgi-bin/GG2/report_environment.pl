#!/usr/bin/perl

# NLui, 6May2004

# print environment report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'environment',
	       'Environment',
	       qq{
		   select name 
		   from environment 
		   where id = $id
		   },
	       ['name'],
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
		   from environment 
		   where id = $id
		   },
	       ['year'],
	       []
	       );	 

# OK location
&print_element(
	       $cgi,
	       $dbh,
	       'location',
	       'Location',
	       qq{
		   select location 
		   from environment 
		   where id = $id
		   },
	       ['location'],
	       []
	       );	       
	       
# OK latitude
&print_element(
	       $cgi,
	       $dbh,
	       'latitude',
	       'Latitude',
	       qq{
		   select latitude 
		   from environment 
		   where id = $id
		   },
	       ['latitude'],
	       []
	       );


# OK longitude
&print_element(
	       $cgi,
	       $dbh,
	       'longitude',
	       'Longitude',
	       qq{
		   select longitude 
		   from environment 
		   where id = $id
		   },
	       ['longitude'],
	       []
	       );	    

# OK elevation
&print_element(
	       $cgi,
	       $dbh,
	       'elevation',
	       'Elevation',
	       qq{
		   select elevation 
		   from environment 
		   where id = $id
		   },
	       ['elevation'],
	       []
	       );

# OK experimentaldesign
&print_element(
	       $cgi,
	       $dbh,
	       'experimentaldesign',
	       'Experimental Design',
	       qq{
		   select experimentaldesign 
		   from environment 
		   where id = $id
		   },
	       ['experimentaldesign'],
	       []
	       );	     

# OK replications
&print_element(
	       $cgi,
	       $dbh,
	       'replications',
	       'Replications',
	       qq{
		   select replications 
		   from environment 
		   where id = $id
		   },
	       ['replications'],
	       []
	       );

# OK evaluator "used only once"
&print_element(
	       $cgi,
	       $dbh,
	       'evaluator',
	       'Evaluator',
	       qq{
		   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name
                   from colleague
                    inner join environment on colleague.id = environment.evaluator_colleagueid
                   where environment.id = $id
		   },
	       ['colleague_link'],
	       []
	       );    
	       
	       
# OK institute	       
&print_element(
	       $cgi,
	       $dbh,
	       'institute',
	       'Institute',
	       qq{
		   select institute 
		   from environment 
		   where id = $id
		   },
	       ['institute'],
	       []
	       );	       	       
	       
# topography, drainage removed from schema
# OK soiltexture
&print_element(
	       $cgi,
	       $dbh,
	       'soiltexture',
	       'Soil Texture',
	       qq{
		   select 
		    remark 
		   from environmentremark 
		   where environmentid = $id
		    and type = 'Soil_texture'
		   },
	       ['remark'],
	       []
	       );	       

# OK irrigation
&print_element(
	       $cgi,
	       $dbh,
	       'irrigation',
	       'Irrigation',
	       qq{
		   select 
		    remark 
		   from environmentremark 
		   where environmentid = $id
		    and type = 'Irrigation'
		   },
	       ['remark'],
	       []
	       );	       
	       
# OK moisture
&print_element(
	       $cgi,
	       $dbh,
	       'moisture',
	       'Moisture',
	       qq{
		   select moisture 
		   from environment 
		   where id = $id
		   },
	       ['moisture'],
	       []
	       );	   

# OK plantingdate
&print_element(
	       $cgi,
	       $dbh,
	       'plantingdate',
	       'Planting Date',
	       qq{
		   select plantingdate 
		   from environment 
		   where id = $id
		   },
	       ['plantingdate'],
	       []
	       );	    

# OK harvestdate
&print_element(
	       $cgi,
	       $dbh,
	       'harvestdate',
	       'Harvest Date',
	       qq{
		   select harvestdate 
		   from environment 
		   where id = $id
		   },
	       ['harvestdate'],
	       []
	       );	

# testingdate removed from schema
# OK nitrogenapplied
&print_element(
	       $cgi,
	       $dbh,
	       'nitrogenapplied',
	       'Nitrogen applied',
	       qq{
		   select 
		    nitrogenapplied 
		   from environment 
		   where id = $id
		   },
	       ['nitrogenapplied'],
	       []
	       );
# OK phosphorusapplied
&print_element(
	       $cgi,
	       $dbh,
	       'phosphorusapplied',
	       'Phosphorus applied',
	       qq{
		   select 
		    phosphorusapplied 
		   from environment 
		   where id = $id
		   },
	       ['phosphorusapplied'],
	       []
	       );
# OK potassiumapplied
&print_element(
	       $cgi,
	       $dbh,
	       'potassiumapplied',
	       'Potassium applied',
	       qq{
		   select 
		    potassiumapplied 
		   from environment 
		   where id = $id
		   },
	       ['potassiumapplied'],
	       []
	       );
# OK remarks
&print_element(
	       $cgi,
	       $dbh,
	       'remarks',
	       'Remarks',
	       qq{
		   select 
		    remark 
		   from environmentremark 
		   where environmentid = $id
		    and type = 'Remarks'
		   },
	       ['remark'],
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
                    inner join traitstudyenvironment on traitstudy.id = traitstudyenvironment.traitstudyid
                   where traitstudyenvironment.environmentid = $id
		   },
	       ['traitstudy_link'],
	       []
	       );     
# OK traitscore
&print_element(
	       $cgi,
	       $dbh,
	       'traitscore',
	       'Trait Scores',
	       qq{
		   select
                    traitscore.id as traitscore_id,
                    traitscore.name as traitscore_name
                   from traitscore
                    inner join traitscoreenvironment on traitscore.id = traitscoreenvironment.traitscoreid
                   where traitscoreenvironment.environmentid = $id
		   },
	       ['traitscore_link'],
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
                   from qtl
                    inner join qtlenvironment on qtl.id = qtlenvironment.qtlid
                   where qtlenvironment.environmentid = $id
		   },
	       ['qtl_link'],
	       []
	       );     

1;
