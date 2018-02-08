package graingenes;

use strict;
use warnings;
use DBI;
use CGI qw(-nosticky);
use HTML::Template;
our $html_basepath = '/www/cgi-bin/graingenes/tmpl';
our $html_header = "$html_basepath/browseheader.tmpl";
our $html_footer = "$html_basepath/footer.tmpl";
our $img = "/tmp/gg-test"; # images (points to a temp dir for now)
our $js = "/home/www/htdocs/js"; #javascript dir

sub new {
    my $class = shift;
    $class = ref($class) || $class;
#    my $dbh = DBI->connect("DBI:mysql:graingenes:localhost","guest","wheat") || return undef;
    my $dbh = DBI->connect("DBI:mysql:graingenes_myisam:localhost","guest","^TFC5rdx") || return undef;

#my $dbh = DBI->connect("DBI:mysql:graingenes_maria:localhost","mnemchuk","savelei") || return undef;
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
	IMG => $img, #mln
	JS =>  $js, #mln
        TMPL => $tmpl,
        ERR => []
    };
    bless ($self, $class);
    return $self;
}

# return javasctipt code in a string
sub get_js {
    my $self = shift;
    my $codename = shift;
    my $jsfile=$self->{'JS'}."\/".$codename."\.js";
    print STDERR "MY JS $jsfile \n";
    open(FILE, "<$jsfile");
    undef $/;
    my $jscode=<FILE>;
    return $jscode;
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

# mln
# check if it's a valid image file
sub is_valid_image {
    my $self = shift;
    my $filename = shift;

    #strip of extra
    $filename =~s/.*[\/\\](.*)/$1/;

    #only gif|jpg|png allowed
    #NO EXTRA dot "." in filename!
    my ($foo,$ext)= split(/\./,$filename);
    if ($foo=~/[\(\)\<\>\,\;\:\\\/\"\[\]]/){
	return 0;
    }
    $ext=lc($ext);
    if ($ext eq "jpg" or $ext eq "gif" or $ext eq "png"){
	return $filename;
    }
    
    return 0;
    
 }



# check if file already  exists in the 
# image directory
sub image_exists {
    my $self = shift;
    my $filename = shift;
    my $fullfilename = $self->{'IMG'} ."/".$filename;

    if (-e $fullfilename){ 
	return 0;
    }else{
	return 1;
    }
    return 0;
 }

# mln
# query_table(tablename, id, collist) 
sub query_table {
    my $self = shift;
    my $table = shift;
    my $id = shift;
    my $collist = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};

#    if($self->in_database($table,'name',$$paramref{'name'})){
#	print STDERR "ERRRR";
#	my $errorm="Could not update. An entry named $$paramref{'name'} already exists in the table $table.";
#	push(@{$self->{'ERR'}},$errorm);
#	return;
#    }
    my $select='*';
    $select=join(",",@$collist) if ($collist);
    my $sqlstm =qq(select $select from $table where id=$id);
    print STDERR $sqlstm;
    #lock_tables($self,[$table]);
    my $res = $dbh->selectrow_hashref($sqlstm) || undef;
    #unlock_tables($self, [$table]);
    return $res;

}

# mln
# querylike_table(tablename,colname,pattern,collist) 
sub querylike_table {
    my $self = shift;
    my $table = shift;
    my $colname = shift;
    my $pattern = shift;
    my $collist = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};

    my $select='*';
    $select=join(",",@$collist) if ($collist);
    my $sqlstm =qq(select $select from $table where $colname like '$pattern%');
    print STDERR $sqlstm;
    #lock_tables($self,[$table]);
    my $res = $dbh->selectall_hashref($sqlstm,'id') || undef;
    #unlock_tables($self, [$table]);
    return $res;
}

# mln
# update_table(tablename, id, paramhashref) 
sub update_table {
    my $self = shift;
    my $table = shift;
    my $id = shift;
    my $paramref = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};

    if($self->in_database($table,'name',$$paramref{'name'}) && 
       !$self->idname_check($table,$$paramref{'name'},$id)){
	print STDERR "ERRRR";
	my $errorm="Could not update. An entry named $$paramref{'name'} already exists in the table $table.";
	push(@{$self->{'ERR'}},$errorm);
	return;
    }

    my $sqlstm =qq(update $table  set );
    my @set;
    while (my ($key,$value) = each (%$paramref) ){
        push(@set,qq($key='$value'));
    }
    $sqlstm.=join(",",@set)." where id=$id";
    print STDERR "\n===".$sqlstm."===\n";
    lock_tables($self,[$table]);
    my $ret = $dbh->do($sqlstm) || undef;
    unlock_tables($self, [$table]);
   

}


# mln
# parse cgi  parameters and call update_table for each table, id 
sub update_class {
    my $self = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    my @allparams = $cgi->param;
    my %paramhash=();

    # get parameters separated
    foreach my $p (@allparams){
        my ($tablename,$id,$field) = split(/\./,$p);
        $paramhash{$tablename}{$id}{$field} = $cgi->param($p) if ($tablename ne 'updateall' and $tablename ne 'classid');
    }

    foreach my $tablename (keys %paramhash){
        foreach my $id (keys %{$paramhash{$tablename}}){
            $self->update_table($tablename,$id,$paramhash{$tablename}{$id}) ;
        }
    }

}
# insert_tableid(tablename,id,classname,paramhashref) 
# works for tables with foreign keys classnameid (colleagueid for example)
sub insert_tableid {
    my $self = shift;
    my $table = shift;
    my $id = shift;
    my $classname = shift;
    my $paramref = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    my $sqlstm =qq(insert into $table  set );
    my @set;
    while (my ($key,$value) = each (%$paramref) ){
        push(@set,qq($key='$value'));
    }
    $sqlstm.=join(",",@set).",".$classname."id=".$id ;
    print STDERR $sqlstm;
    lock_tables($self,[$table]);
    my $ret = $dbh->do($sqlstm) || undef;
    unlock_tables($self, [$table]);
   

}

