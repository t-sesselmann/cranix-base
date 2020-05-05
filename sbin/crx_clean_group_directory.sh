#!/bin/bash
group=$1
CRANIX_HOME_BASE="/home"
. /etc/sysconfig/schoolserver

nameUp=`echo "$group" | tr "[:lower:]" "[:upper:]"`

gdir=${CRANIX_HOME_BASE}/groups/${nameUp}

if [ -d "${gdir}" ] ; then
	rm -rf ${gdir}
fi

mkdir -p -m 3770 $gdir
chgrp $nameUp $gdir
setfacl -d -m g::rwx $gdir

