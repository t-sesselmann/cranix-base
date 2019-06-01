#!/bin/bash
# Hat man massenhaft falscher Minionnamen, kann man mit diesem startscript den Namen jeder einzelnen
# Minion berichtigen. Wichtig ist das man hier "FALSCHER DOMAINNAME" "RICHTIGER DOMAINNAME" ersetzt
# und das script unter /usr/share/oss/plugins/clients/start kopiert
MINION=$1

CORMINION=${MINION/"FALSCHER DOMAINNAME"/"RICHTIGER DOMAINNAME"}

echo "$MINION $CORMINION"
if [ "$MINION" != "$CORMINION" ]; then
        echo "Rename $MINION"
        salt "$MINION" file.replace "C:\\salt\\conf\\minion" pattern="id: .*" repl="id: $CORMINION"
        salt "$MINION" system.restart 0
fi


