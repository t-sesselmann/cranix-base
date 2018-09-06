#!/usr/bin/perl

use DBI;
use strict;
my $DBCON = 'dbi:mysql:database=OSS;host=localhost;port=3306';
my $DBUSER= 'root';
my $DBPW= `grep password= /root/.my.cnf | sed 's/password=//'`;  chomp $DBPW;
my $DBH = DBI->connect( $DBCON, $DBUSER, $DBPW);
my $AvailablePrinters = {};
my $rows  = $DBH->prepare("SELECT * FROM AvailablePrinters");

$rows->execute();
while ( my @row = $rows->fetchrow_array ) {
	my $id  = $row[0];
	my $rid = $row[1];
	my $did = $row[2];
	my $pid = $row[3];
	if ( $rid and defined $AvailablePrinters->{$rid}->{$pid} ) {
		$DBH->do("DELETE FROM AvailablePrinters where id=$id");
	} else {
		$AvailablePrinters->{$rid}->{$pid} = 1;
	}
}
$DBH->disconnect;
system("systemctl restart oss-api");
