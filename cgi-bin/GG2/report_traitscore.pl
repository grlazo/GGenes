#!/usr/bin/perl

# NLui, 26Apr2004

# print traitscore report elements
# require from report.cgi

our ($dbh,$cgi,$id,$class);

# OK name
&print_element(
	       $cgi,
	       $dbh,
	       'traitscore',
	       'Trait Score',
	       qq{
		   select name 
		   from traitscore 
		   where id = $id
		   },
	       ['name'],
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
                    traitstudy.id as traitstudy_id,
                    traitstudy.name as traitstudy_name
                   from traitstudy
                    inner join traitstudytraitscore on traitstudy.id = traitstudytraitscore.traitstudyid
                   where traitstudytraitscore.traitscoreid = $id
		   },
	       ['traitstudy_link'],
	       []
	       );     

# OK environment
&print_element(
	       $cgi,
	       $dbh,
	       'environment',
	       'Environment',
	       qq{
		   select
                    environment.id as environment_id,
                    environment.name as environment_name
                   from environment
                    inner join traitscoreenvironment on environment.id = traitscoreenvironment.environmentid
                   where traitscoreenvironment.traitscoreid = $id
		   },
	       ['environment_link'],
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
		    remark 
		   from traitscoreremark 
		   where traitscoreid = $id
		    and type = 'Comment'
		   },
	       ['remark'],
	       []
	       );	       

# OK scores
&print_element(
	       $cgi,
	       $dbh,
	       'scores',
	       'Scores',
	       qq{
		   select 
		    remark 
		   from traitscoreremark 
		   where traitscoreid = $id
		    and type = 'Scores'
		   },
	       ['remark'],
	       []
	       );
	       
# scoremeansd,germplasmmeansd,germplasmscore removed from schema
# OK germplasm
&print_element(
	       $cgi,
	       $dbh,
	       'germplasm',
	       'Germplasm',
	       qq{
		   select
                    germplasm.id as germplasm_id,
                    germplasm.name as germplasm_name
                   from germplasm
                    inner join traitscore on germplasm.id = traitscore.germplasmid
                   where traitscore.id = $id
		   },
	       ['germplasm_link'],
	       []
	       );    

# OK score
&print_element(
	       $cgi,
	       $dbh,
	       'score',
	       'Score',
	       qq{
		   select score 
		   from traitscore 
		   where id = $id
		   },
	       ['score'],
	       []
	       );
	       
# OK standarddeviation
&print_element(
	       $cgi,
	       $dbh,
	       'standarddeviation',
	       'Standard Deviation',
	       qq{
		   select standarddeviation 
		   from traitscore 
		   where id = $id
		   },
	       ['standarddeviation'],
	       []
	       );

# OK replications
&print_element(
	       $cgi,
	       $dbh,
	       'replications',
	       'Replications',
	       qq{
		   select replications 
		   from traitscore 
		   where id = $id
		   },
	       ['replications'],
	       []
	       );

# OK percentoflocalcheck
&print_element(
	       $cgi,
	       $dbh,
	       'percentoflocalcheck',
	       'Percent of local check',
	       qq{
		   select percentoflocalcheck 
		   from traitscore 
		   where id = $id
		   },
	       ['percentoflocalcheck'],
	       []
	       );

# OK differencefromlocalcheck
&print_element(
	       $cgi,
	       $dbh,
	       'differencefromlocalcheck',
	       'Difference from local check',
	       qq{
		   select differencefromlocalcheck 
		   from traitscore 
		   where id = $id
		   },
	       ['differencefromlocalcheck'],
	       []
	       );

# OK pathogenrace
&print_element(
	       $cgi,
	       $dbh,
	       'pathogenrace',
	       'Pathogen Race',
	       qq{
		   select
                    isolate.id as isolate_id,
                    isolate.name as isolate_name
                   from isolate
                    inner join traitscorepathogenrace on isolate.id = traitscorepathogenrace.isolateid
                   where traitscorepathogenrace.traitscoreid = $id
		   },
	       ['isolate_link'],
	       []
	       );    

1;
