#!/usr/bin/perl

# NLui, 28Apr2004

# print restrictionenzyme report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'restrictionenzyme',
	       'Restriction Enzyme',
	       qq{
		   select name 
		   from restrictionenzyme 
		   where id = $id
		   },
	       ['name'],
	       []
	       );
	     
# OK site
&print_element(
	       $cgi,
	       $dbh,
	       'site',
	       'Site',
	       qq{
		   select site 
		   from restrictionenzyme 
		   where id = $id
		   },
	       ['site'],
	       []
	       );
# OK offset
&print_element(
	       $cgi,
	       $dbh,
	       'offset',
	       'Offset',
	       qq{
		   select offset 
		   from restrictionenzyme 
		   where id = $id
		   },
	       ['offset'],
	       []
	       );
# OK cleavage
&print_element(
	       $cgi,
	       $dbh,
	       'cleavage',
	       'Cleavage',
	       qq{
		   select cleavage 
		   from restrictionenzyme 
		   where id = $id
		   },
	       ['cleavage'],
	       []
	       );
	       
# OK overhang
&print_element(
	       $cgi,
	       $dbh,
	       'overhang',
	       'Overhang',
	       qq{
		   select overhang 
		   from restrictionenzyme 
		   where id = $id
		   },
	       ['overhang'],
	       []
	       );
	       
# OK isoschizomers
&print_element(
	       $cgi,
	       $dbh,
	       'isoschizomers',
	       'Isoschizomers',
	       qq{
		   select
                    restrictionenzyme.id as restrictionenzyme_id,
                    restrictionenzyme.name as restrictionenzyme_name
                   from restrictionenzyme
                    inner join restrictionenzymeisoschizomer 
                     on restrictionenzyme.id = restrictionenzymeisoschizomer.isoschizomer_restrictionenzymeid
                   where restrictionenzymeisoschizomer.restrictionenzymeid = $id
		   },
	       ['restrictionenzyme_link'],
	       []
	       );    

# company,reference,remark removed from schema

1;
