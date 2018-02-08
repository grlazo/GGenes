#!/usr/bin/perl

# named queries with variable substitution required by
# http://wheat.pw.usda.gov/cgi-bin/GG2/quickquery.cgi

# created by David Hummel, 02Jun2004
# Copyright (C) 2004 David Hummel <hummel@pw.usda.gov>
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

#   script "defines a single variable, $quickquery, a hash reference
#   (keys are query names, values are SQL queries)."
# mods by NLui 03Jun2004-16Jun2004

our $quickquery = {

#format:
#'query' =>
#qq{
#-- comment
#select * from sequence
#},

#'SSR-alleles_vs_character' =>
#qq{
#-- SSR Alleles versus Characteristics
#select
# locus.name as Locus,
# allele.name as Allele,
# germplasm.name as Germplasm,
# germplasmremark.remark as Characteristic
#from locus
# inner join  
#},

'references' =>
qq{
-- References by Author, Keyword, Date
select 
  distinct
  reference.year as Year,
  reference.name as Reference,
  author.name as Author,
  colleague.name as Address,
  reference.title as Title
from reference
  inner join referenceauthor on reference.id = referenceauthor.referenceid
  inner join author on referenceauthor.authorid = author.id
  left join colleague on author.fullname_colleagueid = colleague.id
  -- left join to include references without Keyword data:
  left join referencekeyword on reference.id = referencekeyword.referenceid
  left join keyword on referencekeyword.keywordid = keyword.id
where author.name like '%1\%'
  and ( reference.title like '\%%2\%' or 
       keyword.name like '\%%2\%' )
  and reference.year >= %3
order by reference.year desc, author.name
},

'keyword1' =>
qq{
-- References by Keyword 1 only
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
  inner join referencekeyword on reference.id = referencekeyword.referenceid
  inner join keyword on referencekeyword.keywordid = keyword.id
   and keyword.name like '\%%1\%')
union
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
where reference.title like '\%%1\%')
order by Year desc, Reference
},

'keyword1or2' =>
qq{
-- References by Keyword 1 or 2
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
  inner join referencekeyword on reference.id = referencekeyword.referenceid
  inner join keyword on referencekeyword.keywordid = keyword.id
where keyword.name like '\%%1\%' or
      keyword.name like '\%%2\%')
union
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
where reference.title like '\%%1\%' or
      reference.title like '\%%2\%')
order by Year desc, Reference
},

'keyword1or2or3' =>
qq{
-- References by Keywords 1 or 2 or 3
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
  inner join referencekeyword on reference.id = referencekeyword.referenceid
  inner join keyword on referencekeyword.keywordid = keyword.id
where keyword.name like '\%%1\%' or
      keyword.name like '\%%2\%' or
      keyword.name like '\%%3\%')
union
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
where reference.title like '\%%1\%' or
      reference.title like '\%%2\%' or
      reference.title like '\%%3\%')
order by Year desc, Reference
},

'keyword1or2or3or4' =>
qq{
-- References by Keywords 1 or 2 or 3 or 4
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
  inner join referencekeyword on reference.id = referencekeyword.referenceid
  inner join keyword on referencekeyword.keywordid = keyword.id
where keyword.name like '\%%1\%' or
      keyword.name like '\%%2\%' or
      keyword.name like '\%%3\%' or
      keyword.name like '\%%4\%')
union
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
where reference.title like '\%%1\%' or
      reference.title like '\%%2\%' or
      reference.title like '\%%3\%' or
      reference.title like '\%%4\%')
order by Year desc, Reference
},

'keyword1or2or3or4or5' =>
qq{
-- References by Keywords 1 or 2 or 3 or 4 or 5
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
  inner join referencekeyword on reference.id = referencekeyword.referenceid
  inner join keyword on referencekeyword.keywordid = keyword.id
where keyword.name like '\%%1\%' or
      keyword.name like '\%%2\%' or
      keyword.name like '\%%3\%' or
      keyword.name like '\%%4\%' or
      keyword.name like '\%%5\%')
union
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
where reference.title like '\%%1\%' or
      reference.title like '\%%2\%' or
      reference.title like '\%%3\%' or
      reference.title like '\%%4\%' or
      reference.title like '\%%5\%')
order by Year desc, Reference
},

'keyword1and2' =>
qq{
-- References by Keywords 1 and 2
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
  inner join referencekeyword ref1 on reference.id = ref1.referenceid
  inner join keyword key1 on ref1.keywordid = key1.id
    and key1.name like '\%%1\%'
  inner join referencekeyword ref2 on reference.id = ref2.referenceid
  inner join keyword key2 on ref2.keywordid = key2.id
    and key2.name like '\%%2\%')
union
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
where reference.title like '\%%1\%' and
      reference.title like '\%%2\%')    
order by Year desc, Reference
},

'keyword1and2and3' =>
qq{
-- References by Keywords 1 and 2 and 3
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
  inner join referencekeyword ref1 on reference.id = ref1.referenceid
  inner join keyword key1 on ref1.keywordid = key1.id
    and key1.name like '\%%1\%'
  inner join referencekeyword ref2 on reference.id = ref2.referenceid
  inner join keyword key2 on ref2.keywordid = key2.id
    and key2.name like '\%%2\%'
  inner join referencekeyword ref3 on reference.id = ref3.referenceid
  inner join keyword key3 on ref3.keywordid = key3.id
    and key3.name like '\%%3\%')
union
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
where reference.title like '\%%1\%' and
      reference.title like '\%%2\%' and
      reference.title like '\%%3\%')    
order by Year desc, Reference
},

'keyword1and2and3and4' =>
qq{
-- References by Keywords 1 and 2 and 3 and 4
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
  inner join referencekeyword ref1 on reference.id = ref1.referenceid
  inner join keyword key1 on ref1.keywordid = key1.id
    and key1.name like '\%%1\%'
  inner join referencekeyword ref2 on reference.id = ref2.referenceid
  inner join keyword key2 on ref2.keywordid = key2.id
    and key2.name like '\%%2\%'
  inner join referencekeyword ref3 on reference.id = ref3.referenceid
  inner join keyword key3 on ref3.keywordid = key3.id
    and key3.name like '\%%3\%'
  inner join referencekeyword ref4 on reference.id = ref4.referenceid
  inner join keyword key4 on ref4.keywordid = key4.id
    and key4.name like '\%%4\%')
union
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
where reference.title like '\%%1\%' and
      reference.title like '\%%2\%' and
      reference.title like '\%%3\%' and
      reference.title like '\%%4\%')    
order by Year desc, Reference
},

'keyword1and2and3and4and5' =>
qq{
-- References by Keywords 1 and 2 and 3 and 4 and 5
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
  inner join referencekeyword ref1 on reference.id = ref1.referenceid
  inner join keyword key1 on ref1.keywordid = key1.id
    and key1.name like '\%%1\%'
  inner join referencekeyword ref2 on reference.id = ref2.referenceid
  inner join keyword key2 on ref2.keywordid = key2.id
    and key2.name like '\%%2\%'
  inner join referencekeyword ref3 on reference.id = ref3.referenceid
  inner join keyword key3 on ref3.keywordid = key3.id
    and key3.name like '\%%3\%'
  inner join referencekeyword ref4 on reference.id = ref4.referenceid
  inner join keyword key4 on ref4.keywordid = key4.id
    and key4.name like '\%%4\%'
  inner join referencekeyword ref5 on reference.id = ref5.referenceid
  inner join keyword key5 on ref5.keywordid = key5.id
    and key5.name like '\%%5\%')
union
(select
  distinct
  reference.year as Year,
  reference.name as Reference,
  reference.title as Title
from reference
where reference.title like '\%%1\%' and
      reference.title like '\%%2\%' and
      reference.title like '\%%3\%' and
      reference.title like '\%%4\%' and
      reference.title like '\%%5\%')    
order by Year desc, Reference
},

#'Microsatellite primers' =>
#qq{
#-- Microsatellite (SSR) Primers
#select
#  probe.name as SSR,
#  probeprimer.primeronesequence as Primer_1,
#  probeprimer.primertwosequence as Primer_2,
#  probeprimer.ampconditions as Conditions,
#  probeprimer.size as Size
#from probeprimer
#  inner join probe on probeprimer.probeid = probe.id
#  inner join probetype on probeprimer.probeid = probetype.probeid
#where probetype.type = 'SSR'
#  and probe.name like '%1'
#},

