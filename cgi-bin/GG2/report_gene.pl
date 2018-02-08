#!/usr/bin/perl

# DDH 040324

# REMEMBER to update report_marker.pl when any changes made to report_gene.pl
# NL 13Aug2004 Synonym revised ($squeeze)
# NL 19Aug2004 added Candidate locus
# NL 20Aug2004 added link to Marker Report
# NL 29Sep2004 added bgsphoto
# NL 29Oct2004 broke 'remark' out into comment/origin to accommodate comment.cgi
#	NL noticed that elements do not parallel ACEDB report's order, but did not rearrange.
# pending:  compoundgene, componentgene 28Dec2004 -- NL added back to report per DEM
# NL 29Dec2004 added referencealleleandbackground,inheritance,description,firstmutation
 
# print gene report elements
# require from report.cgi


our ($dbh,$cgi,$id,$class);

# name
#&print_element(
#	       $cgi,
#	       $dbh,
#	       'name',
#	       'Gene',
#	       qq{
#		   select name from gene where id = $id
#		   },
#	       ['name'],
#	       []
#	       );

# name & link to marker report
#&print_element(
#	       $cgi,
#	       $dbh,
#	       'name',
#	       'Gene',
#	       qq{
#		   select 
#                   gene.name,
#                   #concat("http://wheat.pw.usda.gov/cgi-bin/GG2/report.cgi?class=marker&id=",marker.id) as url,
#		   concat("$cgiurlpath/report.cgi?class=marker&id=",marker.id) as url,
#                   "Marker Report" as description
#                  from gene
#                   inner join marker on gene.id = marker.geneid
#                    and marker.geneid is not null
#                  where gene.id = $id
#		   },
#	       ['name','url'],
#	       []
#	       );

# name
{
    my $sql = "select 
                name as marker_name
               from marker
               where geneid = $id";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $gene = $sth->fetchall_arrayref({});

    if ( $gene->[0]->{'marker_name'})
    {
      #$gene->[0]->{'gene'} = $cgi->escapeHTML($gene->[0]->{'marker_name'}).'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"$cgiurlpath/report.cgi?class=marker&name=".$gene->[0]->{'marker_name'},-target=>'_blank'},'Marker Report').' ]';
      $gene->[0]->{'gene'} = $cgi->escapeHTML($gene->[0]->{'marker_name'}).'&nbsp;&nbsp;'.'[ '.$cgi->i($cgi->a({-href=>"$cgiurlpath/report.cgi?class=marker&name=".&geturlstring($gene->[0]->{'marker_name'}),-target=>'_blank'},'Marker Report')).' ]';
      delete($gene->[0]->{'marker_name'});
      &print_element(
                   $cgi,
                   $dbh,
                   'name',
                   'Gene',
                   $gene,
                   ['gene_html'],
                   []
                   );
    }
    else   # not in marker table
    {
      &print_element(
                   $cgi,
                   $dbh,
                   'name',
                   'Gene',
  	          qq{
		   select name from gene where id = $id
		   },                   
                   ['name'],
                   []
                   );
    }

}

# fullname
&print_element(
	       $cgi,
	       $dbh,
	       'fullname',
	       'Full Name',
	       qq{
		   select fullname from gene where id = $id
		   },
	       ['fullname'],
	       []
	       );

# synonym
&print_element(
	       $cgi,
	       $dbh,
	       'synonym',
	       'Synonym',
	       qq{
                   select
                    type,
                    gene.id as gene_id,
                    gene.name as gene_name,
                    genesynonym.referenceid as reference_id
                   from genesynonym
                    inner join gene on genesynonym.name = gene.name collate latin1_bin
                   where genesynonym.geneid = $id
                    order by genesynonym.type,gene.name
		   },
	       ['type','gene_link','reference_id'],
	       #['type','gene_link']
	       ['type']
	       );

# geneclass
&print_element(
	       $cgi,
	       $dbh,
	       'geneclass',
	       'Gene Class',
	       qq{
		   select
		       geneclass.id as geneclass_id,
		       geneclass.name as geneclass_name
		       from genegeneclass
		       inner join geneclass on genegeneclass.geneclassid = geneclass.id
		       where genegeneclass.geneid = $id
		       order by geneclass.name
		   },
	       ['geneclass_link'],
	       []
	       );

