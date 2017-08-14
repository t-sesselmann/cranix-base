#!/bin/bash

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

IMPORTS="${SCHOOL_HOME_BASE}/${TO}/Imports/"
if [ $SORTDIR = "y" ]; then
    TARGET="${IMPORTS}/${PROJECT}/$FROM"
else
    TARGET="${IMPORTS}/${PROJECT}"
fi
mkdir -p -m 700 $TARGET

EXPORTS="${SCHOOL_HOME_BASE}/${FROM}/Exports/"

if [ ! -d $EXPORTS ]; then
    echo "The export directory '$EXPORTS' does not exists." 1>&2
fi

if [ $SORTDIR = "y" ]; then
    cp $EXPORTS/* $TARGET/ 
else
    IFS=$'\n'
    for i in $EXPORTS/*
    do
       j=$( basename $i )
       cp $i "${TARGET}/${FROM}-${j}"
    done
fi

chown -R $TO ${TARGET}

if [ $CLEANUP = 'y' ]; then
    rm -rf $EXPORTS/*
fi
