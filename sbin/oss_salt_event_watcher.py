#!/usr/bin/python
#
# Copyright (c) 2017 Peter Varkoly <peter@varkoly.de> Nuremberg, Germany.  All rights reserved.
#
import fnmatch
import subprocess
import threading
import salt.config
import salt.utils.event

def event_handler(ret):
    if event_log_level == "debug":
       print ret
    if fnmatch.fnmatch(ret['tag'], 'salt/minion/*/start'):
       print "Client started: " + ret['data']['id']
       #Start the plugins
       subprocess.call(["/usr/share/oss/plugins/client_plugin_handler.sh","start", ret['data']['id']])
    if fnmatch.fnmatch(ret['tag'], 'salt/presence/change'):
       if event_log_level == "debug":
          #At the moment nothing to do
          print(ret['data'])

opts = salt.config.client_config('/etc/salt/master')

sevent = salt.utils.event.get_event(
        'master',
        sock_dir=opts['sock_dir'],
        transport=opts['transport'],
        opts=opts)

event_log_level="warning"
if opts.has_key('oss_event_log_level'):
   event_log_level = opts['oss_event_log_level']

while True:
    ret = sevent.get_event(full=True)
    if ret is None:
        continue

    if fnmatch.fnmatch(ret['tag'], 'salt/event/exit'):
        continue

    t = threading.Thread(target=event_handler,args=(ret,))
    t.start()


