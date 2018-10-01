#!/bin/bash
# Copyright (c)  Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

MINIONS=$1

rm -rf /var/adm/oss/running/
mkdir -p /var/adm/oss/running/
IFS=","
for i in ${MINIONS}
do
   touch /var/adm/oss/running/$i
done

