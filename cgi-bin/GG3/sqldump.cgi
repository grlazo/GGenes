#!/usr/bin/perl

# sqldump.cgi
# created by david hummel <hummel@pw.usda.gov>
# dump an sql query as text
#
# called from sql.cgi
#
# call this script with a symlink called 'pgsqldump.cgi'
# to use postgresql instead of mysql
# this requires 'Options FollowSymlinks' for cgi-bin
# in httpd.conf

# CGI params:
# db -> sql db name
# sql -> sql string

use DBI;
use CGI qw(-no_xhtml);
CGI::ReadParse(*in);
$cgi = $in{CGI};
$| = 1; # Flush StdOut

# globals
$prog = $0; $prog =~ s/^.*\///;
if ($prog eq 'pgsqldump.cgi') {
    $dbidrv = 'Pg:dbname=';
} else {
    $dbidrv = 'mysql:';
}

require "global.pl";
our ($user,$pass);

$sqluser = $user;
$sqlpass = $pass;

#print "Content-type: text/plain\n\n";
print "Content-type: application/octet-stream\n";
print "Content-Disposition: attachment; filename=\"queryresults.txt\"\n\n";
$dbh = DBI->connect("DBI:$dbidrv$in{'db'}", $sqluser, $sqlpass);
$sth = $dbh->prepare($in{'sql'}); $sth->execute;
$fields_ref = $sth->{NAME};

# If the column is named "Scoringdata" (from Mapdata scores), 
# strip all whitespace.
for ($i = 0; $i <= $#$fields_ref; $i += 1) {
    $label = @$fields_ref[$i];
    if ($label =~ "Scoringdata") {$squeeze = $i;}
}

print join("\t",@$fields_ref),"\n";

while (@row = $sth->fetchrow) {
    if (defined($squeeze)) {
	$row[$squeeze] =~ s/\s//g ;      # Strip whitespace.
    }
    print join("\t",@row),"\n";
}
$dbh->disconnect;
