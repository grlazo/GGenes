#!/usr/bin/perl
###########################################################################
### comment - allows user to add comments to a database via markup rule ###
###########################################################################
# Modified so this script may be used for different DBs.
# Curators can put their e-mails and names into wspec/markup.pl.
# See http://genome.cornell.edu/webace/webaceREADME.html about it. MLN 10/98
#
#NL Above pertains to WebAce version:  /home/www/cgi-bin/WebAce/comment
# comment.cgi NL 18Oct2004 modified for 'Submit comment' link on GrainGenes-mySQL reports
# dem 26jul07: Fixed the test for valid email addresses to allow hyphens.
# dem 28jul07: Temporarily sending results only to me, not curator.
# dem 29jul07: Added Captcha.
die;

# use & require
use Authen::Captcha;
use CGI qw(:standard :cgi-lib);
use strict;	
use warnings;
require 'global.pl';			# for $cgiurlpath, $cgisyspath, $classes

$|=1;					# ensure buffer is immediately flushed after 'print'

### Start captcha setup.
our $md5sum;
our $captcha;
my $output_dir = "/www/htdocs/GG2/captcha";
my $www_output_dir = "/GG2/captcha";
my $db_dir = "/www/captcha";
my $num_of_characters = 5;
# PAGE_LOAD
$captcha = Authen::Captcha->new(
                      output_folder     => $output_dir,
                      data_folder       => $db_dir
                     );
$md5sum = $captcha->generate_code($num_of_characters);
### End captcha setup.


our ($cgisyspath,$cgiurlpath,$classes);	
use constant BGCOLOR =>'#FFFFFF';  #NL 18Oct2004: white page color
use constant TEXT => '#000000';    # text color

print header;

my $class = param('class');
my $name = param('name');
my $print = param('print');		# pass null value so that there's less sqldump to parse
my $show = param('show');		# so that sqldump shows all values (no 'Hide...' links)

param('remote',remote_host());		# assigns a value to 'remote' parameter 20Oct: being captured correctly
param('dbtitle','GrainGenes');		# hardcode the title


# Test whether all fields have already been filled properly.
if ( defined(param('sender')) && 		# Name entered
     param('sender') !~ m/^\s*$/ &&		#  that's not a space.
     defined(param('sender email')) && 		# Email entered
     param('sender email') !~ m/^\s*$/ &&	#  that's not a space.
     param('sender email') =~ m/^[\w\.-]+\@[-A-Za-z0-9]+(\.[\w\-]+)*\.[A-Za-z0-9]+$/ &&  # Email address looks valid.
     $captcha->check_code(param('code'),param('md5sum')) == 1 )  # The captcha checks out.
 {&mailitoff;}
else   # This is either the first entry to the page or there was an error.
 {&opening;}
print endform;
print end_html;
exit;

