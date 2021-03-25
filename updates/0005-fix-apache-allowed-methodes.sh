#!/bin/bash

sed -i 's/Header always set Access-Control-Allow-Methods.*/Header always set Access-Control-Allow-Methods "POST, GET, OPTIONS, DELETE, PUT, PATCH"/' /etc/apache2/vhosts.d/admin_include.conf
/usr/bin/systemctl reload apache2