#changed per DEM 16Jun2004
'Microsatellite primers' =>
qq{
-- Microsatellite (SSR) Primers
select
  distinct
  probe.name as SSR,
  pr.primeronesequence as Primer_1,
  pr.primertwosequence as Primer_2,
  pr.ampconditions as Conditions,
  prSSR.size as SSR_Size,
  sequence.name as Sequence
from probe
  inner join probetype on probe.id = probetype.probeid
  -- get primer sequences and conditions:
  inner join probeprimer pr on probe.id = pr.probeid
    and pr.primeronesequence is not null
  -- get any size data: 
  left join probeprimer prSSR on prSSR.probeid = probe.id
    and prSSR.sizetype = 'SSR_size'
  left join sequenceprobe on probe.id = sequenceprobe.probeid 
  left join sequence on sequenceprobe.sequenceid = sequence.id
where probetype.type = 'SSR'
  and probe.name like '%1'
},

'microsatellite_loci' =>
qq{
-- Microsatellite (SSR) Map Locations
select 
  distinct
  probe.name as SSR,
  locus.name as Locus,
  map.name as Map,
  maplocus.begin as Position
from probe
  inner join locusprobe on probe.id = locusprobe.probeid
    and probe.name like '%1'
  inner join locus on locusprobe.locusid = locus.id
  inner join maplocus on locus.id = maplocus.locusid
    and maplocus.begin is not null
  inner join map on maplocus.mapid = map.id
    and map.name like '\%-%2'
  inner join probetype on probe.id = probetype.probeid
    and probetype.type = 'SSR'
order by probe.name, locus.name
},

'microsatellite_mapdata' =>
qq{
-- Microsatellite (SSR) Mapping Scores
select 
  distinct
  probe.name as SSR,
  mapdata.name as MapData,
  locus.name as Locus,
  mapdatalocus.scoringdata as Scores
from probe
  inner join locusprobe on probe.id = locusprobe.probeid
    and probe.name like '%1'
  inner join locus on locusprobe.locusid = locus.id
  inner join mapdatalocus on locus.id = mapdatalocus.locusid
    and mapdatalocus.scoringdata is not null
  inner join mapdata on mapdatalocus.mapdataid = mapdata.id
  inner join probetype on probe.id = probetype.probeid 
    and probetype.type = 'SSR'
order by probe.name, mapdata.name
},

'STSs' =>
qq{
-- Sequence-Tagged Sites (STSs) and Primers
select
  distinct
  probe.name as STS,
  p1.primeronesequence as Primer_1,
  p1.primertwosequence as Primer_2,
  p1.ampconditions as Conditions,
  p2.size as Size
from probeprimer p1
  inner join probe on p1.probeid = probe.id
    and p1.primeronesequence is not null
  inner join probetype on probe.id = probetype.probeid 
    and probetype.type = 'STS'
  -- left join: to include PCR_size if available  
  left join probeprimer p2 on p1.probeid = p2.probeid
    and p2.sizetype = 'PCR_size'
  inner join probesourcespecies on p1.probeid = probesourcespecies.probeid
  inner join species on species.id = probesourcespecies.speciesid 
    and species.name like '%1'

},

# sort order changed per DEM 17Jun2004
'mapdata' =>
qq{
-- Map_Data and Linkage_Data, Loci, Positions, and Probes
select
  distinct
  map.name as Map,
  locus.name as Locus,
  maplocus.begin as Position,
  probe.name as Probe
from locus
  inner join maplocus on locus.id = maplocus.locusid
    and maplocus.begin is not null
  inner join map on maplocus.mapid = map.id
  inner join mapdata on map.mapdataid = mapdata.id
    and mapdata.name like '%1'
  -- left joins: to include loci w/o corresponding probe data
  left join locusprobe on locus.id = locusprobe.locusid
  left join probe on locusprobe.probeid = probe.id
order by map.name, maplocus.begin
},

'mapdata_scores' =>
qq{
-- Mapping Scores from a Mapdata record
select 
  locus.name as Locus,
  mapdatalocus.scoringdata as Scoringdata
from mapdata
  join mapdatalocus on mapdatalocus.mapdataid = mapdata.id
  join locus on locus.id = mapdatalocus.locusid
where mapdata.name like '%1'
order by locus.name
},

'all_mapdata_scores' =>
qq{
-- All mapping data in GrainGenes
select 
  group_concat(distinct species.name) as Species,
  mapdata.name as Map_Data,
  M1.name as Chromosome,
  locus.name as Locus,
  maplocus.begin as Position,
  mapdatalocus.scoringdata as Segregation_data
from mapdata
  join mapdatalocus on mapdatalocus.mapdataid = mapdata.id
  join locus on locus.id = mapdatalocus.locusid
  join map M1 on M1.mapdataid = mapdata.id
  join maplocus on locus.id = maplocus.locusid
  join map M2 on M2.id = maplocus.mapid
  join mapdataspecies on mapdataspecies.mapdataid = mapdata.id
  join species on species.id = mapdataspecies.speciesid
where mapdatalocus.scoringdata is not null
and M1.id = M2.id
group by Locus, Chromosome
order by Map_Data, Chromosome, Position
},


#'nearbyloci' =>
#qq{
#-- Loci, Maps, Positions, and Nearby Loci/Positions
#select
#  distinct
#  loc1.name as Locus,
#  map.name as Map,
#  p1.begin as Position,
#  loc2.name as Neighbor,
#  p2.begin as Position
#from locus loc1
#  inner join maplocus p1 on loc1.id = p1.locusid
#    and p1.begin is not null
#    and loc1.name like '%1'
#  inner join map on p1.mapid = map.id
#  -- include only those maps that use cM units
#  inner join mapdataremark on map.mapdataid = mapdataremark.mapdataid
#    and mapdataremark.type = 'Map_units'
#    and mapdataremark.remark like 'cM%'
#  -- first get the nearby loci on this map:
#  left join maplocus p2 on p1.mapid = p2.mapid
#    and ( ABS(p2.begin - p1.begin) < %2 )
#  -- then get the names of these nearby loci:
#  left join locus loc2 on p2.locusid = loc2.id
#    -- don't include the same locus:
#    and loc1.id != loc2.id
#where 
#  -- don't list loc1 if there are no neighbors:
#  loc2.name is not null
#order by loc1.name, map.name, loc2.name
#},

#nearbyloci changes per DEM 15Jun2004
# dem 16jul04, changed table aliases like loc1.name to locus_1.name so
#      sql.cgi can parse the query and href the output data to reports.
# dem 7oct06, superseded by the new version below.
#'nearbyloci' =>
#qq{
#-- Loci near a specified locus on any map
#select
#  distinct
#  locus_1.name as Query,
#  map.name as Map,
#  locus_2.name as Locus,
#  p2.begin as Position,
#  ROUND(ABS(p2.begin-p1.begin),1) as Distance
#from locus locus_1
#  inner join maplocus p1 on locus_1.id = p1.locusid
#    and p1.begin is not null
#    and locus_1.name like '%1'
#  inner join map on p1.mapid = map.id
#  -- include only those maps that use cM units
#  inner join mapdataremark on map.mapdataid = mapdataremark.mapdataid
#    and mapdataremark.type = 'Map_units'
#    and mapdataremark.remark like '%cM%'
#  -- first get the nearby loci on this map:
#  left join maplocus p2 on p1.mapid = p2.mapid
#    and ( ABS(p2.begin - p1.begin) < %2 )
#  -- then get the names of these nearby loci:
#  left join locus locus_2 on p2.locusid = locus_2.id
#where 
#  -- don't list locus_1 if there are no neighbors:
#  locus_2.name is not null
#order by locus_1.name, map.name, p2.begin
#},

# dem 7oct06:  This version is the one used in Locus reports from report.cgi.
'nearbyloci' =>
qq{
-- Loci near a specified locus, on any map
select
  distinct
  locus_1.name as Query,
  map.name as Map,
  locus_2.name as Locus,
  p2.begin as Position,
  ROUND(ABS(p2.begin-p1.begin),1) as Distance
from locus locus_1
  inner join maplocus p1 on locus_1.id = p1.locusid
    and p1.begin is not null
    and locus_1.name like '%1'
  inner join map on p1.mapid = map.id
  -- Include only those maps that use cM units.
  inner join mapdataremark on map.mapdataid = mapdataremark.mapdataid
    and mapdataremark.type = 'Map_units'
    and mapdataremark.remark like '%cM%'
  -- First get the nearby loci on this map:
  left join maplocus p2 on p1.mapid = p2.mapid
    and ( ABS(p2.begin - p1.begin) < %2 )
  -- Then get the names of these nearby loci:
  left join locus locus_2 on p2.locusid = locus_2.id
where 
  -- Don't list locus_1 if there are no neighbors:
  locus_2.name is not null
order by locus_1.name, map.name, p2.begin
},


