#!/usr/bin/perl

# NLui, 29Oct2004

# print journal report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'name',
	       'Journal',
	       qq{
		   select name 
		   from journal 
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# OK othername
	&print_element(
	       $cgi,
	       $dbh,
	       'othername',
	       'Other Name',
	       qq{
		   select
		    b.id as journal_id,
		    b.name as journal_name
		   from journal as a, 
		    journal as b,
		    journalremark
		   where b.name = journalremark.remark
		    and journalremark.journalid = a.id
		    and a.id = $id
		    and journalremark.type = 'Other_Name'
		   },
	       ['journal_link'],
	       []
	       );       

# OK remark (e.g., ISSN_Number, Source_Code, Comment) removed 29Oct to accommodate comment.cgi
#{
#    my $types = $dbh->selectcol_arrayref("select distinct type 
#                                           from journalremark 
#                                          where journalremark.journalid = $id
#                                          and (journalremark.type = 'ISSN_Number'
#                                               or journalremark.type = 'Source_Code'
#                                               or journalremark.type = 'Comment')
#                                           order by type");
#    foreach my $type (@$types) {
#	my $element = lc($type); $element =~ s/ /_/g;
#	my $label = $type; $label =~ s/_/ /g;
#	&print_element(
#		       $cgi,
#		       $dbh,
#		       $element,
#		       $label,
#		       sprintf(qq{
#			           select
#				    remark
#				   from journalremark
#				   where journalid = %s and type = %s
#				  },$id,$dbh->quote($type)
#			       ),
#		       ['remark'],
#		       []
#		       );
#    }
#}

# OK sourcecode
	&print_element(
	       $cgi,
	       $dbh,
	       'sourcecode',
	       'Source Code',
	       qq{
		   select
		    remark as sourcecode
		   from journalremark
		   where journalid = $id
		    and type = 'Source_Code'
		   },
	       ['sourcecode'],
	       []
	       );       

# OK issnnumber
	&print_element(
	       $cgi,
	       $dbh,
	       'issnnumber',
	       'ISSN Number',
	       qq{
		   select
		    remark as issnnumber
		   from journalremark
		   where journalid = $id
		    and type = 'ISSN_Number'
		   },
	       ['issnnumber'],
	       []
	       );      
	       
# OK url
&print_element(
	       $cgi,
	       $dbh,
	       'url',
	       'URL',
	       qq{
		   select
                    remark as url,
                    remark as description
                   from journalremark
                   where journalid = $id
                    and type = 'URL'
		   },
	       ['url'],
	       []
	       );

# Remark 
&print_element(
	       $cgi,
	       $dbh,
	       'remark',
	       'Remark',
	       qq{
		   select
                    remark as remark
                   from journalremark
                   where journalid = $id
                    and type = 'Remark'
		   },
	       ['remark'],
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
		   from journal
		    inner join reference on journal.id = reference.journalid
		   where journal.id = $id
                    order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );       


1;
