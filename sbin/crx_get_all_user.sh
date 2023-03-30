#!/bin/bash

/usr/sbin/crx_api.sh | jq '.[] | .uid' | sed 's/"//g'

