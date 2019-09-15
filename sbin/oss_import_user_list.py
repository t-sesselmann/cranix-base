#!/usr/bin/python3

import json
import os
import sys
import time
import shutil
import cranix
from configobj import ConfigObj
from argparse import ArgumentParser

parser = ArgumentParser()
#String parameter
parser.add_argument("--input", dest="input", default="/tmp/userlist.txt",
                    help="The import file with full path.")
parser.add_argument("--role", dest="role", default="students", choices=cranix.roles,
                    help="Role of the users to import: students|teachers|administration")
parser.add_argument("--password", dest="password", default="",
                    help="Default value for password.")
parser.add_argument("--lang", dest="lan", default="DE",
                    help="Language of the header.")
parser.add_argument("--identifier", dest="identifier", default="sn-gn-bd", choices=['sn-gn-bd', 'uid', 'uuid'],
                    help="Which attribute(s) will be used to identify an user. Normaly the sn givenName and birthday combination will be used (sn-gn-bd). Possible values are uid or uuid (uniqueidentifier).")
#Boolean parameter
parser.add_argument("--full", dest="full", default=False, action="store_true",
                    help="List is a full list. User which are not in the list will be removed.")
parser.add_argument("--test", dest="test", default=False, action="store_true",
                    help="If this parameter is true no changes will be done. The scipt only reports what would happends.")
parser.add_argument("--debug", dest="debug", default=False, action="store_true",
                    help="Run in debug mode, no daemonize.")
parser.add_argument("--mustchange", dest="mustchange", default=False, action="store_true",
                    help="If set, the new users must change its password by the first login.")
parser.add_argument("--reset_password", dest="reset_password", default=False, action="store_true",
                    help="If this option is true the password of old user will be reseted too.")
parser.add_argument("--all_classes", dest="all_classes", default=False, action="store_true",
                    help="The import list contains all classes. Classes which are not in the list will be deleted. This parameter has only affect when role=students.")
parser.add_argument("--clean_class_dirs", dest="clean_class_dirs", default=False, action="store_true",
                    help="Remove the content of the directories of the classes. This parameter has only affect when role=students.")
#Integer parameter
parser.add_argument("--sleep", dest="sleep", default=2,
                    help="The import script sleeps between creating the user objects not to catch all the resources of OSS.")

args = parser.parse_args()
# Init the import envinroment
cranix.init(args)

# Now we proceed the user list
for ident in cranix.import_list:
    #First we proceed the classes
    old_user = {}
    new_user = cranix.import_list[ident]
    new_user['role'] = args.role
    old_classes = []
    new_classes = []
    if new_user['classes'].upper() == 'ALL':
        new_classes = cranix.existing_classes
    else:
        new_classes = new_user['classes'].split(' ')
    if ident in cranix.all_users:
    # It is an old user
        old_user = cranix.all_users[ident]
        new_user['id']  = old_user['id']
        new_user['uid'] = old_user['uid']
        old_classes = old_user['classes'].split(' ')
        cranix.log_debug("Old user",old_user)
        cranix.log_msg(ident,"Old user. Old classes: " + old_user['classes'] + " New Classes:" + new_user['classes'] )
        if not args.test:
            if args.reset_password:
                password = args.password
                if password == "":
                    password = cranix.create_secure_pw
                old_user['password'] = password
                import_list[ident]['password'] = password
                old_user['mustChnage'] =  mustchange
            cranix.modify_user(old_user,ident)
    else:
        cranix.log_debug("New user",new_user)
        cranix.log_msg(ident,"New user. Classes:" + new_user['classes'])
        if not args.test:
             cranix.add_user(new_user,ident)
    #trate classes
    for cl in new_user['classes'].split(' '):
        cl = cl.upper()
        if cl not in cranix.required_classes:
            cranix.required_classes.append(cl)
        if cl not in cranix.existing_classes:
            cranix.log_msg(cl,"New class")
            if not args.test:
                cranix.add_class(cl)
    if not args.test:
        cranix.move_user(new_user['uid'],old_classes,new_classes)
    #TODO trate groups

# Now we write the user list
if args.debug:
    print('Resulted user list')
    print(cranix.import_list)
cranix.write_user_list()

if args.full and args.role == 'students':
    for ident in cranix.all_users:
        if not ident in cranix.import_list:
            cranix.log_msg(ident,"User will be deleted")
            if not args.test:
                cranix.delete_user(cranix.all_users[ident]['uid'])

if args.all_classes:
   for c in cranix.existing_classes:
       if not c in cranix.required_classes:
          cranix.log_msg(c,"Class will be deleted")
          if not args.test:
              cranix.delete_class(c)
   cranix.read_classes()

if not args.test and args.clean_class_dirs:
    for c in cranix.existing_classes:
        os.system('/usr/sbin/oss_clean_group_directory.sh "{0}"'.format(c.upper()))

cranix.close()
