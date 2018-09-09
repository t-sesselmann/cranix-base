#!/usr/bin/perl

use strict;
use JSON::XS;
use Encode qw(encode decode);
binmode STDIN, ":encoding(UTF-8)";
binmode STDOUT, ":encoding(UTF-8)";
binmode STDERR, ":encoding(UTF-8)";
use utf8;

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


my $classes = `/usr/sbin/oss_api.sh GET groups/byType/class`;
$classes = eval { decode_json($classes) };

foreach my $classe (@{$classes}) {
	my $groupId = $classe->{id};
	my $name = $classe->{name};
	my $desc = $classe->{description};
	$name =~ s/\s+//g;
	my $json = '{"name":"WLAN-'.$name.'","description":"Wlanraum '.$desc.'","hwconfId":"3","roomType":"AdHocAccess","roomControl":"allTeachers","netMask":"26","places":1}';
	print "$json\n";
	write_file("/tmp/addRoom",$json);
	my $result = `/usr/sbin/oss_api_post_file.sh rooms/add /tmp/addRoom`;
	$result = eval { decode_json($result) };
        if ($@)
        {
            die( "decode_json failed, invalid json. error:$@\n" );
        }
	my $roomId = $result->{'objectId'};
	$json = '{"name":"WLAN-'.$name.'","description":"Wlanraum '.$desc.'","categoryType":"AdHocAccess","studentsOnly":true,"publicAccess":false}';
	print "$json\n";
	write_file("/tmp/addCatetory",$json);
	$result = `/usr/sbin/oss_api_post_file.sh categories/add /tmp/addCatetory`;
	$result = eval { decode_json($result) };
        if ($@)
        {
            die( "decode_json failed, invalid json. error:$@\n" );
        }
	my $categoryId = $result->{'objectId'};
	$result = `/usr/sbin/oss_api.sh PUT categories/$categoryId/Room/$roomId`;
	$result = eval { decode_json($result) };
        if ($@)
        {
            die( "decode_json failed, invalid json. error:$@\n" );
        }
	print $result->{value}."\n";
	$result = `/usr/sbin/oss_api.sh PUT categories/$categoryId/Group/$groupId`;
	$result = eval { decode_json($result) };
        if ($@)
        {
            die( "decode_json failed, invalid json. error:$@\n" );
        }
	print $result->{value}."\n";
}

