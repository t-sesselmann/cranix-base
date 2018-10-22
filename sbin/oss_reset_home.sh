#!/bin/bash
# Copyright (c) 2012 Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

arg=$1

if [ "$arg" = "--help" -o  "$arg" = "-h" ]
then
	echo 'Usage: /usr/share/oss/tools/reset_home.sh [OPTION]'
	echo 'Resets directories in /home.'
	echo
	echo 'Options :'
	echo 'Mandatory parameters :'
	echo "		No need for mandatory parameters. (There's no need for parameters for running this script.)"
	echo 'Optional parameters :'
	echo '		-h,   --help         Display this help.'
	echo '		-d,   --description  Display the descriptiont.'
	echo '		-a,   --all          Resets all directories in /home recursively including profiles and home directories of the users.'
	exit
fi

if [ "$arg" = "--description" -o  "$arg" = "-d" ]
then
	echo 'NAME:'
	echo '	reset_home.sh'
	echo 'DESCRIPTION:'
	echo '	Resets directories in /home.'
	echo 'PARAMETERS:'
	echo '	MANDATORY:'
	echo "		                    : No need for mandatory parameters. (There's no need for parameters for running this script.)"
	echo '	OPTIONAL:'
	echo '		-h,   --help        : Display this help.(type=boolean)'
	echo '		-d,   --description : Display the descriptiont.(type=boolean)'
	echo '		-a,   --all         : Resets all directories in /home recursively including profiles and home directories of the users.(type=boolean)'
	exit
fi

. /etc/sysconfig/schoolserver

/bin/chown root /home/*

/bin/mkdir -p  /home/groups
/bin/chmod 755 /home/groups
/bin/mkdir -p  /home/profiles
setfacl -b     /home/profiles
/bin/chmod 1770 /home/profiles
/bin/chgrp 100  /home/profiles
/bin/mkdir -p  /home/templates
/bin/chmod 750 /home/templates
/bin/mkdir -p  /home/all
if [ "$SCHOOL_TYPE" = "cephalix" -o "$SCHOOL_TYPE" = "business" -o $SCHOOL_TYPE = 'primary' ]
then
        /bin/chmod    1777   /home/all
else
        /bin/chmod    1770   /home/all
fi
/bin/mkdir -p   /home/software
/bin/chmod 1775 /home/software
/bin/mkdir -p   /home/students
/bin/chmod 751  /home/students
/bin/mkdir -p   /home/teachers
/bin/chmod 751  /home/teachers
/bin/mkdir -p   /home/administration
/bin/chmod 750  /home/workstations

/bin/chgrp 	 templates /home/templates
/usr/bin/setfacl -b                      /home/all
/usr/bin/setfacl -m m::rwx               /home/all
/usr/bin/setfacl -m g:teachers:rwx       /home/all
/usr/bin/setfacl -m g:students:rwx       /home/all
/usr/bin/setfacl -m g:administration:rwx /home/all
/bin/chgrp teachers                      /home/software
/usr/bin/setfacl -b                      /home/software
/usr/bin/setfacl -m g:students:rx        /home/software
/usr/bin/setfacl -m g:administration:rx  /home/software
/bin/chgrp          students             /home/students
/bin/chgrp          teachers             /home/teachers
/bin/chgrp          administration       /home/administration
/bin/chgrp          workstations         /home/workstations
/usr/bin/setfacl -b                      /home/workstations
/usr/bin/setfacl -m g:teachers:rx        /home/workstations

if test -d /home/groups/STUDENTS
then
	/usr/bin/setfacl -b                     /home/groups/STUDENTS
	/usr/bin/setfacl -m g:teachers:rx       /home/groups/STUDENTS
	/usr/bin/setfacl -d -m g:teachers:rx    /home/groups/STUDENTS
fi

if [ "$arg" = "-a" -o  "$arg" = "--all" ]
then
    for cn in $( oss_api_text.sh GET groups/text/byType/class )
    do
        g=$( echo $cn|tr '[:lower:]' '[:upper:]' )
        i=/home/groups/$g
        /bin/mkdir -p  $i
        gid=`/usr/sbin/oss_get_gidNumber.sh $cn`
        if [ "$gid" ] 
        then
            chgrp -R $gid  $i
            /usr/bin/setfacl -P -R -b $i
            /bin/chmod -R 3771 $i
            /usr/bin/setfacl -d -m g::rwx $i
            /usr/bin/setfacl -P -R -m g::rwx $i
            echo "Repairing $i"
        else
       	   echo "Class $cn do not exists. Can not repair $i"
        fi
    done
    for cn in $( oss_api_text.sh GET groups/text/byType/workgroup )
    do
        g=$( echo $cn|tr '[:lower:]' '[:upper:]' )
        i=/home/groups/$g
        /bin/mkdir -p  $i
        gid=`/usr/sbin/oss_get_gidNumber.sh $cn`
        if [ "$gid" ] 
        then
            chgrp -R $gid  $i
            /usr/bin/setfacl -P -R -b $i
            /bin/chmod -R 3771 $i
            /usr/bin/setfacl -d -m g::rwx $i
            /usr/bin/setfacl -P -R -m g::rwx $i
            echo "Repairing $i"
        else
       	   echo "Class $cn do not exists. Can not repair $i"
        fi
    done

    #Repaire TEACHERS and SYSADMINS
    /bin/chmod -R 3770 $i
    setfacl -R -dm o::--- /home/groups/TEACHERS
    setfacl -R -m  o::--- /home/groups/TEACHERS
    chmod -R o-x /home/groups/TEACHERS

    for cn in $( oss_api_text.sh GET groups/text/byType/primary )
    do
        for uid in $( oss_api.sh GET users/uidsByRole/$cn )
	do
	    i=$( /usr/sbin/oss_get_home.sh $uid)
	    /bin/mkdir -p $i
	    /bin/chmod -R 711 $i
	    /bin/chown -R $uid  $i
	    echo "Repairing $i"
	done
    done

fi
