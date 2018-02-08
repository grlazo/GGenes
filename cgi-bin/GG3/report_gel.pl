#!/usr/bin/perl

# NLui, 30Apr2004

# print gel report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'gel',
	       'Gel',
	       qq{
		   select name 
		   from gel 
		   where id = $id
		   },
	       ['name'],
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
                    probe.id as probe_id,
                    probe.name as probe_name
                   from probe, gel
                   where gel.id = probe.gelid
                    and gelid = $id
                   },
               ['probe_link'],
               []
               );

# date (no data),runby (no data),conditions (no data) not in schema w/o explanation
# OK polymorphism
&print_element(
               $cgi,
               $dbh,
               'polymorphism',
               'Polymorphism',
               qq{
                   select
                    polymorphism.id as polymorphism_id,
                    polymorphism.name as polymorphism_name
                   from polymorphism
                    inner join gelpolymorphism
                     on polymorphism.id = gelpolymorphism.polymorphismid
                   where gelpolymorphism.gelid = $id
                    order by polymorphism.name
                   },
               ['polymorphism_link'],
               []
               );

# germplasm (no data), image (no data) not in schema
# TABLE removed from schema

# OK band (restrictionenzyme)
&print_element(
               $cgi,
               $dbh,
               'band',
               'Band',
               qq{
                   select
                    restrictionenzyme.id as restrictionenzyme_id,
                    restrictionenzyme.name as restrictionenzyme_name,
                    concat(gelband.size," Kb") as size,
                    concat("Intensity: ",gelband.intensity) as intensity,
                    gelband.chromosomearm
                   from restrictionenzyme
                    inner join gelband
                     on restrictionenzyme.id = gelband.restrictionenzymeid
                   where gelband.gelid = $id
                    order by restrictionenzyme.name
                   },
               ['restrictionenzyme_link','size','intensity','chromosomearm'],
               []
               );

# OK datasource
        &print_element(
               $cgi,
               $dbh,
               'datasource',
               'Data Source',
               qq{
                   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name,
                    geldatasource.date
                   from colleague
                    inner join geldatasource on colleague.id = geldatasource.colleagueid
                   where geldatasource.gelid = $id
                   },
               ['colleague_link','date'],
               []
               );    

1;
