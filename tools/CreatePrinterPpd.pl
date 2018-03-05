#!/usr/bin/perl

use strict;

my @ppds = `find /usr/share/cups -name '*ppd.gz'`;
my $printers = {};
my $drivers  = {};
foreach my $ppd ( @ppds ) {
  chomp $ppd;
  my @content = `cat $ppd | gunzip`;
  my $Manufacturer = "";
  my $ModelName    = "";
  foreach ( @content ) {
      if( /\*Manufacturer:\s+"(.*)"/ ) {
        $Manufacturer = $1;
      }
      if( /\*ModelName:\s+"(.*)"/ ) {
        $ModelName = $1;
      }
      if( $Manufacturer and $ModelName ) {
        push @{$printers->{$Manufacturer}}, $ModelName;
        $drivers->{$ModelName} = $ppd;
	last;
      }
  }

}
open OUT, ">/usr/share/oss/templates/drivers.txt";
foreach(sort keys %$drivers ) {
    print OUT $_.'###'.$drivers->{$_}."\n";
}
close OUT;

open OUT, ">/usr/share/oss/templates/printers.txt";
foreach(sort keys %$printers ) {
    print OUT $_.'###';
    print OUT join("%%",sort(@{$printers->{$_}}))."\n";
}
close OUT;
