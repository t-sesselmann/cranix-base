#!/bin/bash
#
# Copyright (c) 2016 Peter Varkoly Nürnberg, Germany.  All rights reserved.
#

# other global variable
sysconfig="/etc/sysconfig/schoolserver"
logdate=`date "+%y.%m.%d.%H-%M-%S"`
logfile="/var/log/oss-setup.$logdate.log"
passwd=""
netbiosname=""
windomain=""
HOME_BASE="/home";

# input variable
passwdf=""
all="no"
#presetup="no"
samba="no"
#dhcp="no"
#mail="no"
#proxy="no"
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
#	echo "                --presetup          Pre Setup OSS server."
	echo "                --samba             Setup the AD-DC samba server."
	echo "                --dhcp              Setup the DHCP server"
	echo "                --mail              Setup the mail server"
	echo "                --proxy             Setup the proxy server"
	echo "                --accounts          Create the initial groups and user accounts"
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
    log "Start InitGlobalVariable"

    ########################################################################
    log " - Read sysconfig file"
    . $sysconfig

    ########################################################################
    log " - Read password file"
    passwd=`cat $passwdf`
    log "   passwd = $passwd"

    ########################################################################
    log " - Set netbiosname variable"
    if [ $SCHOOL_NETBIOSNAME} ]
    then
        netbiosname=$SCHOOL_NETBIOSNAME
    fi
    netbiosname=`echo "$netbiosname" | tr "[:upper:]" "[:lower:]"`
    log "   netbiosname = $netbiosname"

    ########################################################################
    log " - Set windomain variable"
    windomain=`echo "$SCHOOL_DOMAIN" | awk -F"." '{print $1 }' | tr "[:lower:]" "[:upper:]"`
    log "   windomain = $windomain"

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

    ########################################################################
    log " - Install domain provision"
    samba-tool domain provision --realm="$SCHOOL_DOMAIN" --domain="$windomain" --adminpass="$passwd" --server-role=dc --ldapadminpass="$passwd" --use-rfc2307 --use-xattrs=yes

    ########################################################################
    log " - Setup smb.conf file"
    sed    "s/#NETBIOSNAME#/schooladmin/"       /usr/share/oss/setup/templates/samba-smb.conf.ini > /etc/samba/smb.conf 
    sed -i "s/#REALM#/$SCHOOL_DOMAIN/"          /etc/samba/smb.conf
    sed -i "s/#WORKGROUP#/$windomain/"          /etc/samba/smb.conf
    sed -i "s/#GATEWAY#/$SCHOOL_SERVER_EXT_GW/" /etc/samba/smb.conf

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

    log "End SetupSamba"
}

function SetupDHCP (){
    log "Start SetupDHCP"
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
    mkdir -m 770 -p $HOME_BASE/all
    mkdir -m 755 -p $HOME_BASE/archiv
    mkdir -m 755 -p $HOME_BASE/groups
    mkdir -m 775 -p $HOME_BASE/software
    mkdir -m 755 -p /mnt/backup
    if [ $SCHOOL_TEACHER_OBSERV_HOME = 'yes' ]; then
	mkdir -m 750 -p $HOME_BASE/classes
    fi

    if [ $SCHOOL_TYPE = 'primary' ]; then
	chmod 1777 $HOME_BASE/all
    else
	chmod 1770 $HOME_BASE/all
    fi
    chmod 1775 $HOME_BASE/software
    

    ########################################################################
    log " - Create base role"
    /usr/sbin/oss-add-group.sh --name="sysadmins"      --description="Sysadmins"      --type="primary" --mail="sysadmins@$SCHOOL_DOMAIN"
    /usr/sbin/oss-add-group.sh --name="students"       --description="Students"       --type="primary" --mail="students@$SCHOOL_DOMAIN"
    /usr/sbin/oss-add-group.sh --name="teachers"       --description="Teachers"       --type="primary" --mail="teachers@$SCHOOL_DOMAIN"
    /usr/sbin/oss-add-group.sh --name="workstations"   --description="Workstations"   --type="primary" --mail="workstations@$SCHOOL_DOMAIN"
    /usr/sbin/oss-add-group.sh --name="administration" --description="Administration" --type="primary" --mail="administration@$SCHOOL_DOMAIN"
    /usr/sbin/oss-add-group.sh --name="templates"      --description="Templates"      --type="primary" --mail="templates@$SCHOOL_DOMAIN"

    ########################################################################
    log " - Create primary group type and add base role to primary group"
    samba-tool group add "primary" --description="Primary group for role"
    samba-tool group addmembers "primary" "sysadmins,students,teachers,workstations,administration,templates"

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
    setfacl -m m::rwx               $HOME_BASE/all
    setfacl -m g:$teachers_gn:rwx       $HOME_BASE/all
    setfacl -m g:$students_gn:rwx       $HOME_BASE/all
    setfacl -m g:$administration_gn:rwx $HOME_BASE/all
    setfacl -m g:$sysadmins_gn:rwx      $HOME_BASE/all

    chgrp        $teachers_gn           $HOME_BASE/software
    setfacl -m g:$students_gn:rx        $HOME_BASE/software
    setfacl -m g:$administration_gn:rx  $HOME_BASE/software
    setfacl -m g:$sysadmins_gn:rwx      $HOME_BASE/software

    chgrp   $templates_gn         $HOME_BASE/templates
    chgrp   $students_gn          $HOME_BASE/students
    chgrp   $teachers_gn          $HOME_BASE/teachers
    chgrp   $administration_gn    $HOME_BASE/administration
    chgrp   $workstations_gn      $HOME_BASE/workstations

    setfacl    -m g:$teachers_gn:rx $HOME_BASE/workstations
    setfacl    -m g:$teachers_gn:rx $HOME_BASE/groups/STUDENTS
    setfacl -d -m g:$teachers_gn:rx $HOME_BASE/groups/STUDENTS

    rm -rf $HOME_BASE/groups/{WORKSTATIONS,STUDENTS,TEMPLATES}

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


    log "End SetupInitialAccounts"
}

function PostSetup (){
    log "Start PostSetup"


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
#	--presetup )
#				presetup="yes"
#	;;
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
#if [ "$all" = "yes" ] || [ "$presetup" = "yes" ]; then
#    PreSetup
#fi
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

exit 1
