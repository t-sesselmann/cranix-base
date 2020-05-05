#!/bin/bash
# Copyright (c)  Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

MINIONS=$1

rm -rf /var/adm/cranix/running/
mkdir -p /var/adm/cranix/running/
IFS=","
for i in ${MINIONS}
do
   touch /var/adm/cranix/running/$i
done

