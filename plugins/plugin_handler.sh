#!/bin/bash
# Copyright (c) 2020 Peter Varkoly <pvarkoly@cephalix.eu> Nürnberg, Germany.  All rights reserved.

. /etc/sysconfig/schoolserver
what=$1
conf=$( mktemp /tmp/cranixplugin-XXXXXXXXXX )

cat - > $conf

if test -z "$what"
then
  echo "Usage: $@ action configfile"
  exit
fi

if [ "$CRANIX_DEBUG" = "yes" ]
then
  cp $conf $conf.DEBUG
fi

if [ -d /usr/share/cranix/plugins/$what ]
then
 cd /usr/share/cranix/plugins/$what
 for i in `find -mindepth 1 -maxdepth 1 | sort`
 do
   cat $conf | /usr/share/cranix/plugins/$what/$i
   if [ "$CRANIX_DEBUG" = "yes" ]
   then
     echo "cat $conf | /usr/share/cranix/plugins/$what/$i" >> $conf.DEBUG
   fi
 done
fi 

rm $conf &> /dev/null
