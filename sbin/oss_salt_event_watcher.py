#!/usr/bin/python
#
# Copyright (c) 2017 Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.
#
import fnmatch
import subprocess

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

    if fnmatch.fnmatch(ret['tag'], 'salt/minion/*/start'):
       #Start the plugins
       subprocess.call(["/usr/share/oss/plugins/client_plugin_handler.sh","start", ret['data']['id']])
    if fnmatch.fnmatch(ret['tag'], 'salt/presence/change'):
       #At the moment nothing to do
       print(ret['data'])

