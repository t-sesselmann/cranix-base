#!/bin/bash -x
#
# Copyright (c) 2016 Peter Varkoly Nürnberg, Germany.  All rights reserved.
#

# other global variable
sysconfig="/etc/sysconfig/schoolserver"
logdate=`date "+%y.%m.%d.%H-%M-%S"`
logfile="/var/log/oss-setup.$logdate.log"
passwd=""
windomain=""

# input variable
passwdf=""
all="no"
samba="no"
dhcp="no"
#mail="no"
proxy="no"
postsetup="no"
accounts="no"
verbose="no"


function usage (){
	echo "Usage: oss-setup.sh --passwdf=/tmp/oss_pswd [OPTION]"
	echo "This is the oss setup script."
	echo 
	echo "Options :"
	echo "Mandatory parameters :"
	echo "		--passwdf=<PASSWORDFILE>  Path to the file containing the osspassword."
	echo "Optional parameters :"
	echo "          -h,   --help              Display the help."
	echo "                --all               Setup all services and create the initial groups and user accounts."
	echo "                --samba             Setup the AD-DC samba server."
	echo "                --dhcp              Setup the DHCP server"
	echo "                --mail              Setup the mail server"
	echo "                --proxy             Setup the proxy server"
	echo "                --accounts          Create the initial groups and user accounts"
	echo "                --postsetup         Make additional setups."
	echo "                --verbose           Verbose"
	echo "Ex.: ./oss-setup.sh --passwdf=/tmp/oss_passwd --all"
	exit $1
}

function log() {
    LOG_DATE=`date "+%b %d %H:%M:%S"`
    HOST=`hostname`
    echo "$LOG_DATE $HOST oss-setup: $1" >> "$logfile"
    if [ "$verbose" = "yes" ]; then
	echo "$1"
    fi
}

function InitGlobalVariable (){
    ########################################################################
    log "Setup ntp"
    mv /etc/ntp.conf /etc/ntp.conf.backup
    cp /usr/share/oss/setup/templates/ntp.conf /etc/ntp.conf
    systemctl start ntpd
    systemctl enable ntpd
    log "Start InitGlobalVariable"

    ########################################################################
    log " - Read sysconfig file"
    . $sysconfig

    ########################################################################
    if [ "$passwdf" ]; then
        log " - Read password file"
        passwd=`cat $passwdf`
        log "   passwd = $passwd"
    fi

    ########################################################################
    log " - Set windomain variable"
    windomain=`echo "$SCHOOL_DOMAIN" | awk -F"." '{print $1 }' | tr "[:lower:]" "[:upper:]"`
    log "   windomain = $windomain"
    sed -i s/^SCHOOL_WORKGROUP=.*/SCHOOL_WORKGROUP=\"$windomain\"/ $sysconfig

    log "End InitGlobalVariable"
}

