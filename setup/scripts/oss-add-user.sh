#!/bin/bash
#
# Copyright (c) 2016 Peter Varkoly Nürnberg, Germany.  All rights reserved.
#

. /etc/sysconfig/schoolserver

surname=''
givenname=''
role=''
uid=''
password=''
rpassword='no'
groups=""
uidNumber=""

function usage (){
	echo "Usage: oss-add-user.sh [OPTION]"
	echo "This is the oss add user script."
	echo 
	echo "Options :"
	echo "Mandatory parameters :"
	echo "		--surname=<SURNAME>         User's surname."
	echo "		--givenname=<GIVEN-NAME>    User's given name."
	echo "		--role=<ROLE-TYPE>          User's role type [sysadmins|students|teachers|workstations|administration|templates]."
	echo "Optional parameters :"
	echo "          -h,   --help                Display the help."
	echo "                --uid=<USERNAME>      Username and user's Unix/RFC2307 username."
	echo "                --password=<PASSORD>  Password"
	echo "                --rpassword           Generate random password."
	echo "                --groups              Groups"
	echo "Ex.: ./oss-add-user.sh --uid='deakzs' --givenname='Zsombor' --surname='Deak' --role='students' --password='Deak123' --groups='wgroup1 10A 10B'"
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
	--surname=* )
				surname=$(echo $1 | sed -e 's/--surname=//g');
				if [ "$surname" = '' ]
				then
					usage 0
				fi
	;;
	--givenname=* )
				givenname=$(echo $1 | sed -e 's/--givenname=//g');
				if [ "$givenname" = '' ]
				then
					usage 0
				fi
	;;
	--role=* )
				role=$(echo $1 | sed -e 's/--role=//g');
				if [ "$role" = '' ]
				then
					usage 0
				fi
        ;;
	--uid=* )
                                uid=$(echo $1 | sed -e 's/--uid=//g');
        ;;
	--uid-number=* )
                                uidNumber=$(echo $1 | sed -e 's/--uid-number=//g');
        ;;
	--password=* )
                                password=$(echo $1 | sed -e 's/--password=//g');
        ;;
	--rpassword )
                                rpassword="yes"
        ;;
	--groups=* )
				groups=$(echo $1 | sed -e 's/--groups=//g');
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

skel="/etc/skel"

winprofile="\\\\${SCHOOL_NETBIOSNAME}\\profiles\\$uid"
winhome="\\\\${SCHOOL_NETBIOSNAME}\\$uid"
unixhome=${SCHOOL_HOME_BASE}/$role/$uid

echo "uid:       $uid"
echo "password:  $password"
echo "surname:   $surname"
echo "givenname: $givenname"
echo "winhome:   $winhome"
echo "unixhome:  $unixhome"
echo "profile:   $profile"
echo "role:      $role"

samba-tool user create "$uid" "$password" \
				--username="$uid" \
				--uid="$uid" \
				--password="$password" \
				--surname="$surname" \
				--given-name="$givenname" \
				--home-drive="Z:" \
				--home-directory="$winhome" \
				--profile-path="$winprofile" \
				--script-path="$uid.bat" \
                                --nis-domain="${SCHOOL_WORKGROUP}" \
                                --unix-home="$unixhome" \
                                --login-shell=/bin/bash \
                                --uid-number=$uidNumber \
                                --gid-number=100 \
				--use-username-as-cn

#create home diredtory and set permission
mkdir -p $unixhome
if [ "$SCHOOL_TEACHER_OBSERV_HOME" = "yes" -a "$role" = "students" ]; then
	chown -R $uidNumber:TEACHERS $unixhome
	chmod 0770 $unixhome
else
	chown -R $uidNumber:100 $unixhome
	chmod 0700 $unixhome
fi

#Samba has to recognize the new user
sleep 3

#add user to groups
samba-tool group addmembers "$role" "$uid"

if [ "$groups" ]; then
    for g in $groups ; do
	isgroup=`samba-tool group list | grep "$g"`
	if [ "$isgroup" = "$g" ]; then
	    samba-tool group addmembers $g $uid
	else
	    echo "Not found $g group!!!"
	fi
    done
fi


# passowrd options:
#+  --must-change-at-next-login # Force password to be changed on next login
#+  --random-password           # Generate random password
