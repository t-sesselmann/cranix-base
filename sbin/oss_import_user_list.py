#!/usr/bin/python3

import json
import os
import sys
import socket
import unicodecsv
from configobj import ConfigObj
from argparse import ArgumentParser

# read and set some default values
config = ConfigObj("/opt/oss-java/conf/oss-api.properties")
passwd = config['de.openschoolserver.dao.User.Register.Password']
domain = os.popen('oss_api_text.sh GET system/configuration/DOMAIN').read()
roles  = os.popen('oss_api_text.sh GET groups/text/byType/primary').readlines()


parser = ArgumentParser()
#String parameter
parser.add_argument("-i", "--input", dest="input", default="/tmp/userlist.txt",
                    help="The import file with full path.")
parser.add_argument("-r", "--role", dest="role", default="students", choices=roles,
                    help="Role of the users to import: students|teachers|administration")
parser.add_argument("-p", "--password", dest="password", default="",
                    help="Default value for password.")
parser.add_argument("--identifier", dest="identifier", default="sn-gn-bd", choices=['sn-gn-bd', 'uid', 'uuid'],
                    help="Which attribute(s) will be used to identify an user. Normaly the sn givenName and birthday combination will be used (sn-gn-bd). Possible values are uid or uuid (uniqueidentifier).")
#Boolean parameter
parser.add_argument("-f", "--full", dest="full", default=False, action="store_true",
                    help="List is a full list. User which are not in the list will be removed.")
parser.add_argument("-t", "--test", dest="test", default=False, action="store_true",
                    help="If this parameter is true no changes will be done. The scipt only reports what would happends.")
parser.add_argument("-d", "--debug", dest="debug", default=False, action="store_true",
                    help="Run in debug mode, no daemonize.")
parser.add_argument("-m", "--mustchange", dest="debug", default=False, action="store_true",
                    help="If set, the new users must change its password by the first login.")
parser.add_argument("--reset_password", dest="reset_password", default=False, action="store_true",
                    help="If this option is true the password of old user will be reseted too.")
parser.add_argument("-a", "--all_classes", dest="all_classes", default=False, action="store_true",
                    help="The import list contains all classes. Classes which are not in the list will be deleted. This parameter has only affect when role=students.")
parser.add_argument("-c", "--clean_class_dirs", dest="clean_class_dirs", default=False, action="store_true",
                    help="Remove the content of the directories of the classes. This parameter has only affect when role=students.")
#Integer parameter
parser.add_argument("-s", "--slee", dest="sleep", default=2,
                    help="The import script sleeps between creating the user objects not to catch all the resources of OSS.")

args = parser.parse_args()
print(args)
print(args.debug)

# Start reading the file
with open(args.input) as csvfile:
    #Detect the type of the csv file
    dialect = unicodecsv.Sniffer().sniff(csvfile.read(1024))
    csvfile.seek(0)
    #Create an array of dicts from it
    unicodecsv.register_dialect('oss',dialect)
    reader = unicodecsv.DictReader(csvfile,dialect='oss')
    for row in reader:


