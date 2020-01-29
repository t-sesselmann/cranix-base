#!/bin/bash

for ROLE in $( /usr/sbin/oss_api_text.sh GET groups/text/byType/primary )
do
        /usr/sbin/oss_api.sh GET users/uidsByRole/${ROLE}
done

