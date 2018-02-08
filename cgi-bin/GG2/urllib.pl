#!/usr/bin/perl

sub geturlhash {
    # converts a hash of cgi parameters to a url-encoded version
    # expects a hashref, returns a hash
    my $inref = shift; my %url;
    while (my ($key,$value) = each %{$inref}) {$url{$key} = &geturlstring($value);}
    return %url;
}

sub geturlstring {
    # encode a string for a url
    # expects a string, returns a string
    my $text = shift;
    #$text =~ s/([^\r])\n/$1\r\n/g;
    $text =~ s/([^a-z0-9_.!~*'() -])/sprintf "%%%02X", ord($1)/gei;
    $text =~ tr/ /+/;
    return $text;
}

sub geturlparms {
    # construct cgi parameter portion of url from a hash of parameters
    # (everything after the ?)
    # expects a hashref, returns a string
    my $urlref = shift;
    my $urlstring;
    while (my ($key,$value) = each %{$urlref}) {
	$value = &geturlstring($value);
	$urlstring .= "${key}=${value}&";
    }
    $urlstring =~ s/&$//;
    return $urlstring;
}

1;
