#
# Copyright (c) 2016 Peter Varkoly Nürnberg, Germany.  All rights reserved.
#
DESTDIR         = /
SHARE           = $(DESTDIR)/usr/share/oss/
FILLUPDIR	= /usr/share/fillup-templates/
TOPACKAGE       = Makefile etc cups plugins profiles sbin setup salt tools templates updates README.md
VERSION         = $(shell test -e ../VERSION && cp ../VERSION VERSION ; cat VERSION)
RELEASE         = $(shell cat RELEASE )
NRELEASE        = $(shell echo $(RELEASE) + 1 | bc )
REQPACKAGES     = $(shell cat REQPACKAGES)
HERE            = $(shell pwd)
REPO		= /data1/OSC/home:varkoly:OSS-4-0:stable/
PACKAGE         = oss-base

install:
	for i in $(REQPACKAGES); do \
	    rpm -q --quiet $$i || { echo "Missing Required Package $$i"; exit 1; } \
	done  
	mkdir -p $(SHARE)/{setup,templates,tools,plugins,profiles,updates}
	mkdir -p $(DESTDIR)/usr/sbin/ 
	mkdir -p $(DESTDIR)/$(FILLUPDIR)
	mkdir -p $(DESTDIR)/etc/YaST2/
	mkdir -p $(DESTDIR)/usr/lib/systemd/system/
	mkdir -p $(DESTDIR)/srv/salt/_modules/
	mkdir -p $(DESTDIR)/usr/share/cups/
	install -m 755 sbin/*       $(DESTDIR)/usr/sbin/
	rsync -a   etc/             $(DESTDIR)/etc/
	rsync -a   templates/       $(SHARE)/templates/
	rsync -a   setup/           $(SHARE)/setup/
	rsync -a   plugins/         $(SHARE)/plugins/
	rsync -a   tools/           $(SHARE)/tools/
	rsync -a   updates/         $(SHARE)/updates/
	rsync -a   profiles/        $(SHARE)/profiles/
	rsync -a   salt/            $(DESTDIR)/srv/salt/
	rsync -a   cups/            $(DESTDIR)/usr/share/cups/
	find $(SHARE)/plugins/ $(SHARE)/tools/ -type f -exec chmod 755 {} \;	
	install -m 644 setup/schoolserver      $(DESTDIR)/$(FILLUPDIR)/sysconfig.schoolserver
	install -m 644 setup/oss-firstboot.xml $(DESTDIR)/etc/YaST2/
	install -m 644 setup/oss_*.service $(DESTDIR)/usr/lib/systemd/system/

dist:
	xterm -e git log --raw  &
	if [ -e $(PACKAGE) ] ;  then rm -rf $(PACKAGE) ; fi   
	mkdir $(PACKAGE)
	for i in $(TOPACKAGE); do \
	    cp -rp $$i $(PACKAGE); \
	done
	find $(PACKAGE) -type f > files;
	tar jcpf $(PACKAGE).tar.bz2 -T files;
	rm files
	rm -rf $(PACKAGE)
	sed    's/@VERSION@/$(VERSION)/'  $(PACKAGE).spec.in > $(PACKAGE).spec
	sed -i 's/@RELEASE@/$(NRELEASE)/' $(PACKAGE).spec
	if [ -d $(REPO)/$(PACKAGE) ] ; then \
	    cd $(REPO)/$(PACKAGE); osc up; cd $(HERE);\
	    mv $(PACKAGE).tar.bz2 $(PACKAGE).spec $(REPO)/$(PACKAGE); \
	    cd $(REPO)/$(PACKAGE); \
	    osc vc; \
	    osc ci -m "New Build Version"; \
	fi
	echo $(NRELEASE) > RELEASE
	git commit -a -m "New release"
	git push

package:        dist
	rm -rf /usr/src/packages/*
	cd /usr/src/packages; mkdir -p BUILDROOT BUILD SOURCES SPECS SRPMS RPMS RPMS/athlon RPMS/amd64 RPMS/geode RPMS/i686 RPMS/pentium4 RPMS/x86_64 RPMS/ia32e RPMS/i586 RPMS/pentium3 RPMS/i386 RPMS/noarch RPMS/i486
	cp $(PACKAGE).tar.bz2 /usr/src/packages/SOURCES
	rpmbuild -ba $(PACKAGE).spec
	for i in `ls /data1/PACKAGES/rpm/noarch/$(PACKAGE)* 2> /dev/null`; do rm $$i; done
	for i in `ls /data1/PACKAGES/src/$(PACKAGE)* 2> /dev/null`; do rm $$i; done
	cp /usr/src/packages/SRPMS/$(PACKAGE)-*.src.rpm /data1/PACKAGES/src/
	cp /usr/src/packages/RPMS/noarch/$(PACKAGE)-*.noarch.rpm /data1/PACKAGES/rpm/noarch/
	createrepo -p /data1/PACKAGES/

