#!/bin/bash

passwd=$( /usr/bin/grep de.openschoolserver.dao.User.Register.Password= /opt/oss-java/conf/oss-api.properties | /usr/bin/sed 's/de.openschoolserver.dao.User.Register.Password=//' )
/usr/bin/samba-tool dns zonelist admin -U register%${passwd} | /usr/bin/grep pszZoneName  | /usr/bin/grep -v _msdcs. | /usr/bin/gawk  '{ print $3 }'