# orthologousgeneset
&print_element(
	       $cgi,
	       $dbh,
	       'orthologousgeneset',
	       'Orthologous Gene Set',
	       qq{
		   select
		       geneset.id as geneset_id,
		       geneset.name as geneset_name
		       from gene
		       inner join geneset on gene.orthologousgeneset_genesetid = geneset.id
		       where gene.id = $id
		   },
	       ['geneset_link'],
	       []
	       );

# allele
&print_element(
	       $cgi,
	       $dbh,
	       'allele',
	       'Allele',
	       qq{
		   select
		       allele.id as allele_id,
		       allele.name as allele_name
		       from allelegene
		       inner join allele on allelegene.alleleid = allele.id
		       where allelegene.geneid = $id
		       order by allele.name
		   },
	       ['allele_link'],
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
		       from genepathology
		       inner join pathology on genepathology.pathologyid = pathology.id
		       where genepathology.geneid = $id
		       order by pathology.name
		   },
	       ['pathology_link'],
	       []
	       );

# Use locusassociatedgene instead of the duplicative genelocus table.
# locus
#&print_element(
#	       $cgi,
#	       $dbh,
#	       'locus',
#	       'Locus',
#	       qq{
#		   select
#		       locus.id as locus_id,
#		       locus.name as locus_name,
#		       genelocus.howmapped
#		       from genelocus
#		       inner join locus on genelocus.locusid = locus.id
#		       where genelocus.geneid = $id
#		       order by locus.name
#		   },
#	       ['locus_link','howmapped'],
#	       []
#	       );

# locus
&print_element(
	       $cgi,
	       $dbh,
	       'locus',
	       'Locus',
	       qq{
		   select
		       locus.id as locus_id,
		       locus.name as locus_name
		       from locusassociatedgene
		       inner join locus on locusassociatedgene.locusid = locus.id
                       where locusassociatedgene.geneid = $id
		       order by locus.name
		   },
	       ['locus_link'],
	       []
	       );

# OK candidatelocus
&print_element(
	       $cgi,
	       $dbh,
	       'candidatelocus',
	       'Candidate Locus',
	       qq{
		   select
		    locus.id as locus_id,
		    locus.name as locus_name
  	           from genecandidatelocus
		    inner join locus on genecandidatelocus.candidatelocus_locusid = locus.id
 	           where genecandidatelocus.geneid = $id
		   order by locus.name
		   },
	       ['locus_link'],
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
		       from genereference
		       inner join reference on genereference.referenceid = reference.id
		       where genereference.geneid = $id
		       order by reference.year desc
		   },
	       ['reference_id'],
	       []
	       );

# url
&print_element(
	       $cgi,
	       $dbh,
	       'url',
	       'URL',
	       qq{
		   select
		       url,
		       description
		       from geneurl
		       where geneurl.geneid = $id
		   },
	       ['url'],
	       []
	       );

# OK compoundgene
&print_element(
	       $cgi,
	       $dbh,
	       'compoundgene',
	       'Compound Gene',
             qq{
                select
		 compoundgene.id as gene_id,
		 compoundgene.name as gene_name
		from gene 
		 inner join gene as compoundgene on gene.compoundgene_geneid = compoundgene.id
		 where gene.id = $id
		},
	       ['gene_link'],
	       []
	       );

# OK componentgene
&print_element(
	       $cgi,
	       $dbh,
	       'componentgene',
	       'Component Gene',
              qq{
                select
		 gene.id as gene_id,
		 gene.name as gene_name
		from genecomponentgene 
		 inner join gene on genecomponentgene.componentgene_geneid = gene.id
		 where genecomponentgene.geneid = $id
		},
	       ['gene_link'],
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
		       from qtlassociatedgene
		       inner join qtl on qtlassociatedgene.qtlid = qtl.id
		       where qtlassociatedgene.geneid = $id
		       order by qtl.name
		   },
	       ['qtl_link'],
	       []
	       );

# geneproduct
&print_element(
	       $cgi,
	       $dbh,
	       'geneproduct',
	       'Gene Product',
	       qq{
		   select
		       geneproduct.id as geneproduct_id,
		       geneproduct.name as geneproduct_name
		       from genegeneproduct
		       inner join geneproduct on genegeneproduct.geneproductid = geneproduct.id
		       where genegeneproduct.geneid = $id
		       order by geneproduct.name
		   },
	       ['geneproduct_link'],
	       []
	       );

