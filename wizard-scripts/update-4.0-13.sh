#!/bin/bash
# Add Access-Control-Allow-Methods to the admin server confiugartion.

if [ -e "/var/adm/cranix/update-4.0-13" ]
then
echo "Patch 4.0-13 already installed"
        exit 0
fi

grep -q Access-Control-Expose-Headers /etc/apache2/vhosts.d/admin_include.conf || {
   sed -i '/Access-Control-Allow-Methods/a Header always set Access-Control-Expose-Headers "Content-Disposition"' /etc/apache2/vhosts.d/admin_include.conf
   systemctl reload apache
}

touch /var/adm/cranix/update-4.0-13

