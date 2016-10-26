#!/bin/bash
#
# Copyright (c) 2016 Peter Varkoly Nürnberg, Germany.  All rights reserved.
#


name=''


function usage (){
	echo "Usage: oss-delete-group.sh [OPTION]"
	echo "This is the oss delete group script."
	echo 
	echo "Options :"
	echo "Mandatory parameters :"
	echo "		--name=<NAME>                  Group's name."
	echo "Optional parameters :"
	echo "          -h,   --help                Display the help."
	echo "                --mail=<MAIL-ADDRESS> Group's mail address."
	echo "Ex.: ./oss-delete-group.sh --name='testg'"
	exit $1
}

if [ -z "$1" ]
then
   usage 0
fi

while [ "$1" != "" ]; do
    case $1 in
	-h|-H|--help)
				usage 0
	;;
	-n | --name=* )
				name=$(echo $1 | sed -e 's/--name=//g');
				if [ "$name" = '' ]
				then
					usage 0
				fi
	;;
	\?)
                echo "UNKNOWN argument \"-$OPTARG\"." >&2
                usage 1
                ;;
        :)
                echo "Option \"-$OPTARG\" needs an argument." >&2
                usage 1
                ;;
        *)
                echo "Wrong arguments" >&2
                usage 1
                ;;
    esac
    shift
done

echo "name:        $name"

samba-tool group delete "$name"

gdir="/home/groups/$nameUP"
gdirbase="/home/$name"
gmembers=`samba-tool group listmembers "$name"`

if [ -d "$gdir" ]; then
    rm -r $gdir
fi

if [ -d "$gdirbase" ] && [ !$gmembers ]; then
    rm -r $gdirbase
fi
