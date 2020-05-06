#!/usr/bin/perl
use Mail::IMAPClient;
use strict;
my $passwd=`grep de.cranix.dao.User.Register.Password= /opt/cranix-java/conf/cranix-api.properties | sed 's/de.cranix.dao.User.Register.Password=//'`;
chomp $passwd;
my $imap = Mail::IMAPClient->new(
  Server   => 'localhost',
  User     => 'register',
  Password => $passwd,
  Ssl      => 0,
  Uid      => 1,
);
while(<>) {
chomp;
	my $quota  = $imap->quota("user".$imap->separator."$_");
	if( defined $quota ) {
		my $quotau = $imap->quota_usage("user".$imap->separator."$_");
		print "$_ $quotau $quota\n";
	}
}
print ']';

