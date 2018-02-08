#!/usr/bin/perl

our $search_elements = {

'order' => [qw/
	    name
	    ssr
	    /],

'name' => {
    'realname' => 'Name',
    'sql' => qq{
	select id from probe
	},
    'searchcols' => ['name']
},

'ssr' => {
    'realname' => 'SSR',
    'sql' => qq{
	select distinct
	    probe.id
	    from probe
	    inner join probetype on probe.id = probetype.probeid
	    where probetype.type = 'SSR'
	},
    'searchcols' => ['probe.name']
}

};

1;
