#!/bin/bash

for ROLE in $( /usr/sbin/crx_api_text.sh GET groups/text/byType/primary )
do
        /usr/sbin/crx_api.sh GET users/uidsByRole/${ROLE}
done

