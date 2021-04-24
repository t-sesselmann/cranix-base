#!/usr/bin/python3

import configparser
import json
import os
import sys
from argparse import ArgumentParser

#Define globale variable

parser = ArgumentParser()
parser.add_argument("--id",      dest="id",      default="", help="The room id.")
parser.add_argument("--network", dest="network", default="", help="The network of the room.")
parser.add_argument("--get", dest="get", default=False, action="store_true",
                    help="Gets the actuall access in a room.")
parser.add_argument("--allow_printing",  dest="allow_printing",   default=False, action="store_true",
                    help="Allow the printing access in a room.")
parser.add_argument("--deny_printing", dest="allow_printing",  default=False, action="store_false",
                    help="Deny the printing access in a room.")
parser.add_argument("--allow_login",  dest="allow_login",   default=False, action="store_true",
                    help="Allow the login access in a room.")
parser.add_argument("--deny_login", dest="allow_login",  default=False, action="store_false",
                    help="Deny the login access in a room.")
parser.add_argument("--allow_portal",  dest="allow_portal",   default=False, action="store_true",
                    help="Allow the portal access in a room.")
parser.add_argument("--deny_portal", dest="allow_portal",  default=False, action="store_false",
                    help="Deny the portal access in a room.")
parser.add_argument("--allow_direct",  dest="allow_direct",   default=False, action="store_true",
                    help="Allow the direct internet access in a room.")
parser.add_argument("--deny_direct", dest="allow_direct",  default=False, action="store_false",
                    help="Deny the direct internet access in a room.")
parser.add_argument("--allow_proxy",  dest="allow_proxy",   default=False, action="store_true",
                    help="Allow the proxy access in a room.")
parser.add_argument("--deny_proxy", dest="allow_proxy",  default=False, action="store_false",
                    help="Deny the proxy access in a room.")
parser.set_defaults(allow=True)
args = parser.parse_args()

config = configparser.ConfigParser()
config.read('/etc/samba/smb.conf')

login_denied_rooms=[]
printing_denied_rooms=[]
network = ""
if 'hosts deny' in config['global']:
    login_denied_rooms    = config.get('global','hosts deny').split()
    #print(login_denied_rooms)
if 'hosts deny' in config['printers']:
    printing_denied_rooms = config.get('printers','hosts deny').split()
    #print(printing_denied_rooms)

if args.id != "":
    room = json.load(os.popen('/usr/sbin/crx_api.sh GET rooms/{0}'.format(args.id)))
    if 'startIP' in room:
        network='{0}/{1}'.format(room['startIP'],room['netMask'])
    else:
        print("Can not find the room with id {0}".format(args.id))
        sys.exit(-1)
elif args.network !=  "":
    network = args.network
else:
    print("You have to define a room")
    sys.exit(-1)

print(network)
# Now we can send the state if this was the question
if args.get:
    proxy  = os.popen('/usr/sbin/iptables -L -n -v | grep {0}-{1}'.format('proxy',  network)).read()
    portal = os.popen('/usr/sbin/iptables -L -n -v | grep {0}-{1}'.format('portal', network)).read()
    direct = os.popen('/usr/sbin/iptables -L -t nat -n -v | grep "MASQUERADE.*{0}"'.format(network)).read()
    actual_access = {
            'login':     network not in login_denied_rooms,
            'printing':  ( network not in printing_denied_rooms ) and ( network not in login_denied_rooms ),
            'proxy':     proxy  == "",
            'portal':    portal == "",
            'direct':    direct != ""
    }
    print(actual_access)
    sys.exit(0)

# Now we set the state
print(args.allow_printing)
print(network in printing_denied_rooms)
if args.allow_printing and network in printing_denied_rooms:
    printing_denied_rooms.remove(network)
else:
    if network not in printing_denied_rooms:
        printing_denied_rooms.append(network)

if args.allow_login and network in login_denied_rooms:
    login_denied_rooms.remove(network)
else:
    if network not in login_denied_rooms:
        login_denied_rooms.append(network)

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
