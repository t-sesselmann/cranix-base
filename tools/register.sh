#!/bin/bash

. /etc/sysconfig/schoolserver
REPO_USER=${SCHOOL_REG_CODE:0:9}
REPO_PASSWORD=${SCHOOL_REG_CODE:10:9}
. /etc/os-release

#Register salt-packages repository
mkdir -p /srv/salt/repos.d/
zypper  -D /srv/salt/repos.d/  rr 1 2 3 4 5 6 7 8 9 10 &> /dev/null
echo "[salt-packages]
name=salt-packages
enabled=1
autorefresh=1
baseurl=http://$REPO_USER:$REPO_PASSWORD@repo.cephalix.eu/${SALT_TESTING}salt-packages
path=/
type=rpm-md
keeppackages=0
" > /tmp/salt-packages.repo

zypper -D /srv/salt/repos.d/ ar /tmp/salt-packages.repo

zypper --gpg-auto-import-keys -D /srv/salt/repos.d/ ref

#Register OSS repository
zypper rr 1 2 3 4 5 6 7 8 9 10 &> /dev/null

echo "[OSS]
name=OSS
enabled=1
autorefresh=1
baseurl=http://$REPO_USER:$REPO_PASSWORD@repo.cephalix.eu/${OSS_TESTING}OSS/$VERSION_ID
path=/
type=rpm-md
keeppackages=0
" > /tmp/oss.repo

zypper ar /tmp/oss.repo

zypper --gpg-auto-import-keys ref

echo "[http://repo.cephalix.eu/${OSS_TESTING}OSS/${VERSION_ID}]
username = ${REPO_USER}
password = ${REPO_PASSWORD}

[http://repo.cephalix.eu/${SALT_TESTING}salt-packages]
username = ${REPO_USER}
password = ${REPO_PASSWORD}
" > /etc/zypp/credentials.cat

chmod 600 /etc/zypp/credentials.cat
