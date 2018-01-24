#!/bin/bash

. /etc/sysconfig/schoolserver
REPO_USER=${SCHOOL_REG_CODE:0:9}
REPO_PASSWORD=${SCHOOL_REG_CODE:10:9}
. /etc/os-release

#Save the credentials
echo "[${SCHOOL_UPDATE_URL}/${VERSION_ID}]
username = ${REPO_USER}
password = ${REPO_PASSWORD}

[${SCHOOL_SALT_PKG_URL}]
username = ${REPO_USER}
password = ${REPO_PASSWORD}
" > /etc/zypp/credentials.cat

chmod 600 /etc/zypp/credentials.cat

#Register salt-packages repository
mkdir -p /srv/salt/repos.d/
zypper  -D /srv/salt/repos.d/  rr salt-packages &> /dev/null
echo "[salt-packages]
name=salt-packages
enabled=1
autorefresh=1
baseurl=${SCHOOL_SALT_PKG_URL}
path=/
type=rpm-md
keeppackages=0
" > /tmp/salt-packages.repo

zypper -D /srv/salt/repos.d/ ar -G /tmp/salt-packages.repo

zypper --gpg-auto-import-keys -D /srv/salt/repos.d/ ref

#Register OSS repository
zypper rr OSS &> /dev/null

echo "[OSS]
name=OSS
enabled=1
autorefresh=1
baseurl=${SCHOOL_UPDATE_URL}/$VERSION_ID
path=/
type=rpm-md
keeppackages=0
" > /tmp/oss.repo

zypper ar -G /tmp/oss.repo

zypper --gpg-auto-import-keys ref

