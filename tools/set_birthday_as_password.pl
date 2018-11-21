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
my %options      = ();
my $result       = "";
my $role         = "students";
#############################################################################
## Subroutines
#############################################################################

sub usage
{

        print "import_user_list.pl [<options>]\n";
        print "Options:\n";
        print "  --help         Print this help message\n";
        print "  --role         Role of the users to set the password: students|teachers|administration\n";
        print "                 Default: students \n";
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
sub create_secure_pw {
    my $lenght = shift || 10;
    $lenght    = $lenght-2;
    my $pw     = "";
    my @SIGNS  = ( '#', '+', '$','&','!');
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
    $pw .= $SIGNS[int(rand(5))];
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
                        "role=s"
                        );

if (!$result && ($#ARGV != -1))
{
        usage();
        exit 1;
}
if ( defined($options{'help'}) )
{
        usage();
        exit 0;
}
if ( defined($options{'role'}) )
{
        $role = $options{'role'};
}
# Get the list of the users
my $users = `/usr/sbin/oss_api.sh GET users/byRole/$role`;
$users = eval { decode_json($users) };
if ($@)
{
    die( "decode_json failed, invalid json. error:$@\n" );
}
my $CHECK_PASSWORD_QUALITY = `/usr/sbin/oss_api_text.sh GET system/configuration/CHECK_PASSWORD_QUALITY`;
system("/usr/sbin/oss_api.sh PUT system/configuration/CHECK_PASSWORD_QUALITY/no");
foreach my $user (@{$users})
{
   my $i = $user->{'uid'};
   next if( lc($i) eq 'tstudents' );
   my $birthday  = $user->{'birthDay'};
   my @T=localtime($birthday/1000);
   $birthday = sprintf("%4d-%02d-%02d", $T[5]+1900,$T[4]+1,$T[3]);

   print("/usr/bin/samba-tool user setpassword $i --newpassword=$birthday\n");
   system("/usr/bin/samba-tool user setpassword $i --newpassword=$birthday");
}
system("/usr/sbin/oss_api.sh PUT system/configuration/CHECK_PASSWORD_QUALITY/$CHECK_PASSWORD_QUALITY");
