#!/usr/bin/python
import fnmatch

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
       #We can have a look at starting minions
	print(ret['data'])
        do_something_with_job_return(ret['data'])
    if fnmatch.fnmatch(ret['tag'], 'salt/presence/change'):
       #We can have a look at loosing minions
	print(ret['data'])

