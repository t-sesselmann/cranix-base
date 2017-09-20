#!/bin/bash

. /etc/sysconfig/schoolserver
REPO_USER=${SCHOOL_REG_CODE:0:9}
REPO_PASSWORD=${SCHOOL_REG_CODE:10:9}
. /etc/os-release

mkdir -p /srv/salt/repos.d/
zypper  -D /srv/salt/repos.d/  rr 1 2 3 4 5 6 7 8 9 10 &> /dev/null
echo "[salt-packages]
name=salt-packages
enabled=1
autorefresh=1
baseurl=http://$REPO_USER:$REPO_PASSWORD@repo.cephalix.eu/salt-packages
path=/
type=rpm-md
keeppackages=0
" > /tmp/salt-packages.repo

zypper -D /srv/salt/repos.d/ ar /tmp/salt-packages.repo

zypper rr 1 2 3 4 5 6 7 8 9 10 &> /dev/null

echo "[OSS]
name=OSS
enabled=1
autorefresh=1
baseurl=http://$REPO_USER:$REPO_PASSWORD@repo.cephalix.eu/OSS/$VERSION_ID
path=/
type=rpm-md
keeppackages=0
" > /tmp/oss.repo

zypper ar /tmp/oss.repo

