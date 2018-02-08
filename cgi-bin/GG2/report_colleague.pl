#!/usr/bin/perl

# NLui, 29Oct2004

# print colleague report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'name',
	       'Colleague',
	       qq{
		   select name 
		   from colleague 
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# OK position	       
	&print_element(
	       $cgi,
	       $dbh,
	       'position',
	       'Position',
	       qq{
		   select
 		    remark as position
                   from colleagueremark 
                   where colleagueid = $id
                    and type = 'Position'
		   },
	       ['position'],
	       []
	       );    

# OK profession	       
	&print_element(
	       $cgi,
	       $dbh,
	       'profession',
	       'Profession',
	       qq{
		   select
 		    remark as profession
                   from colleagueremark 
                   where colleagueid = $id
                    and type = 'Profession'
		   },
	       ['profession'],
	       []
	       );    
	       
# OK mail
&print_element(
	       $cgi,
	       $dbh,
	       'mail',
	       'Mail',
	       qq{
		   select 
                    distinct mail
                   from colleagueaddress 
                   where colleagueid = $id
		   },
	       ['mail'],
               []
	       );

# OK country
&print_element(
	       $cgi,
	       $dbh,
	       'country',
	       'Country',
	       qq{
		   select
                    distinct country
                   from colleagueaddress 
                   where colleagueid = $id
		   },
	       ['country'],
               []
	       );

# OK phone
&print_element(
	       $cgi,
	       $dbh,
	       'phone',
	       'Phone',
	       qq{
		   select
                    distinct phone
                   from colleagueaddress 
                   where colleagueid = $id
		   },
	       ['phone'],
               []
	       );

# OK fax
&print_element(
	       $cgi,
	       $dbh,
	       'fax',
	       'Fax',
	       qq{
		   select
                    distinct fax
                   from colleagueaddress 
                   where colleagueid = $id
		   },
	       ['fax'],
               []
	       );

# OK email
&print_element(
	       $cgi,
	       $dbh,
	       'email',
	       'Email',
	       qq{
		   select
		    concat("mailto:",email) as url,
		    email as description
  		   from colleagueemail
                   where colleagueid = $id
		   },
	       ['url'],
	       []
	       );

# OK telex
&print_element(
	       $cgi,
	       $dbh,
	       'telex',
	       'Telex',
	       qq{
		   select
                    distinct telex
                   from colleagueaddress 
                   where colleagueid = $id
		   },
	       ['telex'],
               []
	       );

# OK webpage
&print_element(
	       $cgi,
	       $dbh,
	       'webpage',
	       'Web Page',
	       qq{
		   select
		    remark as url,
		    remark as description
		   from colleagueremark 
		   where colleagueid = $id and type = 'WWW_Page'
		   },
	       ['url'],
	       []
	       );

# OK background	       
	&print_element(
	       $cgi,
	       $dbh,
	       'background',
	       'Background',
	       qq{
		   select
 		    remark as background
                   from colleagueremark 
                   where colleagueid = $id
                    and type = 'Background'
		   },
	       ['background'],
	       []
	       );    

# OK researchinterest	       
	&print_element(
	       $cgi,
	       $dbh,
	       'researchinterest',
	       'Research Interest',
	       qq{
		   select
 		    remark as researchinterest
                   from colleagueremark 
                   where colleagueid = $id
                    and type = 'Research_Interest'
		   },
	       ['researchinterest'],
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
		   from colleagueimage 
		    inner join image on colleagueimage.imageid = image.id
		   where colleagueimage.colleagueid = $id
		    order by image.name
		   },
	       ['image_link'],
	       []
	       );       
	       
# OK author (displayed as "publishes as")
	&print_element(
	       $cgi,
	       $dbh,
	       'author',
	       'Publishes As',
	       qq{
		   select
		    author.id as author_id,
    		    author.name as author_name
		   from colleague 
		    inner join author on colleague.id = author.fullname_colleagueid
		   where colleague.id = $id
		   },
	       ['author_link'],
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
                   from colleagueremark 
                   where colleagueid = $id
                    and type = 'Remark'
		   },
	       ['remark'],
	       []
	       );       
	       
