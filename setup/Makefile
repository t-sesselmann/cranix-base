# Copyright (c) 2016 Peter Varkoly Nürnberg, Germany.  All rights reserved.
#
DESTDIR         = /
SHARE           = $(DESTDIR)/usr/share/oss/
#VERSION         = $(shell  cat ../VERSION)

install:
	mkdir -p $(SHARE)/setup/{templates,plugins}
	install -m 755 scripts/*   $(SHARE)/setup/
	install -m 644 templates/* $(SHARE)/setup/templates/
	install -m 755 plugins/*   $(SHARE)/setup/plugins/
