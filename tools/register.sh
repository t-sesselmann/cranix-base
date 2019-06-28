#!/bin/bash

. /etc/sysconfig/schoolserver
REPO_USER=${SCHOOL_REG_CODE:0:9}
REPO_PASSWORD=${SCHOOL_REG_CODE:10:9}
. /etc/os-release

if [ -z "${REPO_USER}" -o -z "${REPO_PASSWORD}" ]; then
	echo "Invalid regcode."
	exit 1
fi

VALID=$( curl -X GET https://repo.cephalix.eu/api/customers/regcodes/${SCHOOL_REG_CODE} )
if [  $? > 0 -o ]; then
        echo "Can not register."
        exit 1
fi
if [  "${VALID}" = "0" ]; then
        echo "Regcode is not valid."
        exit 2
fi
zypper rr ${NAME}-4.0-0
zypper rr ${NAME}-4.0-1
zypper rr ${NAME}-4.0.1-0
#Save the credentials
echo "[${SCHOOL_UPDATE_URL}/${NAME}/${VERSION_ID}]
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

#Register ${NAME} repository
zypper rr ${NAME} &> /dev/null

echo "[${NAME}]
name=${NAME}
enabled=1
autorefresh=1
baseurl=${SCHOOL_UPDATE_URL}/${NAME}/$VERSION_ID
path=/
type=rpm-md
keeppackages=0
" > /tmp/oss.repo

zypper ar -G /tmp/oss.repo

zypper --gpg-auto-import-keys ref

