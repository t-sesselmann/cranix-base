#!/bin/bash

uid=$1
template=$2
if [ -z "$template" ]; then
   template=$( oss_api_text.sh GET users/byUid/$uid/role )
   template="t${template}"
fi
if [ $uid = $template ]; then
        exit
fi

HOMEDIR=$( /usr/sbin/oss_get_home.sh $uid )
TEMPLATEDIR=$( /usr/sbin/oss_get_home.sh $template )

if [ -d "$HOMEDIR" -a -d "$TEMPLATEDIR/WinDesktop" ]; then
   rsync -a ${TEMPLATEDIR}/WinDesktop/ ${HOMEDIR}/WinDesktop/
   uidNumber=$( /usr/sbin/oss_get_uidNumber $uid )
   chown -R $uidNumber ${HOMEDIR}/WinDesktop/
fi