##### SUBROUTINES ############
sub opening {
    print start_html(-title=>'Correction form for ' . param('dbtitle'),
			     -text=>TEXT,
			     -link=>'#0000ff', 
			     -vlink=>'#551a8b',
			     -alink=>'#ff0000',
			     -bgcolor=>BGCOLOR)."\n";
    # The second parameter seems to be being ignored.
    #print startform(-method => 'POST',"$cgiurlpath/comment.cgi");
    print startform(-method => 'POST',"$cgiurlpath/dummyxxx.cgi");

    # captcha:
    print "<img src=$www_output_dir/$md5sum.png> ";
    print textfield(-name=>'code', -size => 10)." Please type the image text. <font size=-1>(To avert the automated abusers.)</font><br>";
    print "<input type=\"hidden\" name=\"md5sum\" value=\"$md5sum\">";

    print "<strong>Database:</strong> " . param('dbtitle');
    print "<br><strong>Class:</strong> " . $classes->{param('class')};	# or $classes->{$class}
    print "<br><strong>Object Name:</strong> " . param('name');

    	print hidden('remote',param('remote'));			# 'hidden' needed to retain value following refresh
    	print hidden('print',param('print'));			# 'hidden' needed to retain value following refresh
    	print hidden('show',param('show'));			# 'hidden' needed to retain value following refresh
    	print hidden('sendto',param('sendto'));			# REQUIRED for email to be sent  
   	print hidden('dbtitle',param('dbtitle')),"\n";		# 'hidden' needed to retain value following refresh
   	print hidden('class',param('class')),"\n";		# 'hidden' needed to retain value; else 'class' report not found
    	print hidden('name',param('name')),"\n";		# 'hidden' needed to retain value; else report for 'name' not found

    # CAPTCHA
    # CHECK_CODE
    if ( defined(param('code')) ){
        if ($captcha->check_code(param('code'), param('md5sum')) != 1){
	    # If the check fails, print the values.  Note that "Last md5sum" never changes subsequently.
            my $code = param('code');
            my $md5 = param('md5sum');
            print "<br><font color=red> Too fuzzy? Please try again.</font>\n";
            #print "<br><font color=red> Last md5sum = $md5  <br>Next md5sum should be $md5sum</font>\n";
	}
    }

    # SENDER
    if ( defined(param('sender')) ) 			# something was entered
    {
      if ( param('sender') !~ m/^\s*$/ )		# something other than spaces entered
      {
        print hidden('sender',param('sender')),"\n";	# 'hidden' needed to retain value following refresh
      }
      else						# only spaces were entered
      {
        print "<br>", textfield(-name=>'sender', -size => 50)." <strong>Name and affiliation</strong>\n";
      }      
    }
    else						# ( !defined(param('sender'))  -- no name entered) 
    { 
      print "<br>", textfield(-name=>'sender', -size => 50)." <strong>Name and affiliation</strong>\n";
    }

    # EMAIL    
    if ( defined(param('sender email')) && param('sender email') =~ m/^[\w\.-]+\@[-A-Za-z0-9]+(\.[-\w]+)*\.[A-Za-z0-9]+$/ ) 
    {
      print hidden('sender email',param('sender email')),"\n";	# if valid email address -> save value
    }
    else						# invalid email address 						
    {	
      if ( defined(param('sender email')) )		# something was entered, whether spaces or invalid chars
      { 
        print "<br><font color=red>E-mail address is <strong>invalid</strong> - please enter e-mail address again.</font>\n";
      }
      # whether initial load or error, print email textbox
      print "<br>",textfield(-name=>'sender email', -size => 50)," <strong>E-mail address</strong> (required)\n";
    }

    if (param('edited')) {
      print hidden('edited',param('edited')),"\n";	# 'hidden' needed to retain value following refresh
      print hidden('saved sqldump') if (param('saved sqldump'));	# 'hidden' needed to retain value following refresh
    }
    elsif (!param('edited')) {				# if nothing yet in sqldump textarea

	# MESSAGE
	print "<p>Please edit the entry directly and add any comments to the Comments box.  
       <br>If you can supply a reference, we can reconcile your information with the original data source.
       <br> Additional information on the fields available in this data class can be found at the bottom of this page.
       <br>";

	print "\n";

	# TEXTAREA with mySQL dump
	# need double quotes around name for names with parentheses to prevent shell syntax errmsg
	my $args = 'class=$class name="$name" print=$print show=$show';
	my $string = `$cgisyspath/report.cgi $args`;

	# Earlier, header/footer/toolbars were appearing because 'print' param not being passed in from report.cgi
	#  Keep the following for reference:
	#$string =~ s#\<style.*\/style\>##gsi;	# get rid of style specs
	#$string =~ s#\<tbody\>.*\/tbody\>##gsi;	# get rid of tool bars
	#$string =~ s#\<small\>.*\<\/small\>##gsi;	#get rid of footer text "GrainGenes is a product of..."
	#$string =~ s#\[ \<[^\<\>]+\>Printable Version\<[^\<\>]+\> \]##gi;	# get rid of 'Printable Version' link
	#$string =~ s#\[ \<[^\<\>]+\>Submit comment/correction\<[^\<\>]+\> \]##gi;	# get rid of 'Submit comment' link

	# if 'print=' param works properly, only the following are needed:
	$string =~ s#^Content-Type:.*##; # get rid of first line
	$string =~ s/<option value.*option>//g;
	$string =~ s/Query.*name="class">//gi;
	$string =~ s#[\r\n]+##g;			# get rid of \r, \n (for tags spread over mult lines)
	$string =~ s#\<title\>[^\<\>]+\<\/title\>##gi;	# get rid of title (repetitive)
	$string =~ s#\<tr\>#\n#gi;			# add rows between report elements
	$string =~ s#\<td[^\<\>]+\>#  #gi;		# add indent in front of each value
	$string =~ s#\<[^\<\>]*\>##g;			# get rid of html tags
	$string =~ s#\&nbsp\;# #g;			# get rid of &nbsp;
	$string =~ s#( +\n )+#\n #gi;			# get rid of extra newlines
	$string =~ s/\&\#39\;/\'/g;			# change &#39; to single quotes, needed for loci like 'Sr21'
	$string =~ s/\&gt\;/\>/g;			# change html chars to symbols (e.g., (1->3)-beta-glucan 3-glucanohydrolase )
	$string =~ s/\&amp\;/\&/g;			# change html chars to symbols (e.g., 'Johanson & Ladizinsky 1973')
	my $fulloutput = $string;
	
    	param('saved sqldump',$fulloutput);
	print hidden('saved sqldump',param('saved sqldump'));	# REQUIRED for original record to display
	print textarea(-name=>'edited', -rows=>20, -columns=>85, -default=>$fulloutput),"\n";
    }

    if (param('references')) {
	print hidden('references',param('references')),"\n";	# 'hidden' needed to retain value following refresh
    }
    elsif (!param('references')) {
	print "<p><strong>Comments</strong><br>\n";
	print textarea(-name=>'references', -rows=>8, -columns=>85),"\n";
    }

    print p();
    print submit('correction', 'Send corrections to ' . param('dbtitle') . ' curators'),"\n";
    print "<br>Thanks very much for your feedback!\n";
    print "<br> - The " . param('dbtitle') . " curators.\n";
    print "<hr>";

    # FIELDS for data class:
    # grab labels from report_<class>.pl to get fields available:
    # (\11 is tab: tr -s '\11' ' ' changes multiple tabs into single space)
    my @tags =  `cat $cgisyspath/report_$class.pl | egrep "'[A-Za-z0-9]*[A-Z0-9].*'," | grep -v '#' | tr -s '\11' ' ' | sed "s/[',]//g" | sort -uf`;

    print "Fields for \"",$classes->{$class}, "\" class:<p>";
    foreach my $tag (@tags)
    {
      print "$tag", "<br>";
    }
} # end sub opening

