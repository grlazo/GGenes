package graingenes;

use strict;
use warnings;
use DBI;
use CGI qw(-nosticky);
use HTML::Template;

our $html_basepath = '/home/www/htdocs/GG2/templates';
our $html_header = "$html_basepath/header.tmpl";
our $html_footer = "$html_basepath/footer.tmpl";

sub new {
    my $class = shift;
    $class = ref($class) || $class;
    my $dbh = DBI->connect("DBI:mysql:graingenes_staging:localhost","mysql","wheat2001") || return undef;
    my $cgi = new CGI || return undef;
    my $tmplfile = $0; $tmplfile =~ s/^.*\///; $tmplfile =~ s/\.cgi$/\.tmpl/;
    my $tmpl = undef;
    if (-r "tmpl/$tmplfile") {
        $tmpl = HTML::Template->new(filename=>"tmpl/$tmplfile",
                                    associate=>$cgi,
                                    global_vars=>0,
                                    die_on_bad_params=>0,
                                    cache=>1
                                    ) || return undef;
    }
    my $self = {
        CGI => $cgi,
        DBI => $dbh,
        TMPL => $tmpl,
        ERR => []
    };
    bless ($self, $class);
    return $self;
}

sub get_html_header {
    shift;
    return $html_header;
}

sub get_html_footer {
    shift;
    return $html_footer;
}

sub get_sources {
    my $self = shift;
    my $dbh = $self->{'DBI'};
    return $dbh->selectall_arrayref(qq{
        select id,name from source order by name
    },{'Slice'=>{}});
}

sub get_images {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    return $dbh->selectall_arrayref(qq{
        select id,name from image order by name
    },{'Slice'=>{}});
}

sub get_self_url {
    # get a CGI::self_url() with optionally changed params
    my $self = shift;
    my $cgi = $self->{'CGI'};
    my $params = shift;
    my $tempcgi = new CGI($cgi);
    foreach my $prm (keys(%$params)) {
        if ($params->{$prm}) {
            $tempcgi->param(-name=>$prm,-value=>[($params->{$prm})]);
        } else {
            $tempcgi->delete($prm);
        }
    }
    return $tempcgi->self_url;
}

sub print_include {
    # print an include file
    my $self = shift;
    my $file = shift;
    open(FILE,$file) or return undef;
    print while (<FILE>);
    close(FILE);
    return 1;
}

1;
