#!/bin/bash
#
# Copyright (c) 2016 Peter Varkoly Nürnberg, Germany.  All rights reserved.
#

. /etc/sysconfig/schoolserver

name=''
description=''
type=''
mail=''


function usage (){
	echo "Usage: oss-group-user.sh [OPTION]"
	echo "This is the oss add group script."
	echo 
	echo "Options :"
	echo "Mandatory parameters :"
	echo "		--name=<NAME>                  Group's name."
	echo "		--description=<DESCRIPTION>    Group's description."
	echo "		--type=<GROUP-TYPE>            Group type [primary|guest|class|workgroup]."
	echo "Optional parameters :"
	echo "          -h,   --help                Display the help."
	echo "                --mail=<MAIL-ADDRESS> Group's mail address."
	echo "Ex.: ./oss-add-group.sh --name='testg' --description='Test Group' --type='primary' --mail='testg@domain.com'"
	echo "Ex.: ./oss-add-group.sh --name='tesztcsop' --description='Teszt Csoport' --type='primary'"
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
	-d | --description=* )
				description=$(echo $1 | sed -e 's/--description=//g');
				if [ "$description" = '' ]
				then
					usage 0
				fi
	;;
	-t | --type=* )
				type=$(echo $1 | sed -e 's/--type=//g');
				if [ "$type" = '' ]
				then
					usage 0
				fi
        ;;
	-m | --mail=* )
                                mail=$(echo $1 | sed -e 's/--mail=//g');
                                if [ "$mail" = '' ]
                                then
                                        usage 0
                                fi
        ;;
	-g | --gid-number=* )
                                gidNumber=$(echo $1 | sed -e 's/--gid-number=//g');
                                if [ "$gidNumber" = '' ]
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

name=`echo "$name" | tr "[:lower:]" "[:upper:]"`

echo "name:        $name"
echo "description: $description"
echo "type:        $type"
echo "mail:        $mail"
#exit

params=''
if [ "$mail" ]; then
    params="--mail-address=\"$mail\""
fi
samba-tool group add "$name" --description="$description" --gid-number=$gidNumber --nis-domain=${SCHOOL_WORKSATATION} $params


#create diredtory and set permission
nameLo=`echo "$name" | tr "[:upper:]" "[:lower:]"`
gdir=${SCHOOL_HOME_BASE}/groups/${name}

mkdir -p -m 3770 $gdir
chgrp $gidNumber $gdir
setfacl -d -m g::rwx $gdir

if [ "$type" = "primary" ]; then
   mkdir -m 750 ${SCHOOL_HOME_BASE}/${nameLo}
   chgrp $gidNumber ${SCHOOL_HOME_BASE}/${nameLo}
fi
