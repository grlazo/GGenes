#!/usr/bin/perl

# report_contigset
# dem 11dec05, from:
# NLui, 27Oct2004

# print contigset report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'contigset',
	       'Contigset',
	       qq{
		   select name 
		   from contigset
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# OK author
&print_element(
	       $cgi,
	       $dbh,
	       'author',
	       'Author',
	       qq{
		   select
                    author.id as author_id,
                    author.name as author_name
                   from contigsetauthor
                    inner join author on author.id = contigsetauthor.authorid
                   where contigsetauthor.contigsetid = $id
		   },
	       ['author_link'],
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
                   from contigset
                    inner join species on species.id = contigset.speciesid
                   where contigset.id = $id
		   },
	       ['species_link'],
	       []
	       );    

# OK date
&print_element(
	       $cgi,
	       $dbh,
	       'date',
	       'Date',
	       qq{
		   select date 
		   from contigset
		   where id = $id
		   },
	       ['date'],
	       []
	       );

# OK description
&print_element(
	       $cgi,
	       $dbh,
	       'description',
	       'Description',
	       qq{
		   select
		    remark
		   from contigsetremark
		   where contigsetid = $id
		   and type = 'Description'
		   },
	       ['remark'],
	       []
	       );    

# OK software
&print_element(
	       $cgi,
	       $dbh,
	       'software',
	       'Software',
	       qq{
		   select software 
		   from contigset
		   where id = $id
		   },
	       ['software'],
	       []
	       );

# OK parameters
&print_element(
	       $cgi,
	       $dbh,
	       'parameters',
	       'Parameters',
	       qq{
		   select parameters 
		   from contigset
		   where id = $id
		   },
	       ['parameters'],
	       []
	       );

# OK procedure
&print_element(
	       $cgi,
	       $dbh,
	       'procedure',
	       'Procedure',
	       qq{
		   select
		    remark
		   from contigsetremark
		   where contigsetid = $id
		   and type = 'Procedure'
		   },
	       ['remark'],
	       []
	       );    

# OK contigs
&print_element(
	       $cgi,
	       $dbh,
	       'contigs',
	       'Contigs',
	       qq{
		   select contigs 
		   from contigset
		   where id = $id
		   },
	       ['contigs'],
	       []
	       );

# OK singletons
&print_element(
	       $cgi,
	       $dbh,
	       'singletons',
	       'Singletons',
	       qq{
		   select singletons 
		   from contigset
		   where id = $id
		   },
	       ['singletons'],
	       []
	       );

# OK clones
&print_element(
	       $cgi,
	       $dbh,
	       'clones',
	       'Clones',
	       qq{
		   select clones 
		   from contigset
		   where id = $id
		   },
	       ['clones'],
	       []
	       );

# OK markers
&print_element(
	       $cgi,
	       $dbh,
	       'markers',
	       'Markers',
	       qq{
		   select markers 
		   from contigset
		   where id = $id
		   },
	       ['markers'],
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
		   from contigsetremark
		   where contigsetid = $id
		   and type = 'Remarks'
		   },
	       ['remark'],
	       []
	       );    

# OK wwwpage
&print_element(
	       $cgi,
	       $dbh,
	       'wwwpage',
	       'Web Page',
	       qq{
		   select wwwpage as url
		   from contigset
		   where id = $id
		   },
	       ['url'],
	       []
	       );


	       
1;
