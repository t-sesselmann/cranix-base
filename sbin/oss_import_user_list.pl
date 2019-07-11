#!/usr/bin/perl -w
# Copyright (c) 2018 Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.
# Copyright (c) 2001 SuSE GmbH Nuernberg, Germany.  All rights reserved.
#
#

use strict;
use JSON::XS;
use Data::Dumper;
use Getopt::Long;
use Encode qw(encode decode);
binmode STDIN, ":encoding(UTF-8)";
binmode STDOUT, ":encoding(UTF-8)";
binmode STDERR, ":encoding(UTF-8)";
use utf8;

# Global variable
my $config       = "/etc/sysconfig/schoolserver";
my $cprefix      = "SCHOOL_";
my $globals      = {};
my $mailserver   = 'mailserver';
my %options      = ();
my $result       = "";
my $role         = "students";
my $full         = 0;
my $lang         = 'DE';
my $input        = '/tmp/userlist.txt';
my $domain       = `hostname -d`; chomp $domain;
my $LOGDIR       = "/var/log/";
my $PIDFILE      = "/run/oss_import_user.pid";
my $RUNFILE      = "/run/oss_import_user";
my $DEBUG        = 0;
my $mailenabled  = 0;
my $password     = "";
my $mustchange   = 0;
my $alias        = 0;
my $test         = 0;
my $resetPassword= 0;
my $message      = {};
my @attr_ext      = ();
my $cleanClassDirs= 0;
my $allClasses    = 0;
my $identifier    = 'sn-gn-bd';
my $output       = "";
my $date         = `date +%Y-%m-%d.%H-%M-%S`; chop $date;
my $attr_ext_name = {};
my $CHECK_PASSWORD_QUALITY = `oss_api_text.sh GET system/configuration/CHECK_PASSWORD_QUALITY`;
my $USERCOUNT    = 0;
my $SLEEP        = 2;
#############################################################################
## Subroutines
#############################################################################

sub usage
{

	print "\n";
        print "import_user_list.pl [<options>]\n";
        print "Options:\n";
        print "  --help         Print this help message\n";
        print "  --input        The import file.\n";
        print "                 Default: /tmp/userlist.txt \n";
        print "  --role         Role of the users to import: students|teachers|administration\n";
        print "                 Default: students \n";
        print "  --full         List is a full list. User which are not in the list will be removed.\n";
        print "                 Default: no \n";
        print "                        This parameter has only affect when role=students\n";
        print "  --debug        Run in debug mode, no daemonize\n";
        print "  --domain       The domain of the school\n";
        print "                 Default: the output of `hostname -d` \n";
        print "  --mailenabled  Default value for mailenabled\n";
        print "  --password     Default value for password\n";
        print "                 Default: each new user gets its own random password\n";
        print "  --alias        If set, the new users gets the default alias if not already exists\n";
        print "                 Default: no \n";
        print "  --mustchange   If set, the new users must change its password by the first login\n";
        print "                 Default: no \n";
        print "  --lang         The language of the messages\n";
        print "                 Default: EN \n";
        print "  --test         If this option is given no changes will be done. The scipt only reports what's to do.\n";
        print "  --resetPassword If this option is set the password of old user will be reseted too.\n";
        print "  --allClasses   The import list contains all classes. Classes which are not in the list will be deleted.\n";
        print "                 This parameter has only affect when role=students\n";
        print "  --cleanClassDirs Remove the content of the directories of the classes.\n";
        print "                 This parameter has only affect when role=students\n";
        print "  --identifier   Which attribute(s) will be used to identify an user.\n";
        print "                 Normaly the sn givenName and birthday combination will be used.\n";
        print "                 Possible values are uid or uuid (uniqueidentifier).\n";
	print "  --sleep        The import script sleeps between creating the user objects not to catch all the resources of OSS.\n";
	print "                 The default value is 2 second. You can modify this.\n";
	print "\n";

}


sub __($)
{
        my $i = shift;
	if( $message->{$i} and ! utf8::is_utf8($message->{$i}) ){
                utf8::decode($message->{$i})
        }
        return $message->{$i} ? $message->{$i} : $i;
}

sub save_file($$){
   my $Lines = shift;
   my $File  = shift;

   open OUTPUT, ">$File";
   binmode OUTPUT, ':encoding(utf8)';
   foreach(@$Lines){
        print OUTPUT $_."\n";
   }
   close OUTPUT;
}

sub hash_to_json($) {
    my $hash = shift;
    my $json = '{';
    foreach my $key ( keys %{$hash} ) {
	my $value = $hash->{$key};
        $json .= '"'.$key.'":';
	if( $value eq 'true' ) {
       $json .= 'true,';
	} elsif ( $value eq 'false' ) {
       $json .= 'false,';
	} elsif ( $value =~ /^\d+$/ ) {
       $json .= $value.',';
	} else {
		$value =~ s/"/\\"/g;
		$json .= '"'.$value.'",';
	}
    }
    $json =~ s/,$//;
    $json .= '}';
}
sub daemonize
{
  my ($LOGDIR,$PIDFILE,$debug)=@_;
  if ( ! $debug )
  {
    open STDIN,"/dev/null";
    my $logfile = $LOGDIR."/import_user-$date.log";
    system("touch $logfile; chmod 600 $logfile");
    open STDOUT,">>$logfile";
    open STDERR,">>$logfile";
    binmode STDERR, ':encoding(utf8)';
    binmode STDOUT, ':encoding(utf8)';
    chdir "/";
    fork && exit 0;
    print "\n\n----------------------------------------\n";
    print `date`;
    print time,": User import successfully forked into background and running on PID ",$$,"\n";
  }
  else
  {
    print time,": User import running in debug-mode on PID ",$$,"\n";
  }
  open  FILE,">$PIDFILE";
  print FILE $$;
  close FILE;
}

