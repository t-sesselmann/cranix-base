#!/usr/bin/perl
use Mail::IMAPClient;
use strict;
my $user  = shift;
my $quota = shift || 0;

my $passwd=`grep de.openschoolserver.dao.User.Register.Password= /opt/oss-java/conf/oss-api.properties | sed 's/de.openschoolserver.dao.User.Register.Password=//'`;
chomp $passwd;
my $imap = Mail::IMAPClient->new(
  Server   => 'localhost',
  User     => 'register',
  Password => $passwd,
  Ssl      => 0,
  Uid      => 1,
);

$imap->setquota("user".$imap->separator.$user,"STORAGE",$quota);
print $imap->quota("user".$imap->separator.$user)."\n";
print $imap->quota_usage("user".$imap->separator.$user)."\n";

