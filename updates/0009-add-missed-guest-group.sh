#!/bin/bash

export HOME="/root"

GUESTGROUP=$( echo "select * from Groups where name='guests' and groupType='primary' " | mysql CRX )
if [ -z "${GUESTGROUP}" ]
then
	crx_api.sh POST groups/add '{"name":"guests","description":"Guest Users","groupType":"primary"}'
fi
