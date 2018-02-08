#!/usr/bin/perl

# DDH 040416
# rev. NL 29Oct2004 to break traitstudyremark into separate elements to accommodate comment.cgi
# rev. NL 22Dec2004 added germplasmdescription, germplasmscore, parentalmeansd, phenotypicr2, geneticr2
# rev. DEM 31oct05: Added ontology external links (gramene).

# print traitstudy report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# name
&print_element(
	       $cgi,
	       $dbh,
	       'name',
	       'Trait Study',
	       qq{
		   select name from traitstudy where id = $id
		   },
	       ['name'],
	       []
	       );

# trait
&print_element(
	       $cgi,
	       $dbh,
	       'trait',
	       'Trait',
	       qq{
		   select
		       trait.id as trait_id,
		       trait.name as trait_name
		       from traitstudy
		       inner join trait on traitstudy.traitid = trait.id
		       where traitstudy.id = $id
		   },
	       ['trait_link'],
	       []
	       );

# pathology
&print_element(
	       $cgi,
	       $dbh,
	       'pathology',
	       'Pathology',
	       qq{
		   select
		       pathology.id as pathology_id,
		       pathology.name as pathology_name
		       from traitstudy
		       inner join pathology on traitstudy.pathologyid = pathology.id
		       where traitstudy.id = $id
		   },
	       ['pathology_link'],
	       []
	       );

# reference
&print_element(
	       $cgi,
	       $dbh,
	       'reference',
	       'Reference',
	       qq{
		   select
		       reference.id as reference_id
		       from traitstudyreference
		       inner join reference on traitstudyreference.referenceid = reference.id
		       where traitstudyreference.traitstudyid = $id
		       order by reference.year desc
		   },
	       ['reference_id'],
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
 	            remark as description
 	           from traitstudyremark
	           where traitstudyid = $id
	            and type = 'Description'
		   },
	       ['description'],
	       []
	       );

# OK protocol
&print_element(
	       $cgi,
	       $dbh,
	       'protocol',
	       'Protocol',
	       qq{
		   select
 	            remark as protocol
 	           from traitstudyremark
	           where traitstudyid = $id
	            and type = 'Protocol'
		   },
	       ['protocol'],
	       []
	       );

# remark - NL 29Oct2004 replaced with separate calls for 7 elements of traitstudyremark to accommodate comment.cgi
# print separate elements for each type
# use type as element and label
#{
#    my $types = $dbh->selectcol_arrayref("select distinct type from traitstudyremark where traitstudyid = $id order by type");
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
#				       remark
#				       from traitstudyremark
#				       where traitstudyid = %s and type = %s
#				  },$id,$dbh->quote($type)
#			       ),
#		       ['remark'],
#		       []
#		       );
#    }
#}

# ontology
# Edit 05.2017 Directed ontologies to Planteome -> Gramene has been archived
&print_element(
	       $cgi,
	       $dbh,
	       'ontology',
	       'Ontology',
	       qq{
		   select
		       accession,
		       "Planteome" as description,
		       concat("http://browser.planteome.org/amigo/term/",accession) as url,
		       remark
		       from traitstudyontology
		       where traitstudyid = $id
		   },
	       ['accession','url','remark'],
	       []
	       );

# OK value
&print_element(
	       $cgi,
	       $dbh,
	       'value',
	       'Values',
	       qq{
		   select
 	            remark as value
 	           from traitstudyremark
	           where traitstudyid = $id
	            and type = 'Values'
		   },
	       ['value'],
	       []
	       );
# environment
&print_element(
	       $cgi,
	       $dbh,
	       'environment',
	       'Environment',
	       qq{
		   select
		       environment.id as environment_id,
		       environment.name as environment_name
		       from traitstudyenvironment
		       inner join environment on traitstudyenvironment.environmentid = environment.id
		       where traitstudyenvironment.traitstudyid = $id
		       order by environment.name
		   },
	       ['environment_link'],
	       []
	       );

# parentaldescription
&print_element(
	       $cgi,
	       $dbh,
	       'parentaldescription',
	       'Parental Description',
	       qq{
		   select
		       germplasm.id as germplasm_id,
		       germplasm.name as germplasm_name,
		       traitstudyparentaldescription.description
		       from traitstudyparentaldescription
		       inner join germplasm on traitstudyparentaldescription.germplasmid = germplasm.id
		       where traitstudyparentaldescription.traitstudyid = $id
		       order by germplasm.name
		   },
	       ['germplasm_link','description'],
	       []
	       );

