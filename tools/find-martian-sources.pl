#!/usr/bin/perl
#Jun 30 06:08:52 schooladmin kernel: [7068589.200657] martian source 192.168.0.2 from 192.168.218.45, on dev eth0
#Jun 30 06:08:52 schooladmin kernel: [7068589.200665] ll header: ff:ff:ff:ff:ff:ff:00:04:00:17:5c:2d:08:06

use strict;
my $since;
my $until;

#Parse parameter
use Getopt::Long;
my %options    = ();
my $result = GetOptions(\%options,
                        "help",
                        "description",
                        "since=s",
                        "until=s"
                );
sub usage
{
        print   'Usage: /usr/share/cranix/tools/find-martian-sources.pl [OPTION]'."\n".
                'This script find the IP and MAC-Adresses of devices which causes martian sources messages'."\n\n".
                'Options :'."\n".
                'Mandatory parameters :'."\n".
                "       No need for mandatory parameters. (There's no need for parameters for running this script.)\n".
                'Optional parameters: '."\n".
                '       -h, --help         Display this help.'."\n".
                '       -d, --description  Display the descriptiont.'."\n";
                '       -s, --since        Date from.'."\n";
                '       -u, --until        Date until.'."\n";
}
if ( defined($options{'help'}) ){
        usage(); exit 0;
}
if ( defined($options{'since'}) ){
        $since = $options{'since'};
}

if ( defined($options{'until'}) ){
        $until = $options{'until'};
}

my $martians = `journalctl -S $since -U $until | grep -P "ll header|martian source"` ;
my $found    = {};

foreach( split(/ 08 06/,$martians) )
{
   /martian source (.*) from (.*), on dev.*\n.*ff ff ff ff ff ff (.*)/m;
   $found->{$2}->{mac}    = $3;
   $found->{$2}->{serach} = $1;
}

foreach( sort keys( %$found ) )
{
    print "$_;$found->{$_}->{mac}\n";
}

