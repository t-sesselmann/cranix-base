#!/bin/bash
#
# Copyright (c) 2016 Peter Varkoly Nürnberg, Germany.  All rights reserved.
#


uid=''

function usage (){
	echo "Usage: oss-delete-user.sh [OPTION]"
	echo "This is the oss delete user script."
	echo 
	echo "Options :"
	echo "Mandatory parameters :"
	echo "          --uid=<USERNAME>      Username and user's Unix/RFC2307 username."
	echo "Optional parameters :"
	echo "          -h,   --help                Display the help."
	echo "Ex.: ./oss-delete-user.sh --uid='deakzs'"
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
	-u | --uid=* )
				uid=$(echo $1 | sed -e 's/--uid=//g');
				if [ "$uid" = '' ]
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

. /etc/sysconfig/schoolserver

#winprofile="\\\\schooladmin\\profiles\\$uid"
unixprofile="/var/lib/samba/profiles/$uid"
#winhome="\\\\schooladmin\\$uid"
unixhome="/home/*/$uid"

for primaryg in $( samba-tool group listmembers primary ); do
    echo $ptimaryg
    isprimaryg=`samba-tool group listmembers $primaryg |grep $uid`
    if [ "$isprimaryg" = "$uid" ]; then
	echo $isprimary
	unixhome="/home/$primaryg/$uid"
    fi
done

echo "uid:       $uid"

# delete user
samba-tool user delete "$uid"

#delete home dir and profile dirs
if [ -d "$unixhome" ]; then
    rm -r $unixhome
fi
rm -r $unixprofile*

# delete logon script
rm /var/lib/samba/sysvol/$SCHOOL_DOMAIN/scripts/$uid.bat
