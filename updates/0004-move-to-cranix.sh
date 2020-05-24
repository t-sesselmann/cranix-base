#!/bin/bash

mv /etc/sysconfig/schoolserver /etc/sysconfig/cranix
sed -i s/SCHOOL_/CRANIX_/g /etc/sysconfig/cranix
sed -i s/OSS/CRANIX/ /etc/sysconfig/cranix
#Remove old link
rm /srv/salt/repos.d/OSS.repo
#Move customized files to the right place
rsync -av /usr/share/oss/ /usr/share/cranix/
