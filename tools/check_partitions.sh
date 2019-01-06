#!/bin/bash

unset NEXT
echo -n "{"
for i in $( mount | gawk '/^\/dev/ { print $1 }'  )
do
	p=$( df -BM $i | tail -n1 )
	if [ "$NEXT" ]; then
		echo -n ","
	fi
	echo $p | gawk '{ printf  "\"%s\":{\"size\":%d,\"used\":%d,\"free\":%d,\"mount\":\"%s\"}", $1, $2, $3, $4, $6 }'
	NEXT=1
done
echo -n "}"

