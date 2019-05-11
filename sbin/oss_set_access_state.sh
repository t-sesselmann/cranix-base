#!/bin/bash
#
# Copyright (c) 2012 Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.
# Copyright (c) 2005 Peter Varkoly Fuerth, Germany.  All rights reserved.
# Copyright (c) 2002 SuSE Linux AG Nuernberg, Germany.  All rights reserved.
#
#

usage()
{
        echo 
        echo -e "\toss_set_access_state.sh -r=<room name> -a=true|false -s=direct|login|print|proxy|portal [ -t=<Timeout in minutes> -e=<your ip> ]"
        echo
        exit
}
for i in "$@"
do
   case $i in
       -a=*|--access=*)
       ACCESS="${i#*=}"
       shift
       ;;
       -r=*|--room=*)
       ROOM="${i#*=}"
       shift
       ;;
       -s=*|--service=*)
       SERVICE="${i#*=}"
       shift
       ;;
       -e=*|--except=*)
       EXCEPT="${i#*=}"
       shift
       ;;
       -t=*|--timeout=*)
       TIME="--timeout=${i#*=}"
       shift
       ;;
       -h|--help)
           usage
       ;;
       *)
           usage
       ;;
   esac
done

if [ -z "$ACCESS" -o -z "$ROOM" -o -z "$SERVICE" ]; then
	usage
fi

CMD="--add-rich-rule"
if [ "$ACCESS" = "true" ]; then
	CMD="--remove-rich-rule"
fi
. /etc/sysconfig/schoolserver 

case "$SERVICE" in
   direct)
	if test "$SCHOOL_ISGATE" = "no"; then
                echo -n '1'
                exit 0
	fi
	if [ "$ACCESS" = "true" ]; then
		/usr/bin/firewall-cmd --zone=$ROOM --add-masquerade $TIME &> /dev/null
	else
		/usr/bin/firewall-cmd --zone=$ROOM --remove-masquerade &> /dev/null
	fi
        echo -n '0'
	exit
	;;
   login)
	/usr/bin/firewall-cmd --zone=$ROOM $CMD="rule family=ipv4 destination address=$SCHOOL_SERVER service name=samba drop" $TIME  &> /dev/null
        echo -n '0'
        exit 0
	;;
   proxy|internet)
        if [ "SCHOOL_USE_TFK" = "yes" ]; then
                echo -n '1'
                exit 0
        fi
	export DEST=$SCHOOL_PROXY
	;;
   printing)
	export DEST=$SCHOOL_PRINTSERVER
	;;
   portal)
	export DEST=$SCHOOL_MAILSERVER
	;;
esac

/usr/bin/firewall-cmd --zone=$ROOM $CMD="rule family=ipv4 destination address=$DEST drop" $TIME &> /dev/null
echo -n '0'
