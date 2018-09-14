#!/bin/bash

for p in $( oss_api_text.sh GET groups/text/byType/primary )
do
	if [ ${p} != "workstations" ]; then
		/usr/share/oss/tools/clean_up_userWorkstations_for_role.sh $p
	fi
done
