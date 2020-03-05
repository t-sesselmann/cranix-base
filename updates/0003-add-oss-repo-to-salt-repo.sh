#!/bin/bash

if [ ! -e /srv/salt/repos.d/OSS.repo ]; then
	ln -s /etc/zypp/repos.d/OSS.repo  /srv/salt/repos.d/OSS.repo
fi

