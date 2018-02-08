#!/usr/bin/perl

# DDH 040416
# NL 04Oct2004 to italicize image link

# print image report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class,$dbimagepath);

# name
&print_element(
	       $cgi,
	       $dbh,
	       'name',
	       'Image Name',
	       qq{
		   select name from image where id = $id
		   },
	       ['name'],
	       []
	       );

# continuedfrom
&print_element(
	       $cgi,
	       $dbh,
	       'continuedfrom',
	       'Continued From',
	       qq{
		   select
		       b.id as image_id,
		       b.name as image_name
		       from image
		       inner join image as b on image.continuedfrom_imageid = b.id
		       where image.id = $id
		   },
	       ['image_link'],
	       []
	       );

# gene
&print_element(
	       $cgi,
	       $dbh,
	       'gene',
	       'Gene',
	       qq{
		   select
		       gene.id as gene_id,
		       gene.name as gene_name
		       from geneimage
		       inner join gene on geneimage.geneid = gene.id
		       where geneimage.imageid = $id
		       order by gene.name
		   },
	       ['gene_link'],
	       []
	       );

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
		       from locusimage
		       inner join locus on locusimage.locusid = locus.id
		       where locusimage.imageid = $id
		       order by locus.name
		   },
	       ['locus_link'],
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
		       from alleleimage
		       inner join allele on alleleimage.alleleid = allele.id
		       where alleleimage.imageid = $id
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
		       from pathologyimage
		       inner join pathology on pathologyimage.pathologyid = pathology.id
		       where pathologyimage.imageid = $id
		       order by pathology.name
		   },
	       ['pathology_link'],
	       []
	       );

# probe
&print_element(
	       $cgi,
	       $dbh,
	       'probe',
	       'Probe',
	       qq{
		   select
		       probe.id as probe_id,
		       probe.name as probe_name
		       from probeimage
		       inner join probe on probeimage.probeid = probe.id
		       where probeimage.imageid = $id
		       order by probe.name
		   },
	       ['probe_link'],
	       []
	       );

# polymorphism
&print_element(
	       $cgi,
	       $dbh,
	       'polymorphism',
	       'Polymorphism',
	       qq{
		   select
		       polymorphism.id as polymorphism_id,
		       polymorphism.name as polymorphism_name
		       from polymorphismimage
		       inner join polymorphism on polymorphismimage.polymorphismid = polymorphism.id
		       where polymorphismimage.imageid = $id
		       order by polymorphism.name
		   },
	       ['polymorphism_link'],
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
		       from qtlimage
		       inner join qtl on qtlimage.qtlid = qtl.id
		       where qtlimage.imageid = $id
		       order by qtl.name
		   },
	       ['qtl_link'],
	       []
	       );

# germplasm
&print_element(
	       $cgi,
	       $dbh,
	       'germplasm',
	       'Germplasm',
	       qq{
		   select
		       germplasm.id as germplasm_id,
		       germplasm.name as germplasm_name
		       from germplasmimage
		       inner join germplasm on germplasmimage.germplasmid = germplasm.id
		       where germplasmimage.imageid = $id
		       order by germplasm.name
		   },
	       ['germplasm_link'],
	       []
	       );

# species
&print_element(
	       $cgi,
	       $dbh,
	       'species',
	       'Species',
	       qq{
		   select
		       species.id as species_id,
		       species.name as species_name
		       from speciesimage
		       inner join species on speciesimage.speciesid = species.id
		       where speciesimage.imageid = $id
		       order by species.name
		   },
	       ['species_link'],
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
		       from mapdataimage
		       inner join mapdata on mapdataimage.mapdataid = mapdata.id
		       where mapdataimage.imageid = $id
		       order by mapdata.name
		   },
	       ['mapdata_link'],
	       []
	       );

# colleague
&print_element(
	       $cgi,
	       $dbh,
	       'colleague',
	       'Colleague',
	       qq{
		   select
		       colleague.id as colleague_id,
		       colleague.name as colleague_name
		       from colleagueimage
		       inner join colleague on colleagueimage.colleagueid = colleague.id
		       where colleagueimage.imageid = $id
		       order by colleague.name
		   },
	       ['colleague_link'],
	       []
	       );

# traitstudy
&print_element(
	       $cgi,
	       $dbh,
	       'traitstudy',
	       'Trait Study',
	       qq{
		   select
		       traitstudy.id as traitstudy_id,
		       traitstudy.name as traitstudy_name
		       from traitstudyimage
		       inner join traitstudy on traitstudyimage.traitstudyid = traitstudy.id
		       where traitstudyimage.imageid = $id
		       order by traitstudy.name
		   },
	       ['traitstudy_link'],
	       []
	       );

# author
&print_element(
	       $cgi,
	       $dbh,
	       'author',
	       'Author',
	       qq{
		   select
		       author.id as author_id,
		       author.name as author_name
		       from authorimage
		       inner join author on authorimage.authorid = author.id
		       where authorimage.imageid = $id
		       order by author.name
		   },
	       ['author_link'],
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
		       reference.id as reference_id,
		       reference.name as reference_name
		       from referenceimage
		       inner join reference on referenceimage.referenceid = reference.id
		       where referenceimage.imageid = $id
		       order by reference.year desc
		   },
	       ['reference_link'],
	       []
	       );

# caption
&print_element(
	       $cgi,
	       $dbh,
	       'caption',
	       'Caption',
	       qq{
		   select
		       caption
		       from imagecaption
		       where imageid = $id
		   },
	       ['caption'],
	       []
	       );

# image
{
    my $sql = "select filename from image where id = $id";
    my $sth = $dbh->prepare($sql); $sth->execute;
    my $image = $sth->fetchall_arrayref({});
    if ($image->[0]->{'filename'} && -r "$ENV{'DOCUMENT_ROOT'}$dbimagepath/$image->[0]->{'filename'}") {
	#$image->[0]->{'image'} = '[ '.$cgi->a({-href=>"$dbimagepath/".$image->[0]->{'filename'},-target=>'_blank'},'Direct Link').' ]';
	$image->[0]->{'image'} = '[ '.$cgi->i($cgi->a({-href=>"$dbimagepath/".$image->[0]->{'filename'},-target=>'_blank'},'Direct Link')).' ]';
	$image->[1]->{'image'} = $cgi->img({-src=>"$dbimagepath/".$image->[0]->{'filename'}});
	delete($image->[0]->{'filename'});
    } elsif ($image->[0]->{'filename'}) {
	$image->[0]->{'image'} = $cgi->escapeHTML("[ Image $image->[0]->{'filename'} unavailable ]");
	delete($image->[0]->{'filename'});
    } else {
	$image->[0]->{'image'} = $cgi->escapeHTML("[ Image unavailable ]");
	delete($image->[0]->{'filename'});
    }
    &print_element(
		   $cgi,
		   $dbh,
		   'image',
		   'Image',
		   $image,
		   ['image_html'],
		   []
		   );
}

1;
