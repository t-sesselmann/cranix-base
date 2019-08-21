#!/usr/bin/python
#This script rewrites in RSEBS the bad named minions
import sys
import os

if len(sys.argv) < 2:
  sys.exit("Missing minion id")

id=sys.argv[1]
lid=id.split('.')

if len(lid) != 3:
   newid=id.replace('rsebs.lokal','.rsebs.lokal')
   cmd = "salt '{0}' file.replace 'C:\salt\conf\minion' pattern='id: .*' repl='id: {1}'".format(id,newid)
   print(cmd)
   os.system(cmd)
   cmd = "salt '{0}' system.reboot 0".format(id)
   print(cmd)
   os.system(cmd)
   cmd = "salt-key -y -d '{0}' ".format(id)
   print(cmd)
   os.system(cmd)

