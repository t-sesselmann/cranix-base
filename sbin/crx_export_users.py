#!/usr/bin/python3
#
# Copyright (c) Peter Varkoly <peter@varkoly.de> Nuremberg, Germany.  All rights reserved.
#

import json
import time
import sys
import os

role=sys.argv[1]

users=json.load(os.popen('crx_api.sh GET users/byRole/'+role))

with open(role+".csv", 'w') as fp:
    fp.write("uid;givenName;surName;classes;birthDay\n")
    for user in users:
        fp.write("{};{};{};{};{}\n".format(user['uid'],user['givenName'],user['surName'],user['classes'],time.strftime('%Y-%m-%d', time.localtime(user['birthDay']/1000))))
