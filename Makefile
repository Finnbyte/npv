PREFIX=/usr/local
DESTDIR=$(PREFIX)/bin

npv: npv.ha namedates.ha
	hare build -o npv .

install:
	install -m5 ./npv "$(DESTDIR)/npv"
