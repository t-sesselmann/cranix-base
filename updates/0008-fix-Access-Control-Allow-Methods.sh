sed -i 's/Access-Control-Allow-Methods "POST, GET, OPTIONS, DELETE, PUT"/Access-Control-Allow-Methods "POST, GET, OPTIONS, DELETE, PUT, PATCH"/' /etc/apache2/vhosts.d/admin_include.conf
/usr/bin/systemctl restart apache2
