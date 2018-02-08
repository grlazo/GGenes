<?php
include ('/data/inc/GG3.inc');
if ($_SERVER['REQUEST_METHOD'] == 'POST'){
  process_form($_POST);
 } else { print_form();}

function print_form() {
global $classes;
/* 
print <<<HEAD
<html><head>
<style>
input.submit { border: 1px solid black; font: small sans-serif;}
</style>
<script src='https://www.google.com/recaptcha/api.js'></script>
<title>Correction form for GrainGenes</title>
</head><body bgcolor="white">
HEAD;
*/
readfile("/data/htdocs/GG3.old/h.tmpl");
print "<div style=\"margin-left:20px;margin-top:20px;\">";
    if (isset($_POST['error'])){
      print "<table><tr><td>";
      foreach (required_field_check() as $error){echo $error;}
      print "</td></tr></table>";
}

// Get link of page where this form was invoked
if($_SERVER['HTTP_REFERER'] != ""){
    $ref = $_SERVER['HTTP_REFERER'];
}else {$ref = "NA";}

// IP of user in case we need to block abusive addy
if($_SERVER['REMOTE_ADDR'] != ""){
    $ip = $_SERVER['REMOTE_ADDR'];
} else {$ip = "NA";}

print "<form action=" .$_SERVER['PHP_SELF'] . " method=\"post\">";

// Get vars from URL if present
// Add logic to get from hidden if not present

//if(isset($_GET['class'])){$class = $_GET['class'];$_POST['class']=$_GET['class'];}
if(isset($_GET['class'])){
    if(!array_key_exists($_GET['class'], $classes)){
        //header('Location: https://wheat.pw.usda.gov');
        die;
    }
    $class = $_GET['class'];$_POST['class']=$_GET['class'];
}
if(isset($_GET['name'])){$name = $_GET['name'];$_POST['name']=$_GET['name'];}
//if(isset($_GET['print'])){$print = $_GET['print'];$_POST['print']=$_GET['print'];}
if(isset($_GET['show'])){
    $show = $_GET['show'];
    $_POST['show']=$_GET['show'];
} else {$show = '';}
if(isset($_POST['class'])){$class = $_POST['class'];}
if(isset($_POST['name'])){$name = $_POST['name'];}
if(isset($_POST['show'])){$show = $_POST['show'];}
$name = preg_replace("/\s/", "+",$name);

print "<strong>Database:</strong> GrainGenes";
print "<br><strong>Class:</strong> " . @$_POST['class'];	
print "<br><strong>Name:</strong> " . @$_POST['name'];

print '<p><br><input name="sender" size="20" maxlength="32" value="';
if (isset($_POST['sender'])){
   print $_POST['sender'];
}
print '"> <strong>Name and affiliation</strong><br>';
print '<br><input name="email" size="20" maxlength="32" value="';
if (isset($_POST['email'])){
   print $_POST['email'];
}
print '"> <strong>Email Address (required)</strong><br>';

# MESSAGE
	print "</p><p>Please edit the entry directly and add any comments to the Comments box.  
       <br>If you can supply a reference, we can reconcile your information with the original data source.
       <br> Additional information on the fields available in this data class can be found at the bottom of this page.
       <br>";

print "\n";

# TEXTAREA with mySQL dump
# need double quotes around name for names with parentheses to prevent shell syntax errmsg
$args = "class=$class&name=$name&print=%27%27&show=$show";
//$args = "class=$class&name=".$_POST['name']."&print=%27%27&show=$show";
//$string = `/cgi-bin/GG3/report.cgi $args`;
$url = "https://wheat.pw.usda.gov/cgi-bin/GG3/report.cgi?".$args;

// Clean up the sql dump to make it human readable
#$string = file_get_contents("https://feline.pw.usda.gov/cgi-bin/GG3/report.cgi?class=author;query=;name=Aakerman+A&print=''&show=all");
$string = file_get_contents($url);
$string = preg_replace("/<option value.*<\/option>/", "", $string); // remove drop down class list
$string = preg_replace("/@import .*/", "",$string);
$string = preg_replace('/#39;/',"'",$string); // change &#39; to single quotes, needed for loci like 'Sr21'
$string = preg_replace('/&gt;/',">",$string); // change html chars to symbols (e.g., (1->3)-beta-glucan 3-glucanohydrolase )
$string = preg_replace('/&nbsp;/',"'",$string);
$string = preg_replace('/&amp;/',"&",$string); // change html chars to symbols (e.g., 'Johanson & Ladizinsky 1973')
//$string = preg_replace('/&/',"'",$string);
$string = preg_replace("/''/","'",$string);
$string = preg_replace("/<tr\>/","&#13;",$string); // add carriage return in between report elements
$string = strip_tags($string); //strip the rest of the html tags
$string = preg_replace("/'GrainGenes .* Report: '.*'/","",$string); // Get rid of duplicate title
$string = preg_replace("/(^[\r\n]*|[\r\n]+)[\s\t]*[\r\n]+/", "\n", $string); // remove large chunk of empty lines

print '<textarea rows="40" cols="85" name="corrected">';

if (isset($_POST['corrected'])){
   print $_POST['corrected'];
} else {echo $string;}
print '</textarea>';
//echo "<br>$url<br>$name";
//print "<br>".$_POST['ip']. "<br>".
print "<p><strong>Comments</strong><br>\n";
print '<textarea rows="20" cols="85" name="comments">';
if(isset($_POST["comments"])){print $_POST["comments"];}
print '</textarea>';

// edited sqldump to compare to the textarea entry from user
print '<input type="hidden" name="rawsql" value="'.$string.'">';
print '<input type="hidden" name="ip" value="'.$ip.'">';
print '<input type="hidden" name="ref" value="'.$ref.'">';
print '<input type="hidden" name="class" value="'.$class.'">';
print '<input type="hidden" name="name" value="'.$name.'">';
print '<input type="hidden" name="show" value="'.$show.'">';
print '<input type="hidden" name="server" value="'.$_SERVER['SERVER_ADDR'].'">';

print <<<FORM
<div class="g-recaptcha" data-sitekey="6LdypAoTAAAAABvSIV6rpJLAZbYAxfCiO7SvVQHC"></div>
<p><input type="submit" name="submit" value="Send corrections to GrainGenes curators">
</form>
</p><p></p><hr>
</div>
</body>
</html>
FORM;

}

