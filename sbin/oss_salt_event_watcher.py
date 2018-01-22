#!/usr/bin/python
#
# Copyright (c) 2017 Peter Varkoly <peter@varkoly.de> Nuremberg, Germany.  All rights reserved.
#
import fnmatch
import subprocess
import os

import salt.config
import salt.utils.event

opts = salt.config.client_config('/etc/salt/master')

sevent = salt.utils.event.get_event(
        'master',
        sock_dir=opts['sock_dir'],
        transport=opts['transport'],
        opts=opts)

while True:
    ret = sevent.get_event(full=True)
    if ret is None:
        continue

    if fnmatch.fnmatch(ret['tag'], 'salt/event/exit'):
	continue

    newpid = os.fork()
    if newpid == 0:
        continue

    #TODO only for debug
    print ret
    if fnmatch.fnmatch(ret['tag'], 'salt/minion/*/start'):
       #TODO only for verbose
       print "Client started: " + ret['data']['id']
       #Start the plugins
       subprocess.call(["/usr/share/oss/plugins/client_plugin_handler.sh","start", ret['data']['id']])

    if fnmatch.fnmatch(ret['tag'], 'salt/presence/change'):
       #At the moment nothing to do
       print(ret['data'])

