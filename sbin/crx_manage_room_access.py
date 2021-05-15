#!/usr/bin/python3

import configparser
import json
import os
import re
import sys
from argparse import ArgumentParser

#Parse arguments
parser = ArgumentParser()
parser.add_argument("--id",   dest="id",   default="", help="The room id.")
parser.add_argument("--all",  dest="all",  default=False, action="store_true", help="Get or set the values of all rooms.")
parser.add_argument("--get", dest="get", default=False, action="store_true",
                    help="Gets the actuall access in a room.")
parser.add_argument("--deny_printing",  dest="deny_printing",   default=False, action="store_true",
                    help="Allow the printing access in a room.")
parser.add_argument("--deny_login",  dest="deny_login",   default=False, action="store_true",
                    help="Allow the login access in a room.")
parser.add_argument("--deny_portal",  dest="deny_portal",   default=False, action="store_true",
                    help="Allow the portal access in a room.")
parser.add_argument("--deny_direct",  dest="deny_direct",   default=False, action="store_true",
                    help="Allow the direct internet access in a room.")
parser.add_argument("--let_direct",  dest="let_direct",   default=False, action="store_true",
                    help="Do not change the direct internet setting.")
parser.add_argument("--deny_proxy",  dest="deny_proxy",   default=False, action="store_true",
                    help="Allow the proxy access in a room.")
parser.add_argument("--set_defaults",  dest="set_defaults",   default=False, action="store_true",
                    help="Set the default access state in the room(s).")
parser.set_defaults(allow=True)
args = parser.parse_args()

#Global variables
args
allow_printing = not args.deny_printing
allow_login    = not args.deny_login
allow_portal   = not args.deny_portal
allow_direct   = not args.deny_direct
allow_proxy    = not args.deny_proxy
login_denied_rooms   =[]
printing_denied_rooms=[]
room    = {}
rooms   = []
zones   = {}
proxy   = os.popen('/usr/sbin/crx_api_text.sh GET system/configuration/PROXY').read()
portal  = os.popen('/usr/sbin/crx_api_text.sh GET system/configuration/MAILSERVER').read()
debug   = os.popen('/usr/sbin/crx_api_text.sh GET system/configuration/DEBUG').read() == "yes"
network = ""
name    = ""
room_id = 0

def log_debug(msg):
    global debug
    if debug:
        print(msg)

def set_state():
    global allow_printing, allow_login, allow_portal, allow_direct, allow_proxy
    global args, login_denied_rooms, printing_denied_rooms, rooms, zones
    global proxy, portal, name, network, room_id

    if args.set_defaults:
        access = json.load(os.popen('/usr/sbin/crx_api.sh GET rooms/{0}/defaultAccess'.format(args.id)))
        if 'printing' in access:
            allow_printing = access['printing']
            allow_login    = access['login']
            allow_portal   = access['portal']
            allow_proxy    = access['proxy']
            allow_direct   = access['direct']
    if allow_printing:
        allow_login = True
        if network in printing_denied_rooms:
            printing_denied_rooms.remove(network)
    elif network not in printing_denied_rooms:
            printing_denied_rooms.append(network)

    if allow_login:
        if network in login_denied_rooms:
            login_denied_rooms.remove(network)
    elif network not in login_denied_rooms:
            login_denied_rooms.append(network)

    if allow_portal and portal in zones[name]['rule']:
        os.system('/usr/bin/firewall-cmd --zone={0} --remove-rich-rule="rule family=ipv4 destination address={1} drop" &>/dev/null'.format(name,portal))
        log_debug('/usr/bin/firewall-cmd --zone={0} --remove-rich-rule="rule family=ipv4 destination address={1} drop" &>/dev/null'.format(name,portal))
    if not allow_portal and portal not in zones[name]['rule']:
        os.system('/usr/bin/firewall-cmd --zone={0} --add-rich-rule="rule family=ipv4 destination address={1} drop" &>/dev/null'.format(name,portal))
        log_debug('/usr/bin/firewall-cmd --zone={0} --add-rich-rule="rule family=ipv4 destination address={1} drop" &>/dev/null'.format(name,portal))

    if allow_proxy and proxy in zones[name]['rule']:
        os.system('/usr/bin/firewall-cmd --zone={0} --remove-rich-rule="rule family=ipv4 destination address={1} drop" &>/dev/null'.format(name,proxy))
        log_debug('/usr/bin/firewall-cmd --zone={0} --remove-rich-rule="rule family=ipv4 destination address={1} drop" &>/dev/null'.format(name,proxy))
    if not allow_proxy and proxy not in zones[name]['rule']:
        os.system('/usr/bin/firewall-cmd --zone={0} --add-rich-rule="rule family=ipv4 destination address={1} drop" &>/dev/null'.format(name,proxy))
        log_debug('/usr/bin/firewall-cmd --zone={0} --add-rich-rule="rule family=ipv4 destination address={1} drop" &>/dev/null'.format(name,proxy))

    if not args.let_direct:
        if allow_direct and zones[name]['masquerade'] == 'no':
            os.system('/usr/bin/firewall-cmd --zone={0} --add-masquerade &>/dev/null'.format(name))
            log_debug('/usr/bin/firewall-cmd --zone={0} --add-masquerade &>/dev/null'.format(name))
        if not allow_direct and  zones[name]['masquerade'] == 'yes':
            os.system('/usr/bin/firewall-cmd --zone={0} --remove-masquerade &>/dev/null'.format(name))
            log_debug('/usr/bin/firewall-cmd --zone={0} --remove-masquerade &>/dev/null'.format(name))

