#!/bin/bash
# Copyright (c)  Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

MINIONS=$1

IFS=","
for i in ${MINIONS}
do
   rm -f /var/adm/oss/running/$i
done

