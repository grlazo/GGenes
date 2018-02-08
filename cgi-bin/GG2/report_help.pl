#!/usr/bin/perl

# NLui, 3May2004

# print help report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'help',
	       'Help',
	       qq{
		   select 
		    name 
		   from help 
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# OK intro
&print_element(
	       $cgi,
	       $dbh,
	       'intro',
	       'Intro',
	       qq{
	           select
		    remark
                   from helpremark
                   where helpid = $id
                    and type = 'Intro'
		   },
	       ['remark'],
	       []
	       );

# ? overview ( no data )
&print_element(
	       $cgi,
	       $dbh,
	       'overview',
	       'Overview',
	       qq{
	           select
		    remark
                   from helpremark
                   where helpid = $id
                    and type = 'Overview'
		   },
	       ['remark'],
	       []
	       );
# OK note
&print_element(
	       $cgi,
	       $dbh,
	       'note',
	       'Note',
	       qq{
	           select
		    remark
                   from helpremark
                   where helpid = $id
                    and type = 'Note'
		   },
	       ['remark'],
	       []
	       );
# OK tip
&print_element(
	       $cgi,
	       $dbh,
	       'tip',
	       'Tip',
	       qq{
	           select
		    remark
                   from helpremark
                   where helpid = $id
                    and type = 'Tip'
		   },
	       ['remark'],
	       []
	       );
# OK more
{
  my $sql = qq{
	           select
                    preformattext.preformattext as more
                   from preformattext
                    inner join helpmore on preformattext.id = helpmore.preformattextid
                   where helpmore.helpid = $id
		   };
  my $sth = $dbh->prepare($sql); $sth->execute;
  my $more = $sth->fetchall_arrayref({});
  foreach my $m (@$more) {
    	$m->{'more'} = $cgi->pre($cgi->escapeHTML($m->{'more'}));
  }		   
  &print_element(
               $cgi,
               $dbh,
               'more',
               'More',
               $more,
               ['more_html'],
               []
               );

}

1;
