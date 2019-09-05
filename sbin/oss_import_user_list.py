#!/usr/bin/python3

import json
import os
import sys
import socket
import csv
import time
import cranix
from configobj import ConfigObj
from argparse import ArgumentParser
# Define some global variables
date = time.strftime("%Y-%m-%d.%H-%M-%S")
# read and set some default values
config = ConfigObj("/opt/oss-java/conf/oss-api.properties")
passwd = config['de.openschoolserver.dao.User.Register.Password']
domain = os.popen('oss_api_text.sh GET system/configuration/DOMAIN').read()
home_base = os.popen('oss_api_text.sh GET system/configuration/HOME_BASE').read()
roles  = []
for role in os.popen('oss_api_text.sh GET groups/text/byType/primary').readlines():
  roles.append(role.strip())

parser = ArgumentParser()
#String parameter
parser.add_argument("--input", dest="input", default="/tmp/userlist.txt",
                    help="The import file with full path.")
parser.add_argument("--role", dest="role", default="students", choices=roles,
                    help="Role of the users to import: students|teachers|administration")
parser.add_argument("--password", dest="password", default="",
                    help="Default value for password.")
parser.add_argument("--identifier", dest="identifier", default="sn-gn-bd", choices=['sn-gn-bd', 'uid', 'uuid'],
                    help="Which attribute(s) will be used to identify an user. Normaly the sn givenName and birthday combination will be used (sn-gn-bd). Possible values are uid or uuid (uniqueidentifier).")
#Boolean parameter
parser.add_argument("--full", dest="full", default=False, action="store_true",
                    help="List is a full list. User which are not in the list will be removed.")
parser.add_argument("--test", dest="test", default=False, action="store_true",
                    help="If this parameter is true no changes will be done. The scipt only reports what would happends.")
parser.add_argument("--debug", dest="debug", default=False, action="store_true",
                    help="Run in debug mode, no daemonize.")
parser.add_argument("--mustchange", dest="debug", default=False, action="store_true",
                    help="If set, the new users must change its password by the first login.")
parser.add_argument("--reset_password", dest="reset_password", default=False, action="store_true",
                    help="If this option is true the password of old user will be reseted too.")
parser.add_argument("--all_classes", dest="all_classes", default=False, action="store_true",
                    help="The import list contains all classes. Classes which are not in the list will be deleted. This parameter has only affect when role=students.")
parser.add_argument("--clean_class_dirs", dest="clean_class_dirs", default=False, action="store_true",
                    help="Remove the content of the directories of the classes. This parameter has only affect when role=students.")
#Integer parameter
parser.add_argument("--slee", dest="sleep", default=2,
                    help="The import script sleeps between creating the user objects not to catch all the resources of OSS.")

args = parser.parse_args()

# Now we read the available groups classes and users
all_classes = []
all_groups  = []
all_users   = {}
for group in os.popen('/usr/sbin/oss_api_text.sh GET groups/text/byType/class').readlines():
  all_classes.append(group.strip())
for group in os.popen('/usr/sbin/oss_api_text.sh GET groups/text/byType/workgroups').readlines():
  all_groups.append(group.strip())
for user in json.load(os.popen('/usr/sbin/oss_api.sh GET users/byRole/' + args.role )):
  identifier = ""
  birthDay = time.strftime("%Y-%m-%d",time.localtime(user['birthDay']/1000))
  if args.identifier == "sn-gn-bd":
     identifier = user['surName'].upper() + '-' + user['givenName'].upper() + '-' + birthDay
  else:
      identifier = user[args.identifier]
  all_users[identifier]={}
  for key in user:
    all_users[identifier][key] = user[key]
if args.debug:
  print(all_users)

# Start reading the file
with open(args.input) as csvfile:
    #Detect the type of the csv file
    dialect = csv.Sniffer().sniff(csvfile.read(1024))
    csvfile.seek(0)
    #Create an array of dicts from it
    csv.register_dialect('oss',dialect)
    reader = csv.DictReader(csvfile,dialect='oss')
    print(reader.fieldnames)
    for row in reader:
      user = {}
      for key in row:
        print(cranix.attr_ext_name[key] + " " + row[key])
