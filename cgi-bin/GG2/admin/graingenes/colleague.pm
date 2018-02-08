package graingenes::colleague;

use strict;
use warnings;

use base ("graingenes");
#our @ISA = ("graingenes");

sub new {
    my $class = shift;
    $class = ref($class) || $class;
    my $self = $class->SUPER::new || return undef;
    #$self->{'COLLEAGUE'} = undef;
    bless ($self, $class);
    return $self;
}

sub get_id {
    my $self = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    my $id = shift || $cgi->param('id');
    if (!defined($id) || $id eq '' || $id =~ /^\s+$/ || $id == 0) {
	$cgi->delete('id');
        return undef;
    }
    if ($id =~ /^\d+$/) {
	my ($validid) = $dbh->selectrow_array(qq{
	    select id from colleague where id = $id
	});
	if ($validid) {
	    return $id;
	}
    }
    $cgi->delete('id');
    return undef;
}

sub get_colleague {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    my $colleague = $dbh->selectrow_hashref(qq{
        select * from colleague where id = $id
    });
    $colleague->{'address'} = $dbh->selectall_arrayref(qq{
        select * from colleagueaddress where colleagueid = $id
    },{'Slice'=>{}});
    $colleague->{'email'} = $dbh->selectall_arrayref(qq{
        select * from colleagueemail where colleagueid = $id
    },{'Slice'=>{}});
    $colleague->{'image'} = $dbh->selectall_arrayref(qq{
        select
	    colleagueimage.*,
	    image.name as imagename
	from colleagueimage
	inner join image on colleagueimage.imageid = image.id
	where colleagueimage.colleagueid = $id
    },{'Slice'=>{}});
    $colleague->{'obtainedfrom'} = $dbh->selectall_arrayref(qq{
        select
	    colleagueobtainedfrom.*,
	    source.name as sourcename
	from colleagueobtainedfrom
	inner join source on colleagueobtainedfrom.sourceid = source.id
	where colleagueobtainedfrom.colleagueid = $id
    },{'Slice'=>{}});
    $colleague->{'remark'} = $dbh->selectall_arrayref(qq{
        select * from colleagueremark where colleagueid = $id
    },{'Slice'=>{}});
    return $colleague;
}

sub get_colleaguename {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    my ($name) = $dbh->selectrow_array(qq{
	select name from colleague where id = $id
    });
    return $name;
}

sub insert_colleague {
    my $self = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    $dbh->do(qq{
	insert colleague set
	    name = ?,
	    lastupdate = ?
    },
    undef,
    $cgi->param('name') || undef,
    $cgi->param('lastupdate') || undef
    ) || return undef;
    my ($id) = $dbh->selectrow_array("select last_insert_id()");
    return $id;
}

sub update_colleague {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    return $dbh->do(qq{
	update colleague set
	    name = ?,
	    lastupdate = ?
	where id = ?
    },
    undef,
    $cgi->param('name') || undef,
    $cgi->param('lastupdate') || undef,
    $id
    ) || undef;
}

sub delete_colleague {
    # need to null out foreign keys
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    eval {
	$dbh->do(qq{delete from colleague where id = $id}) || die;
	$dbh->do(qq{delete from colleagueaddress where colleagueid = $id}) || die;
	$dbh->do(qq{delete from colleagueemail where colleagueid = $id}) || die;
	$dbh->do(qq{delete from colleagueimage where colleagueid = $id}) || die;
	$dbh->do(qq{delete from colleagueobtainedfrom where colleagueid = $id}) || die;
	$dbh->do(qq{delete from colleagueremark where colleagueid = $id}) || die;
    };
    if ($@) {
	return undef;
    } else {
	return $id;
    }
}

sub get_colleagueaddress {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    return $dbh->selectrow_hashref(qq{
        select
	    colleagueaddress.*,
	    colleague.name as colleaguename
	    from colleagueaddress
	    inner join colleague on colleagueaddress.colleagueid = colleague.id
	where colleagueaddress.id = $id
    }) || undef;
}

sub insert_colleagueaddress {
    my $self = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    $dbh->do(qq{
	insert colleagueaddress set
	    colleagueid = ?,
	    mail = ?,
	    country = ?,
	    phone = ?,
	    fax = ?,
	    telex = ?
    },
    undef,
    $cgi->param('colleagueid') || undef,
    $cgi->param('mail') || undef,
    $cgi->param('country') || undef,
    $cgi->param('phone') || undef,
    $cgi->param('fax') || undef,
    $cgi->param('telex') || undef
    ) || return undef;
    my ($id) = $dbh->selectrow_array("select last_insert_id()");
    return $id;
}

sub update_colleagueaddress {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    return $dbh->do(qq{
	update colleagueaddress set
	    mail = ?,
	    country = ?,
	    phone = ?,
	    fax = ?,
	    telex = ?
	where id = ?
    },
    undef,
    $cgi->param('mail') || undef,
    $cgi->param('country') || undef,
    $cgi->param('phone') || undef,
    $cgi->param('fax') || undef,
    $cgi->param('telex') || undef,
    $id
    ) || undef;
}

