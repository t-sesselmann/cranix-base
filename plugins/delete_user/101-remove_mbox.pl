#!/usr/bin/perl
use Mail::IMAPClient;
use strict;
my $user = "";

while(<>)
{
        /(.*): (.*)/;
        if ( $1 eq 'uid' )
        {
                $user = $2;
        }
}

my $passwd=`grep de.cranix.dao.User.Register.Password= /opt/cranix-java/conf/cranix-api.properties | sed 's/de.cranix.dao.User.Register.Password=//'`;
chomp $passwd;
my $imap = Mail::IMAPClient->new(
  Server   => 'localhost',
  User     => 'register',
  Password => $passwd,
  Ssl      => 0,
  Uid      => 1,
);

if( $imap and $user ) {
        $imap->setacl("user".$imap->separator.$user,'register','lrswipkxtecda');
        $imap->delete("user".$imap->separator.$user);
        my $sieve = "/var/lib/sieve/".substr($user,0,1)."/".$user;
        if( -d $sieve ) {
                system("rm -rf $sieve");
        }
} else {
        print("ERROR or not IMAP '$user'\n" );
}

