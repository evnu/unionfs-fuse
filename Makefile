PREFIX=/usr/local
BINDIR=/bin
SBINDIR=/sbin

build:
	$(MAKE) -C src/

build_coverage:
	CFLAGS="-g -O0 -fprofile-arcs -ftest-coverage" \
	       LDFLAGS="-lgcov -coverage" $(MAKE) -C src/

build_sanitize:
	CFLAGS="-fsanitize=address -fsanitize=undefined" \
	       LDFLAGS='-lasan -lubsan' \
	       $(MAKE) -C src/

clean: clean_coverage
	$(MAKE) -C src/ clean

test_coverage: clean build_coverage coverage
	./test.py
	(cd src && gcovr -r . --html -o ../coverage/index.html --html-details)
	(cd src && gcovr -r .)

test_sanitize: clean build_sanitize
	ASAN_OPTIONS=symbolize=1 \
		     ./test.py

clean_coverage:
	rm -rf coverage
	rm -rf src/*.gcda
	rm -rf src/*.gcno

coverage:
	mkdir $@

install: build
	install -d $(DESTDIR)$(PREFIX)$(BINDIR)
	install -d $(DESTDIR)$(PREFIX)$(SBINDIR)
	install -d $(DESTDIR)$(PREFIX)/share/man/man8
	install -m 0755 src/unionfs $(DESTDIR)$(PREFIX)$(BINDIR)
	install -m 0755 src/unionfsctl $(DESTDIR)$(PREFIX)$(BINDIR)
	install -m 0755 mount.unionfs $(DESTDIR)$(PREFIX)$(SBINDIR)
	install -m 0644 man/unionfs.8 $(DESTDIR)$(PREFIX)/share/man/man8/