# chromosome
&print_element(
	       $cgi,
	       $dbh,
	       'chromosome',
	       'Chromosome',
	       qq{
		   select
		       genechromosome.chromosome,
		       reference.id as reference_id
		       from genechromosome
		       left join reference on genechromosome.referenceid = reference.id
		       where genechromosome.geneid = $id
		       order by genechromosome.chromosome
		   },
	       ['chromosome','reference_id'],
	       ['chromosome']
	       );

# chromosomearm
&print_element(
	       $cgi,
	       $dbh,
	       'chromosomearm',
	       'Chromosome Arm',
	       qq{
		   select
		       genechromosomearm.chromosomearm,
		       reference.id as reference_id
		       from genechromosomearm
		       left join reference on genechromosomearm.referenceid = reference.id
		       where genechromosomearm.geneid = $id
		       order by genechromosomearm.chromosomearm
		   },
	       ['chromosomearm','reference_id'],
	       ['chromosomearm']
	       );

# germplasm
&print_element(
	       $cgi,
	       $dbh,
	       'germplasm',
	       'Germplasm',
	       qq{
		   select
		       genegermplasm.type,
		       germplasm.id as germplasm_id,
		       germplasm.name as germplasm_name,
		       reference.id as reference_id
		       from genegermplasm
		       inner join germplasm on genegermplasm.germplasmid = germplasm.id
		       left join reference on genegermplasm.referenceid = reference.id
		       where genegermplasm.geneid = $id
		       order by genegermplasm.type,germplasm.name
		   },
	       ['type','germplasm_link','reference_id'],
	       #['type','germplasm_name']
	       ['type']
	       );

# ok origin
&print_element(
	       $cgi,
	       $dbh,
	       'origin',
	       'Origin',
	       qq{
		   select
  	            remark as origin
		   from generemark
		   where geneid = $id
		    and type = 'Origin'
		   },
	       ['origin'],
	       []
	       );

# referencealleleandbackground (UNTESTED as no ACEDB objects with this tag NL29Dec2004)
# will likely need some tweaking once actual data available, as multiple germplasms for given allele. NL
&print_element(
	       $cgi,
	       $dbh,
	       'referencealleleandbackground',
	       'Reference Allele and Background',
	       qq{
		   select
		    allele.id as allele_id,
		    allele.name as allele_name,
		    germplasm.id as germplasm_id,
		    germplasm.name as germplasm_name
		   from genereferencealleleandbackground
		    inner join allele on genereferencealleleandbackground.alleleid = allele.id
		    left join germplasm on genereferencealleleandbackground.germplasmid = germplasm.id
	           where genereferencealleleandbackground.geneid = $id
		    order by allele.name, germplasm.name
		   },
	       ['allele_link','germplasm_link'],
	       []
	       );
	       
# inheritance (UNTESTED as no ACEDB objects with this tag NL29Dec2004)
&print_element(
	       $cgi,
	       $dbh,
	       'inheritance',
	       'Inheritance',
	       qq{
		   select
		    inheritance
		   from geneinheritance
	           where geneinheritance.geneid = $id
		   },
	       ['inheritance'],
	       []
	       );
	       
# description (UNTESTED as no ACEDB objects with this tag NL29Dec2004)
&print_element(
	       $cgi,
	       $dbh,
	       'description',
	       'Description',
	       qq{
		   select
		    description
		   from genedescription
	           where genedescription.geneid = $id
		   },
	       ['description'],
	       []
	       );

# firstmutation (UNTESTED as no ACEDB objects with this tag NL29Dec2004)
&print_element(
	       $cgi,
	       $dbh,
	       'firstmutation',
	       'First Mutation',
	       qq{
		   select
		    firstmutation
		   from genefirstmutation
	           where genefirstmutation.geneid = $id
		   },
	       ['firstmutation'],
	       []
	       );

# ok comment
&print_element(
	       $cgi,
	       $dbh,
	       'comment',
	       'Comment',
	       qq{
		   select
  	            remark as comment
		   from generemark
		   where geneid = $id
		    and type = 'Comment'
		   },
	       ['comment'],
	       []
	       );

