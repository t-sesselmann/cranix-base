#!/usr/bin/python3
#
# Copyright (c) Peter Varkoly <peter@varkoly.de> Nuremberg, Germany.  All rights reserved.
#

import json
import os
import sys
import socket


def print_cards(cards):
    for key in cards:
        print('  {0} {1}'.format(key,cards[key]))
    print("")

cached_grains=json.load(os.popen("salt-run --out=json  cache.grains '*'"))
for minion in cached_grains:
    error = False
    should_ip = "0"
    has_ip    = "1"
    #print('Checking {0}:'.format(minion))
    has_ip    = cached_grains[minion]["ipv4"][0]
    cards     = cached_grains[minion]["hwaddr_interfaces"]
    try:
        should_ip = socket.gethostbyname(minion)
    except:
        print('ERROR: fqhn {0} can not be resolved to ip. Actual ip: {1}. Actual hostname: {2}'.format(minion,has_ip,cached_grains[minion]["host"]))
        print_cards(cards)
        continue
    if has_ip != should_ip:
        print('ERROR: minion {0} has bad ip. Should be {1} is {2}:'.format(minion,should_ip,has_ip))
        print_cards(cards)
        error=True
    #if not error:
    #    print(' OK')