sub close_on_error
{
    my $a = shift;
    print STDERR $a."\n";
    system("rm $PIDFILE");
    system("rm $RUNFILE");
    system("oss_api.sh PUT system/configuration/CHECK_PASSWORD_QUALITY/$CHECK_PASSWORD_QUALITY");
    open( LOGIMPORTLIST,">>$output");
    binmode LOGIMPORTLIST, ':encoding(utf8)';
    print LOGIMPORTLIST "$a";
    close(LOGIMPORTLIST);
    exit 1;
}

sub contains {
    my $a = shift;
    my $b = shift;
    foreach(@{$b}){
        if($a eq $_) {
                return 1;
        }
    }
    return 0;
}

sub group_diff {
    my $old   = shift;
    my $new   = shift;
    my @toadd = ();
    my @todel = ();
    foreach(@{$old}) {
        if( !contains($_,$new)) {
           push @todel,$_;
        }
    }
    foreach(@{$new}) {
        if( !contains($_,$old)) {
           push @toadd,$_;
        }
    }
    return ( \@todel, \@toadd );
}

sub write_file($$) {
  my $file = shift;
  my $out  = shift;
  local *F;
  open F, ">$file" || die "Couldn't open file '$file' for writing: $!; aborting";
  binmode F, ':encoding(utf8)';
  local $/ unless wantarray;
  print F $out;
  close F;
}

sub create_secure_pw {
    my $lenght = shift || 10;
    $lenght    = $lenght-2;
    my $pw     = "";
    my @SIGNS  = ( '#', '+', '$');
    my $start  = int(rand($lenght/2))+3;
    for( my $i=0; $i < $start; $i++)
    {
        my $i = int(rand(2));
        if( $i ) {
          $pw .= pack( "C", int(rand(25)+97) );
        } else {
          $pw .= pack( "C", int(rand(25)+65) );
        }
    }
    $pw .= $SIGNS[int(rand(3))];
    $pw .= int(rand(8))+2;
    for( my $i=0; $i < $lenght-$start; $i++)
    {
        my $i = int(rand(2));
        if( $i ) {
          $pw .= pack( "C", int(rand(25)+97) );
        } else {
          $pw .= pack( "C", int(rand(25)+65) );
        }
    }
    #Il can be read very badly
    $pw =~ s/I/G/g;
    $pw =~ s/l/g/g;
    return $pw;
}

#############################################################################
# Parsing the attributes
#############################################################################
$result = GetOptions(\%options,
                        "help",
                        "full",
                        "debug",
                        "alias",
                        "test",
                        "mustchange",
                        "input=s",
                        "role=s",
                        "domain=s",
                        "lang=s",
			"sleep=s",
                        "mailenabled=s",
                        "password=s",
                        "resetPassword",
                        "allClasses",
                        "cleanClassDirs",
			"identifier=s"
                        );

