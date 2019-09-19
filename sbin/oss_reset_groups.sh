#!/bin/bash
# Copyright (c) Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

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
        /bin/chmod    0777   /home/all
else
        /bin/chmod    0770   /home/all
	/usr/bin/setfacl -Rb                       /home/all
	/usr/bin/setfacl -Rm  m::rwx               /home/all
	/usr/bin/setfacl -Rm  g:teachers:rwx       /home/all
	/usr/bin/setfacl -Rm  g:students:rwx       /home/all
	/usr/bin/setfacl -Rm  g:administration:rwx /home/all
	/usr/bin/setfacl -Rdm m::rwx               /home/all
	/usr/bin/setfacl -Rdm g:teachers:rwx       /home/all
	/usr/bin/setfacl -Rdm g:students:rwx       /home/all
	/usr/bin/setfacl -Rdm g:administration:rwx /home/all
fi
/bin/mkdir -p   /home/software
/bin/chmod 0775 /home/software
/bin/chmod o-t /home/software /home/all

/bin/chgrp 	 templates /home/templates

if test -d /home/groups/STUDENTS
then
	/usr/bin/setfacl -b                     /home/groups/STUDENTS
	/usr/bin/setfacl -m g:teachers:rx       /home/groups/STUDENTS
	/usr/bin/setfacl -d -m g:teachers:rx    /home/groups/STUDENTS
fi

IFS=$'\n'
for cn in $( /usr/sbin/oss_api_text.sh GET groups/text/byType/class )
do
    g=$( echo $cn|tr '[:lower:]' '[:upper:]' )
    i="/home/groups/$g"
    /bin/mkdir -p  "$i"
    gid=`/usr/sbin/oss_get_gidNumber.sh "$cn"`
    if [ "$gid" ] 
    then
        chgrp -R $gid  "$i"
        /usr/bin/setfacl -P -R -b "$i"
        find "$i" -type d -exec /bin/chmod o-t,g+rwx {}  \;
        find "$i" -type d -exec /usr/bin/setfacl -d -m g::rwx {} \;
        echo "Repairing $i"
    else
   	   echo "Class $cn do not exists. Can not repair $i"
    fi
done
IFS=$'\n'
for cn in $( /usr/sbin/oss_api_text.sh GET groups/text/byType/workgroup )
do
    g=$( echo $cn|tr '[:lower:]' '[:upper:]' )
    i="/home/groups/$g"
    /bin/mkdir -p  "$i"
    gid=`/usr/sbin/oss_get_gidNumber.sh "$cn"`
    if [ "$gid" ] 
    then
        chgrp -R $gid  "$i"
        /usr/bin/setfacl -P -R -b "$i"
        find "$i" -type d -exec /bin/chmod o-t,g+rwx {}  \;
        find "$i" -type d -exec /usr/bin/setfacl -d -m g::rwx {} \;
        echo "Repairing $i"
    else
   	   echo "Class $cn do not exists. Can not repair $i"
    fi
done

#Repaire TEACHERS and SYSADMINS
setfacl -R -dm o::--- /home/groups/TEACHERS
setfacl -R -m  o::--- /home/groups/TEACHERS
chmod -R o-x /home/groups/TEACHERS

for cn in $( /usr/sbin/oss_api_text.sh GET groups/text/byType/primary )
do
    setfacl -b /home/$cn
    chmod 755  /home/$cn
done

if [ -e /usr/share/oss/tools/custom_reset_groups.sh ]; then
	/usr/share/oss/tools/custom_reset_groups.sh
fi
