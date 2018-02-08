#!/usr/bin/perl

# query db and build xml record 
# based on results 


use strict;
use warnings;
use graingenes;

my $gg = new graingenes || die;
my $dbh = $gg->{'DBI'};
my $cgi = $gg->{'CGI'};
my $tmpl = $gg->{'TMPL'};

my $table = $cgi->param('table');
my $colname = $cgi->param('col');
my $pattern = $cgi->param('match');
my $msg ="";

if ($table && $colname && $pattern){
	my $columnsref = $gg->table_info($table);
	# build table here
	#$tmpl->param('tablename'=>$table);
	my $res = $gg->querylike_table($table,$colname,$pattern);
	my @arr;      
	print $cgi->header('text/xml');
	print '<?xml version="1.0" encoding="ISO-8859-1"?>'."\n"; #no encoding crashed IE
	print '<collection>';
	print '<class>'.$table.'</class>';
	foreach my $id (keys %$res){
	    print STDERR "ID=".$id."\n";
	    print '<'.$table.'>';
	    
	    foreach my $col (keys %{$res->{$id}}){
		#print STDERR "TEST=".$res->{$id}->{$col};
		print "<".$col.">";
		print $res->{$id}->{$col};
		print "</".$col.">";
		#push(@arr,{'rowname'=>$col,
		 #      'rowvalue'=>$$res{$col} }) unless ($col eq 'id');
	    }
	    print '</'.$table.'>';
	}
	print '</collection>';

} else {
    # show error msg
    #print $cgi->redirect("browse.cgi");
    #exit;
}

#print $cgi->header;
#print $tmpl->output;
