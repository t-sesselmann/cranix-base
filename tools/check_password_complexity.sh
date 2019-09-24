#!/bin/bash

. /etc/sysconfig/schoolserver

read pw2check
if [[ $pw2check =~ [\&§] ]]; then
	echo "User password must not contain this chracters: &§"
	exit 6
fi
if [ ${pw2check:0:0} = '-' ]; then
	echo "User password must not start with '-'"
	exit 6
fi
if [ -e "/var/lib/samba/private/sam.ldb" ]; then
	#During the installation samba is not installed.
	MINL=$( samba-tool domain passwordsettings show | grep "Minimum password length:" | sed 's/Minimum password length: //' )
	if [ $SCHOOL_MINIMAL_PASSWORD_LENGTH -ne $MINL ]; then
		samba-tool domain passwordsettings set --min-pwd-length=$SCHOOL_MINIMAL_PASSWORD_LENGTH &> /dev/null
		MINL=$SCHOOL_MINIMAL_PASSWORD_LENGTH
	fi
	if [ ${#pw2check} -lt ${MINL} ]; then
		echo "User password must contain minimum %s characters.##${MINL}"
		exit 1
	fi
else
	if [ ${#pw2check} -lt $SCHOOL_MINIMAL_PASSWORD_LENGTH ]; then
		echo "User password must contain minimum %s characters.##${SCHOOL_MINIMAL_PASSWORD_LENGTH}"
		exit 1
	fi
fi

if [ ${SCHOOL_CHECK_PASSWORD_QUALITY} = "no" ]; then
        exit 0
fi

if [ -x /usr/share/oss/tools/custom_check_password_complexity.sh ]; then
	PWCHECK=$( echo ${pw2check} | /usr/share/oss/tools/custom_check_password_complexity.sh )
	if [ "$PWCHECK" ]; then
		echo ${PWCHECK}
		exit 1
	fi
	exit 0
fi

if [ ${#pw2check} -gt $SCHOOL_MAXIMAL_PASSWORD_LENGTH ]; then
	echo "User password must not contain more then %s characters.##$SCHOOL_MAXIMAL_PASSWORD_LENGTH"
	exit 2
fi

if [[ $pw2check =~ [[:upper:]] ]]; then
	a=1
else
	echo "User password must contain uppercase characters."
	exit 3
fi
if [[ $pw2check =~ [[:lower:]] ]]; then
	a=1
else
	echo "User password must contain lowercase characters."
	exit 4
fi
if [[ $pw2check =~ [[:digit:]] ]]; then
	a=1
else
	echo "User password must contain digits."
	exit 5
fi
if [ $pw2check = ${pw2check/&/} ]; then
	a=1
else
	echo "User password must not contains '&'."
	exit 5
fi

PWCHECK=$( echo ${pw2check} | /usr/sbin/cracklib-check )
if [ $? != 0 ]; then
	echo $PWCHECK
	exit 7
fi
exit 0
