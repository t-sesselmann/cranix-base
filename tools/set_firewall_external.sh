#!/bin/bash
# Copyright Dipl. Ing. Peter Varkoly <peter@varkoly.de>

SERVICES=$1
for i in $( firewall-cmd --zone=external --list-services );
do
        firewall-cmd --zone=external --remove-service=$i;
        firewall-cmd --permanent  --zone=external --remove-service=$i;
done

IFS=,

for i in $SERVICES
do
        firewall-cmd --zone=external --add-service=$i
        firewall-cmd --permanent --zone=external --add-service=$i
done
