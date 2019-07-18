#!/usr/bin/python3
#
# Copyright (c) Peter Varkoly <peter@varkoly.de> Nuremberg, Germany.  All rights reserved.
#

import json
import os

rooms=json.load(os.popen('oss_api.sh GET rooms/all'))
for room in rooms:
    #print room
    f = os.popen("/usr/share/oss/plugins/add_room/100-add-firewalld.sh","w")
    f.write("name: "+ room["name"] + "\n")
    f.write("startip: "+ room["startIP"] + "\n")
    f.write("netmask: %i\n" % room["netMask"] )
    f.close

#SCHOOL_NET
network=os.popen('oss_api_text.sh GET system/configuration/NETWORK').read()
netmask=os.popen('oss_api_text.sh GET system/configuration/NETMASK').read()
f = os.popen("/usr/share/oss/plugins/add_room/100-add-firewalld.sh","w")
f.write("name: SCHOOL_NET\n")
f.write("startip: "+ network + "\n")
f.write("netmask: "+ netmask + "\n")
f.close

#ANON_DHCP
anon=os.popen('oss_api_text.sh GET system/configuration/ANON_DHCP_NET').read().split("/")
f = os.popen("/usr/share/oss/plugins/add_room/100-add-firewalld.sh","w")
f.write("name: SCHOOL_NET\n")
f.write("startip: "+ anon[0] + "\n")
f.write("netmask: "+ anon[1] + "\n")
f.close

