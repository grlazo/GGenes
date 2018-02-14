#!/bin/bash
# DDH 2005-09-11
# creates cache file of class total row counts for innodb browsing
mysql -u guest --password=PASSWORD -s graingenes <<EOF >| `dirname $0`/class_counts
select 'allele',count(*) from allele;
select 'author',count(*) from author;
select 'breakpoint',count(*) from breakpoint;
select 'breakpointinterval',count(*) from breakpointinterval;
select 'chromband',count(*) from chromband;
select 'colleague',count(*) from colleague;
select 'collection',count(*) from collection;
select 'contigset',count(*) from contigset;
select 'dna',count(*) from dna;
select 'environment',count(*) from environment;
select 'gel',count(*) from gel;
select 'gene',count(*) from gene;
select 'geneclass',count(*) from geneclass;
select 'geneproduct',count(*) from geneproduct;
select 'geneset',count(*) from geneset;
select 'germplasm',count(*) from germplasm;
select 'help',count(*) from help;
select 'image',count(*) from image;
select 'isolate',count(*) from isolate;
select 'journal',count(*) from journal;
select 'keyword',count(*) from keyword;
select 'library',count(*) from library;
select 'locus',count(*) from locus;
select 'map',count(*) from map;
select 'mapdata',count(*) from mapdata;
select 'marker',count(*) from marker;
select 'pathology',count(*) from pathology;
select 'peptide',count(*) from peptide;
select 'polymorphism',count(*) from polymorphism;
select 'probe',count(*) from probe;
select 'protein',count(*) from protein;
select 'qtl',count(*) from qtl;
select 'rearrangement',count(*) from rearrangement;
select 'reference',count(*) from reference;
select 'restrictionenzyme',count(*) from restrictionenzyme;
select 'sequence',count(*) from sequence;
select 'source',count(*) from source;
select 'species',count(*) from species;
select 'trait',count(*) from trait;
select 'traitscore',count(*) from traitscore;
select 'traitstudy',count(*) from traitstudy;
select 'twopointdata',count(*) from twopointdata;
EOF
