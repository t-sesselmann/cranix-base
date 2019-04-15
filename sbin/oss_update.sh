DATE=$( /usr/share/oss/tools/oss_date.sh )
. /etc/profile.d/profile.sh
#Restart all processes which have deleted files
for i in $( zypper ps --print "%s" )
do
	systemctl restart $i
done

echo "/var/log/OSS-UPDATE-$DATE" > /var/adm/oss/update-started
zypper --no-gpg-checks --gpg-auto-import-keys -n up --auto-agree-with-licenses $@ 2>&1 | tee /var/log/OSS-UPDATE-$DATE

#Restart all processes which have deleted files
for i in $( zypper ps --print "%s" )
do
	systemctl restart $i
done
rm /var/adm/oss/update-started
