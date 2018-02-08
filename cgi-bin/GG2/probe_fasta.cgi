#!/usr/bin/perl -w

#----------------------------------------------------
# file name: probe_fasta.cgi
# description: obtain a fasta file from a list of probes
# created: 5jul05 DEM, based on:
#   est_fasta.cgi
#   created: 04/26/2002 DDH
#---------------------------------------------------

# CGI params:
# e -> list of probes
# f -> uploaded file list of probes

use CGI qw(-no_xhtml);
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
$probes = ''; 		# list of requested probes
@probes = ();		# list of requested probes

$ests = ''; 		# list of requested accessions
@ests = ();		# list of requested accessions

$requests = 0; 		# number of probes entered
$results = 0; 		# number of sequences obtained
$cgipath = "$cgiurlpath/probe_fasta.cgi";

if ($ENV{'REQUEST_METHOD'} eq 'POST' && $get->param()) {

    if ($get->param('f')) {			# filename entered
        my $buffer;
	my $bytes = 0; 				# byte tally
        my $file = $get->upload('f');
        while (read($file,$buffer,$readbytes)) {
		$probes .= $buffer;		# add probe list from file
		$bytes += $readbytes;
		if ($bytes > $maxbytes) { &maxbytes; exit(0); }
	}
    }

    if ($probes .= $get->param('e')) {}		# add probe list from list entered in textarea

    if (length($probes) > $maxbytes) { &maxbytes; exit(0); }

    $probes =~ s/^\s+//; $probes =~ s/\s+$//;	# strip off leading/trailing spaces
    @probes = split (/[\r\n]+/, $probes);
    $requests = @probes;
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
<title>Batch Query for Probes' FASTA Sequences</title>
<h3>Batch Query for Probes: Obtain Sequences in FASTA Format</h3>
<p>Obtain FASTA for all sequences derived from a list of probe names.</p>
TITLE
}

sub printform {
print <<FORM;
<font size="11px">
	<form action="$cgipath" method="post" enctype="multipart/form-data">
	<table>
		<tr>
		<td valign="top">
			<b>Select a file containing a list of probe names</b><br>
FORM
			printf "<input type=\"file\" name=\"f\" value=\"\" size=\"42\"><br>\n", $get->param('f');
print <<FORM;
			</p>
			<p><b>and/or</b></p>
			<p>
			<b>Insert a list of probe names</b><br>
FORM
			printf "<textarea cols=\"48\" name=\"e\" rows=\"14\" wrap=\"virtual\">%s</textarea>\n", $get->param('e');
print <<FORM;
			</p>
		</td>
		<td valign="top">
                        <ul><big><b><u>Search&nbsp;instructions</u></b></big><br>
                                <li>Specify a file and/or insert your list (one per row) of probe names.</li>
                                <li>You may enter up to a maximum of $maxseq names.</li>
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
    my @missing; 	# probes where no sequence found
    if ($ENV{'HTTP_USER_AGENT'} =~ /windows/i) {
        $nl = "\r\n";
    } else {
        $nl = "\n";
    }
    print "Content-type: application/octet-stream\n";
    print "Content-Disposition: attachment; filename=\"probes_fasta.txt\"\n\n";
    foreach my $p (@probes) {
	#print "${p} ${nl}";
	my $seqref = &getseq($p);
	my $seqfound = 0;
	foreach my $sr (@$seqref) {
	    my ($probe,$name,$title,$seq) = @$sr;
	    if ($seq) {
		$seqfound = 1;
		$results++;
		print ">${name} ${title} Probe: ${probe} ${nl}";
		$seq =~ tr/a-z/A-Z/;
                if ($seq !~ /\n/) {
                    # assume that seq is one long string without linebreaks
                    my $newseq;
                    while ($seq) {
                        my $sub = substr ($seq, 0, 50, "");
                        $newseq .= "$sub\n";
                    }
                    print "$newseq";
                } else {
                    # assume that seq is already in FASTA format
                    print "$seq";
                    print "\n" if $seq !~ /\n$/;
                }
	    } elsif ($seqfound == 0) {
		push(@missing, $probe);
	    }
	}
    }
    if ($results == 0) {
	print "No sequences found${nl}${nl}Please try again$nl";
    } else {
	print "$nl";
	printf "// %d probe%s requested, %d sequence%s obtained$nl", $requests, $requests > 1 ? 's' : '', $results, $results > 1 ? 's' : '';
	if (@missing) {
	    print "// No sequences found for:$nl";
	    foreach (@missing) {
		print "// $_$nl";
	    }
	}
    }
}

sub getseq {
    my $probe = shift;
    my $sql = "select probe.name, sequence.name, sequence.title, dna.sequence
               from probe
                left join sequenceprobe on sequenceprobe.probeid = probe.id
                left join sequence on sequenceprobe.sequenceid = sequence.id
                left join dna on sequence.dnaid = dna.id
               where probe.name = '$probe'";
    my $seqref = $dbh->selectall_arrayref($sql);
#    my $sth = $dbh->prepare($sql); $sth->execute;
#    my $seqref = $sth->fetchall_arrayref({});
    return $seqref;
}

sub maxseqs {
        print "Content-type: text/html\n\n";
        print "<html><body>\n";
	print "You have entered more than $maxseq names.<br><br>";
	print "Please <a href=\"$cgipath\">try again</a> with up to $maxseq probes.\n";
	print "</body></html>\n";
}

sub noseqs {
        print "Content-type: text/html\n\n";
        print "<html><body>\n";
	print "You have not entered any probe names.<br><br>";
	print "Please <a href=\"$cgipath\">try again</a> with up to $maxseq probes.\n";
	print "</body></html>\n";
}

sub maxbytes {
        print "Content-type: text/html\n\n";
        print "<html><body>\n";
	print "You have uploaded too much data. The limit is $maxbytes bytes.<br><br>";
	print "Please <a href=\"$cgipath\">try again</a>\n";
	print "</body></html>\n";
}
