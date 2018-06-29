#!/bin/bash

usage() 
{
	echo 
	echo -e "\toss_set_password_for_group_member.sh -g=<group name> -p=<password>"
	echo
	exit 
}

for i in "$@"
do
   case $i in
       -g=*|--group=*)
       GROUP="${i#*=}"
       shift # past argument=value
       ;;
       -p=*|--password=*)
       PASSWORD="${i#*=}"
       shift # past argument=value
       ;;
       -h|--help)
           usage
       ;;
       *)
   	   usage
       ;;
   esac
done

if [ -z "$GROUP" -o -z "$PASSWORD" ]; then
	usage
fi
for i in $( oss_api_text.sh GET groups/text/$GROUP/members )
do
	echo "Proceeding $i"
	samba-tool user setpassword $i --newpassword="$PASSWORD"
done