# OK parentalmeansd
&print_element(
	       $cgi,
	       $dbh,
	       'parentalmeansd',
	       'Parental Mean SD',
	       qq{
		   select
		    germplasm.id as germplasm_id,
		    germplasm.name as germplasm_name,
		    traitstudyparentalmeansd.stddevone,
		    traitstudyparentalmeansd.stddevtwo
		   from traitstudyparentalmeansd
		    inner join germplasm on traitstudyparentalmeansd.germplasmid = germplasm.id
		   where traitstudyparentalmeansd.traitstudyid = $id
		    order by germplasm.name
		   },
	       ['germplasm_link','stddevone','stddevtwo'],
	       []
	       );
	       
# mapdata
&print_element(
	       $cgi,
	       $dbh,
	       'mapdata',
	       'Map Data',
	       qq{
		   select
		       mapdata.id as mapdata_id,
		       mapdata.name as mapdata_name
		       from traitstudy
		       inner join mapdata on traitstudy.mapdataid = mapdata.id
		       where traitstudy.id = $id
		   },
	       ['mapdata_link'],
	       []
	       );

# populationsize
&print_element(
	       $cgi,
	       $dbh,
	       'populationsize',
	       'Population Size',
	       qq{
		   select populationsize from traitstudy where id = $id
		   },
	       ['populationsize'],
	       []
	       );

# populationtype
&print_element(
	       $cgi,
	       $dbh,
	       'populationtype',
	       'Population Type',
	       qq{
		   select populationtype from traitstudy where id = $id
		   },
	       ['populationtype'],
	       []
	       );

# qtlanalysismethod
&print_element(
	       $cgi,
	       $dbh,
	       'qtlanalysismethod',
	       'QTL Analysis Method',
	       qq{
		   select
		       qtlanalysismethod
		       from traitstudyqtlanalysismethod
		       where traitstudyid = $id
		   },
	       ['qtlanalysismethod'],
	       []
	       );

# OK statistics
&print_element(
	       $cgi,
	       $dbh,
	       'statistics',
	       'Statistics',
	       qq{
		   select
 	            remark as statistics
 	           from traitstudyremark
	           where traitstudyid = $id
	            and type = 'Statistics'
		   },
	       ['statistics'],
	       []
	       );


# heritability
&print_element(
	       $cgi,
	       $dbh,
	       'heritability',
	       'Heritability',
	       qq{
		   select
		       heritability,
		       description
		       from traitstudyheritability
		       where traitstudyid = $id
		   },
	       ['heritability','description'],
	       []
	       );

# OK typeierror
&print_element(
	       $cgi,
	       $dbh,
	       'typeierror',
	       'Type I error rate per locus',
	       qq{
		   select
 	            remark as typeierror
 	           from traitstudyremark
	           where traitstudyid = $id
	            and type = 'Type_I_error_rate_per_locus'
		   },
	       ['typeierror'],
	       []
	       );

# markerstested
&print_element(
	       $cgi,
	       $dbh,
	       'markerstested',
	       'Markers Tested',
	       qq{
		   select markerstested from traitstudy where id = $id
		   },
	       ['markerstested'],
	       []
	       );

# qtlsfound
&print_element(
	       $cgi,
	       $dbh,
	       'qtlsfound',
	       'QTLs Found',
	       qq{
		   select qtlsfound from traitstudy where id = $id
		   },
	       ['qtlsfound'],
	       []
	       );

# OK phenotypicr2 
&print_element(
	       $cgi,
	       $dbh,
	       'phenotypicr2',
	       'Phenotypic R2',
	       qq{
		   select
 	            phenotypicr2,
 	            comments
 	           from traitstudyphenotypicr2
	           where traitstudyid = $id
		   },
	       ['phenotypicr2','comments'],
	       []
	       );
	       
# OK geneticr2 
&print_element(
	       $cgi,
	       $dbh,
	       'geneticr2',
	       'Genetic R2',
	       qq{
		   select
 	            geneticr2
 	           from traitstudygeneticr2
	           where traitstudyid = $id
		   },
	       ['geneticr2'],
	       []
	       );
	       
# OK rsqdefinition
&print_element(
	       $cgi,
	       $dbh,
	       'rsqdefinition',
	       'R2 Definition',
	       qq{
		   select
 	            remark as rsqdefinition
 	           from traitstudyremark
	           where traitstudyid = $id
	            and type = 'R2_definition'
		   },
	       ['rsqdefinition'],
	       []
	       );

# OK comment
&print_element(
	       $cgi,
	       $dbh,
	       'comment',
	       'Comment',
	       qq{
		   select
 	            remark as comment
 	           from traitstudyremark
	           where traitstudyid = $id
	            and type = 'Comment'
		   },
	       ['comment'],
	       []
	       );

# image
&print_element(
	       $cgi,
	       $dbh,
	       'image',
	       'Image',
	       qq{
		   select
		       image.id as image_id,
		       image.name as image_name
		       from traitstudyimage
		       inner join image on traitstudyimage.imageid = image.id
		       where traitstudyimage.traitstudyid = $id
		       order by image.name
		   },
	       ['image_link'],
	       []
	       );

