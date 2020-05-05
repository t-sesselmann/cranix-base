#!/bin/bash

df | grep '^/dev/' | gawk '{ print $6" "$3/1000000" "$4/1000000}'