function SetupSamba (){
    log "Start SetupSamba"

    ########################################################################
    log " - Disable AppArmor on smbd, nmbd, winbindd if exists"
    if [ -f "/etc/apparmor.d/usr.sbin.smbd" ] && [ -f "/etc/apparmor.d/usr.sbin.nmbd" ] && [ -f "/etc/apparmor.d/usr.sbin.winbindd" ]; then
	log " - Disable AppArmor on smbd, nmbd, winbindd"
	mv /etc/apparmor.d/usr.sbin.smbd     /etc/apparmor.d/disable/
	mv /etc/apparmor.d/usr.sbin.nmbd     /etc/apparmor.d/disable/
	mv /etc/apparmor.d/usr.sbin.winbindd /etc/apparmor.d/disable/
	systemctl restart apparmor.service
    fi

    ########################################################################
    log " - Remove old samba config"
    cp -r /etc/samba/ /etc/samba-backup-$logdate
    rm -r /etc/samba/*

    #######################################################################
    log " - Turn off not used network devices."
    . /etc/sysconfig/SuSEfirewall2
    if [ "$FW_DEV_EXT" ]; then
       ifdown $FW_DEV_EXT
    fi
    ifconfig "$FW_DEV_INT:mail" down
    ifconfig "$FW_DEV_INT:print" down
    ifconfig "$FW_DEV_INT:proxy" down

    ########################################################################
    log " - Install domain provision"
    samba-tool domain provision --realm="$SCHOOL_DOMAIN" --domain="$windomain" --adminpass="$passwd" --server-role=dc --ldapadminpass="$passwd" --use-rfc2307 --use-xattrs=yes --host-ip="$SCHOOL_SERVER"

    ########################################################################
    log " - Setup smb.conf file"
    sed    "s/#NETBIOSNAME#/admin/g"             /usr/share/oss/setup/templates/samba-smb.conf.ini > /etc/samba/smb.conf 
    sed -i "s/#REALM#/$SCHOOL_DOMAIN/g"          /etc/samba/smb.conf
    sed -i "s/#WORKGROUP#/$windomain/g"          /etc/samba/smb.conf
    sed -i "s/#GATEWAY#/$SCHOOL_SERVER_EXT_GW/g" /etc/samba/smb.conf
    sed -i "s/#IPADDR#/$SCHOOL_SERVER/g"          /etc/samba/smb.conf
    sed -i "s#HOMEBASE#$SCHOOL_HOME_BASE#g"      /etc/samba/smb.conf

    ########################################################################
    log " - Config resolv.conf"
    sed -i "s/nameserver .*/nameserver $SCHOOL_SERVER/" /etc/resolv.conf

    ########################################################################
    log " - Start samba service"
    systemctl enable samba.service
    systemctl restart samba.service

    ########################################################################
    log " - Setup samba private krbconf to kerberos conf"
    mv /etc/krb5.conf /etc/krb5.conf.$logdate
    cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

    ########################################################################
    log " - Tell nsswitch to use winbind."
    cp /usr/share/oss/setup/templates/nsswitch.conf /etc/nsswitch.conf

    ########################################################################
    log " - Use our enhanced samba.service file."
    cp /usr/share/oss/setup/templates/samba.service /usr/lib/systemd/system/samba.service

    ########################################################################
    log " - Create linked groups directory "
    mkdir -p -m 755 $SCHOOL_HOME_BASE/groups/LINKED/

    ########################################################################
    log " - Create dns entries "
    samba-tool dns add localhost $SCHOOL_DOMAIN mailserver   A $SCHOOL_MAILSERVER    -U Administrator%"$passwd"
    samba-tool dns add localhost $SCHOOL_DOMAIN schoolserver A $SCHOOL_MAILSERVER    -U Administrator%"$passwd"
    samba-tool dns add localhost $SCHOOL_DOMAIN proxy        A $SCHOOL_PROXY         -U Administrator%"$passwd"
    samba-tool dns add localhost $SCHOOL_DOMAIN printserver  A $SCHOOL_PRINTSERVER   -U Administrator%"$passwd"
    samba-tool dns add localhost $SCHOOL_DOMAIN backup       A $SCHOOL_BACKUP_SERVER -U Administrator%"$passwd"

    ########################################################################
    log " - Setup printserver "
    cp /usr/share/oss/setup/templates/samba-printserver.service /usr/lib/systemd/system/samba-printserver.service
    cp /usr/share/oss/setup/templates/samba-printserver /etc/sysconfig/
    mkdir -p /var/lib/samba/printserver/private
    mkdir -p /var/log/samba/printserver/
    sed    "s/#REALM#/$SCHOOL_DOMAIN/g"          /usr/share/oss/setup/templates/samba-printserver.conf.ini > /etc/samba/smb-printserver.conf
    sed -i "s/#WORKGROUP#/$windomain/g"          /etc/samba/smb-printserver.conf
    sed -i "s/#IPADDR#/$SCHOOL_PRINTSERVER/g"    /etc/samba/smb-printserver.conf
    net ADS JOIN -s /etc/samba/smb-printserver.conf -U Administrator%"$passwd"
    systemctl enable samba-printserver
    systemctl start  samba-printserver
    
    log "End SetupSamba"
}

function SetupDHCP (){
    log "Start SetupDHCP"
    sed    "s/#SCHOOL_SERVER#/${SCHOOL_SERVER}/g"                   /usr/share/oss/setup/templates/dhcpd.conf.ini > /usr/share/oss/templates/dhcpd.conf 
    sed -i "s/#SCHOOL_PRINTSERVER#/${SCHOOL_PRINTSERVER}/g"         /usr/share/oss/templates/dhcpd.conf
    sed -i "s/#SCHOOL_DOMAIN#/${SCHOOL_DOMAIN}/g"                   /usr/share/oss/templates/dhcpd.conf
    sed -i "s/#SCHOOL_ANON_DHCP_RANGE#/${SCHOOL_ANON_DHCP_RANGE}/g" /usr/share/oss/templates/dhcpd.conf
    sed -i "s/#SCHOOL_NETWORK#/${SCHOOL_NETWORK}/g"                 /usr/share/oss/templates/dhcpd.conf
    sed -i "s/#SCHOOL_NETMASK#/${SCHOOL_NETMASK_STRING}/g"          /usr/share/oss/templates/dhcpd.conf
    cp /usr/share/oss/templates/dhcpd.conf /etc/dhcpd.conf
    sed -i 's/^DHCPD_INTERFACE=.*/DHCPD_INTERFACE="ANY"/'	    /etc/sysconfig/dhcpd
    systemctl enable dhcpd
    systemctl start  dhcpd
    log "End SetupDHCP"
}

