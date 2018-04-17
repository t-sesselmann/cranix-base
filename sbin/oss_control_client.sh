#!/bin/bash

client=$1
action=$2

/usr/bin/curl "http://$client:1992/?action=$action"