# remark
# print separate elements for each type
# use type as element and label
#{
#   my $types = $dbh->selectcol_arrayref("select distinct type from generemark where geneid = $id order by type");
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
#				       from generemark
#				       where geneid = %s and type = %s
#				  },$id,$dbh->quote($type)
#			       ),
#		       ['remark'],
#		       []
#		       );
#   }
#}

# clone
&print_element(
	       $cgi,
	       $dbh,
	       'clone',
	       'Clone',
	       qq{
		   select
		       probe.id as probe_id,
		       probe.name as probe_name
		       from geneclone
		       inner join probe on geneclone.probeid = probe.id
		       where geneclone.geneid = $id
		       order by probe.name
		   },
	       ['probe_link'],
	       []
	       );

# sequence
&print_element(
	       $cgi,
	       $dbh,
	       'sequence',
	       'Sequence',
	       qq{
		   select
		       sequence.id as sequence_id,
		       sequence.name as sequence_name
		       from genesequence
		       inner join sequence on genesequence.sequenceid = sequence.id
		       where genesequence.geneid = $id
		       order by sequence.name
		   },
	       ['sequence_link'],
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
		       from geneimage
		       inner join image on geneimage.imageid = image.id
		       where geneimage.geneid = $id
		       order by image.name
		   },
	       ['image_link'],
	       []
	       );

# OK bgsphoto
{
    my $sql = "select 
                name 
               from genebgsphoto
               where geneid = $id";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $name = $sth->fetchall_arrayref({});
    
    if ( $name )
    {  
      foreach my $n (@$name)
      {
        #$n->{'name'} = $cgi->escapeHTML($n->{'name'}).'&nbsp;&nbsp;'.'[ '.$cgi->a({-href=>"http://ace.untamo.net/cgi-bin/ace/tree/default?name=".$n->{'name'}."&class=Image",-target=>'_blank'},'BGS Database').' ]';
        $n->{'name'} = $cgi->escapeHTML($n->{'name'}).'&nbsp;&nbsp;'.'[ '.$cgi->i($cgi->a({-href=>"http://ace.untamo.net/cgi-bin/ace/tree/default?name=".$n->{'name'}."&class=Image",-target=>'_blank'},'BGS Database')).' ]';
      } # end foreach
      &print_element(
                   $cgi,
                   $dbh,
                   'name',
                   'BGS Photo',
                   $name,
                   ['name_html'],
                   []
                   );

    } # end if
}

# twopointdata
&print_element(
	       $cgi,
	       $dbh,
	       'twopointdata',
	       '2 Point Data',
	       qq{
		   select
		       twopointdata.id as twopointdata_id,
		       twopointdata.name as twopointdata_name
		       from genetwopointdata
		       inner join twopointdata on genetwopointdata.twopointdataid = twopointdata.id
		       where genetwopointdata.geneid = $id
		       order by twopointdata.name
		   },
	       ['twopointdata_link'],
	       []
	       );

# wgcreference
&print_element(
	       $cgi,
	       $dbh,
	       'wgcreference',
	       'Wheat Gene Catalog Reference',
	       qq{
		   select
		       reference.id as reference_id,
		       genewgcreference.number
		       from genewgcreference
		       inner join reference on genewgcreference.referenceid = reference.id
		       where genewgcreference.geneid = $id
		       order by reference.year desc
		   },
	       ['number','reference_id'],
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
		       genedatasource.date
		       from genedatasource
		       inner join colleague on genedatasource.colleagueid = colleague.id
		       where genedatasource.geneid = $id
		       order by colleague.name
		   },
	       ['colleague_link','date'],
	       []
	       );

# infosource
&print_element(
	       $cgi,
	       $dbh,
	       'infosource',
	       'Info Source',
	       qq{
		   select
		       reference.id as reference_id
		       from geneinfosource
		       inner join reference on geneinfosource.referenceid = reference.id
		       where geneinfosource.geneid = $id
		   },
	       ['reference_id'],
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
		       genedatacurator.date
		       from genedatacurator
		       inner join colleague on genedatacurator.colleagueid = colleague.id
		       where genedatacurator.geneid = $id
		       order by colleague.name
		   },
	       ['colleague_link','date'],
	       []
	       );

1;
