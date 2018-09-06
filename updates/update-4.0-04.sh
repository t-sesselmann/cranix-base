#!/bin/bash


if [ -e "/var/adm/oss/update-4.0-04" ]
then
echo "Patch 4.0-04 already installed"
        exit 0
fi

/usr/share/oss/updates/fix-AvailablePrinters.pl
touch /var/adm/oss/update-4.0-04

