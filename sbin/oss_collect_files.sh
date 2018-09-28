#!/bin/bash
#
# Copyright (c) 2017 Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.
#

FROM=""
TO=""
PROJECT=""
CLEANUP=""

while getopts f:t:p:c:d:h name
do
    case $name in
    f)
       FROM="$OPTARG";;
    t)
       TO="$OPTARG";;
    p)
       PROJECT="$OPTARG";;
    c)
       CLEANUP="$OPTARG";;
    d)
       SORTDIR="$OPTARG";;
    h)
       usage
       exit 0;;
    ?)
       usage
       exit 2;;
    esac
done

. /etc/sysconfig/schoolserver

IMPORT="$( oss_get_home.sh ${TO} )/Import/"
if [ $SORTDIR = "y" ]; then
    TARGET="${IMPORT}/${PROJECT}/$FROM"
else
    TARGET="${IMPORT}/${PROJECT}"
fi
mkdir -p -m 700 $TARGET

USERHOME=$( oss_get_home.sh ${FROM} )
EXPORT="${USERHOME}/Export/"

if [ ! -d $EXPORT ]; then
    echo "The export directory '$EXPORT' does not exists." 1>&2
fi

if [ "$SORTDIR" = "y" ]; then
    cp $EXPORT/* $TARGET/ 
else
    IFS=$'\n'
    for i in $EXPORT/*
    do
       j=$( basename $i )
       cp "$i" "${TARGET}/${FROM}-${j}"
    done
fi

chown -R $TO "${IMPORT}/${PROJECT}"

if [ "$CLEANUP" = 'y' ]; then
    rm -rf $EXPORT/*
    role=$( oss_api_text.sh GET users/byUid/${FROM}/role )
    if [ "${role}" != "teachers" -a "${role}" ]; then
        rm -rf ${USERHOME}/Import/*
    fi
fi
