#!/usr/bin/perl

our $search_elements = {

'order' => [qw/
	    name
	    altname
	    title
	    species
	    germplasm
	    tissue
	    devstage
	    treatment
	    library
	    blasthitaccession
	    emblfeature
	    datasource
	    /],

'name' => {
    'realname' => 'Accession',
    'sql' => qq{
	select id from sequence
	},
    'searchcols' => ['name']
},

'altname' => {
    'realname' => 'Other Name',
    'sql' => qq{
	select id from sequence
	},
    'searchcols' => ['altname']
},

'title' => {
    'realname' => 'Title',
    'sql' => qq{
	select id from sequence
	},
    'searchcols' => ['title'],
    'searchtypes' => {'title'=>'match'}
},

#'correspondingprotein' => {
#    'realname' => 'Corresponding Protein',
#    'sql' => qq{
#	select
#	    sequence.id
#	    from sequence
#	    inner join protein on sequence.correspondingprotein_proteinid = protein.id
#	},
#    'searchcols' => ['protein.name']
#},

#'sourcesequence' => {
#    'realname' => 'Source Sequence',
#    'sql' => qq{
#	select
#	    a.id
#	    from sequence as a
#	    inner join sequence as b on a.source_sequenceid = b.id
#	},
#    'searchcols' => ['b.name']
#},

'germplasm' => {
    'realname' => 'Germplasm',
    'sql' => qq{
	select
	    sequence.id
	    from sequence
	    inner join germplasm on sequence.germplasmid = germplasm.id
	},
    'searchcols' => ['germplasm.name']
},

'species' => {
    'realname' => 'Species',
    'sql' => qq{
	select
	    sequencespecies.sequenceid
	    from sequencespecies
	    inner join species on sequencespecies.speciesid = species.id
	},
    'searchcols' => ['species.name']
},

#'geneclass' => {
#    'realname' => 'Gene Class',
#    'sql' => qq{
#	select
#	    sequence.id
#	    from sequence
#	    inner join geneclass on sequence.geneclassid = geneclass.id
#	},
#    'searchcols' => ['geneclass.name']
#},

#'tracefile' => {
#    'realname' => 'Tracefile',
#    'sql' => qq{
#	select id from sequence
#	},
#    'searchcols' => ['tracefile']
#},

'library' => {
    'realname' => 'Library',
    'sql' => qq{
	select
	    sequence.id
	    from sequence
	    inner join library on sequence.libraryid = library.id
	},
    'searchcols' => ['library.name']
},

'tissue' => {
    'realname' => 'Tissue',
    'sql' => qq{
	select
	    sequence.id
	    from sequence
	    inner join library on sequence.libraryid = library.id
	},
    'searchcols' => ['library.tissue']
},

'devstage' => {
    'realname' => 'Developmental Stage',
    'sql' => qq{
	select
	    sequence.id
	    from sequence
	    inner join library on sequence.libraryid = library.id
	},
    'searchcols' => ['library.developmentalstage']
},

'treatment' => {
    'realname' => 'Treatment',
    'sql' => qq{
	select
	    sequence.id
	    from sequence
	    inner join library on sequence.libraryid = library.id
	},
    'searchcols' => ['library.treatment']
},

# codonframe
# type

#'reference' => {
#    'realname' => 'Reference',
#    'sql' => qq{
#	select
#	    sequencereference.sequenceid
#	    from sequencereference
#	    inner join reference on sequencereference.referenceid = reference.id
#	},
#    'searchcols' => ['reference.name','reference.title']
#},

#'probe' => {
#    'realname' => 'Probe',
#    'sql' => qq{
#	select distinct
#	    sequenceprobe.sequenceid
#	    from sequenceprobe
#	    inner join probe on sequenceprobe.probeid = probe.id
#	},
#    'searchcols' => ['probe.name']
#},

# exons

#'subsequence' => {
#    'realname' => 'Subsequence',
#    'sql' => qq{
#	select distinct
#	    sequencesubsequence.sequenceid
#	    from sequencesubsequence
#	    inner join sequence on sequencesubsequence.subsequence_sequenceid = sequence.id
#	},
#    'searchcols' => ['sequence.name']
#},

#'externaldb' => {
#    'realname' => 'External Database',
#    'sql' => qq{
#	select distinct
#	    sequenceid
#	    from sequenceexternaldb
#	},
#    'searchcols' => ['name','accession','url','remark']
#},

#'blasthittitle' => {
#    'realname' => 'BLAST Hit Title',
#    'sql' => qq{
#	select distinct
#	    sequenceid
#	    from sequenceblasthits
#	},
#    'searchcols' => ['title']
#},

'datasource' => {
    'realname' => 'Data Source',
    'sql' => qq{
        select distinct
            sequencedatasource.sequenceid
            from sequencedatasource
            inner join colleague on sequencedatasource.colleagueid = colleague.id
        },
    'searchcols' => ['colleague.name']
},

'emblfeature' => {
    'realname' => 'EMBL Feature',
    'sql' => qq{
	select distinct
	    sequenceid
	    from sequenceemblfeature
	},
    'searchcols' => ['feature','remark']
},

'blasthitaccession' => {
    'realname' => 'BLAST Hit Accession',
    'sql' => qq{
	select distinct
	    sequenceid
	    from sequenceblasthits
	},
    #'searchcols' => ['blasttype','dbname','dbversion','accession','title']
    'searchcols' => ['accession']
}

# remark (_big_ one)

};

1;
