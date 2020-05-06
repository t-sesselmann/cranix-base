#!/bin/bash
. /etc/sysconfig/cranix
echo -n "["
for i in ${CRANIX_MONITOR_SERVICES}
do
  if [ "${NEXT}" ]; then
    echo -n ","
  fi
  echo -n '{"service":"'$i'",'
  enabled=$(systemctl is-enabled $i 2> /dev/null )
  #if [ $? = 0 ]; then
  #  echo -n '"status":"ok",'
  #fi
  if [ "${enabled}" = "enabled" ]; then
    echo -n '"enabled":"true",'
  else
    echo -n '"enabled":"false",'
  fi
  active=$(systemctl is-active $i 2> /dev/null )
  #if [ $? = 0 ]; then
  #  echo -n '"status":"ok",'
  #fi
  if [ "${active}" = "active" ]; then
    echo -n '"active":"true"'
  else
    echo -n '"active":"false"'
  fi
  echo -n "}"
  NEXT=1
done
echo -n "]"