# insert_table(tablename,paramhashref)
# works for any table
sub insert_table{
    my $self = shift;
    my $table = shift;
    my $paramref = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    my $sqlstm =qq(insert into $table  set );
    my @set;
 
   if($self->in_database($table,'name',$$paramref{'name'})){
#       print STDERR "ERRRR";
        my $errorm="Could not insert. An entry named $$paramref{'name'} already exists in the table $table.";
        push(@{$self->{'ERR'}},$errorm);
        return;
    }


    while (my ($key,$value) = each (%$paramref) ){
        push(@set,qq($key='$value'));
    }
    $sqlstm.=join(",",@set);
    print STDERR $sqlstm;
    lock_tables($self,[$table]);
    my $ret = $dbh->do($sqlstm) || undef;
    my ($id) = $dbh->selectrow_array("select last_insert_id()");
    unlock_tables($self, [$table]);
    return $id;
}

# mln
# parse cgi  parameters and call update_table for each table, id 
# works for tables with foreign keys classnameid (colleagueid for example)
sub insert_class {
    my $self = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    my @allparams = $cgi->param;
    my %paramhash=();

    # get parameters separated
    my $id=undef;
    my $classname=undef;
    foreach my $p (@allparams){
        my ($tablename,$field) = split(/\./,$p);
        $paramhash{$tablename}{$field} = $cgi->param($p) if ($tablename ne 'addnew' and $tablename ne 'classid' and $tablename ne 'classname');
	$id=$cgi->param($p) if ($tablename eq 'classid');
	$classname=$cgi->param($p) if ($tablename eq 'classname');
    }

    foreach my $tablename (keys %paramhash){
            $self->insert_tableid($tablename,$id,$classname,$paramhash{$tablename}) ;
    }

}
# mln
sub add_class {
    my $self = shift;
    my $dbh = $self->{'DBI'};
    my $cgi = $self->{'CGI'};
    my @allparams = $cgi->param;
    my %paramhash=();
    #print STDERR "\n\nADD CLASS=====\n";
    # get parameters separated
    my $id=undef;
    my $classname=undef;
    my $link=undef;
   foreach my $p (@allparams){
        my ($tablename,$field) = split(/\./,$p);
	#print STDERR "====$tablename==$field==\n";
        $paramhash{$tablename}{$field} = $cgi->param($p) if ($tablename ne 'addnew' and $tablename ne 'classid' and $tablename ne 'classname' and $tablename ne 'link');
	$id=$cgi->param($p) if ($tablename eq 'classid');
	$link=$cgi->param($p) if ($tablename eq 'link');
	$classname=$cgi->param($p) if ($tablename eq 'classname');
    }

    foreach my $tablename (keys %paramhash){
	#print STDERR "==TABLE==$tablename==";

	if($self->in_database($tablename,'name',$paramhash{$tablename}->{'name'})){
	    my $errorm="An entry named $paramhash{$tablename}->{'name'} already exists in the table $tablename.";
	    push(@{$self->{'ERR'}},$errorm);
	    return;
	}

	my $lastid=$self->insert_table($tablename,$paramhash{$tablename}) ;
	#and link
	my $newparam={$classname.'id'=>$id,
		      $tablename.'id'=>$lastid};
       $self->insert_table($link,$newparam);
	
	
    }

}

# writelock tables
sub lock_tables {
    my $self=shift;
    my $tablesref=shift;
    my $dbh = $self->{'DBI'};
    my $sqlstm="lock tables ".join(" WRITE,",@$tablesref)." WRITE";
    print STDERR $sqlstm;
    return $dbh->do($sqlstm) || undef;


}

sub unlock_tables {
    my $self = shift;
    my $dbh = $self->{'DBI'};
    my $sqlstm = "unlock tables";
    return $dbh->do($sqlstm) || undef;
}

# check if entry if already in the database
# return true/false
sub in_database {
    my $self = shift;
    my $table = shift;
    my $field = shift;
    my $value = shift;
    my $dbh = $self->{'DBI'};
    my $sqlstm =  "select count(*) from ".$table." where ".$field."='".$value."'";
    print STDERR "\nTEST SQLIN: ".$sqlstm."ENDTEST SQLIN\n";
    my ($count) = $dbh->selectrow_array($sqlstm);
    if ($count) { 
	return 1;
    }
    return 0;

}

# check if id and name belong to the same record
# return true/false
sub idname_check {
    my $self = shift;
    my $table = shift;
    my $name = shift;
    my $id = shift;
    my $dbh = $self->{'DBI'};
    my $sqlstm =  "select id from ".$table." where name='".$name."'";
    print STDERR "\nTEST IDNME: ".$sqlstm."ENDTEST SQLIN\n";
    my ($idret) = $dbh->selectrow_array($sqlstm);
    if ($idret==$id) { 
	return 1;
    }
    return 0;
}


# get table info
#  return ref to array of column names
sub table_info {
    my $self = shift;
    my $table = shift;
    my $dbh = $self->{'DBI'};
    my $sqlstm="select * from $table limit 1";
    my $qh = $dbh->prepare($sqlstm);
    $qh->execute() or  push( @{$self->{'ERR'}},$dbh->errstr);
    my @columns=@{$qh->{NAME}};
    return \@columns;
}


1;