def get_state():
    global network, proxy, portal, name, room_id
    global login_denied_rooms, printing_denied_rooms, zones
    return {
        'accessType': 'FW',
        'roomId':    room_id,
        'roomName':  name,
        'login':     network not in login_denied_rooms,
        'printing':  ( network not in printing_denied_rooms ) and ( network not in login_denied_rooms ),
        'proxy':     proxy  not in zones[name]['rule'],
        'portal':    portal not in zones[name]['rule'],
        'direct':    zones[name]['masquerade'] == 'yes'
    }


#Start collecting datas
config = configparser.ConfigParser(delimiters=('='))
config.read('/etc/samba/smb.conf')

if 'hosts deny' in config['global']:
    login_denied_rooms    = config.get('global','hosts deny').split()
if 'hosts deny' in config['printers']:
    printing_denied_rooms = config.get('printers','hosts deny').split()

if args.id != "":
    room = json.load(os.popen('/usr/sbin/crx_api.sh GET rooms/{0}'.format(args.id)))
    name = room['name']
    room_id = args.id
    if 'startIP' in room:
        network='{0}/{1}'.format(room['startIP'],room['netMask'])
    elif room['roomControl'] == 'no':
        print("This room '{0}' can not be dynamical controlled".format(room['name']))
        sys.exit(-1)
    else:
        print("Can not find the room with id {0}".format(args.id))
        sys.exit(-2)
elif args.all:
    rooms = json.load(os.popen('/usr/sbin/crx_api.sh GET rooms/allWithControl'))
else:
    print("You have to define a room")
    sys.exit(-1)

rule = False
for line in os.popen('/usr/bin/firewall-cmd --list-all-zones').readlines():
    match1 = re.search("^(\S+)",line)
    match2 = re.search("\s+rich rules:",line)
    match3 = re.search("\s+(\S+): (\S+)",line)
    if match1:
        key = match1.group(1)
        zones[key] = {}
        rule = False
    elif match2:
        rule = True
        zones[key]['rule'] = []
    elif match3:
        zones[key][match3.group(1)] = match3.group(2)
    elif rule:
        match4 = re.search('address="([0-9\.]+)"',line)
        if match4:
            zones[key]['rule'].append(match4.group(1))

# Now we can send the state if this was the question
if args.get:
    if args.all:
        status = []
        for room in rooms:
            room_id = room['id']
            name    = room['name']
            network ='{0}/{1}'.format(room['startIP'],room['netMask'])
            status.append(get_state())
        print(json.dumps(status))
    else:
        print(json.dumps(get_state()))
else:
    if args.all:
        status = []
        for room in rooms:
            if room['roomControl'] != 'no':
                name = room['name']
                network='{0}/{1}'.format(room['startIP'],room['netMask'])
                set_state()
    else:
        set_state()

    if len(printing_denied_rooms) == 0:
        config.remove_option('printers','hosts deny')
    else:
        config.set('printers','hosts deny'," ".join(printing_denied_rooms))

    if len(login_denied_rooms) == 0:
        config.remove_option('global','hosts deny')
    else:
        config.set('global','hosts deny'," ".join(login_denied_rooms))

    with open('/etc/samba/smb.conf','wt') as f:
        config.write(f)