# dem 7oct06: Added specifying a particular map, e.g. Rudi's Wheat Composite.
#      This version is the one used on the Quick Queries page.
'nearbyloci.qq' =>
qq{
-- Loci near a specified locus, and/or on a specified map.
select
  distinct
  locus_1.name as Query,
  map.name as Map,
  locus_2.name as Locus,
  p2.begin as Position,
  ROUND(ABS(p2.begin-p1.begin),1) as Distance
from locus locus_1
  inner join maplocus p1 on locus_1.id = p1.locusid
    and p1.begin is not null
    and locus_1.name like '%1'
  inner join map on p1.mapid = map.id
  -- Include only those maps that use cM units.
  inner join mapdataremark on map.mapdataid = mapdataremark.mapdataid
    and mapdataremark.type = 'Map_units'
    and mapdataremark.remark like '%cM%'
  -- First get the nearby loci on this map:
  left join maplocus p2 on p1.mapid = p2.mapid
    and ( ABS(p2.begin - p1.begin) < %2 )
  -- Then get the names of these nearby loci:
  left join locus locus_2 on p2.locusid = locus_2.id
where 
  -- Don't list locus_1 if there are no neighbors:
  locus_2.name is not null
  -- Look only on specified maps, e.g. 'Wheat-Composite%':
    and map.name like '%3'
order by locus_1.name, map.name, p2.begin
},


#'nearbygenes' =>
#qq{
#-- Loci, Maps, Positions, and Nearby Genes/Positions
#select
#  distinct
#  loc1.name as Locus,
#  map.name as Map,
#  p1.begin as Position,
#  loc2.name as Neighbor,
#  p2.begin as Position
#from locus loc1
#  inner join maplocus p1 on loc1.id = p1.locusid
#    and p1.begin is not null
#    and loc1.name like '%1'
#  inner join map on p1.mapid = map.id
#  -- include only those maps that use cM units
#  inner join mapdataremark on map.mapdataid = mapdataremark.mapdataid
#    and mapdataremark.type = 'Map_units'
#    and mapdataremark.remark like 'cM%'
#  -- first get the nearby loci on this map:
#  left join maplocus p2 on p1.mapid = p2.mapid
#    and ( ABS(p2.begin - p1.begin) <= %2 )
#  -- then get the names of these nearby loci:
#  left join locus loc2 on p2.locusid = loc2.id
#    -- don't include the same locus:
#    and loc1.id != loc2.id
#  -- bring in the loci with Associated_gene
#  left join locusassociatedgene on loc2.id = locusassociatedgene.locusid
#where 
#  -- list only if locus has Candidate_gene or Associated_gene
#  ( loc2.candidategene_geneid is not null or
#        locusassociatedgene.locusid is not null )
#  -- don't list loc1 if there are no neighbors:
#  and loc2.name is not null
#order by loc1.name, map.name, loc2.name
#},

#nearbygenes changes per DEM 15Jun2004
'nearbygenes' =>
qq{
-- Genes near a specified locus on any map
select
  distinct
  locus_1.name as Query,
  map.name as Map,
  p1.begin as Position,
  locus_2.name as Gene,
  p2.begin as Position
from locus locus_1
  inner join maplocus p1 on locus_1.id = p1.locusid
    and p1.begin is not null
    and locus_1.name like '%1'
  inner join map on p1.mapid = map.id
  -- include only those maps that use cM units
  inner join mapdataremark on map.mapdataid = mapdataremark.mapdataid
    and mapdataremark.type = 'Map_units'
    and mapdataremark.remark like 'cM%'
  -- first get the nearby loci on this map:
  left join maplocus p2 on p1.mapid = p2.mapid
    and ( ABS(p2.begin - p1.begin) <= %2 )
  -- then get the names of these nearby loci:
  left join locus locus_2 on p2.locusid = locus_2.id
  -- bring in the loci with Associated_gene
  left join locusassociatedgene on locus_2.id = locusassociatedgene.locusid
where 
  -- list only if locus has Candidate_gene or Associated_gene
  ( locus_2.candidategene_geneid is not null or
        locusassociatedgene.locusid is not null )
  -- don't list locus_1 if there are no neighbors:
  and locus_2.name is not null
order by locus_1.name, map.name, p2.begin
},

'nearbyqtls' =>
qq{
-- QTLs near a specified locus
select
  distinct
  locus.name as Locus,
  qtl.name as QTL,
  map.name as Map,
  p2.begin as Position,
  ROUND(ABS(p2.begin-p1.begin),1) as Distance
from locus
  join maplocus p1 on locus.id = p1.locusid
    and p1.begin is not null
    and locus.name like '%1'
  join map on p1.mapid = map.id
  -- First get the nearby QTLs on this map:
  join mapqtl p2 on p1.mapid = p2.mapid
    and (( ABS(p2.begin - p1.begin) < %2 )
    or   ( ABS(p2.end - p1.begin) < %2 ))
  -- Then get the names of these nearby QTLs:
  join qtl on p2.qtlid = qtl.id
order by locus.name, map.name, p2.begin
},

#'order by' sequence changed per DEM 15Jun2004
'tweenloci' =>
qq{
-- Locus 1, Map, Position 1, Locus 2, Position 2, and Loci/Positions Between
select
  distinct
  locus_1.name as Locus_1,
  map.name as Map,
  p1.begin as L1_Position,
  locus_2.name as Locus_2,
  p2.begin as L2_Position,
  locus_3.name as Loci_Found,
  p3.begin as Position
from locus locus_1
  inner join maplocus p1 on locus_1.id = p1.locusid
    and p1.begin is not null
    and locus_1.name like '%1'
  inner join map on p1.mapid = map.id
  -- first get the 2nd locus on the same map:
  left join maplocus p2 on p1.mapid = p2.mapid
  -- then get the name of the second locus:
  left join locus locus_2 on p2.locusid = locus_2.id
    and locus_2.name like '%2'
  -- finally, get the loci 'tween these two:
  left join maplocus p3 on p1.mapid = p3.mapid
    and ( ( p1.begin > p3.begin AND p3.begin > p2.begin )
          or
          ( p1.begin < p3.begin AND p3.begin < p2.begin )
        )
  left join locus locus_3 on p3.locusid = locus_3.id      
where 
  -- don't list locus_1/locus_2 for locus_3 not matching criteria:
  locus_3.name is not null
  -- don't include the same locus (keep here in 'where' clause):
  and locus_1.id != locus_2.id
order by locus_1.name, map.name, locus_2.name, p3.begin
},

'trait_markers' =>
qq{
-- Trait Markers
select
  twopointdata.name as 2_Point_Data,
  gene.name as Gene,
  geneclass.name as Gene_Class
from twopointdata
  left join genetwopointdata on twopointdata.id = genetwopointdata.twopointdataid
  left join gene on genetwopointdata.geneid = gene.id
  left join genegeneclass on gene.id = genegeneclass.geneid
  left join geneclass on genegeneclass.geneclassid = geneclass.id
where twopointdata.traitmarker = 1  
order by twopointdata.name
},

'probe_maps' =>
qq{
-- Maps for Specified Probe
select
  distinct
  probe.name as Probe,
  locus.name as Locus,
  map.name as Map
from probe
  inner join locusprobe on probe.id = locusprobe.probeid
    and probe.name like '%1'
  inner join locus on locusprobe.locusid = locus.id
  -- change 'left' to 'inner' to exclude records w/o associated maps
  left join maplocus on locus.id = maplocus.locusid
  left join map on maplocus.mapid = map.id
order by probe.name, locus.name, map.name
},

'gene_chromgroup' =>
qq{
-- Genes in Specified Chromosome Group
select
  distinct
  gene.name as Gene,
  genechromosome.chromosome as Chromosome,
  locus.name as Locus,
  map.name as Map,
  maplocus.begin as Location
from gene
  inner join genechromosome on gene.id = genechromosome.geneid
    and genechromosome.chromosome like '%1\%'
  left join locusassociatedgene on gene.id = locusassociatedgene.geneid
  left join locus on locusassociatedgene.locusid = locus.id
  left join maplocus on locus.id = maplocus.locusid
    and maplocus.begin is not null
  left join map on maplocus.mapid = map.id
order by gene.name, genechromosome.chromosome
},