function SetupMail (){
    log "Start SetupMail"
    log "End SetupMail"
}

function SetupProxy (){
    log "Start SetupProxy"
    log "End SetupProxy"
}


function SetupInitialAccounts (){
    log "Start SetupInitialAccounts"

    ########################################################################
    log " - Create base directory"
    mkdir -m 770 -p $SCHOOL_HOME_BASE/all
    mkdir -m 755 -p $SCHOOL_HOME_BASE/archiv
    mkdir -m 755 -p $SCHOOL_HOME_BASE/groups
    mkdir -m 775 -p $SCHOOL_HOME_BASE/software
    mkdir -m 755 -p /mnt/backup
    if [ $SCHOOL_TEACHER_OBSERV_HOME = 'yes' ]; then
	mkdir -m 750 -p $SCHOOL_HOME_BASE/classes
    fi

    if [ $SCHOOL_TYPE = 'primary' ]; then
	chmod 1777 $SCHOOL_HOME_BASE/all
    else
	chmod 1770 $SCHOOL_HOME_BASE/all
    fi
    chmod 1775 $SCHOOL_HOME_BASE/software
    

    ########################################################################
    log " - Create base role"
    /usr/sbin/oss-add-group.sh --name="sysadmins"      --description="Sysadmins"      --type="primary" --mail="sysadmins@$SCHOOL_DOMAIN"
    /usr/sbin/oss-add-group.sh --name="students"       --description="Students"       --type="primary" --mail="students@$SCHOOL_DOMAIN"
    /usr/sbin/oss-add-group.sh --name="teachers"       --description="Teachers"       --type="primary" --mail="teachers@$SCHOOL_DOMAIN"
    /usr/sbin/oss-add-group.sh --name="workstations"   --description="Workstations"   --type="primary" --mail="workstations@$SCHOOL_DOMAIN"
    /usr/sbin/oss-add-group.sh --name="administration" --description="Administration" --type="primary" --mail="administration@$SCHOOL_DOMAIN"
    /usr/sbin/oss-add-group.sh --name="templates"      --description="Templates"      --type="primary" --mail="templates@$SCHOOL_DOMAIN"

    ########################################################################
    #log " - Create primary group type and add base role to primary group"
    #samba-tool group add "primary" --description="Primary group for role"
    #samba-tool group addmembers "primary" "sysadmins,students,teachers,workstations,administration,templates"

    ########################################################################
    log " - sysadmin primary group add to administrator group"
    samba-tool group addmembers "sysadmins" "administrator"

    ########################################################################
    log " - Create admin user"
    /usr/sbin/oss-add-user.sh --uid="admin" --givenname="Main" --surname="Sysadmin" --role="sysadmins" --password="$passwd" --groups=""

    ########################################################################
    log " - Create base template users"
    /usr/sbin/oss-add-user.sh --uid="tstudents"       --givenname="Default profile" --surname="for students"       --role="templates" --password="$passwd" --groups=""
    /usr/sbin/oss-add-user.sh --uid="tteachers"       --givenname="Default profile" --surname="for teachers"       --role="templates" --password="$passwd" --groups=""
    /usr/sbin/oss-add-user.sh --uid="tworkstations"   --givenname="Default profile" --surname="for workstations"   --role="templates" --password="$passwd" --groups=""
    /usr/sbin/oss-add-user.sh --uid="tadministration" --givenname="Default profile" --surname="for administration" --role="templates" --password="$passwd" --groups=""

    sysadmins_gn=`wbinfo -n sysadmins | awk '{print "wbinfo -S "$1}'| bash`
    students_gn=`wbinfo -n students | awk '{print "wbinfo -S "$1}'| bash`
    teachers_gn=`wbinfo -n teachers | awk '{print "wbinfo -S "$1}'| bash`
    workstations_gn=`wbinfo -n workstations | awk '{print "wbinfo -S "$1}'| bash`
    administration_gn=`wbinfo -n administration | awk '{print "wbinfo -S "$1}'| bash`
    templates_gn=`wbinfo -n templates | awk '{print "wbinfo -S "$1}'| bash`
#    _gn=`wbinfo -n  | awk '{print "wbinfo -S "$1}'| bash`


    ########################################################################
    log " - Create base directory rights"
    setfacl -m m::rwx                   $SCHOOL_HOME_BASE/all
    setfacl -m g:$teachers_gn:rwx       $SCHOOL_HOME_BASE/all
    setfacl -m g:$students_gn:rwx       $SCHOOL_HOME_BASE/all
    setfacl -m g:$administration_gn:rwx $SCHOOL_HOME_BASE/all
    setfacl -m g:$sysadmins_gn:rwx      $SCHOOL_HOME_BASE/all

    chgrp        $teachers_gn           $SCHOOL_HOME_BASE/software
    setfacl -m g:$students_gn:rx        $SCHOOL_HOME_BASE/software
    setfacl -m g:$administration_gn:rx  $SCHOOL_HOME_BASE/software
    setfacl -m g:$sysadmins_gn:rwx      $SCHOOL_HOME_BASE/software

    ########################################################################
    log " - Create itool directory and right "
    mkdir -p /srv/itool/{config,hwinfo,images,ROOT}
    chmod 755  /srv/itool
    chgrp -R $sysadmins_gn /srv/itool
    chmod 4770 /srv/itool/{config,hwinfo,images}
    chmod 755  /srv/itool/ROOT
    setfacl -m    g::rwx /srv/itool/images
    setfacl -d -m g::rwx /srv/itool/images
    setfacl -m    g:$teachers_gn:rx /srv/itool/{config,images}
    setfacl -d -m g:$teachers_gn:rx /srv/itool/{config,images}
    setfacl -m    g:$workstations_gn:rx /srv/itool/{config,images}
    setfacl -d -m g:$workstations_gn:rx /srv/itool/{config,images}

    ########################################################################
    log "Make administrator passwort do not expire"
    pdbedit -u Administrator -c "[X]"
    
    log "End SetupInitialAccounts"
}

