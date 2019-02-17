#!/usr/bin/perl -w
# Copyright (c) Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.
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

my $role         = "students";
my $input = "/tmp/userlist.txt";
my $lang  = 'DE'
my $test  = 0;
my $globals       = {};
my @attr_ext      = ();
my $attr_ext_name = {};

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

sub close_on_error
{
    my $a = shift;
    print STDERR $a."\n";
    exit 1;
}

my $result = GetOptions(\%options,
	"input=s",
        "role=s",
        "lang=s",
	"test");

if (!$result && ($#ARGV != -1))
{
        exit 1;
}

if ( defined($options{'input'}) )
{
        $input = $options{'input'};
}
if ( defined($options{'role'}) )
{
        $role = $options{'role'};
}
if ( defined($options{'test'}) )
{
        $test = 1;
}
if ( defined($options{'lang'}) )
{
        $lang = $options{'lang'};
}

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

my $NEWLIST    = {};
my @ALLUID     = ();
my %ALLUSER    = ();
my @AKTUID     = ();
my @lines      = ();
my $ret        = '';

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
   my $key = "$surName-$givenName";
   $key =~ s/\s//g;
   $key = uc($key);
   if( defined $ALLUSER{$key} ) {
     print "$surName $givenName $birthday is duplicate.\n";
   } else {
     $ALLUSER{$key} = $i;
   }
}

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
    my $key = uc($USER{'surName'}.'-'.$USER{'givenName'});
    if( exists($ALLUSER{$key}) )
    {
        print Dumper($ALLUSER{$key});
    }
}