function process_form(){
    global $secret;
    required_field_check($_POST);
    if(isset($_POST['g-recaptcha-response']))
        $captcha=$_POST['g-recaptcha-response'];

    if(!$captcha){
        echo '<h2>Please use your browser\'s back button and check the captcha form near the bottom of the page.</h2>';
        exit;
    }
    $google = "https://www.google.com/recaptcha/api/siteverify?secret=".$secret."&response=".$captcha."&remoteip=".$_SERVER['REMOTE_ADDR'];
    $response=json_decode(file_get_contents($google), true);
    //if($response.'success' == false)
   // {
     //   array_push ($error_msg, '<li>You have not passed the human test. Please try again.</li>');
    //    $_POST['error'] = "y";
   // }
if (isset($_POST['error'])){ print_form();}
	if (!isset($_POST['error'])){ 
		send_curator_email($_POST);
        thank_you();
        //header("Location: https://feline.pw.usda.gov/");
		}
}
########################
function send_curator_email(){
	$from = "From: ".$_POST['email']."r\n";
	$subject = "***GrainGenes (mySQL) correction ALERT***";
    
    $body =  "Remote machine: ".$_POST['ip']."\n";
	$body .=  "Server Source: ".$_POST['server']."\n";
    $body .=  "Reference page: ".$_POST['ref']."\n";
    $body .=  "Sender: ".$_POST['sender']."\n";
    $body .=  "Sender E-mail: ".$_POST['email']."\n\n";
    $body .=  "CORRECTED RECORD:\n".$_POST['corrected']."\n\n";
    $body .=  "COMMENTS:\n".$_POST['comments']."\n\n";
    $body .=  "ORIGINAL RECORD:\n".$_POST['rawsql']."\n\n";

	mail("curator\@graingenes.org", $subject, $body, $from);
	//mail("davidhane\@gmail.com", $subject, $body, $from);

}

function required_field_check(){
  global $error_msg;
  $req_fields = array('email');
  $error_msg = array('');
  
  foreach ($req_fields as $k){
    if (!$_POST[$k]){
      array_push ($error_msg, 'The ' . $k . ' field  is empty<br>');
    }
}

if (!preg_match("/^[^@\s]+@([-a-z0-9]+\.)+[a-z]{2,}$/i", $_POST['email'])){
      array_push ($error_msg, 'The email address you entered is not in a valid format.<br>');
    }

if (count($error_msg) > 1){$_POST['error'] ='1';
    array_unshift ($error_msg,'<font color="red">There was an error with your subscription. Please correct these errors:<br>');
    array_push ($error_msg, '</font><br>');
  }

  return $error_msg;
}

function thank_you(){
readfile("/data/htdocs/GG3.old/h.tmpl");
print <<<THANKS
<p>
<h3>
Thank you for submitting your corrections to GrainGenes!<br>
</h3>
Please click <INPUT type="button" value="HERE" ONCLICK="window.parent.location='https://wheat.pw.usda.gov/GG3'"> to return to the GrainGenes home page or use the menu above.
THANKS;
}
die;
?>
