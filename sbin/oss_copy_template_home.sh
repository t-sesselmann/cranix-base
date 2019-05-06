#!/bin/bash

uid=$1
template=$2

if [ -z "$template" ]; then
   template=$( oss_api_text.sh GET users/byUid/$uid/role )
   template="t${template}"
fi

HOMEDIR=$( /usr/sbin/oss_get_home.sh $uid )
TEMPLATEDIR=$( /usr/sbin/oss_get_home.sh $template )

if [ -d "$HOMEDIR" -a -d "$TEMPLATEDIR" ]; then
   rsync -a --exclude-from=/usr/share/oss/templates/exclude-from-sync-home ${TEMPLATEDIR}/ ${HOMEDIR}/
   uidNumber=$( /usr/sbin/oss_get_uidNumber $uid )
   chown -R $uidNumber ${HOMEDIR}/
fi
