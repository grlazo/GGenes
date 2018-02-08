#!/usr/bin/perl

#----------------------------------------------------
# file name: est_fasta.cgi
# description: obtain a fasta file from a list of sequence accessions
# created: 04/26/2002 DDH
# rev. NL 10Nov2004 for use with GrainGenes2
#---------------------------------------------------

# CGI params:
# e -> list of accessions
# f -> uploaded file list of accessions

use CGI;
use DBI;
require "global.pl";

$| = 1; # Flush StdOut

# open db
$dbh = DBI->connect("DBI:mysql:$db", $user, $pass);

# globals
$get = new CGI;
$maxseq = 10000;
#$maxbytes = 1048576;	# max bytes of uploaded data allowed
$maxbytes = 200000;	# max bytes of uploaded data allowed
$readbytes = 1024; 	# read uploaded file bytes at a time
$sql = '';
$ests = ''; 		# list of requested accessions
@ests = ();		# list of requested accessions
$requests = 0; 		# number of accessions entered
$results = 0; 		# number of sequences obtained
$cgipath = "$cgiurlpath/est_fasta.cgi";

if ($ENV{'REQUEST_METHOD'} eq 'POST' && $get->param()) {

    if ($get->param('f')) {			# filename entered
        my $buffer;
	my $bytes = 0; 				# byte tally
        my $file = $get->upload('f');
        while (read($file,$buffer,$readbytes)) {
		$ests .= $buffer;		# add names/accessions from file
		$bytes += $readbytes;
		if ($bytes > $maxbytes) { &maxbytes; exit(0); }
	}
    }

    if ($ests .= $get->param('e')) {}		# add names/accessions from list entered in textarea

    if (length($ests) > $maxbytes) { &maxbytes; exit(0); }

    $ests =~ s/^\s+//; $ests =~ s/\s+$//;	# strip off leading/trailing spaces
    @ests = split (/[\r\n]+/, $ests);
    $requests = @ests;
    if (!$requests) {
	&noseqs;
    } elsif ($requests > $maxseq) {
	&maxseqs;
    } else {
	&getfasta;
    }

} else {

    &printtop;
    &printform;
    &printbottom;

}

# close db
$dbh->disconnect;

#########################

sub printtop {
print $get->header;
print $get->start_html(-title=>"Batch Query for Sequences: Obtain Sequences in FASTA Format")
    unless (-r $html_include_header && &print_include($html_include_header));
print <<TITLE;
<title>Batch Query for FASTA Sequences</title>
<h3>Batch Query for Sequences: Obtain Sequences in FASTA Format</h3>
<p>Obtain FASTA sequences from a list of sequence names or GenBank accession numbers.</p>
TITLE
}

sub printform {
print <<FORM;
<font size="11px">
	<form action="$cgipath" method="post" enctype="multipart/form-data">
	<table>
		<tr>
		<td valign="top">
			<b>Select a file containing a list of names or accession numbers</b><br>
FORM
			printf "<input type=\"file\" name=\"f\" value=\"\" size=\"42\"><br>\n", $get->param('f');
print <<FORM;
			</p>
			<p><b>and/or</b></p>
			<p>
			<b>Insert a list of names or accession numbers</b><br>
FORM
			printf "<textarea cols=\"48\" name=\"e\" rows=\"14\" wrap=\"virtual\">%s</textarea>\n", $get->param('e');
print <<FORM;
			</p>
		</td>
		<td valign="top">
                        <ul><big><b><u>Search&nbsp;instructions</u></b></big><br>
                                <li>Specify a file and/or insert your list (one per row) of names/accessions.</li>
                                <li>You may enter up to a maximum of $maxseq names/accessions.</li>
                                <li>Click <i>Submit</i>.</li>
                                <li>Specify a location to save the resulting file.</li>
                                <li>View the bottom of the file for statistics and missing sequences.</li>
                        </ul>
		</td>
		</tr>
		<tr>
		<td colspan="2">
			<input type="submit" value="Submit"><input type="reset" value="Reset">
		</td>
		</tr>
	</table>
	</form>
</font>	
FORM
}

sub printbottom {
   print $get->end_html
    unless (-r $html_include_footer && &print_include($html_include_footer));

}

sub getfasta {
    my $nl; 		# platform dependent line endings
    my @missing; 	# names/accessions where no sequence found
    if ($ENV{'HTTP_USER_AGENT'} =~ /windows/i) {
        $nl = "\r\n";
    } else {
        $nl = "\n";
    }
    print "Content-type: application/octet-stream\n";
    print "Content-Disposition: attachment; filename=\"ests_fasta.txt\"\n\n";
    foreach (@ests) {
	my $seqref = &getseq($_);
	my ($name,$title,$seq) = @$seqref;
	if ($seq) {
	    $results++;
	    print ">${name} ${title} ${nl}";
	    $seq =~ tr/a-z/A-Z/;
	    print "$seq";	# no need to get substring as sequences already in FASTA format
	} else {
	    push(@missing, $_);
	}
    }
    if ($results == 0) {
	print "No sequences found${nl}${nl}Please try again$nl";
    } else {
	print "$nl";
	printf "// %d sequence%s requested, %d obtained$nl", $requests, $requests > 1 ? 's' : '', $results;
	if (@missing) {
	    print "// no sequences found for:$nl";
	    foreach (@missing) {
		print "// $_$nl";
	    }
	}
    }
}

sub getseq {
    my $est = shift;
    my $sql = "select sequence.name, sequence.title, dna.sequence 
               from sequence 
                inner join dna on sequence.dnaid = dna.id 
               where sequence.name = '$est'";
    my $seqref = $dbh->selectrow_arrayref($sql);
    return $seqref;
}

sub maxseqs {
        print "Content-type: text/html\n\n";
        print "<html><body>\n";
	print "You have entered more than $maxseq names or accessions.<br><br>";
	print "Please <a href=\"$cgipath\">try again</a> with up to $maxseq names or accessions.\n";
	print "</body></html>\n";
}

sub noseqs {
        print "Content-type: text/html\n\n";
        print "<html><body>\n";
	print "You have not entered any names or accessions.<br><br>";
	print "Please <a href=\"$cgipath\">try again</a> with up to $maxseq names or accessions.\n";
	print "</body></html>\n";
}

sub maxbytes {
        print "Content-type: text/html\n\n";
        print "<html><body>\n";
	print "You have uploaded too much data. The limit is $maxbytes bytes.<br><br>";
	print "Please <a href=\"$cgipath\">try again</a>\n";
	print "</body></html>\n";
}
