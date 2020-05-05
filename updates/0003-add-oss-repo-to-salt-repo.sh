#!/bin/bash

if [ ! -e /srv/salt/repos.d/CRANIX.repo ]; then
	ln -s /etc/zypp/repos.d/CRANIX.repo  /srv/salt/repos.d/CRANIX.repo
fi

