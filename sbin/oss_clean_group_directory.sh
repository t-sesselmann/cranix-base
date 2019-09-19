#!/bin/bash
group=$1
SCHOOL_HOME_BASE="/home"
. /etc/sysconfig/schoolserver

nameUp=`echo "$group" | tr "[:lower:]" "[:upper:]"`

gdir=${SCHOOL_HOME_BASE}/groups/${nameUp}

if [ -d "${gdir}" ] ; then
	rm -rf ${gdir}
fi

mkdir -p -m 0770 $gdir
chgrp $nameUp $gdir
setfacl -d -m g::rwx $gdir

