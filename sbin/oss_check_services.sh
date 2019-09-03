#!/bin/bash
# Copyright Dipl Ing Peter Varkoly <peter@varkoly.de>

. /etc/sysconfig/schoolserver

for i in ${SCHOOL_MONITOR_SERVICES}
do
   if /usr/bin/systemctl is-enabled $i &> /dev/null
   then
      if ! /usr/bin/systemctl is-active $i &> /dev/null
      then
         echo "oss_check_services.sh start $i"
         /usr/bin/systemctl start $i
      fi
   fi
done