'gene_chromgroup2' =>
qq{
-- Genes in Specified Chromosome Group
select
  distinct
  gene.name as Gene,
  genechromosome.chromosome as Chromosome,
  locus.name as Locus,
  map.name as Map,
  maplocus.begin as Location
from gene
  inner join genechromosome on gene.id = genechromosome.geneid
    and genechromosome.chromosome like '%2\%'
  left join locusassociatedgene on gene.id = locusassociatedgene.geneid
  left join locus on locusassociatedgene.locusid = locus.id
  left join maplocus on locus.id = maplocus.locusid
    and maplocus.begin is not null
  left join map on maplocus.mapid = map.id
  where gene.name like '%1\%'
  and map.name is not null
order by genechromosome.chromosome, gene.name
},

#'probe_chrom' =>
#qq{
#-- Probes Mapped to a Specified Chromosome, Ordered by Probe
#select
#  distinct
#  locus.name as Locus,
#  map.name as Map,
#  probe.name as Probe
#from probe
#  inner join locusprobe on probe.id = locusprobe.probeid 
#  inner join locus on locusprobe.locusid = locus.id
#  inner join locuschromosome on locus.id = locuschromosome.locusid
#  inner join maplocus on locus.id = maplocus.locusid
#  left join map on maplocus.mapid = map.id
#where 
#  locuschromosome.chromosome like '%1\%' 
#    or 
#  map.name like '\%-%1'
#order by probe.name, locus.name, map.name
#},

# changed per DEM 17Jun2004 so that maps meeting spec included
# ACEDB query is (map AND chrom) or (chrom) [but not (map)]
'probe_chrom' =>
qq{
-- Probes Mapped to a Specified Chromosome.
--   If the Map field is empty, the Chromosome value for
--   the locus meets the criterion although names of
--   maps associated with the locus may not.
select
  distinct
  locus.name as Locus,
  map.name as Map,
  probe.name as Probe
from locus
  -- Include any loci with chromosomes matching the criterion.
  left join locuschromosome on locus.id = locuschromosome.locusid
    and locuschromosome.chromosome like '%1\%'
  -- Add any loci with maps matching criterion.
  left join maplocus on locus.id = maplocus.locusid
  left join map on maplocus.mapid = map.id
    and map.name like '\%-%1'
  inner join locusprobe on locus.id = locusprobe.locusid 
  inner join probe on locusprobe.probeid = probe.id
where 
  locuschromosome.chromosome is not null
    or 
  map.name is not null
order by probe.name, locus.name, map.name
},

'mapped_seqs' =>
qq{
-- All Mapped Sequences (Probes with Sequences and Loci)
select
  distinct
  probe.name as Probe
from probe
  inner join sequenceprobe on probe.id = sequenceprobe.probeid
  inner join locusprobe on sequenceprobe.probeid = locusprobe.probeid
order by probe.name
},

'mapped_seqs2' =>
qq{
-- Mapped Sequences (Probes with Sequences and Loci)
-- from species "%1".
select distinct
   probe.name as Probe,
   mapdata.name as MapData,
   map.name as Map
from probe
   join locusprobe on locusprobe.probeid = probe.id
   join mapdatalocus on mapdatalocus.locusid = locusprobe.locusid
   join mapdataspecies on mapdataspecies.mapdataid = mapdatalocus.mapdataid
   join species on species.id = mapdataspecies.speciesid
     and species.name like '%1'
   join sequenceprobe on probe.id = sequenceprobe.probeid
   join maplocus on maplocus.locusid = locusprobe.locusid
   join mapdata on mapdata.id = mapdatalocus.mapdataid
   join map on map.id = maplocus.mapid and map.mapdataid = mapdata.id
order by Probe, MapData, Map
},

'mapped_seq' =>
qq{
--  Loci for a specific sequence (GenBank Accession) 
select
  distinct
  sequence.name as Sequence,
  locus.name as Locus,
  map.name as Map,
  maplocus.begin as Position
from probe
  inner join locusprobe on probe.id = locusprobe.probeid
  inner join locus on locusprobe.locusid = locus.id
  inner join maplocus on locus.id = maplocus.locusid
    and maplocus.begin is not null
  inner join map on maplocus.mapid = map.id
  inner join sequenceprobe on probe.id = sequenceprobe.probeid
  inner join sequence on sequenceprobe.sequenceid = sequence.id
    and sequence.name = '%1'
order by locus.name, map.name
},

'mapped_homologs' =>
qq{
--  Map Locations of homologs of a specified sequence (GenBank Accession) 
--   Sequence->Homol DNA_homol(Sequence)->Probe-> Locus     ->Map              ->Position
--   AB005878->BCD200-3                 ->BCD200->Xbcd200-1B->Tturgidum-JKxC-1B->187.2
select
  distinct
  sequence_1.name as Sequence,
  probe.name as Homologous_Clone,
  locus.name as Locus,
  map.name as Map,
  maplocus.begin as Position
from sequenceblasthits
  inner join sequence sequence_1 on sequenceblasthits.sequenceid = sequence_1.id
    and sequence_1.name = '%1'
  inner join sequence s2 on sequenceblasthits.accession = s2.name   
  inner join sequenceprobe on s2.id = sequenceprobe.sequenceid    
  inner join probe on sequenceprobe.probeid = probe.id
  inner join locusprobe on probe.id = locusprobe.probeid
  inner join locus on locusprobe.locusid = locus.id
  inner join maplocus on locus.id = maplocus.locusid
    and maplocus.begin is not null
  inner join map on maplocus.mapid = map.id
order by probe.name, locus.name, map.name
},

#'homologs_GG' =>
#qq{
#-- Mapped sequences, by homology keyword
#-- Probe, Sequence, BLAST Hit, Title
#select 
#  probe.name as Probe,
#  sequence.name as Sequence,
#  sequenceblasthits.accession as BLAST_Hit,
#  sequence.title as Title
#from sequenceblasthits
#  inner join sequence seqhit on sequenceblasthits.sequenceid = seqhit.id
#  can't get tblmkr query to yield anything using *ribosom* *dehydrog* *dehydrin*  

#},

#'hits_by_species' =>
#qq{
#-- Hits vs. Species
#-- Contig, Peptide Hit, E-Value, Title
#select 
# Contig (Sequence like contig*), Peptide_Hit (Best_Pep from 1),
#   Score (Best_Pep[1?]), E-value, ([2]?), Title (from Best_Pep, like '%1')
#},

'seqd_genes' =>
qq{
-- Sequenced Genes by Gene Classes
select 
  distinct
  geneclass.name as Gene_Class,
  probe.name as Clone,
  sequence.name as Sequence,
  locus.name as Locus
from geneclass
  inner join geneclassclone on geneclass.id = geneclassclone.geneclassid
  inner join probe on geneclassclone.probeid = probe.id
  inner join sequenceprobe on probe.id = sequenceprobe.probeid
  inner join sequence on sequenceprobe.sequenceid = sequence.id
  left join locusprobe on probe.id = locusprobe.probeid
  left join locus on locusprobe.locusid = locus.id
order by geneclass.name, probe.name, sequence.name, locus.name
},


'best_pep' =>
qq{
-- Best peptide BLAST hits
select sequence.name as Sequence, 
       protein.name as Protein, 
       protein.title as Title,
       sequence.bestpepscore as Score,
       sequence.bestpepevalue as Evalue
from sequence
     join protein on sequence.bestpep_proteinid = protein.id
},

'blast_hits' =>
qq{
-- DNA BLAST hits
select sequence.name as Sequence,
       accession as Sequence,
       score as Score,
       blasttype as Method,
       querybegin,
       queryend,
       subjectbegin,
       subjectend
from sequenceblasthits
     join sequence on sequence.id=sequenceblasthits.sequenceid
},

'seqs_by_cultivar' =>
qq{
-- Sequence count by Cultivar
-- (The species can be changed by editing the words 'Secale cereale').
select 
 sequenceremark.remark as Cultivar, 
 count(distinct sequence.name) as Count
from sequence
 inner join sequencespecies on sequence.id = sequencespecies.sequenceid
 inner join species on sequencespecies.speciesid = species.id
   and species.name like '%1'
 inner join sequenceremark on sequence.id = sequenceremark.sequenceid
   and sequenceremark.type = 'Cultivar'
group by sequenceremark.remark
},

