#!/usr/bin/perl

# NLui, 29Apr2004

# print collection report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'collection',
	       'Collection',
	       qq{
		   select name 
		   from collection 
		   where id = $id
		   },
	       ['name'],
	       []
	       );

# OK curator
&print_element(
               $cgi,
               $dbh,
               'curator',
               'Curator',
               qq{
                   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name
                   from colleague
                    inner join collection
                     on colleague.id = collection.curator_colleagueid
                   where collection.id = $id
                   },
               ['colleague_link'],
               []
               );	       
# OK mail
&print_element(
	       $cgi,
	       $dbh,
	       'mail',
	       'Mail',
	       qq{
		   select mail 
		   from collection 
		   where id = $id
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
		   select country 
		   from collection 
		   where id = $id
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
		   select phone 
		   from collection 
		   where id = $id
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
		   select fax 
		   from collection 
		   where id = $id
		   },
	       ['fax'],
	       []
	       );
# OK email (some weird email addresses)
 &print_element(
	       $cgi,
	       $dbh,
	       'email',
	       'Email',
	       qq{
		   select 
		    concat("mailto:",email) as url,
                    email as description
		   from collection 
		   where id = $id
		    and email is not null
		   },
	       ['url'],
	       []
	       );
# OK cable
&print_element(
	       $cgi,
	       $dbh,
	       'cable',
	       'Cable',
	       qq{
		   select cable 
		   from collection 
		   where id = $id
		   },
	       ['cable'],
	       []
	       );
	       
# OK telex
&print_element(
	       $cgi,
	       $dbh,
	       'telex',
	       'Telex',
	       qq{
		   select telex 
		   from collection 
		   where id = $id
		   },
	       ['telex'],
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
                    from collectionremark
                   where collectionid = $id
                    and type = 'Description'
		   },
	       ['remark'],
	       []
	       );

# pleasesee: "used only twice" not in schema -- later removed per DaveM

# OK containedin 
&print_element(
               $cgi,
               $dbh,
               'containedin',
               'Contained in',
               qq{
                   select
                    b.id as collection_id,
                    b.name as collection_name
                   from collection as a, collection as b
	            where b.id = a.containedin_collectionid
	             and a.id = $id
                   },
               ['collection_link'],
               []
               );
# OK contains
&print_element(
               $cgi,
               $dbh,
               'contains',
               'Contains',
               qq{
                   select
                    a.id as collection_id,
                    a.name as collection_name
                   from collection as a, collection as b
	            where b.id = a.containedin_collectionid
	             and b.id = $id
                   },
               ['collection_link'],
               []
               );
# OK ipgricode
&print_element(
	       $cgi,
	       $dbh,
	       'ipgricode',
	       'IPGRI code',
	       qq{
		   select ipgricode 
		   from collection 
		   where id = $id
		   },
	       ['ipgricode'],
	       []
	       );

# pleasesee
&print_element(
               $cgi,
               $dbh,
               'pleasesee',
               'Please see',
               qq{
                   select
                    b.id as collection_id,
                    b.name as collection_name
                   from collection as a, collection as b
	            where b.id = a.pleasesee_collectionid
	             and a.id = $id
                   },
               ['collection_link'],
               []
               );

# OK wwwpage
&print_element(
	       $cgi,
	       $dbh,
	       'wwwpage',
	       'Web Page',
	       qq{
	           select
		    remark as url
                    from collectionremark
                   where collectionid = $id
                    and type = 'WWW_page'
		   },
	       ['url'],
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
                    species.name as species_name,
                    collectionspecies.entries
                   from species
                    inner join collectionspecies
                     on species.id = collectionspecies.speciesid
                   where collectionspecies.collectionid = $id
                   },
               ['species_link','entries'],
               []
               );

# entries removed from schema

# OK update (text instead of source_link, as only value is IGPRI, other_name removed from schema)
&print_element(
               $cgi,
               $dbh,
               'update',
               'Update',
               qq{
                   select
                    source.name,
                    collectionupdate.date
                   from source
                    inner join collectionupdate
                     on source.id = collectionupdate.sourceid
                   where collectionupdate.collectionid = $id
                   },
               ['name','date'],
               []
               );

# OK datasource (source - results similar to collectionupdate:  all IPGRI)
&print_element(
               $cgi,
               $dbh,
               'datasource',
               'Data Source',
               qq{
                   select
                    source.name,
                    collectiondatasource.date
                   from source
                    inner join collectiondatasource
                     on source.id = collectiondatasource.sourceid
                   where collectiondatasource.collectionid = $id
                    and source.contact_colleagueid is null
                    and source.referenceid is null
                    and source.journalid is null
                   },
               ['name','date'],
               []
               );

# OK datasource (colleague - 21; no 'Direct')
&print_element(
               $cgi,
               $dbh,
               'datasource',
               'Data Source',
               qq{
                   select
                    colleague.id as colleague_id,
                    colleague.name as colleague_name,
                    collectiondatasource.date
                   from colleague
                    inner join source on colleague.id = source.contact_colleagueid
                    inner join collectiondatasource
                     on source.id = collectiondatasource.sourceid
                   where collectiondatasource.collectionid = $id
                    and source.contact_colleagueid is not null
                   },
               ['colleague_link','date'],
               []
               );

# ? datasource (reference -- no data)
&print_element(
               $cgi,
               $dbh,
               'datasource',
               'Data Source',
               qq{
                   select
                    reference.id as reference_id,
                    reference.name as reference_name,
                    collectiondatasource.date
                   from reference
                    inner join source on reference.id = source.referenceid
                    inner join collectiondatasource
                     on source.id = collectiondatasource.sourceid
                   where collectiondatasource.collectionid = $id
                    and source.referenceid is not null
                   },
               ['reference_link','date'],
               []
               );

# ? datasource (journal -- no data)
&print_element(
               $cgi,
               $dbh,
               'datasource',
               'Data Source',
               qq{
                   select
                    journal.id as journal_id,
                    journal.name as journal_name,
                    collectiondatasource.date
                   from journal
                    inner join source on journal.id = source.journalid
                    inner join collectiondatasource
                     on source.id = collectiondatasource.sourceid
                   where collectiondatasource.collectionid = $id
                    and source.journalid is not null
                   },
               ['journal_link','date'],
               []
               );               

1;
