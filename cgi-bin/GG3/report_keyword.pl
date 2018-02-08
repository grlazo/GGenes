#!/usr/bin/perl

# NL 2Aug2004

# print keyword report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# name
&print_element(
	       $cgi,
	       $dbh,
	       'name',
	       'Keyword',
	       qq{
		   select name from keyword where id = $id
		   },
	       ['name'],
	       []
	       );

# quotedin
&print_element(
	       $cgi,
	       $dbh,
	       'quotedin',
	       'Quoted in',
	       qq{
		   select
		    reference.id as reference_id
		   from reference
		    inner join referencekeyword on referencekeyword.referenceid = reference.id
		   where referencekeyword.keywordid = $id
		   order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );


1;