function PostSetup (){
    log "Start PostSetup"

    ########################################################################
    log "Start and setup mysql"
    systemctl start  mysql
    systemctl enable mysql
    sleep 5
    SERVER_NETWORK=$( echo $SCHOOL_SERVER_NET | gawk -F '/' '{ print $1 }' )
    SERVER_NETMASK=$( echo $SCHOOL_SERVER_NET | gawk -F '/' '{ print $2 }' )
    ANON_NETWORK=$( echo $SCHOOL_ANON_DHCP_NET | gawk -F '/' '{ print $1 }' )
    ANON_NETMASK=$( echo $SCHOOL_ANON_DHCP_NET | gawk -F '/' '{ print $2 }' )
    sed -i "s/#SERVER_NETWORK#/${SERVER_NETWORK}/g" /opt/oss-java/data/oss-objects.sql
    sed -i "s/#SERVER_NETMASK#/${SERVER_NETMASK}/g" /opt/oss-java/data/oss-objects.sql
    sed -i "s/#ANON_NETWORK#/${ANON_NETWORK}/g"     /opt/oss-java/data/oss-objects.sql
    sed -i "s/#ANON_NETMASK#/${ANON_NETMASK}/g"     /opt/oss-java/data/oss-objects.sql
    sed -i "s/#SCHOOL_SERVER#/${SCHOOL_SERVER}/g" /opt/oss-java/data/oss-objects.sql
    sed -i "s/#SCHOOL_MAILSERVER#/${SCHOOL_MAILSERVER}/g" /opt/oss-java/data/oss-objects.sql
    sed -i "s/#SCHOOL_PROXY#/${SCHOOL_PROXY}/g" /opt/oss-java/data/oss-objects.sql
    sed -i "s/#SCHOOL_PRINTSERVER#/${SCHOOL_PRINTSERVER}/g" /opt/oss-java/data/oss-objects.sql
    sed -i "s/#SCHOOL_BACKUP_SERVER#/${SCHOOL_BACKUP_SERVER}/g" /opt/oss-java/data/oss-objects.sql
    mysql < /opt/oss-java/data/oss-objects.sql

    ########################################################################
    log "Make mysql secure"
    cd /root
    password=`mktemp XXXXXXXXXX`
    mysqladmin -u root password $password
echo "[client]
host=localhost
user=root
password=$password" > /root/.my.cnf
chmod 600 /root/.my.cnf

    echo "grant all on OSS.* to 'claxss'@'localhost'  identified by '$password'" | mysql
    sed -i s/MYSQLPWD/$password/ /opt/oss-java/conf/oss-api.properties

    ########################################################################
    log "Create profile directory"
    mkdir -p -m 1770 "$SCHOOL_HOME_BASE/profiles"
    chgrp "Domain Users" "$SCHOOL_HOME_BASE/profiles/"

    ########################################################################
    log "Create Certificates"
    /usr/share/oss/tools/create_server_certificates.sh -N CA
    /usr/share/oss/tools/create_server_certificates.sh -N admin
    /usr/share/oss/tools/create_server_certificates.sh -N schoolserver

    ########################################################################
    log "Adapt Apache configuration"
    sed -i 's/^APACHE_MODULES=.*/APACHE_MODULES="actions alias auth_basic authn_file authz_host authz_groupfile authz_core authz_user autoindex cgi dir env expires include log_config mime negotiation setenvif ssl socache_shmcb userdir reqtimeout php5 rewrite authn_core proxy proxy_http proxy_connect"/' /etc/sysconfig/apache2
    sed -i 's/^APACHE_SERVER_FLAGS=.*/APACHE_SERVER_FLAGS="SSL"/' /etc/sysconfig/apache2
    sed "s/#DOMAIN#/$SCHOOL_DOMAIN/g" /usr/share/oss/setup/templates/admin_include.conf.ini > /etc/apache2/vhosts.d/admin_include.conf
    sed "s/#DOMAIN#/$SCHOOL_DOMAIN/g" /usr/share/oss/setup/templates/oss_include.conf.ini   > /etc/apache2/vhosts.d/oss_include.conf
    systemctl enable apache2
    systemctl start  apache2

    ########################################################################
    log "Setup SuSEFirewall2"
    sed -i 's/^FW_ROUTE=.*/FW_ROUTE="yes"/'           /etc/sysconfig/SuSEfirewall2
    sed -i 's/^FW_MASQUERADE=.*/FW_MASQUERADE="yes"/' /etc/sysconfig/SuSEfirewall2

    ########################################################################
    log "Configure salt"
    sed -i 's/#auto_accept: False/auto_accept: True/'  /etc/salt/master

    ########################################################################
    log "Prepare roots desktop"
    mkdir -p /root/Desktop/
    cp /etc/skel/Desktop/* /root/Desktop/

    log "End PostSetup"

}


if [ ! -f $sysconfig ]; then
        echo -e "\033[0;31;1mThis script is for Open School Server only!\033[\0m"
        echo -e "\033[0;31;1m*********         exiting         *********\033[\0m"
        exit 0
fi

if [ -z "$1" ]
then
   usage 0
fi

while [ "$1" != "" ]; do
    case $1 in
	-h|-H|--help)
				usage 0
	;;
	--passwdf=* )
				passwdf=$(echo $1 | sed -e 's/--passwdf=//g');
				if [ "$passwdf" = '' ]
				then
					usage 0
				fi
	;;
	--all )
				all="yes"
	;;
	--samba )
				samba="yes"
        ;;
	--dhcp )
                                dhcp="yes"
        ;;
	--mail )
                                mail="yes"
        ;;
	--proxy )
                                proxy="yes"
        ;;
	--accounts )
                                accounts="yes"
        ;;
	--postsetup )
                                postsetup="yes"
        ;;
	--verbose )
                                verbose="yes"
        ;;
	\?)
                echo "UNKNOWN argument \"-$OPTARG\"." >&2
                usage 1
                ;;
        :)
                echo "Option \"-$OPTARG\" needs an argument." >&2
                usage 1
                ;;
        *)
                echo "Wrong arguments" >&2
                usage 1
                ;;
    esac
    shift
done

InitGlobalVariable
if [ "$all" = "yes" ] || [ "$samba" = "yes" ]; then
    SetupSamba
fi
if [ "$all" = "yes" ] || [ "$dhcp" = "yes" ]; then
    SetupDHCP
fi
if [ "$all" = "yes" ] || [ "$mail" = "yes" ]; then
    SetupMail
fi
if [ "$all" = "yes" ] || [ "$proxy" = "yes" ]; then
    SetupProxy
fi
if [ "$all" = "yes" ] || [ "$accounts" = "yes" ]; then
    SetupInitialAccounts
fi
if [ "$all" = "yes" ] || [ "$postsetup" = "yes" ]; then
    PostSetup
fi

chmod 600 $logfile
exit 0