# OK remark (e.g., research interest, position, profession, background, remark) - NL 29Oct2004 removed to accommodate comment.cgi need for explicit labels
#{
#    my $types = $dbh->selectcol_arrayref("select distinct type 
#                                           from colleagueremark 
#                                          where colleagueid = $id
#                                           and type != 'WWW_Page'
#                                          order by type");
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
#				   from colleagueremark
#				   where colleagueid = %s and type = %s
#				  },$id,$dbh->quote($type)
#			       ),
#		       ['remark'],
#		       []
#		       );
#   }
#}



# OK obtainedfrom (self - colleague)
# 24Jun2004 combined self-colleague and other-colleague per DaveM
# 24Jun2004 later:  added sources w/o colleague or reference link per NL
&print_element(
	       $cgi,
	       $dbh,
	       'obtainedfrom',
	       'Obtained From',
	       qq{
		   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name,
                    s2.name,
                    colleagueobtainedfrom.date
                   from colleagueobtainedfrom
                    inner join source s1 on colleagueobtainedfrom.sourceid = s1.id
                    left join colleague on 
                     -- other colleague
                     (colleague.id = s1.contact_colleagueid and s1.name != 'Direct')
			or
		     -- colleague him/herself
		     (colleague.id = colleagueobtainedfrom.colleagueid and s1.name = 'Direct')
                    left join source s2 on colleagueobtainedfrom.sourceid = s2.id
                     -- do not duplicate colleague and reference sources:
                     and s2.contact_colleagueid is null
                     and s2.referenceid is null
                   where colleagueobtainedfrom.colleagueid = $id
                     and
                    (colleague.name is not null or s2.name is not null)
		   },
	       ['colleague_link','name','date'],
	       []
	       );
# OK obtainedfrom (last_update - colleague)
# 25Jan2005 DLH added to show the new column "last_update"
# in the colleague table
&print_element(
	       $cgi,
	       $dbh,
	       'last_update',
	       'Last Update',
	       qq{
		   select
		       colleague.lastupdate as colleague_lastupdate
		   from colleague
		   where colleague.id = $id
		   },
	       ['colleague_lastupdate','date'],
	       []
	       );

# OK obtainedfrom (reference)
&print_element(
	       $cgi,
	       $dbh,
	       'obtainedfrom',
	       'Obtained From',
	       qq{
		   select
                    reference.id as reference_id,
                    colleagueobtainedfrom.date
                   from colleagueobtainedfrom 
                    inner join source on colleagueobtainedfrom.sourceid = source.id
                    inner join reference on reference.id = source.referenceid
                   where colleagueobtainedfrom.colleagueid = $id
		   },
	       ['reference_id','date'],
	       []
	       );

# OK obtainedfrom (another colleague)
#&print_element(
#	       $cgi,
#	       $dbh,
#	       'obtainedfrom',
#	       'Obtained From',
#	       qq{
#		   select
#                    colleague.id as colleague_id,
#                    colleague.name as colleague_name,
#                    colleagueobtainedfrom.date
#                   from colleagueobtainedfrom 
#                    inner join source on colleagueobtainedfrom.sourceid = source.id
#                    inner join colleague on colleague.id = source.contact_colleagueid
#                   where colleagueobtainedfrom.colleagueid = $id
#		   },
#	       ['colleague_link','date'],
#	       []
#	       );

# OK mapdata
	&print_element(
	       $cgi,
	       $dbh,
	       'mapdata',
	       'Map Data',
	       qq{
		   select
                    mapdatacontact.mapdataid as mapdata_id,
                    mapdata.name as mapdata_name
                   from mapdatacontact
                    inner join mapdata on mapdatacontact.mapdataid = mapdata.id
                   where mapdatacontact.colleagueid = $id
		   },
	       ['mapdata_link'],
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
                    traitstudydatasource.traitstudyid as traitstudy_id,
                    traitstudy.name as traitstudy_name
                   from traitstudydatasource
                    inner join traitstudy on traitstudydatasource.traitstudyid = traitstudy.id
                   where traitstudydatasource.colleagueid = $id
		   },
	       ['traitstudy_link'],
	       []
	       );       
	
1;
