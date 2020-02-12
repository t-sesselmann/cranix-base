#!/bin/bash
DATE=$( /usr/share/oss/tools/oss_date.sh )
/usr/share/oss/tools/migrate-to-4-1.sh 2>&1 | tee /var/log/OSS-MIGRATE-TO-4-1-$DATE

