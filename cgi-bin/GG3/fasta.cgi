#!/usr/bin/perl

# David Hummel (dhummel@chip.org) 2005-01-12

# download FASTA from list of sequence ids or names
# call from search.cgi button

# CGI params:
# t -> target, id or name (i|n)
# e -> space-separated list of ids/names

use strict;
use warnings;
use CGI qw(-no_xhtml);
use DBI;
require "global.pl";

our ($user,$pass,$dsn);
our $dbh = DBI->connect($dsn,$user,$pass);
our $cgi = new CGI;
our $target = $cgi->param('t');
our $seqs = $cgi->param('e');
exit unless $target =~ /^(i|n)$/;
exit unless $seqs;
our @seqs = split (/\s+/, $seqs);
our $requested = @seqs;
our $obtained = 0;

$dbh->disconnect;

#print "Content-type: text/plain\n\n";
print "Content-type: application/octet-stream\n";
print "Content-Disposition: attachment; filename=\"sequences.fasta\"\n\n";
foreach my $s (@seqs) {
    my $seqref = &getseq($s);
    my ($name,$seq) = @$seqref;
    if ($seq) {
	$obtained++;
	print ">$name\n";
	$seq =~ s/\s+//g;
	$seq =~ tr/a-z/A-Z/;
	while ($seq) {
	    my $sub = substr ($seq, 0, 50, "");
	    print "$sub\n";
	}
    }
}
if ($obtained == 0) {
    print "No sequences found\n\nPlease try again\n";
} else {
    printf "\n// %d sequence%s requested, %d obtained\n", $requested, $requested > 1 ? 's' : '', $obtained;
}

#######

sub getseq {
    my $seq = shift;
    my $sql = qq{
	select sequence.name,dna.sequence
	from sequence
	inner join dna on sequence.dnaid = dna.id
	where };
    if ($target eq 'i') {
        $sql .= 'sequence.id';
        $sql .= " = $seq";
    } elsif ($target eq 'n') {
        $sql .= 'sequence.name';
        $sql .= sprintf(" = %s",$dbh->quote($seq));
    }
    return $dbh->selectrow_arrayref($sql);
}