'mapped_fncl_genes' =>
qq{
-- Mapped known-function probes
-- Cloned genes that have been mapped in barley. 
-- (The barley restriction can be changed by editing the word 'Hordeum%').
select 
  distinct
  locus.name as Locus,
  locuschromosome.chromosome as Chrom,
  probe.name as Probe,
  gene.name as Gene,
  geneclass_1.name as Gene_Class,
  geneclass_source.name as Source_Gene_Class
from locus
  inner join mapdatalocus on locus.id = mapdatalocus.locusid
  inner join mapdata on mapdatalocus.mapdataid = mapdata.id
  inner join mapdataspecies on mapdata.id = mapdataspecies.mapdataid
  -- get species-specific mapdata
  inner join species on mapdataspecies.speciesid = species.id
    and species.name like '%1'
  inner join locusprobe on locus.id = locusprobe.locusid
  inner join probe on locusprobe.probeid = probe.id
  -- left joins for optional items chromosome, gene, geneclass
  left join locuschromosome on locus.id = locuschromosome.locusid
  left join gene on locus.candidategene_geneid = gene.id
  left join genegeneclass on gene.id = genegeneclass.geneid
  left join geneclass geneclass_1 on genegeneclass.geneclassid = geneclass_1.id
  left join geneclassclone on probe.id = geneclassclone.probeid
  left join geneclass geneclass_source on geneclassclone.geneclassid = geneclass_source.id
where (geneclass_1.id is not null or geneclass_source.id is not null)  
order by locus.name, locuschromosome.chromosome
},

# Showing FASTA sequence only.
# dem 1aug06: Should merge this with the 'STSs' query above?
'mapped_STSs' =>
qq{
-- Mapped STSs
select 
  distinct
  probe.name as STS,
  dna.name as DNA,
  dna.sequence as Sequence
from probe
  inner join probeprimer on probe.id = probeprimer.probeid
    and probeprimer.type = 'STS_primers'
  inner join sequenceprobe on probe.id = sequenceprobe.probeid
  inner join sequence on sequenceprobe.sequenceid = sequence.id
  inner join dna on sequence.dnaid = dna.id
order by dna.name
},

'trmts' =>
qq{
-- Library, Treatment
--  may want to change to GG2/search.cgi later?
select
 library.name as Library,
 treatment
from library
 where treatment is not null
order by library
},

