#!/bin/bash

. /etc/sysconfig/cranix
user=$1
old=${SCHOOL_HOME_BASE}/groups/$2
new=${SCHOOL_HOME_BASE}/groups/$3
if [ -z "$user" -o -z "$old" -o -z "$new" ]; then
        echo "Usage /usr/share/cranix/tools/move_user_class_files.sh <uid> <oldclass> <newclass>"
        exit 1
fi
if [ "$2" = "$3" ]; then
        echo "Source and target must not be the same"
        exit 6
fi

id $user &> /dev/null
if [ $? != 0 ]; then
        echo "User does not exist"
        exit 2
fi
role=$( oss_api_text.sh GET users/byUid/${user}/role )
if [ "$role" != "students" ]; then
        echo "This command can be only used for students"
        exit 3
fi
if [ ! -d $old ]; then
        echo "Old class directory does not exist"
        exit 4
fi
if [ ! -d $new ]; then
        echo "New class directory does not exist"
        exit 5
fi
echo "$user $old $new"
cd $old
find -type f -user $user -exec cp -rp --parents {} $new \;
find -type f -user $user -exec rm -f {} \;
find -type d -user $user -exec rmdir {} \; &> /dev/null

