# st - simple terminal
# See LICENSE file for copyright and license details.
.POSIX:

include config.mk

SRC = st.c x.c hb.c
OBJ = $(SRC:.c=.o)

all: options st

options:
	@echo st build options:
	@echo "CFLAGS  = $(STCFLAGS)"
	@echo "LDFLAGS = $(STLDFLAGS)"
	@echo "CC      = $(CC)"

config.h:
	cp config.def.h config.h

.c.o:
	$(CC) $(STCFLAGS) -c $<

st.o: config.h st.h win.h
x.o: arg.h config.h st.h win.h hb.h
hb.o: st.h

$(OBJ): config.h config.mk

st: $(OBJ)
	$(CC) -o $@ $(OBJ) $(STLDFLAGS)

clean:
	rm -f st $(OBJ) st-$(VERSION).tar.gz

dist: clean
	mkdir -p st-$(VERSION)
	cp -R FAQ LEGACY TODO LICENSE Makefile README config.mk\
		config.def.h st.info st.1 arg.h st.h win.h $(SRC)\
		st-$(VERSION)
	tar -cf - st-$(VERSION) | gzip > st-$(VERSION).tar.gz
	rm -rf st-$(VERSION)

install: st
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f st $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/st
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	sed "s/VERSION/$(VERSION)/g" < st.1 > $(DESTDIR)$(MANPREFIX)/man1/st.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/st.1
	tic -sx st.info
	mkdir -p $(DESTDIR)$(PREFIX)/share/applications
	sed -e "s:%DESTDIR%:$(DESTDIR)$(PREFIX):g" share/applications/st.desktop > $(DESTDIR)$(PREFIX)/share/applications/st.desktop
	mkdir -p $(DESTDIR)$(PREFIX)/share/icons/hicolor/scalable/apps
	for i in 128 16 24 256 32 48 512 64; do mkdir -p $(DESTDIR)$(PREFIX)/share/icons/hicolor/$${i}x$${i}/apps; done
	cp -f share/icons/hicolor/scalable/apps/st.svg $(DESTDIR)$(PREFIX)/share/icons/hicolor/scalable/apps
	for i in 128 16 24 256 32 48 512 64; do cp -f share/icons/hicolor/$${i}x$${i}/apps/st.png $(DESTDIR)$(PREFIX)/share/icons/hicolor/$${i}x$${i}/apps; done
	@echo Please see the README file regarding the terminfo entry of st.

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/st
	rm -f $(DESTDIR)$(MANPREFIX)/man1/st.1
	rm -f $(DESTDIR)$(PREFIX)/share/applications/st.desktop
	rm -f $(DESTDIR)$(PREFIX)/share/icons/hicolor/scalable/apps/st.svg
	for i in 128 16 24 256 32 48 512 64; do rm -f $(DESTDIR)$(PREFIX)/share/icons/hicolor/$${i}x$${i}/apps/st.png; done

.PHONY: all options clean dist install uninstall