'contigs_vs_libraries' =>
qq{
-- EST Contigs vs. Libraries
--    ACEDB case-sensitive, mysQL case-insensitive (same/higher # of results),
select 
  distinct
  contig.name as Contig,
  sequence_mem1.name as Member_EST_1,
  library_1.name as Library_1,
  library_1.treatment as Treatment_1,
  sequence_mem2.name as Member_EST_2,
  library_2.name as Library_2,
  library_2.treatment as Treatment_2
from sequence as contig
  inner join sequenceblasthits sbh1 on contig.name = sbh1.accession
    and contig.name like 'Contig%'
  inner join sequence as sequence_mem1 on sbh1.sequenceid = sequence_mem1.id
  inner join library as library_1 on sequence_mem1.libraryid = library_1.id
    and library_1.treatment like '%1'
  inner join sequenceblasthits sbh2 on contig.name = sbh2.accession  
  inner join sequence as sequence_mem2 on sbh2.sequenceid = sequence_mem2.id
    and sequence_mem1.id != sequence_mem2.id
  inner join library as library_2 on sequence_mem2.libraryid = library_2.id
    and library_2.treatment like '%2'
order by contig.name, sequence_mem1.name, sequence_mem2.name
},

'qtls' =>
qq{
-- QTLs
select 
  qtl.name as QTL,
  trait.name as Trait,
  mapdata.name as 'Map Data',
  qtl.chromosomearm as 'Chromosome arm',
  group_concat(distinct locus.name) as 'Significant marker'
from qtl
  left join trait on qtl.traitaffected_traitid=trait.id
  left join qtlmapdata on qtl.id=qtlmapdata.qtlid
  left join mapdata on qtlmapdata.mapdataid=mapdata.id
  left join qtlsignificantmarker on qtl.id=qtlsignificantmarker.qtlid
  left join locus on qtlsignificantmarker.locusid=locus.id
where trait.name like '%1'
group by QTL
order by Trait, QTL
},

'barleyqtls' =>
qq{
-- QTLs
select 
  qtl.name as QTL,
  trait.name as Trait,
  mapdata.name as 'Map Data',
  qtl.chromosomearm as 'Chromosome arm',
  group_concat(distinct locus.name) as 'Significant marker'
from qtl
  left join trait on qtl.traitaffected_traitid=trait.id
  left join qtlmapdata on qtl.id=qtlmapdata.qtlid
  left join mapdata on qtlmapdata.mapdataid=mapdata.id
  left join qtlsignificantmarker on qtl.id=qtlsignificantmarker.qtlid
  left join locus on qtlsignificantmarker.locusid=locus.id
  join qtlspecies on qtlspecies.qtlid=qtl.id
  join species on species.id=qtlspecies.speciesid
where trait.name like '%1'
and species.name like 'Hordeum%'
group by QTL
order by Trait, QTL
},

'qtltraits' =>
qq{
-- Traits that have QTLs in GrainGenes
select distinct
 trait.name as Trait
from qtl 
 inner join trait on qtl.traitaffected_traitid=trait.id
-- where treatment is not null
order by trait.name
},


'barley_genes' =>
qq{
-- Barley genes
select 
  distinct
  gene.name as Gene_Symbol,
  genesynonym.name as Synonym,
  genechromosome.chromosome as Chrom,
  reference_1.name as Reference,
  reference_2.name as Info_Source,
  colleague.name as Data_Source
from gene
  left join genesynonym on gene.id = genesynonym.geneid
    and genesynonym.type = 'Synonym'
  left join genechromosome on gene.id = genechromosome.geneid
  left join genereference on gene.id = genereference.geneid
  left join reference reference_1 on genereference.referenceid = reference_1.id
  left join geneinfosource on gene.id = geneinfosource.geneid
  left join reference reference_2 on geneinfosource.referenceid = reference_2.id
  left join genedatasource on gene.id = genedatasource.geneid
  left join colleague on genedatasource.colleagueid = colleague.id
where gene.name like '%hordeum%'
order by gene.name, genesynonym.name, reference_1.name
},


'gene_germplasm' =>
    qq{
select
  gene.name as Gene,
  germplasm.name as Germplasm
from gene
  join genegermplasm on gene.id = genegermplasm.geneid
  join germplasm on genegermplasm.germplasmid = germplasm.id
order by gene.name
},


'allele_germplasm' =>
    qq{
select
  allele.name as Allele,
  gene.name as Gene,
  germplasm.name as Germplasm
from allele
  join allelegene on allele.id = allelegene.alleleid
  join gene on allelegene.geneid = gene.id
  join genegermplasm on gene.id = genegermplasm.geneid
  join germplasm on genegermplasm.germplasmid = germplasm.id
order by allele.name
},


'allele_differences' =>
qq{
-- Polymorphisms between two germplasm lines
select 
  allele.name as Allele,
  germplasm.name as Germplasm
from allele
  inner join allelegermplasm on allele.id = allelegermplasm.alleleid
  inner join germplasm on allelegermplasm.germplasmid = germplasm.id
    and allelegermplasm.type = 'Germplasm'
    -- '\%' can be used as wildcard
    and ( germplasm.name like '%1' 
       or germplasm.name like '%2' )
-- to ensure that either one or the other germplasm, but not both:     
group by allele.name having count(allele.name) = 1
order by allele.name
},

'allele_identities' =>
qq{
-- Monomorphisms between two germplasm lines
select 
  allele.name as Allele
from allele
  inner join allelegermplasm on allele.id = allelegermplasm.alleleid
  inner join germplasm on allelegermplasm.germplasmid = germplasm.id
    and allelegermplasm.type = 'Germplasm'
    -- '\%' can be used as wildcard
    and ( germplasm.name like '%1' 
       or germplasm.name like '%2' )
-- to ensure alleles from both lines:
group by allele.name having count(allele.name) = 2
order by allele.name
},

'WGRC_resistants' =>
qq{
-- Resistant Accessions (Wheat Genetics Resource Center)
select 
  germplasm.name as Accession,
  traitstudy.name as Trait_Study,
  germplasmtraitdescription.score as Score,
  germplasmtraitdescription.interpretation as Score_Interpretation
from germplasm
  inner join germplasmtraitdescription on germplasm.id = germplasmtraitdescription.germplasmid
    and germplasm.name like '%TA%'
    and (germplasmtraitdescription.interpretation = 'Resistant' or
         germplasmtraitdescription.interpretation = 'Immune' or
         germplasmtraitdescription.interpretation = 'Low sporulation')
  inner join traitstudy on germplasmtraitdescription.traitstudyid = traitstudy.id
    and traitstudy.name like '%WGRC%'
order by traitstudy.name
},

'icarda_durums' =>
qq{
-- ICARDA durums
select 
  germplasm.name as Name,
  germplasmremark.remark as Pedigree
from germplasm
  inner join germplasmcollection on germplasm.id = germplasmcollection.germplasmid
    and germplasm.name like '%ic%'
  inner join collection on germplasmcollection.collectionid = collection.id
    and collection.name = 'ICARDA'
  inner join germplasmspecies on germplasm.id = germplasmspecies.germplasmid
    and germplasmspecies.type = 'Subspecies'
  inner join species on germplasmspecies.speciesid = species.id
    and species.name like '%durum'
  left join germplasmremark on germplasm.id = germplasmremark.germplasmid
    and germplasmremark.type = 'Pedigree'
order by germplasm.name
},

'breeders' =>
qq{
-- Plant breeders
select
  colleague.name as Colleague,
  MIN(colleagueemail.email) as Email_Address,
  group_concat(DISTINCT colleagueremark.remark SEPARATOR '. ') as 'Position and interests'
from colleague
  left join colleagueemail on colleague.id = colleagueemail.colleagueid
  left join colleagueremark on colleague.id = colleagueremark.colleagueid
where colleagueremark.remark like '%breed%'
group by colleague.name
order by Colleague
},

'colleagues' =>
qq{
-- Colleagues
select 
  colleague.name as Colleague,
  colleagueemail.email as Email_Address,
  image.name as Photo
from colleague
  left join colleagueemail on colleague.id = colleagueemail.colleagueid
  left join colleagueimage on colleague.id = colleagueimage.colleagueid
  left join image on colleagueimage.imageid = image.id
where ( colleagueemail.email is not null ) or
      ( image.name is not null )
order by colleague.name, colleagueemail.email, image.name
},

# For Grainotypes (using GG data).
'traitstudyscores' =>
qq{
-- Trait Scores
-- All Environments, for a particular Trait_study,
-- "%1"
select distinct
  environment.name as Environment,
  germplasm.name as Germplasm,
  traitscore.score as Score,
  traitscore.standarddeviation as 'S.D.',
  traitscore.percentoflocalcheck as '% of check',
--  traitscore.differencefromlocalcheck as 'Diff from check',
  traitscore.replications as Reps
from traitscore
  join traitstudytraitscore on traitstudytraitscore.traitscoreid=traitscore.id
  join traitstudy on traitstudy.id=traitstudytraitscore.traitstudyid
  join traitscoreenvironment on traitscoreenvironment.traitscoreid=traitscore.id
  join environment on environment.id=traitscoreenvironment.environmentid
  join germplasm on germplasm.id=traitscore.germplasmid
where traitstudy.name like '%1'
order by Environment, score
},

# For UE-MOPN:
'traitstudyscores.uopn' =>
qq{
-- Trait Scores
-- All Environments, for a particular Trait_study,
-- "%1"
select distinct
  environment.name as Environment,
  germplasm.name as Germplasm,
  traitscore.score as Score,
  traitscore.unit as Units
from traitscore
  join traitstudytraitscore on traitstudytraitscore.traitscoreid=traitscore.id
  join traitstudy on traitstudy.id=traitstudytraitscore.traitstudyid
  join traitscoreenvironment on traitscoreenvironment.traitscoreid=traitscore.id
  join environment on environment.id=traitscoreenvironment.environmentid
  join germplasm on germplasm.id=traitscore.germplasmid
where traitstudy.name like '%1'
order by Environment, score
},

'traitstudies' =>
qq{
-- Trait Studies from ISWYN24.
select 
 traitstudy.name as 'Trait Study'
from traitstudy
where traitstudy.name like '%ISWYN24'
},

# For UE-MOPN:
'traitstudies.uopn' =>
qq{
-- Trait Studies from UE-MOPN.
select 
 traitstudy.name as 'Trait Study'
from traitstudy
where traitstudy.name like '%OPN'
or traitstudy.name like '%QUON'
},

'environmentscores' =>
qq{
-- Trait Scores
-- All Trait_studies, for a particular Environment,
-- "%1"
select distinct
  traitstudy.name as 'Trait Study',
  germplasm.name as Germplasm,
  traitscore.score as Score,
  traitscore.standarddeviation as 'S.D.',
  traitscore.percentoflocalcheck as '% of check',
--  traitscore.differencefromlocalcheck as 'Diff from check',
  traitscore.replications as Reps
from traitscore
  join traitscoreenvironment on traitscoreenvironment.traitscoreid=traitscore.id
  join environment on environment.id=traitscoreenvironment.environmentid
  join traitstudytraitscore on traitstudytraitscore.traitscoreid=traitscore.id
  join traitstudy on traitstudy.id=traitstudytraitscore.traitstudyid
  join germplasm on germplasm.id=traitscore.germplasmid
where environment.name like '%1'
order by 'Trait Study', score
},

'environments' =>
qq{
-- Environments from ISWYN24.
select 
  environment.name as 'Environment'
from environment
where environment.name like '%ISWYN24'
},


'germplasmscores' =>
qq{
-- All Environments, for a particular Trait, 
-- '%1', for one or two Germplasm lines
select distinct
  environment.name as Environment,
  germplasm.name as Germplasm,
  traitscore.score as Score,
  traitscore.standarddeviation as 'S.D.',
  traitscore.percentoflocalcheck as '% of check',
--  traitscore.differencefromlocalcheck as 'Diff from check',
  traitscore.replications as Reps
from traitscore
  join traitstudytraitscore on traitstudytraitscore.traitscoreid=traitscore.id
  join traitstudy on traitstudy.id=traitstudytraitscore.traitstudyid
  join traitscoreenvironment on traitscoreenvironment.traitscoreid=traitscore.id
  join environment on environment.id=traitscoreenvironment.environmentid
  join germplasm on germplasm.id=traitscore.germplasmid
where (germplasm.name like '%2'
  or germplasm.name like '%3')
  and traitstudy.name like '%1'
order by Environment, Germplasm
},

'germplasmscores.uopn' =>
qq{
-- All Environments for a particular set of Trait Studies, 
-- '%1', for one or two Germplasm lines
select distinct
  environment.name as Environment,
  germplasm.name as Germplasm,
  traitscore.score as Score,
  traitscore.unit as Units
from traitscore
  join traitstudytraitscore on traitstudytraitscore.traitscoreid=traitscore.id
  join traitstudy on traitstudy.id=traitstudytraitscore.traitstudyid
  join traitscoreenvironment on traitscoreenvironment.traitscoreid=traitscore.id
  join environment on environment.id=traitscoreenvironment.environmentid
  join germplasm on germplasm.id=traitscore.germplasmid
where (germplasm.name like '%2'
  or germplasm.name like '%3')
  and traitstudy.name like '%1'
order by Environment, Germplasm
},

'germplasms' =>
qq{
-- Germplasms from ISWYN24.
select distinct
  germplasm.name as 'Germplasm'
from traitscore
  join germplasm on germplasm.id=traitscore.germplasmid
where traitscore.name like '%ISWYN24'
},

'germplasms.uopn' =>
qq{
-- Germplasms from UE-MOPN.
select distinct
  germplasm.name as 'Germplasm'
from germplasm
  join germplasmspecies on germplasm.id=germplasmspecies.germplasmid
  join species on species.id=germplasmspecies.speciesid
  join germplasmremark on germplasm.id = germplasmremark.germplasmid
    and germplasmremark.type = 'Pedigree'
where species.name='Avena sativa'
},

'pedigrees.uopn' =>
qq{
-- Pedigrees from UE-MOPN.
select distinct
  germplasm.name as 'Germplasm',
  germplasmremark.remark as 'Pedigree'
from germplasm
  join germplasmspecies on germplasm.id=germplasmspecies.germplasmid
  join species on species.id=germplasmspecies.speciesid
  join germplasmremark on germplasm.id = germplasmremark.germplasmid
    and germplasmremark.type = 'Pedigree'
where species.name='Avena sativa'
and germplasm.name like '%1'
order by germplasm.name
},

# For UE-MOPN.
'locationscores.uopn' =>
qq{
-- Search by trait "%1" 
-- and location "%2", for all years
select environment.name as Year, 
       germplasm.name as Germplasm, 
       traitscore.score as Score,
       traitscore.unit as Units
from environment
  join traitscoreenvironment on traitscoreenvironment.environmentid=environment.id
  join traitscore on traitscore.id=traitscoreenvironment.traitscoreid
  join germplasm on germplasm.id=traitscore.germplasmid
  join traitstudytraitscore on traitstudytraitscore.traitscoreid=traitscore.id
  join traitstudy on traitstudy.id=traitstudytraitscore.traitstudyid
where environment.name like '%2'
  and traitstudy.name like '%1'
order by Germplasm, Year
},


# Also for Grainotypes:
'qtltraitscores' =>
qq{
-- Trait scores from a QTL mapping population
select
  traitstudy.name as "Trait Study",
  traitscore.name as Location,
  traitscoreremark.remark as Scores
from traitstudy
  join traitstudytraitscore on traitstudytraitscore.traitstudyid=traitstudy.id
  join traitscore on traitstudytraitscore.traitscoreid=traitscore.id
  join traitscoreremark on traitscoreremark.traitscoreid=traitscore.id
where traitscoreremark.type="Scores"
and traitstudy.name like '%1'
order by "Trait Study"
},

'qtltraitstudies' =>
qq{
-- All Trait Studies for QTL mapping.
select distinct
 traitstudy.name as 'Trait Study'
from traitstudy
  join traitstudytraitscore on traitstudytraitscore.traitstudyid=traitstudy.id
  join traitscore on traitstudytraitscore.traitscoreid=traitscore.id
  join traitscoreremark on traitscoreremark.traitscoreid=traitscore.id
where traitscoreremark.type="Scores"
},

'qtlmarkerscores' =>
qq{
-- Marker scores from a QTL mapping population
select distinct
  traitstudy.name as "Trait Study",
  locus.name as Locus,
  mapdatalocus.scoringdata as "Marker scores",
  mapdata.name as "Map Data"
from traitstudy
  join mapdata on mapdata.id=traitstudy.mapdataid
  join mapdatalocus on mapdatalocus.mapdataid=mapdata.id
  join locus on locus.id=mapdatalocus.locusid
where  traitstudy.name like '%1'
and mapdatalocus.scoringdata is not null
order by Locus
},


#################
# for "Avena Ave.", http://wheat.pw.usda.gov/GG2/oat.shtml

'oatqtls' =>
qq{
-- Oat QTLs
select 
  qtl.name as QTL,
  map.name as Map,
  group_concat(distinct locus.name) as 'Significant marker'
from qtl
  join qtlspecies on qtlspecies.qtlid = qtl.id
  join species on species.id = qtlspecies.speciesid 
     and species.name like 'Avena%'
  left join trait on qtl.traitaffected_traitid=trait.id
  left join mapqtl on mapqtl.qtlid = qtl.id
  left join map on map.id = mapqtl.mapid
  left join qtlsignificantmarker on qtl.id=qtlsignificantmarker.qtlid
  left join locus on qtlsignificantmarker.locusid=locus.id
where trait.name like '%1'
group by QTL
order by QTL
},

'oatssrs' =>
qq{
-- Microsatellites from oat
select
  distinct
  probe.name as SSR,
  pr.primeronesequence as Primer_1,
  pr.primertwosequence as Primer_2,
  pr.ampconditions as Conditions,
  prSSR.size as SSR_Size,
  sequence.name as Sequence
from probe
  inner join probetype on probe.id = probetype.probeid
    and probetype.type = 'SSR'
  inner join probesourcespecies on probe.id = probesourcespecies.probeid
  inner join species on species.id = probesourcespecies.speciesid 
    and species.name like 'Avena%'
  -- Get primer sequences and conditions:
  inner join probeprimer pr on probe.id = pr.probeid
    and pr.primeronesequence is not null
  -- Get any size data: 
  left join probeprimer prSSR on prSSR.probeid = probe.id
    and prSSR.sizetype = 'SSR_size'
  left join sequenceprobe on probe.id = sequenceprobe.probeid 
  left join sequence on sequenceprobe.sequenceid = sequence.id
},

'oat-mappedssrs' =>
qq{
-- SSR's mapped on oat
select
  distinct
  probe.name as SSR,
  locus.name as Locus,
  map.name as Map,
  maplocus.begin as Position
from species 
  join mapdataspecies on mapdataspecies.speciesid = species.id
     and species.name like 'Avena%'
  join mapdata on mapdata.id = mapdataspecies.mapdataid 
     and mapdata.name not like 'Triticeae%'
  join mapdatalocus on mapdatalocus.mapdataid = mapdata.id
  join locus on locus.id = mapdatalocus.locusid 
  join locusprobe on locusprobe.locusid = locus.id 
  join probe on probe.id = locusprobe.probeid
  join probetype on probetype.probeid  = probe.id 
    and probetype.type = 'SSR'
  join maplocus on maplocus.locusid = locus.id
    and maplocus.begin is not null
  join map on map.mapdataid = mapdata.id
    and map.id = maplocus.mapid
order by Map, Position
},

'oatstss' =>
qq{
-- STSs from oat
select
  distinct
  probe.name as STS,
  p1.primeronesequence as Primer_1,
  p1.primertwosequence as Primer_2,
  p1.ampconditions as Conditions,
  p2.size as Size
from probeprimer p1
  inner join probe on p1.probeid = probe.id
    and p1.primeronesequence is not null
  inner join probetype on probe.id = probetype.probeid 
    and probetype.type = 'STS'
  -- left join: to include PCR_size if available  
  left join probeprimer p2 on p1.probeid = p2.probeid
    and p2.sizetype = 'STS_size'
  inner join probesourcespecies on p1.probeid = probesourcespecies.probeid
  inner join species on species.id = probesourcespecies.speciesid 
    and species.name like 'Avena%'
  order by STS
},

'oat-mappedstss' =>
qq{
-- STS's mapped on oat
select
  distinct
  probe.name as STS,
  locus.name as Locus,
  map.name as Map,
  maplocus.begin as Position
from species 
  join mapdataspecies on mapdataspecies.speciesid = species.id
     and species.name like 'Avena%'
  join mapdata on mapdata.id = mapdataspecies.mapdataid 
     and mapdata.name not like 'Triticeae%'
  join mapdatalocus on mapdatalocus.mapdataid = mapdata.id
  join locus on locus.id = mapdatalocus.locusid 
  join locusprobe on locusprobe.locusid = locus.id 
  join probe on probe.id = locusprobe.probeid
  join probetype on probetype.probeid  = probe.id 
    and probetype.type = 'STS'
  join maplocus on maplocus.locusid = locus.id
    and maplocus.begin is not null
  join map on map.mapdataid = mapdata.id
    and map.id = maplocus.mapid
order by Map, Position
},


'oatmail-list' =>
qq{
-- Members of the oatmail mailgroup
select distinct
  colleague.name as Colleague,
  colleagueemail.email as Email, 
  colleagueaddress.mail as Address,
  colleagueaddress.country as Country
from colleague
  join colleagueobtainedfrom on colleagueobtainedfrom.colleagueid = colleague.id
  join source on source.id = colleagueobtainedfrom.sourceid
     and source.name = 'oatmail'
  join colleagueemail on colleagueemail.colleagueid = colleague.id 
  left join colleagueaddress on colleagueaddress.colleagueid = colleague.id 
order by Colleague, Email
},

'locustype' =>
qq{
-- Loci of a particular type from a particular species
select locus.name as Locus, probe.name as Probe, species.name as Species,
  locustype.type
from locus
  join locustype on locustype.locusid = locus.id
  join locusprobe on locusprobe.locusid = locus.id
  join probe on probe.id = locusprobe.probeid
  join probesourcespecies on probesourcespecies.probeid = probe.id
  join species on species.id = probesourcespecies.speciesid
where locustype.type like '%1'
  and species.name like '%2'
},

'barleyssrs' =>
qq{
-- SSRs derived from barley
select distinct probe.name
from probe
join probesourcespecies on probesourcespecies.probeid = probe.id
join species on species.id = probesourcespecies.speciesid
join probetype on probetype.probeid = probe.id
where species.name like 'Hordeum%'
and probetype.type = 'SSR'
order by probe.name
},

'barley-mappedssrs' =>
qq{
-- SSRs mapped on barley
select distinct probe.name
from probe
join locusprobe on locusprobe.probeid = probe.id
join locus on locus.id = locusprobe.locusid
join mapdatalocus on mapdatalocus.locusid = locus.id
join mapdata on mapdata.id = mapdatalocus.mapdataid
join mapdataspecies on mapdataspecies.mapdataid = mapdata.id
join species on species.id = mapdataspecies.speciesid
join probetype on probetype.probeid = probe.id
where species.name like 'Hordeum%'
and probetype.type = 'SSR'
order by probe.name
},

'barleysnps' =>
qq{
-- SNPs derived from barley
select distinct probe.name
from probe
join probesourcespecies on probesourcespecies.probeid = probe.id
join species on species.id = probesourcespecies.speciesid
join locusprobe on locusprobe.probeid = probe.id
join locus on locus.id = locusprobe.locusid
join locustype on locustype.locusid = locus.id
where species.name like 'Hordeum%'
and locustype.type = 'SNP'
order by probe.name
},

'barley-mappedsnps' =>
qq{
-- SNPs mapped on barley
select distinct probe.name
from probe
join locusprobe on locusprobe.probeid = probe.id
join locus on locus.id = locusprobe.locusid
join locustype on locustype.locusid = locus.id
join mapdatalocus on mapdatalocus.locusid = locus.id
join mapdata on mapdata.id = mapdatalocus.mapdataid
join mapdataspecies on mapdataspecies.mapdataid = mapdata.id
join species on species.id = mapdataspecies.speciesid
where species.name like 'Hordeum%'
and locustype.type = 'SNP'
order by probe.name
},

'barleyrflps' =>
qq{
-- RFLPs derived from barley
select distinct probe.name
from probe
join probesourcespecies on probesourcespecies.probeid = probe.id
join species on species.id = probesourcespecies.speciesid
join locusprobe on locusprobe.probeid = probe.id
join locus on locus.id = locusprobe.locusid
join locustype on locustype.locusid = locus.id
where species.name like 'Hordeum%'
and locustype.type = 'RFLP'
order by probe.name
},

'barley-mappedrflps' =>
qq{
-- RFLPs mapped on barley
select distinct probe.name
from probe
join locusprobe on locusprobe.probeid = probe.id
join locus on locus.id = locusprobe.locusid
join locustype on locustype.locusid = locus.id
join mapdatalocus on mapdatalocus.locusid = locus.id
join mapdata on mapdata.id = mapdatalocus.mapdataid
join mapdataspecies on mapdataspecies.mapdataid = mapdata.id
join species on species.id = mapdataspecies.speciesid
where species.name like 'Hordeum%'
and locustype.type = 'RFLP'
order by probe.name
},

'barleyparents' =>
qq{
-- Parents of barley maps
select distinct 
   mapdata.name as Mapdata,
   germplasm.name as Parent,
   g2.name as 'Female parent',
   g3.name as 'Male parent'
from mapdata
left join mapdataparent on mapdataparent.mapdataid = mapdata.id
left join germplasm on germplasm.id = mapdataparent.germplasmid
left join germplasm g2 on g2.id = mapdata.femaleparent_germplasmid
left join germplasm g3 on g3.id = mapdata.maleparent_germplasmid
join germplasmspecies on germplasmspecies.germplasmid = germplasm.id 
  or germplasmspecies.germplasmid = g2.id 
  or germplasmspecies.germplasmid = g3.id
join species on species.id = germplasmspecies.speciesid
where species.name like 'Hordeum%'
order by mapdata.name
},

'barleyparents2' =>
qq{
-- Parents of barley maps
-- Faster, but not all parents are included.
select distinct 
   mapdata.name as Mapdata,
   germplasm.name as Parent
from mapdata
join mapdataparent on mapdataparent.mapdataid = mapdata.id
join germplasm on germplasm.id = mapdataparent.germplasmid
join germplasmspecies on germplasmspecies.germplasmid = germplasm.id 
join species on species.id = germplasmspecies.speciesid
where species.name like 'Hordeum%'
order by mapdata.name
},

'ryessrs' =>
qq{
-- Microsatellites from rye
select
  distinct
  probe.name as SSR,
  pr.primeronesequence as Primer_1,
  pr.primertwosequence as Primer_2,
  pr.ampconditions as Conditions,
  prSSR.size as SSR_Size,
  sequence.name as Sequence
from probe
  inner join probetype on probe.id = probetype.probeid
    and probetype.type = 'SSR'
  inner join probesourcespecies on probe.id = probesourcespecies.probeid
  inner join species on species.id = probesourcespecies.speciesid 
    and species.name like 'Secale%'
  -- Get primer sequences and conditions:
  inner join probeprimer pr on probe.id = pr.probeid
    and pr.primeronesequence is not null
  -- Get any size data: 
  left join probeprimer prSSR on prSSR.probeid = probe.id
    and prSSR.sizetype = 'SSR_size'
  left join sequenceprobe on probe.id = sequenceprobe.probeid 
  left join sequence on sequenceprobe.sequenceid = sequence.id
},

'rye-mappedssrs' =>
qq{
-- SSR's mapped on rye
select
  distinct
  probe.name as SSR,
  locus.name as Locus,
  map.name as Map,
  maplocus.begin as Position
from species 
  join mapdataspecies on mapdataspecies.speciesid = species.id
     and species.name like 'Secale%'
  join mapdata on mapdata.id = mapdataspecies.mapdataid 
     and mapdata.name not like 'Triticeae%'
  join mapdatalocus on mapdatalocus.mapdataid = mapdata.id
  join locus on locus.id = mapdatalocus.locusid 
  join locusprobe on locusprobe.locusid = locus.id 
  join probe on probe.id = locusprobe.probeid
  join probetype on probetype.probeid  = probe.id 
    and probetype.type = 'SSR'
  join maplocus on maplocus.locusid = locus.id
    and maplocus.begin is not null
  join map on map.mapdataid = mapdata.id
    and map.id = maplocus.mapid
order by Map, Position
},

'ryestss' =>
qq{
-- STSs from rye
select
  distinct
  probe.name as STS,
  p1.primeronesequence as Primer_1,
  p1.primertwosequence as Primer_2,
  p1.ampconditions as Conditions,
  p2.size as Size
from probeprimer p1
  inner join probe on p1.probeid = probe.id
    and p1.primeronesequence is not null
  inner join probetype on probe.id = probetype.probeid 
    and probetype.type = 'STS'
  -- left join: to include PCR_size if available  
  left join probeprimer p2 on p1.probeid = p2.probeid
    and p2.sizetype = 'STS_size'
  inner join probesourcespecies on p1.probeid = probesourcespecies.probeid
  inner join species on species.id = probesourcespecies.speciesid 
    and species.name like 'Secale%'
  order by STS
},

'rye-mappedstss' =>
qq{
-- STS's mapped on rye
select
  distinct
  probe.name as STS,
  locus.name as Locus,
  map.name as Map,
  maplocus.begin as Position
from species 
  join mapdataspecies on mapdataspecies.speciesid = species.id
     and species.name like 'Secale%'
  join mapdata on mapdata.id = mapdataspecies.mapdataid 
     and mapdata.name not like 'Triticeae%'
  join mapdatalocus on mapdatalocus.mapdataid = mapdata.id
  join locus on locus.id = mapdatalocus.locusid 
  join locusprobe on locusprobe.locusid = locus.id 
  join probe on probe.id = locusprobe.probeid
  join probetype on probetype.probeid  = probe.id 
    and probetype.type = 'STS'
  join maplocus on maplocus.locusid = locus.id
    and maplocus.begin is not null
  join map on map.mapdataid = mapdata.id
    and map.id = maplocus.mapid
order by Map, Position
},

'wheat-snps' =>
qq{
-- Wheat SNPs
select probe.name as Probe, 
       proberemark.remark as 'Linkage Group',
       probeprimer.primeronesequence as Primer1,
       probeprimer.primertwosequence as Primer2
from probe
left join proberemark on proberemark.probeid = probe.id
  and proberemark.type = "Linkage_Group"
left join probeprimer on probeprimer.probeid = probe.id
join probetype on probetype.probeid = probe.id
join probesourcespecies on probesourcespecies.probeid = probe.id
join species on species.id = probesourcespecies.speciesid
where probetype.type = 'SNP'
  and species.name = 'Triticum aestivum'
order by probe.name
},

};

1;

