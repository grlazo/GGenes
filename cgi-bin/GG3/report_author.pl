#!/usr/bin/perl

# NLui, 28Apr2004

# print author report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'name',
	       'Author',
	       qq{
		   select name 
		   from author 
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# OK seealso
	&print_element(
	       $cgi,
	       $dbh,
	       'seealso',
	       'See Also',
	       qq{
		   select
		    b.id as author_id,
		    b.name as author_name
		   from author as a
		    inner join colleague on a.fullname_colleagueid = colleague.id
		    inner join author as b on colleague.id = b.fullname_colleagueid
		   where a.id = $id
                    and b.id != a.id
		   },
	       ['author_link'],
	       []
	       );       

# OK fullname
	&print_element(
	       $cgi,
	       $dbh,
	       'fullname',
	       'Full Name',
	       qq{
		   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name
                   from author
                    inner join colleague on author.fullname_colleagueid = colleague.id
                   where author.id = $id
		   },
	       ['colleague_link'],
	       []
	       );       

# OK paper
	&print_element(
	       $cgi,
	       $dbh,
	       'paper',
	       'Paper',
	       qq{
		   select
		    reference.id as reference_id
		   from author
                    inner join referenceauthor on author.id = referenceauthor.authorid
		    inner join reference on referenceauthor.referenceid = reference.id
 		   where author.id = $id
                   -- added by DDH 040424
                   order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );       

# OK image
	&print_element(
	       $cgi,
	       $dbh,
	       'image',
	       'Image',
	       qq{
		   select
		    image.id as image_id,
    		    image.name as image_name
		   from authorimage 
		    inner join image on authorimage.imageid = image.id
		   where authorimage.authorid = $id
		    order by image.name
		   },
	       ['image_link'],
	       []
	       );       



	
1;
