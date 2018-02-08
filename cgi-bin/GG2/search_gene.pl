#!/usr/bin/perl

# missing: compoundgene, componentgene

our $search_elements = {

'order' => [qw/
	    name
	    fullname
	    synonym
	    geneclass
	    orthologousgeneset
	    allele
	    pathology
	    locus
	    reference
	    url
	    qtl
	    geneproduct
	    chromosome
	    germplasm
	    species
	    remark
	    clone
	    sequence
	    image
	    twopointdata
	    wgcreference
	    datasource
	    infosource
	    datacurator
	    /],

'name' => {
    'realname' => 'Name',
    'sql' => qq{
	select id from gene
	},
    'searchcols' => ['name']
},

'fullname' => {
    'realname' => 'Full Name',
    'sql' => qq{
	select id from gene
	},
    'searchcols' => ['fullname']
},

'synonym' => {
    'realname' => 'Synonym',
    'sql' => qq{
	select distinct
	    genesynonym.geneid
	    from genesynonym
	    left join reference on genesynonym.referenceid = reference.id
	},
    'searchcols' => ['genesynonym.type','genesynonym.name','reference.title']
},

'geneclass' => {
    'realname' => 'Gene Class',
    'sql' => qq{
	select distinct
	    genegeneclass.geneid
	    from genegeneclass
	    inner join geneclass on genegeneclass.geneclassid = geneclass.id
	},
    'searchcols' => ['geneclass.name']
},

'orthologousgeneset' => {
    'realname' => 'Orthologous Gene Set',
    'sql' => qq{
	select
	    gene.id
	    from gene
	    inner join geneset on gene.orthologousgeneset_genesetid = geneset.id
	},
    'searchcols' => ['geneset.name']
},

'allele' => {
    'realname' => 'Allele',
    'sql' => qq{
	select distinct
	    allelegene.geneid
	    from allelegene
	    inner join allele on allelegene.alleleid = allele.id
	},
    'searchcols' => ['allele.name']
},

'pathology' => {
    'realname' => 'Pathology',
    'sql' => qq{
	select distinct
	    genepathology.geneid
	    from genepathology
	    inner join pathology on genepathology.pathologyid = pathology.id
	},
    'searchcols' => ['pathology.name']
},

'locus' => {
    'realname' => 'Locus',
    'sql' => qq{
	select distinct
	    genelocus.geneid
	    from genelocus
	    inner join locus on genelocus.locusid = locus.id
	},
    'searchcols' => ['locus.name','genelocus.howmapped']
},

'reference' => {
    'realname' => 'Reference',
    'sql' => qq{
	select distinct
	    genereference.geneid
	    from genereference
	    inner join reference on genereference.referenceid = reference.id
	},
    'searchcols' => ['reference.name','reference.title']
},

'url' => {
    'realname' => 'URL',
    'sql' => qq{
	select distinct
	    geneid
	    from geneurl
	},
    'searchcols' => ['url','description']
},

'qtl' => {
    'realname' => 'QTL',
    'sql' => qq{
	select distinct
	    qtlassociatedgene.geneid
	    from qtlassociatedgene
	    inner join qtl on qtlassociatedgene.qtlid = qtl.id
	},
    'searchcols' => ['qtl.name']
},

'geneproduct' => {
    'realname' => 'Gene Product',
    'sql' => qq{
	select distinct
	    genegeneproduct.geneid
	    from genegeneproduct
	    inner join geneproduct on genegeneproduct.geneproductid = geneproduct.id
	},
    'searchcols' => ['geneproduct.name']
},

'chromosome' => {
    'realname' => 'Chromosome',
    'sql' => qq{
	select distinct
	    genechromosome.geneid
	    from genechromosome
	    left join genechromosomearm on genechromosome.geneid = genechromosomearm.geneid
	    left join reference on genechromosome.referenceid = reference.id
	},
    'searchcols' => ['genechromosome.chromosome','genechromosomearm.chromosomearm','reference.title']
},

'germplasm' => {
    'realname' => 'Germplasm',
    'sql' => qq{
	select distinct
	    genegermplasm.geneid
	    from genegermplasm
	    inner join germplasm on genegermplasm.germplasmid = germplasm.id
	    left join reference on genegermplasm.referenceid = reference.id
	},
    'searchcols' => ['genegermplasm.type','germplasm.name','reference.title']
},

'species' => {
    'realname' => 'Species',
    'sql' => qq{
	select distinct
	    genegermplasm.geneid
	    from genegermplasm
	    inner join germplasmspecies on genegermplasm.germplasmid = germplasmspecies.germplasmid
	    inner join species on germplasmspecies.speciesid = species.id
	},
    'searchcols' => ['species.name']
},

'remark' => {
    'realname' => 'Remark',
    'sql' => qq{
	select distinct
	    generemark.geneid
	    from generemark
	},
    'searchcols' => ['generemark.type','generemark.remark']
},

'clone' => {
    'realname' => 'Clone',
    'sql' => qq{
	select distinct
	    geneclone.geneid
	    from geneclone
	    inner join probe on geneclone.probeid = probe.id
	},
    'searchcols' => ['probe.name']
},

'sequence' => {
    'realname' => 'Sequence',
    'sql' => qq{
	select distinct
	    genesequence.geneid
	    from genesequence
	    inner join sequence on genesequence.sequenceid = sequence.id
	},
    'searchcols' => ['sequence.name']
},

'image' => {
    'realname' => 'Image',
    'sql' => qq{
	select distinct
	    geneimage.geneid
	    from geneimage
	    inner join image on geneimage.imageid = image.id
	    left join imagecaption on image.id = imagecaption.imageid
	},
    'searchcols' => ['image.name','imagecaption.caption']
},

'twopointdata' => {
    'realname' => '2 Point Data',
    'sql' => qq{
	select distinct
	    genetwopointdata.geneid
	    from genetwopointdata
	    inner join twopointdata on genetwopointdata.twopointdataid = twopointdata.id
	},
    'searchcols' => ['twopointdata.name']
},

'wgcreference' => {
    'realname' => 'Wheat Gene Catalog Reference',
    'sql' => qq{
	select distinct
	    genewgcreference.geneid
	    from genewgcreference
	    inner join reference on genewgcreference.referenceid = reference.id
	},
    'searchcols' => ['genewgcreference.number','reference.name','reference.title']
},

'datasource' => {
    'realname' => 'Data Source',
    'sql' => qq{
	select distinct
	    genedatasource.geneid
	    from genedatasource
	    inner join colleague on genedatasource.colleagueid = colleague.id
	},
    'searchcols' => ['colleague.name']
},

'infosource' => {
    'realname' => 'Info Source',
    'sql' => qq{
	select distinct
	    geneinfosource.geneid
	    from geneinfosource
	    inner join reference on geneinfosource.referenceid = reference.id
	},
    'searchcols' => ['reference.name','reference.title']
},

'datacurator' => {
    'realname' => 'Data Curator',
    'sql' => qq{
	select distinct
	    genedatacurator.geneid
	    from genedatacurator
	    inner join colleague on genedatacurator.colleagueid = colleague.id
	},
    'searchcols' => ['colleague.name']
}

};

1;
