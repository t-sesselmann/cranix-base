#!/bin/bash

df | grep '^/dev/' | gawk '{ print "{\"fs "$6"\":[{\"name\":\"used\",\"count\":"$3/1000000"},{\"name\":\"free\",\"count\":"$4/1000000"}]}"}'