# qtl
&print_element(
	       $cgi,
	       $dbh,
	       'qtl',
	       'QTL',
	       qq{
		   select
		       qtl.id as qtl_id,
		       qtl.name as qtl_name
		       from qtltraitstudy
		       inner join qtl on qtltraitstudy.qtlid = qtl.id
		       where qtltraitstudy.traitstudyid = $id
		       order by qtl.name
		   },
	       ['qtl_link'],
	       []
	       );

# OK germplasmdescription
{
    # get germplasmid
    my $sql = "select
                distinct 
                germplasm.id as germplasm_id,
                germplasm.name as germplasm_name
               from traitstudygermplasmdescription
                inner join germplasm on traitstudygermplasmdescription.germplasmid = germplasm.id
               where traitstudygermplasmdescription.traitstudyid = $id
                order by germplasm.name";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $germplasmdescription = $sth->fetchall_arrayref({});
    
    if ($germplasmdescription)
    {
      foreach my $gd (@$germplasmdescription)	
      { 
        $gd->{'germplasmdescription'} = $cgi->a({-href=>"$cgiurlpath/report.cgi?class=germplasm;name=".&geturlstring($gd->{'germplasm_name'})},$gd->{'germplasm_name'});
        
        my $sql = sprintf(qq{
                             select 
                              characteristicone,
                              characteristictwo
                             from traitstudygermplasmdescription
                             where traitstudyid = $id
                              and germplasmid = %s
                            },$gd->{'germplasm_id'}
                         );
        my $sth = $dbh->prepare($sql); $sth->execute;
        my $value = $sth->fetchall_arrayref({});
        
	if ($value)
        { 
          foreach my $v (@$value)
          {
            $gd->{'germplasmdescription'} .= '<br>'.$cgi->escapeHTML($v->{'characteristicone'}).'&nbsp;&nbsp;&nbsp;'.$cgi->escapeHTML($v->{'characteristictwo'});
            delete($v->{'characteristicone'});
            delete($v->{'characteristictwo'});
          } # end foreach trait value
        } # end if value
        delete($gd->{'germplasm_id'});
        delete($gd->{'germplasm_name'});
      } # end foreach germplasmdescription
          &print_element(
                   $cgi,
                   $dbh,
                   'germplasmdescription',
                   'Germplasm Description',
                   $germplasmdescription,
                   ['germplasmdescription_html'],
                   []
                   );
    } # end if germplasmdescription
} # end germplasmdescription 

# OK germplasmscore
&print_element(
	       $cgi,
	       $dbh,
	       'germplasmscore',
	       'Germplasm Score',
	       qq{
		   select
		    germplasm.id as germplasm_id,
		    germplasm.name as germplasm_name,
		    traitstudygermplasmscore.germplasmscore,
		    traitstudygermplasmscore.units
		   from traitstudygermplasmscore
		    inner join germplasm on traitstudygermplasmscore.germplasmid = germplasm.id
		   where traitstudygermplasmscore.traitstudyid = $id
		    order by germplasm.name
		   },
	       ['germplasm_link','germplasmscore','units'],
	       []
	       );
	       
# traitscore
&print_element(
	       $cgi,
	       $dbh,
	       'traitscore',
	       'Trait Score',
	       qq{
		   select
		       traitscore.id as traitscore_id,
		       traitscore.name as traitscore_name
		       from traitstudytraitscore
		       inner join traitscore on traitstudytraitscore.traitscoreid = traitscore.id
		       where traitstudytraitscore.traitstudyid = $id
		       order by traitscore.name
		   },
	       ['traitscore_link'],
	       []
	       );

# datasource
&print_element(
	       $cgi,
	       $dbh,
	       'datasource',
	       'Data Source',
	       qq{
		   select
		       colleague.id as colleague_id,
		       colleague.name as colleague_name,
		       traitstudydatasource.date
		       from traitstudydatasource
		       inner join colleague on traitstudydatasource.colleagueid = colleague.id
		       where traitstudydatasource.traitstudyid = $id
		       order by colleague.name
		   },
	       ['colleague_link','date'],
	       []
	       );

# datacurator
&print_element(
	       $cgi,
	       $dbh,
	       'datacurator',
	       'Data Curator',
	       qq{
		   select
		       colleague.id as colleague_id,
		       colleague.name as colleague_name,
		       traitstudydatacurator.date
		       from traitstudydatacurator
		       inner join colleague on traitstudydatacurator.colleagueid = colleague.id
		       where traitstudydatacurator.traitstudyid = $id
		       order by colleague.name
		   },
	       ['colleague_link','date'],
	       []
	       );

1;