sub mailitoff {
    print start_html(-title=>'Correction form for ' . param('dbtitle'),
		     -text=>TEXT,
		     -link=>'#0000ff', 
		     -vlink=>'#551a8b',
		     -alink=>'#ff0000',
		     -bgcolor=>BGCOLOR)."\n";

    my $old_url="$cgiurlpath\/report.cgi?class=$class&name=$name";

    print " <meta http-equiv=\"Refresh\" content=\"100; url=$old_url\">";

    print startform(-method => 'POST',"$cgiurlpath/comment.cgi");
    my $sendmail = "/usr/lib/sendmail";
    # DLH - Feb 28, 2006 - fixes potential abuse by removing editable param for email address
    my $send_to = 'curator@graingenes.org'; 
    #my $send_to = 'matthews@greengenes.cit.cornell.edu'; 
    #my $send_to = param('sendto');
    my $send_from = param('sender email');

    my $myedited = param('edited');
    $myedited =~ s/\r//g; #gets rid of \r which DOS machines combine with \n to make a ^M, which causes problems

    my $mysqldump = param('saved sqldump');
    # this double-spaces the original record: $mysqldump  =~ s/\r/\n/g; #gets rid of \r which DOS machines combine with \n to make a ^M, which causes problems
    $mysqldump =~ s/\r//g; #gets rid of \r which DOS machines combine with \n to make a ^M, which causes problems

    # get the difference between the original record and the edited version:
    my $change = '';

    # test string for match
    my $mysqldump_test = $mysqldump;
    $mysqldump_test =~ s/[\|\(\)\[\]\{\}\\\^\$\?\*\+]//g;   # get rid of spcl chars that would botch regex match

    my $line_test;
    foreach my $line ( split '\n', $myedited )
    {
      $line_test = $line;
      $line_test =~ s/[\|\(\)\[\]\{\}\\\^\$\?\*\+]//g;	# get rid of spcl chars that would botch regex match
      if ( $mysqldump_test !~ /$line_test/ )
      {
        $change .= "$line\n";
      }
    }
    
    my $myreferences = param('references');
    $myreferences =~ s/\r//g; #gets rid of \r which DOS machines combine with \n to make a ^M, which causes problems
    open(MAILIT, "| $sendmail \"$send_to\"");
    print MAILIT <<ENDOFHEADERINFO;
From: $send_from
To: $send_to
Subject: ***GrainGenes (mySQL) correction ALERT*** 
  
ENDOFHEADERINFO
    print "Your corrections/comments have been mailed to the ", param('dbtitle'), " curators.",p(),
    "Click ", a({-href=>$old_url}, b("here")),  " to get back to the original report.";

    print MAILIT 
                   "Remote machine: ",param('remote'),"\n",
                   "Sender: ",param('sender'), "\n",
	           "Sender E-mail: ",param('sender email'), "\n\n",
                   "CORRECTED RECORD:\n",$myedited, "\n\n",
		   "CHANGE:\n",$change, "\n",
                   "ORIGINAL RECORD:\n", $mysqldump,"\n\n";

       print p(),
           b("Sender: "),param('sender'),br(),
           b("Sender E-mail: "),param('sender email'),p(),
           b("CORRECTED RECORD:"),br(),pre($myedited),p(),
           b("CHANGE:"),br(),pre($change),p(),
           b("ORIGINAL RECORD:"),br(),pre($mysqldump),p();

    if (param('references')) {
	print b("COMMENTS/REFERENCES:"),br,pre($myreferences);
	print   MAILIT "COMMENTS/REFERENCES:\n\n",$myreferences, "\n";
    }
    close MAILIT;
} # end mailitoff
