#!/bin/bash

MINION=$1

#
# hier kommt unser code
#

TMPF=$( mktemp /tmp/saltXXXXXXXX )
echo $MINION > $TMPF
/usr/share/oss/plugins/plugin_handler.sh minion_afterState $TMPF