if (!$result && ($#ARGV != -1))
{
        usage();
        exit 1;
}
if ( defined($options{'input'}) )
{
        $input = $options{'input'};
}
if ( defined($options{'help'}) )
{
        usage();
        exit 0;
}
if ( defined($options{'role'}) )
{
        $role = lc($options{'role'});
}
if ( defined($options{'full'}) )
{
        $full = 1;
}
if ( defined($options{'debug'}) )
{
        $DEBUG = 1;
}
if ( defined($options{'sleep'}) )
{
        $SLEEP = $options{'sleep'};
}
if ( defined($options{'test'}) )
{
        $test = 1;
}
if ( defined($options{'resetPassword'}) )
{
        $resetPassword = 1;
}
if ( defined($options{'alias'}) )
{
        $alias = 1;
}
if ( defined($options{'mustchange'}) )
{
        $mustchange = 1;
}
if ( defined($options{'mailenabled'}) )
{
        $mailenabled = $options{'mailenabled'};
}
if ( defined($options{'password'}) )
{
        $password = $options{'password'};
}
if ( defined($options{'domain'}) )
{
        $domain = $options{'domain'};
}
if ( defined($options{'lang'}) )
{
        $lang = uc($options{'lang'});
}
if ( defined($options{'identifier'}) )
{
       $identifier = $options{'identifier'};
}
if ( defined($options{'allClasses'}) && $role eq 'students' )
{
        $allClasses = 1;
}
if ( defined($options{'cleanClassDirs'}) && $role eq 'students' )
{
        $cleanClassDirs = 1;
}

  open  FILE,">$RUNFILE";
  print FILE $date;
  close FILE;
daemonize($LOGDIR,$PIDFILE,$DEBUG);

$attr_ext_name = {
     "UID"              => "uid",
     "LOGIN"            => "uid",
     "BENUTZERKÜRZEL"   => "uid",
     "BENUTZERKENNUNG"  => "uid",
     "BENUTZERNAME"     => "uid",
     "ANMELDENAME"      => "uid",
     "SN"               => "surName",
     "SURNAME"          => "surName",
     "NAME"             => "surName",
     "NACHNAME"         => "surName",
     "GIVENNAME"        => "givenName",
     "VORNAME"          => "givenName",
     "BIRTHDAY"         => "birthDay",
     "GEBURTSTAG"       => "birthDay",
     "GEBURTSDATUM"     => "birthDay",
     "UUID"             => "uuid",
     "KENNUNG"          => "uuid",
     "PERSONALNUMMER"   => "uuid",
     "IDENTIFIKATOR"    => "uuid",
     "PASSWORD"         => "password",
     "PASSWORT"         => "password",
     "CLASS"            => "class",
     "KLASSE"           => "class",
     "GROUP"            => "group",
     "GRUPPE"           => "group",
     "MSQUOTA"          => "msQuota",
     "E-MAIL-QUOTA"     => "msQuota",
     "MAIL-QUOTA"       => "msQuota",
     "FSQUOTA"          => "fsQuota",
     "FESTPLATTENQUOTA" => "fsQuota",
     "DATEI-QUOTA"      => "fsQuota"
};

if($lang eq "DE" ) {
   $message = {
        "uid"       => "BENUTZERNAME",
	"surName"   => "NACHNAME",
	"givenName" => "VORNAME",
	"birthDay"  => "GEBURTSTAG",
	"uuid"      => "KENNUNG",
	"password"  => "PASSWORT",
	"class"     => "KLASSE",
	"group"     => "GRUPPE",
	"msQuota"   => "E-MAIL-QUOTA",
	"fsQuota"   => "DATEI-QUOTA"
   }
}


my @userAttributes = ( "uid", "surName", "givenName", "birthDay", "uuid", "password", "msQuota", "fsQuota","class","group");
# log the starting options
print "OPTIONS: ".Dumper(\%options);

#READ SYSTEM SETTINGS:
open IN,$config;
binmode IN, ':encoding(utf8)';
while (<IN>) {
     next if (/^#/);
     /$cprefix(.*)="(.*)"/;
     if(defined $1)
     {
         my $key   = $1;
         my $value = $2;
         $globals->{$key} = $value;
         print STDERR $key.'=>'.$globals->{$key}.":\n" if ($DEBUG);
     }
}
close(IN);

my $IMPORTDIR = $globals->{HOME_BASE}."/groups/SYSADMINS/userimports/$date";
system("mkdir -pm 770 $IMPORTDIR/tmp");
if( $input ne "$IMPORTDIR/userlist.txt" ) {
	system("cp $input $IMPORTDIR/userlist.txt");
}
$output   = $IMPORTDIR."/import.log";

#private String  role;
#private String  lang;
#private String  identifier;
#private boolean test;
#private String  password;
#private boolean mustchange;
#private boolean full;
#private boolean allClasses;
#private boolean cleanClassDirs;
#private boolean resetPassword;
# Save the parameters
open( OUT, ">$IMPORTDIR/parameters.json");
print OUT '{"role":"'.$role.'"'.
          ',"lang":"'.$lang.'"'.
	  ',"identifier":"'.$identifier.'"'.
	  ',"startTime":"'.$date.'"'.
	  ',"test":'.($test?"true":"false").
	  ',"password":"'.$password.'"'.
	  ',"mustchange":'.($mustchange?"true":"false").
	  ',"full":'.($full?"true":"false").
	  ',"allClasses":'.($allClasses?"true":"false").
	  ',"cleanClassDirs":'.($cleanClassDirs?"true":"false").
	  ',"resetPassword":'.($resetPassword?"true":"false").
	  '}';
close( OUT );

#Now let start to do it
my $NEWLIST    = {};
my @CLASSES    = ();
my %ALLCLASSES = ();
my @GROUPS     = ();
my @ALLUID     = ();
my %ALLUSER    = ();
my @AKTUID     = ();
my $DOMAIN     = $domain;
my @lines      = ();
my $ret        = '';

# Variable to handle the file header
my $sep           = "";
my $header        = {};

# Get the list of the classes
@CLASSES = `/usr/sbin/oss_api_text.sh GET groups/text/byType/class`;
if( !scalar(@CLASSES) ) {
	push @CLASSES,'dummy';
}
@GROUPS  = `/usr/sbin/oss_api_text.sh GET groups/text/byType/workgroup`;

# Get the list of the users
my $users = `/usr/sbin/oss_api.sh GET users/byRole/$role`;
$users = eval { decode_json($users) };
if ($@)
{
    close_on_error( "decode_json failed, invalid json. error:$@\n" );
}
foreach my $user (@{$users})
{
   my $i = $user->{'uid'};
   next if( lc($i) eq 'tstudents' );
   push @ALLUID , $i;
   my $surName   = $user->{'surName'};
   my $givenName = $user->{'givenName'};
   my $birthday  = $user->{'birthDay'};
   my @T=localtime($birthday/1000);
   $birthday = sprintf("%4d-%02d-%02d", $T[5]+1900,$T[4]+1,$T[3]);

   Encode::_utf8_on($surName);        #if( ! utf8::is_utf8($sn) );
   Encode::_utf8_on($givenName); #if( ! utf8::is_utf8($givenName) );
   my $key = "$surName-$givenName-$birthday";
   if( $identifier ne 'sn-gn-bd' )
   {
      if( ! defined $user->{$identifier} ) {
          close_on_error( "<font color='red'>".__LINE__ ." ". __('The identifier must be contained by all user.')."</font>" );
      }
      $key = $user->{$identifier};
   }
   $key =~ s/\s//g;
   $ALLUSER{uc($key)} = $i;
}
print "OLD-USER: ".Dumper(\%ALLUSER);
# -- building file header attributes
foreach my $attr (keys %$attr_ext_name) {
	push @attr_ext, $attr;
}
foreach my $attr (@userAttributes)
{
    push @attr_ext, $attr;
    $attr_ext_name->{$attr} = uc($attr);
}
my $muster = "";
foreach my $i (@attr_ext)
{
  if( $i ne "")
  {
    $muster.="$i|";
  }
}
foreach my $i (@attr_ext)
{
  if( $i ne "")
  {
    $muster.="$i|";
  }
}
chomp $muster;
$muster =~ s/\|$//;

#-- reading the file in a variable
open (INPUT, "<$input")  || close_on_error("<font color='red'>". __LINE__ ." ". __('cant_open_file')."</font>" );
binmode INPUT,':encoding(utf8)';
while ( <INPUT> )
{
    Encode::_utf8_on($_);
    print "NOT OK $_\n" if( ! utf8::is_utf8($_) ) ;
    #Clean up some character
    chomp; s/\r$//; s/"//g;
    push @lines, $_;
}
close (INPUT);
#-- empty file
if(scalar(@lines) < 2)
{
    close_on_error( "<font color='red'>".__LINE__ ." ". __('emtpy_file')."</font>" );
}
#-- reading and evaluating the header
my $HEADER = uc(shift @lines);
print "Header".$HEADER."\n";
$HEADER =~ s/^[^A-Z]//;
print "Cleaned Header ".$HEADER."\n";
#-- removing white spaces
#$HEADER =~ s/\s+//g;
#-- determine the field separator
#print $HEADER."\n";
print "Muster $muster\n";
$HEADER =~ /($muster)(.+?)($muster)/i;
if( defined $2 )
{
   $sep = $2;
}
else
{
    close_on_error( "<font color='red'>".__LINE__ ." ". __('bad_header')."</font>" );
}
my $counter  = 0;
my $hasUid   = 0;
my $hasPassword = 0;
foreach my $i (split /$sep/,$HEADER)
{
    if( contains($attr_ext_name->{uc($i)},\@userAttributes))
    {
        $header->{$counter} = $attr_ext_name->{uc($i)} || lc($i) ;
	if( $attr_ext_name->{uc($i)} eq "uid" ) {
	    $hasUid = 1;
	}
	if( $attr_ext_name->{uc($i)} eq "password" ) {
	    $hasPassword = 1;
	}
    }
    else
    {
            print STDERR "Unknown attribute $i on place $counter in the header.\n";
            open( OUT, ">>$output");
	    binmode OUT,':encoding(utf8)';
            print OUT "<font color='red'>Unknown attribute $i on place $counter in the header</font>\n";
            close( OUT );
    }
    $counter++;
}
if( !$hasUid ) {
    $header->{$counter} = "uid";
    $HEADER .= $sep.__("uid");
    $counter++;
}
if( !$hasPassword ) {
    #TODO translate
    $header->{$counter} = "password";
    $HEADER .= $sep.__("password");
    $counter++;
}
print '$header: '.Dumper($header);
print '$attr_ext_name: '.Dumper($attr_ext_name);
foreach my $cl (@CLASSES)
{
   chomp $cl;
   $NEWLIST->{$cl}->{'header'} = $HEADER;
}
# Only studenst will be sorted in class lists.
if( $role ne 'students' )
{
   $NEWLIST->{$role}->{'header'} = $HEADER;
}
print '$NEWLIST: '.Dumper($NEWLIST);


if( !$test ) {
	system("/usr/sbin/oss_api.sh PUT system/configuration/CHECK_PASSWORD_QUALITY/no");
}
# Now we begins du setup the html side
foreach my $act_line (@lines)
{
    # Logging
    print "------$act_line------\n";
    my %USER = ();
    # Setup some standard values
    $USER{'role'}               = $role;
    #Not supported at the moment
    #if( $mailenabled )
    #{
    #  $USER{'mailenabled'} = $mailenabled;
    #}
    if( $mustchange )
    {
      $USER{'mustChange'} = 'true';
    }
    #Not supported at the moment
    #if( $alias )
    #{
    #  $USER{'alias'} = 'true';
    #}
    my $uid     = undef;
    my $ERROR   = 0;
    my $ERRORS = '';
    my @classes = ();
    my @groups  = ();
    my $MYCLASSES  = "";
    my $PRIMERCLASS = "";

    # Pearsing the line
    my @line = split /$sep/, $act_line;
    # Continue if there was an empty line
    next if( scalar (@line) < 3);
    foreach my $h (keys %$header)
    {
      next if( ! defined $header->{$h} );
      if( $header->{$h} eq "class" )
      {  #It may be more then one classes
         foreach my $c (split /\s+/,$line[$h])
         {
	    $c = uc($c);
            $ALLCLASSES{$c} = 1;
            push @classes, $c;
         }
      }
      elsif( $header->{$h} eq "group" )
      {  #It may be more then one groups
         foreach my $c (split /\s+/,$line[$h])
         {
            push @groups, uc($c);
         }
      }
      else
      {
         if( ($header->{$h} eq "uid" || $header->{$h} eq "password") && defined($line[$h]) )
         {  #remove white spaces from uid and password
            $line[$h] =~ s/\s//g;
         }
         next if( !$line[$h] );
         $USER{$header->{$h}}  = $line[$h];
         Encode::_utf8_on($USER{$header->{$h}});
      }
    }
    # It is more simplier :-)
    if( scalar(@classes) )
    { # We need this only for reporting
      $MYCLASSES =join(' ',@classes);
      $PRIMERCLASS=$classes[0];
    }
    if( $PRIMERCLASS eq 'ALL' )
    {
        @classes = @CLASSES;
    }
    if( ! $PRIMERCLASS ) {
	$PRIMERCLASS = 'dummy';
    }

    # If there is no domain defined we use the main mail domain
    #if( !defined $USER{'domain'} )
    #{
    #    $USER{'domain'} = $DOMAIN;
    #}
    #Check if all classes are present, someone who belongs to all classes
    #can not belong to not existend classes
    if( scalar(@classes) && $classes[0] ne 'ALL' )
    {
        foreach my $c (@classes)
        {
            my $cn = uc($c);
            if( !defined $NEWLIST->{$cn}->{'header'} )
            {
                if( !$test )
                {
                    my $GROUP             = {};
                    $GROUP->{name}        = $cn;
                    $GROUP->{groupType}   = 'class';
                    $GROUP->{description} = __('class')." $cn";
		    write_file("$IMPORTDIR/tmp/add_group.$cn",hash_to_json($GROUP));
		    #TODO Check result
		    print("/usr/sbin/oss_api_post_file.sh groups/add $IMPORTDIR/tmp/add_group.$cn\n");
		    system("/usr/sbin/oss_api_post_file.sh groups/add $IMPORTDIR/tmp/add_group.$cn");
                    print "  NEW CLASS $cn:\n";
                    $ERRORS .= "<b>Creating new class: $cn</b><br>\n";
                }
                else
                {
                    print "  NEW CLASS $cn\n";
                    $ERRORS .= "<b>Creating new class: $cn</b><br>\n";
                }
                # Logging
                push @CLASSES, $cn;
                $NEWLIST->{$cn}->{'header'} = $HEADER;
            }
        }
    }

    #Check if all groups are present
    foreach my $g (@groups)
    {
        my $cn = uc($g);
        next if( $cn =~ /^\-/ );
        if( !contains($cn,\@GROUPS ))
        {
            if( !$test )
            {
                    my $GROUP             = {};
                    $GROUP->{cn}          = $cn;
                    $GROUP->{groupType}   = 'workgroup';
                    $GROUP->{description} = "$cn";
		    write_file("$IMPORTDIR/tmp/add_group.$cn",hash_to_json($GROUP));
		    print("/usr/sbin/oss_api_post_file.sh groups/add $IMPORTDIR/tmp/add_group.$cn\n");
		    system("/usr/sbin/oss_api_post_file.sh groups/add $IMPORTDIR/tmp/add_group.$cn");
                    print "  NEW GROUP $cn\n";
                    $ERRORS .= "<b>Creating new group: $cn</b><br>\n";
            }
            else
            {
                    print "  NEW GROUP $cn\n";
                    $ERRORS .= "<b>Creating new group: $cn</b><br>\n";
            }
            # Logging
            push @GROUPS, $cn;
        }
    }
    # Analysing the birthday. We accept following forms:
    # DDMMYYYY
    # DD-MM-YYYY DD:MM:YYYY DD MM YYYY
    # YYYY-MM-DD
    $USER{'birthDay'} =~ tr/.: /---/;
    if( $USER{'birthDay'} =~ /(\d{2})-(\d{2})-(\d{4})/)
    {
      $USER{'birthDay'} = "$3-$2-$1";
    }
    elsif ( $USER{'birthDay'} =~ /(\d+)-(\d+)-(\d{4})/)
    {
      $USER{'birthDay'} = sprintf("$3-%02d-%02d",$2,$1);
    }
    elsif ( $USER{'birthDay'} =~ /(\d{4})-(\d{2})-(\d{2})/)
    {
      #Nothing to do it is all right.
    }
    else
    {
       $ERRORS .= "<font color='red'> ".$USER{'givenName'}." ".$USER{'surName'}." ".__('birthday_format_false')." ".$USER{'birthDay'}."</font>\n";
       $ERROR = 1;
    }

    # uid must be lower case
    if( defined  $USER{'uid'} and  $USER{'uid'} ne "" )
    {
               $USER{'uid'} = lc($USER{'uid'});
    }

    # Do this user exist?
    my $key = uc($USER{'surName'}.'-'.$USER{'givenName'}.'-'.$USER{'birthDay'});
    if( $identifier ne 'sn-gn-bd' )
    {
       $key = uc($USER{lc($identifier)});
    }
    $key =~ s/\s//g;
    print "  USER-KEY $key\n";
    if( exists($ALLUSER{$key}) )
    {
       $uid=$ALLUSER{$key};
       if( !defined  $USER{'uid'} || $USER{'uid'} eq "" )
       {
               $USER{'uid'} = $uid;
       }
       else
       {
          if( $ALLUSER{$key} ne $USER{'uid'} )
          {
            $ERRORS .= "<font color='red'> ".$USER{'givenName'}." ".$USER{'surName'}." ".$USER{'birthDay'}.": ".__('same_person')." $uid </font>\n";
            $ERROR = 1;
          }
       }
    }

    # And now let's do it
    if( defined $uid )
    {
        # Logging
        print "  OLD USER $uid\n";
        #First we make the older user
        my @old_classes    = ();
        print "/usr/sbin/oss_api_text.sh GET users/text/$uid/classes\n";
        foreach my $i ( `/usr/sbin/oss_api_text.sh GET users/text/$uid/classes` )
        {
	   chomp $i;
           push @old_classes, uc($i);
        }
        $ERRORS .= "<b>".$USER{'givenName'}." ".$USER{'surName'}."</b>: ".__('old_classes').": ".join(" ",@old_classes)." ".__('new_classes').": ".$MYCLASSES;
        if( $resetPassword )
        {
            if( $password )
            {
              $USER{'password'} = $password;
	    }
	}
	$ERRORS .= "<br>\n";
        if( !$test )
        {
                if( $resetPassword )
                {
                    # If a default password was defined we use it
                    if( $password )
                    {
                      $USER{'password'} = $password;
                    }
                    if( !$USER{'password'} || $USER{'password'} eq "*")
                    {
                       $USER{'password'} = create_secure_pw();
                    }
                }
                my ($classes_to_del,$classes_to_add) = group_diff(\@old_classes,\@classes);
                foreach my $g (@$classes_to_del)
                {
			print "/usr/sbin/oss_api_text.sh DELETE users/text/$uid/groups/$g\n";
			my $result = `/usr/sbin/oss_api_text.sh DELETE users/text/$uid/groups/$g`;
			if( $result ne "OK" ) {
				$ERRORS .= "<b>".$USER{'givenName'}." ".$USER{'surName'}."</b>: ".__("Can not be removed from group:")." ".$g;
			}
                }
                foreach my $g (@$classes_to_add)
                {
			print "/usr/sbin/oss_api_text.sh PUT users/text/$uid/groups/$g\n";
			my $result = `/usr/sbin/oss_api_text.sh PUT users/text/$uid/groups/$g`;
			if( $result ne "OK" ) {
				$ERRORS .= "<b>".$USER{'givenName'}." ".$USER{'surName'}."</b>: ".__("Can not be addedd group:")." ".$g;
			}
                }
                foreach my $g ( @groups )
                {
                    my $cn = uc($g);
                    if( $cn =~ s/^\-// )
                    {
			print "/usr/sbin/oss_api_text.sh DELETE users/text/$uid/groups/$cn\n";
			my $result = `/usr/sbin/oss_api_text.sh DELETE users/text/$uid/groups/$cn`;
			if( $result ne "OK" ) {
				$ERRORS .= "<b>".$USER{'givenName'}." ".$USER{'surName'}."</b>: ".__("Can not be removed from group:")." ".$cn;
			}
                    }
                    else
                    {
		   print "/usr/sbin/oss_api_text.sh PUT users/text/$uid/groups/$cn\n";
			my $result = `/usr/sbin/oss_api_text.sh PUT users/text/$uid/groups/$cn`;
			if( $result ne "OK" ) {
				$ERRORS .= "<b>".$USER{'givenName'}." ".$USER{'surName'}."</b>: ".__("Can not be addedd group:")." ".$cn;
			}
                    }
                }
        }
        push @AKTUID, $uid;
        print Dumper(\%USER);
    }
    else
    {
        # Loging
        print "  NEW USER\n";
        # If a default password was defined we use it
        if( $password )
        {
          $USER{'password'} = $password;
        }

        # It is a new user
        if( !$USER{'password'} || $USER{'password'} eq "*")
        {
           $USER{'password'} = create_secure_pw();
        }
        if($USER{"surName"} eq "" || $USER{"password"} eq "" )
        {
            $ERRORS .= "<font color='red'> ".$USER{'givenName'}." ".$USER{'surName'}.": ".__('miss_some_values')."</font>\n";
            $ERROR = 1;
        }
        else
        {
            if(defined($USER{"uid"}) && $USER{"uid"} ne '' )
            { # there is an uid predefiend let's test it
                if($USER{"uid"} =~ /[^a-zA-Z0-9-_\.]+/)
                {  #   Match a non-word character
                    $ERRORS .= "<font color='red'> ".$USER{'givenName'}." ".$USER{'surName'}.": ".__('uid_invalid')."</font>\n";
                    $ERROR = 1;
                }
                elsif( ($USER{"uid"} eq "anyone") || ($USER{"uid"} eq "anybody"))
                { # Don't allow anybody or anyone as uid (these keywords are needed by cyrus for ACLs)
                    $ERRORS .= "<font color='red'> ".$USER{'givenName'}." ".$USER{'surName'}.": ".__('value_anyone_not_allowed')."</font>\n";
                    $ERROR = 1;
                }
                else
                {
                    $USER{"uid"} = lc($USER{"uid"});  # uid always lowercase
                }
            }

            # at time only SMD5 is supported
            #if(length $USER{"password"} < 5 || ( $USER{"pwmech"} eq "SMD5" ? 0 : length($USER{"password"}) > 8 ) ) {
            #    $ERRORS .= "<font color='red'> $USER{'givenName'} $USER{'surName'}: $message->{incorrect_passwd_length}</font>\n";
            #    $ERROR = 1;
            #}
        }
        print "Befor creating\n".Dumper(\%USER)."Classes:".join(" ",@classes)."\n";
        if( !$ERROR )
        { # If no error accours the user will be created
            $USERCOUNT+=1;
	    write_file("$IMPORTDIR/tmp/add_user.$USERCOUNT",hash_to_json(\%USER));
            if( !$test )
            {
		    write_file("$IMPORTDIR/tmp/add_user.$USERCOUNT",hash_to_json(\%USER));
		    print "/usr/sbin/oss_api_post_file.sh users/insert $IMPORTDIR/tmp/add_user.$USERCOUNT\n";
		    my $result = `/usr/sbin/oss_api_post_file.sh users/insert $IMPORTDIR/tmp/add_user.$USERCOUNT`;
		    $result = eval { decode_json($result) };
		    sleep($SLEEP);
		    if ($@)
		    {
		        close_on_error( "decode_json failed, invalid json. error:$@\n" );
		    }
                    if( $result->{"code"} eq "OK" )
                    {
                      print $result->{'value'}."\n";
		      my $id = $result->{'objectId'};
		      print "/usr/sbin/oss_api.sh GET users/$id\n";
		      $result = `/usr/sbin/oss_api.sh GET users/$id`;
                      $result = eval { decode_json($result) };
                      if ($@)
                      {
                          close_on_error( "decode_json failed, invalid json. error:$@\n" );
                      }
		      if( ! defined $USER{'uid'} ) {
		          $USER{'uid'} = $result->{'uid'};
		      }
                      $uid        = $USER{'uid'};
                      $ERRORS    .= "<b>".$USER{'givenName'}." ".$USER{'surName'}."</b> ".__('created')." ".__('uid').": \"$uid\" ".__('class').":".$MYCLASSES." <br>\n";
		      foreach my $g (@classes)
		      {
		          print "/usr/sbin/oss_api_text.sh PUT users/text/$uid/groups/$g\n";
			  my $result = `/usr/sbin/oss_api_text.sh PUT users/text/$uid/groups/$g`;
		          if( $result ne "OK" ) {
		         $ERRORS .= "  <b>".$USER{'givenName'}." ".$USER{'surName'}."</b>: ".__("Can not be addedd to class:")." ".$g." ";
		          } else {
			     print "  <b>Add $uid to $g $result</b>\n";
			  }
		      }
                      push @AKTUID, $uid;
                    }
                    else
                    {
                      print $result->{'value'}."\n";
                      $ERROR   = 1;
                      $ERRORS .= "<font color='red'> ".$USER{'givenName'}." ".$USER{'surName'}.": ".__('failed')."<br>".$result->{'value'}."</font>\n";
                    }
            }
            else
            {
		#TODO
                #    if( ! defined $USER{uid} || $USER{uid} eq '' )
                #    {
                #            $oss->create_uid(\%USER);
                #    }
                    $uid         = $USER{'uid'} || $USER{'surName'}.'-'.$USER{'givenName'}.'-'.$USER{'birthDay'};
                    $ERRORS    .= "<b>".__('new')." ".$USER{'givenName'}." ".$USER{'surName'}.":</b> ".$uid.", ".__('class').":".$MYCLASSES." <br>\n";
            }
            $ALLUSER{$key}=$uid;
        }
        print "After creating\n".Dumper(\%USER)."\n";
    }
    if( $ERROR eq 0 )
    { # Prework for the list:
        my $line = "";
        foreach my $h (sort {$a <=> $b} (keys %$header))
        {
          if( defined $USER{$header->{$h}}  )
          {
             $line .= $USER{$header->{$h}}.$sep;
          } else {
	     if( $header->{$h} eq 'class' ) {
	         $line .= join(" ",@classes).$sep;
	     } elsif( $header->{$h} eq 'group' ) {
	         $line .= join(" ",@groups).$sep;
	     } else {
	         $line .= "".$sep;
	     }
	  }
        }
        $line =~ s/$sep$//;
        if( $role eq 'students' )
        {
           $NEWLIST->{$PRIMERCLASS}->{$uid} = $line;
        }
        else
        {
           $NEWLIST->{$role}->{$uid} = $line;
        }
    }

    #$ERRORS .= "givenName=".$USER{'givenName'}.";surName=".$USER{'surName'}.";birthday=".$USER{'birthDay'}."\n";
    open( OUT, ">>$output");
    binmode OUT,':encoding(utf8)';
    print OUT "$ERRORS";
    close( OUT );
}
# Logging
#    print ">>>>>>>>>>>>>>>>DUMP OF THE NEW USER LIST<<<<<<<<<<<<<\n".Dumper($NEWLIST)."\n>>>>>>>>>>>>>>>END DUMP OF THE NEW USER LIST<<<<<<<<<<<<<<<<<<<";
# Save the user list:
if( $role eq 'students' )
{
    my @AllList = ($HEADER);
    foreach my $cl (@CLASSES)
    {
        my @ClassList = ($HEADER);
        foreach my $h (keys %{$NEWLIST->{$cl}})
        {
            if( $h ne "header" )
            {
                push @ClassList, " ";
                push @ClassList, $NEWLIST->{$cl}->{$h};
                push @AllList, $NEWLIST->{$cl}->{$h};
            }
        }
        if( scalar @ClassList > 1 )
        {
            save_file( \@ClassList, "$IMPORTDIR/userlist.$cl.txt" );
        }
    }
    if( scalar @AllList > 1 )
    {
        save_file( \@AllList, "$IMPORTDIR/all-students.txt" );
    }
}
else
{
    my @List = ($HEADER);
    foreach my $h (keys %{$NEWLIST->{$role}})
    {
        if( $h ne "header" )
        {
            push @List, $NEWLIST->{$role}->{$h};
        }
    }
    if( scalar @List > 1 )
    {
        save_file( \@List, "$IMPORTDIR/all-user.txt" );
    }
}
# Delete old students
if( $role eq 'students' &&  $full )
{
    my $ind = {};
    $ind->{$_} = 1 foreach(@AKTUID);
    foreach my $uid (@ALLUID )
    {
      if(not exists($ind->{$uid}))
      {
            my $delete_old_student = '';
            if( !$test )
            {
		    print "/usr/sbin/oss_api_text.sh DELETE users/text/$uid\n";
		    my $result = `/usr/sbin/oss_api_text.sh DELETE users/text/$uid`;
		    if( $result ne "OK" ) {
			$delete_old_student .= "User: <b>".$uid."</b>: ".__("Can not be deleted:")."<br>\n";
		    } else {
	                $delete_old_student .= "uid=$uid#;#message=<b>Login: $uid</b> ".__('deleted')." /home/archiv/$uid.tgz<br>\n";
		    }
            }
            else
            {
                    $delete_old_student .= "uid=$uid#;#message=<b>Login: $uid</b> ".__('deleted')."<br>\n";
            }

            open( OUT, ">>$output");
            binmode OUT,':encoding(utf8)';
            print OUT "$delete_old_student";
            close( OUT );
      }
    }
}
if( $allClasses )
{   #Remove Classes which are not in the list
    my $MESSAGE = __("<b>Classes to remove:</b>");
    print "/usr/sbin/oss_api_text.sh GET groups/text/byType/class\n";
    foreach my $cn ( `/usr/sbin/oss_api_text.sh GET groups/text/byType/class` )
    {
	Encode::_utf8_on($cn);
	chomp $cn;
	next if( defined $ALLCLASSES{$cn} );
	$MESSAGE .= " $cn: ";
        print "/usr/sbin/oss_api_text.sh DELETE groups/text/$cn\n";
        my $result = `/usr/sbin/oss_api_text.sh DELETE groups/text/$cn`;
	if( $result ne "OK" ) {
	    $MESSAGE .= __("Can not be deleted:");
	} else {
	    $MESSAGE .= __("Deleted");
	}
	$MESSAGE .= "<br>\n";
    }
    open( OUT, ">>$output");
    binmode OUT,':encoding(utf8)';
    print OUT  "$MESSAGE";
    close( OUT );
}
if( $cleanClassDirs && !$test )
{
    my $MESSAGE = __("<b>Clean up the directories of the classes:</b>")."<br>\n";
    print "/usr/sbin/oss_api_text.sh GET groups/text/byType/class\n";
    foreach my $cn ( `/usr/sbin/oss_api_text.sh GET groups/text/byType/class` )
    {
	chomp $cn;
	my $path =  $globals->{HOME_BASE}.'/groups/'.$cn;
	system("rm -rf $path") if( -d $path );
	system("mkdir -m 3771 $path; chgrp $cn $path; setfacl -d -m g::rwx $path;");
	$MESSAGE .= "    $path<br>\n";
    }
    open( OUT, ">>$output");
    binmode OUT,':encoding(utf8)';
    print OUT  "$MESSAGE";
    close( OUT );
}
#Some important things to do if it was not a test
if( !$test )
{
    print("/usr/sbin/oss_api.sh PUT system/configuration/CHECK_PASSWORD_QUALITY/$CHECK_PASSWORD_QUALITY\n");
    system("/usr/sbin/oss_api.sh PUT system/configuration/CHECK_PASSWORD_QUALITY/$CHECK_PASSWORD_QUALITY");
    system("systemctl try-restart squid");
    system("/usr/share/oss/tools/create_password_files.py $IMPORTDIR");
}
system("rm $RUNFILE");
system("rm $PIDFILE");
system("chown root $input");
system("chmod 600  $input");

1;
