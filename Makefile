# Makefile

## live-config(7) - System Configuration Scripts
## Copyright (C) 2006-2013 Daniel Baumann <daniel@debian.org>
##
## This program comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


SHELL := sh -e

LANGUAGES = $(shell cd manpages/po && ls)

SCRIPTS = backends/*/*.init bin/* scripts/*.sh scripts/*/*

all: build

test:
	@echo -n "Checking for syntax errors"

	@for SCRIPT in $(SCRIPTS); \
	do \
		sh -n $${SCRIPT}; \
		echo -n "."; \
	done

	@echo " done."

	@if [ -x "$$(which checkbashisms 2>/dev/null)" ]; \
	then \
		echo -n "Checking for bashisms"; \
		for SCRIPT in $(SCRIPTS); \
		do \
			checkbashisms -f -x $${SCRIPT}; \
			echo -n "."; \
		done; \
		echo " done."; \
	else \
		echo "W: checkbashisms - command not found"; \
		echo "I: checkbashisms can be obtained from: "; \
		echo "I:   http://git.debian.org/?p=devscripts/devscripts.git"; \
		echo "I: On Debian based systems, checkbashisms can be installed with:"; \
		echo "I:   apt-get install devscripts"; \
	fi

build:
	@echo "Nothing to build."

install:
	# Installing backends
	mkdir -p $(DESTDIR)/etc/init.d
	cp backends/sysvinit/live-config.init $(DESTDIR)/etc/init.d/live-config
	cp backends/sysvinit/live.init $(DESTDIR)/etc/init.d/live

	mkdir -p $(DESTDIR)/etc/init
	cp backends/upstart/live-config.upstart $(DESTDIR)/etc/init/live-config.conf

	mkdir -p $(DESTDIR)/lib/systemd/system
	cp backends/systemd/live-config.systemd $(DESTDIR)/lib/systemd/system/live-config.service

	# Installing scripts
	mkdir -p $(DESTDIR)/lib/live
	cp -r scripts/config.sh scripts/config $(DESTDIR)/lib/live
	mkdir -p $(DESTDIR)/var/lib/live/config

	cp bin/boot-init.sh $(DESTDIR)/lib/live

	mkdir -p $(DESTDIR)/sbin

	# Installing shared data
	mkdir -p $(DESTDIR)/usr/share/live/config
	cp -r VERSION share/* $(DESTDIR)/usr/share/live/config

	# Installing docs
	mkdir -p $(DESTDIR)/usr/share/doc/live-config
	cp -r COPYING examples $(DESTDIR)/usr/share/doc/live-config

	# Installing manpages
	for MANPAGE in manpages/en/*; \
	do \
		SECTION="$$(basename $${MANPAGE} | awk -F. '{ print $$2 }')"; \
		install -D -m 0644 $${MANPAGE} $(DESTDIR)/usr/share/man/man$${SECTION}/$$(basename $${MANPAGE}); \
	done

	for LANGUAGE in $(LANGUAGES); \
	do \
		for MANPAGE in manpages/$${LANGUAGE}/*; \
		do \
			SECTION="$$(basename $${MANPAGE} | awk -F. '{ print $$3 }')"; \
			install -D -m 0644 $${MANPAGE} $(DESTDIR)/usr/share/man/$${LANGUAGE}/man$${SECTION}/$$(basename $${MANPAGE} .$${LANGUAGE}.$${SECTION}).$${SECTION}; \
		done; \
	done

uninstall:
	# Uninstalling backends
	rm -f $(DESTDIR)/etc/init.d/live
	rm -f $(DESTDIR)/etc/init.d/live-config
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/etc/init.d > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/etc > /dev/null 2>&1 || true

	rm -f $(DESTDIR)/etc/init/live-config.conf
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/etc/init > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/etc > /dev/null 2>&1 || true

	rm -f $(DESTDIR)/lib/systemd/system/live-config.service
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/lib/systemd/system > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/lib/systemd > /dev/null 2>&1 || true

	# Uninstalling scripts
	rm -f $(DESTDIR)/lib/live/boot-init.sh

	rm -rf $(DESTDIR)/lib/live/config.sh $(DESTDIR)/lib/live/config
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/lib/live > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/lib > /dev/null 2>&1 || true

	rmdir --ignore-fail-on-non-empty $(DESTDIR)/var/lib/live/config > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/var/lib/live > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/var/lib > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/var > /dev/null 2>&1 || true

	# Uninstalling shared data
	rm -rf $(DESTDIR)/usr/share/live/config
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share/live

	# Uninstalling docs
	rm -rf $(DESTDIR)/usr/share/doc/live-config
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share/doc > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr > /dev/null 2>&1 || true

	# Uninstalling manpages
	for MANPAGE in manpages/en/*; \
	do \
		SECTION="$$(basename $${MANPAGE} | awk -F. '{ print $$2 }')"; \
		rm -f $(DESTDIR)/usr/share/man/man$${SECTION}/$$(basename $${MANPAGE} .en.$${SECTION}).$${SECTION}; \
	done

	for LANGUAGE in $(LANGUAGES); \
	do \
		for MANPAGE in manpages/$${LANGUAGE}/*; \
		do \
			SECTION="$$(basename $${MANPAGE} | awk -F. '{ print $$3 }')"; \
			rm -f $(DESTDIR)/usr/share/man/$${LANGUAGE}/man$${SECTION}/$$(basename $${MANPAGE} .$${LANGUAGE}.$${SECTION}).$${SECTION}; \
		done; \
	done

	for SECTION in $(ls manpages/en/* | awk -F. '{ print $2 }'); \
	do \
		rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share/man/man$${SECTION} > /dev/null 2>&1 || true; \
		rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share/man/*/man$${SECTION} > /dev/null 2>&1 || true; \
	done

	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share/man > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr/share > /dev/null 2>&1 || true
	rmdir --ignore-fail-on-non-empty $(DESTDIR)/usr > /dev/null 2>&1 || true

	rmdir --ignore-fail-on-non-empty $(DESTDIR) > /dev/null 2>&1 || true

clean:
	@echo "Nothing to clean."

distclean: clean
	@echo "Nothing to distclean."

reinstall: uninstall install
