#!/bin/bash

U=$1

if [ -z "${U}" ]; then
        echo "User name is mandatory."
        exit 1
fi      

for i in  $( find /home/profiles/${U}.V? -iname ntuser.man )
do    
        b=$( echo $i | sed 's/ntuser.man/NTUSER.DAT/i' )
        mv $i $b
done

