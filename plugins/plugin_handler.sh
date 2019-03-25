#!/bin/bash
# Copyright (c) 2012-2017 Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

. /etc/sysconfig/schoolserver
what=$1
conf=$( mktemp /tmp/ossplugin-XXXXXXXXXX )

while read a
do
    echo $a >> $conf
done

if test -z "$what"
then
  echo "Usage: $@ action configfile"
  exit
fi

if [ "$SCHOOL_DEBUG" = "yes" ]
then
  cp $conf $conf.DEBUG
fi

if [ -d /usr/share/oss/plugins/$what ]
then
 cd /usr/share/oss/plugins/$what
 for i in `find -mindepth 1 -maxdepth 1 | sort` 
 do
   cat $conf | /usr/share/oss/plugins/$what/$i
   if [ "$SCHOOL_DEBUG" = "yes" ]
   then
     echo "cat $conf | /usr/share/oss/plugins/$what/$i" >> $conf.DEBUG
   fi
 done
fi 

rm $conf &> /dev/null