sub delete_colleagueaddress {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    return $dbh->do(qq{delete from colleagueaddress where id = $id}) || undef;
}

sub get_colleagueemail {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    return $dbh->selectrow_hashref(qq{
        select
	    colleagueemail.*,
	    colleague.name as colleaguename
	    from colleagueemail
	    inner join colleague on colleagueemail.colleagueid = colleague.id
	where colleagueemail.id = $id
    }) || undef;
}

sub insert_colleagueemail {
    my $self = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    $dbh->do(qq{
	insert colleagueemail set
	    colleagueid = ?,
	    email = ?
    },
    undef,
    $cgi->param('colleagueid') || undef,
    $cgi->param('email') || undef
    ) || return undef;
    my ($id) = $dbh->selectrow_array("select last_insert_id()");
    return $id;
}

sub update_colleagueemail {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    return $dbh->do(qq{
	update colleagueemail set
	    email = ?
	where id = ?
    },
    undef,
    $cgi->param('email') || undef,
    $id
    ) || undef;
}

sub delete_colleagueemail {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    return $dbh->do(qq{delete from colleagueemail where id = $id}) || undef;
}


sub get_colleagueimage {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    return $dbh->selectrow_hashref(qq{
        select
	    colleagueimage.*,
	    colleague.name as colleaguename
	    from colleagueimage
	    inner join colleague on colleagueimage.colleagueid = colleague.id
	where colleagueimage.id = $id
    }) || undef;
}

sub insert_colleagueimage {
    my $self = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    $dbh->do(qq{
	insert colleagueimage set
	    colleagueid = ?,
	    imageid = ?
    },
    undef,
    $cgi->param('colleagueid') || undef,
    $cgi->param('imageid') || undef
    ) || return undef;
    my ($id) = $dbh->selectrow_array("select last_insert_id()");
    return $id;
}

sub update_colleagueimage {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    return $dbh->do(qq{
	update colleagueimage set
	    imageid = ?
	where id = ?
    },
    undef,
    $cgi->param('imageid') || undef,
    $id
    ) || undef;
}

sub delete_colleagueimage {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    return $dbh->do(qq{delete from colleagueimage where id = $id}) || undef;
}

sub get_colleagueobtainedfrom {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    return $dbh->selectrow_hashref(qq{
        select
	    colleagueobtainedfrom.*,
	    colleague.name as colleaguename
	    from colleagueobtainedfrom
	    inner join colleague on colleagueobtainedfrom.colleagueid = colleague.id
	where colleagueobtainedfrom.id = $id
    }) || undef;
}

sub insert_colleagueobtainedfrom {
    my $self = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    $dbh->do(qq{
        insert colleagueobtainedfrom set
            colleagueid = ?,
            sourceid = ?,
            date = ?
    },
    undef,
    $cgi->param('colleagueid') || undef,
    $cgi->param('sourceid') || undef,
    $cgi->param('date') || undef
    ) || return undef;
    my ($id) = $dbh->selectrow_array("select last_insert_id()");
    return $id;
}

sub update_colleagueobtainedfrom {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    return $dbh->do(qq{
        update colleagueobtainedfrom set
            sourceid = ?,
            date = ?
        where id = ?
    },
    undef,
    $cgi->param('sourceid') || undef,
    $cgi->param('date') || undef,
    $id
    ) || undef;
}

sub delete_colleagueobtainedfrom {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    return $dbh->do(qq{delete from colleagueobtainedfrom where id = $id}) || undef;
}

sub get_colleagueremark {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    return $dbh->selectrow_hashref(qq{
        select
	    colleagueremark.*,
	    colleague.name as colleaguename
	    from colleagueremark
	    inner join colleague on colleagueremark.colleagueid = colleague.id
	where colleagueremark.id = $id
    }) || undef;
}

sub insert_colleagueremark {
    my $self = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    $dbh->do(qq{
	insert colleagueremark set
	    colleagueid = ?,
	    type = ?,
	    remark = ?
    },
    undef,
    $cgi->param('colleagueid') || undef,
    $cgi->param('type') || undef,
    $cgi->param('remark') || undef
    ) || return undef;
    my ($id) = $dbh->selectrow_array("select last_insert_id()");
    return $id;
}

sub update_colleagueremark {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    return $dbh->do(qq{
	update colleagueremark set
	    type = ?,
	    remark = ?
	where id = ?
    },
    undef,
    $cgi->param('type') || undef,
    $cgi->param('remark') || undef,
    $id
    ) || undef;
}

sub delete_colleagueremark {
    my $self = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    return $dbh->do(qq{delete from colleagueremark where id = $id}) || undef;
}

1;
