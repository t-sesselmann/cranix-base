#!/usr/bin/python3
import json
import os
import sys
password=sys.argv[1] 

users=json.load(os.popen('crx_api.sh GET users/all'))
for user in users:
  uid       = user["uid"]
  givenname = user["givenName"]
  surname   = user["surName"]
  role      = user["role"]
  with open("/tmp/{}.ini".format(uid),'w') as f:
      f.write("uid: {}\ngivenname: {}\nsurname: {}\nrole: {}\npassword: {}\n".format(uid,givenname,surname,role,password))
# p = os.popen("/usr/share/cranix/plugins/add_user/100-add-user.sh","w")
# p.write("uid: {}\ngivenname: {}\nsurname: {}\nrole: {}\npassword: {}".format(uid,givenname,surname,role,password))
# p.close()

