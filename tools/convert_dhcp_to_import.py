#!/usr/bin/python3
#
# Copyright (c) Peter Varkoly <peter@varkoly.de> Nuremberg, Germany.  All rights reserved.
#

import sys
import os
import re

room = sys.argv[2]
name = ""
mac  = ""
ip   = ""
out = open(room + '.csv','w')
with open(sys.argv[1],'r') as file:
    out.write('room;name;mac;ip\n')
    for line in file.readlines():
        if name != "" and mac != "" and ip != "":
            out.write('{0};{1};{2};{3}\n'.format(room,name,mac,ip))
            name = mac = ip = ""
        namematch = re.search("host (\S+) ", line)
        if namematch:
            name = namematch.group(1)
            continue
        macmatch = re.search("hardware ethernet (\S+);", line)
        if macmatch:
            mac = macmatch.group(1)
            continue
        ipmatch = re.search("fixed-address (\S+);", line)
        if ipmatch:
            ip = ipmatch.group(1)
            continue

