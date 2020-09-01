#!/bin/bash

import=$1
if [ -d  /home/groups/SYSADMINS/userimports/${import} ]
then
        cd /home/groups/SYSADMINS/userimports/${import}
        zip userimport.zip *txt
fi
