#!/usr/bin/perl
# Copyright (c) 2012-2018 Peter Varkoly <peter@varkoly.de> Nurember, Germany.  All rights reserved.

use strict;
use URI::Escape;

my $minion = shift;
my ( $hostname ) = split(/\./,$minion);
my $count  = 0;
my @pkgs   = `salt $minion pkg.list_pkgs`;
my $name   = "";
my $version = "";

foreach(@pkgs) {
   if( $count > 1 ) {
	if(  $count % 2 ) {
		/\s+(.*)$/;
		$version = uri_escape($1);
		system("oss_api.sh PUT 'softwares/devicesByName/$hostname/$name/$version'");
	} else {
		/\s+(.*):/;
		$name = uri_escape($1);
	}
   }
   $count++;
}
