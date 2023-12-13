#-------------------------------------------------------------------------
#
# Makefile for pg_hexedit
#
# Copyright (c) 2018-2021, Crunchy Data Solutions, Inc.
# Copyright (c) 2017-2018, VMware, Inc.
# Copyright (c) 2002-2010, Red Hat, Inc.
# Copyright (c) 2011-2021, PostgreSQL Global Development Group
#
#-------------------------------------------------------------------------

PGFILEDESC = "pg_hexedit - emits descriptive XML tag format for PostgreSQL relation files"
PGAPPICON=win32
HEXEDIT_VERSION = 0.1

#PG_CONFIG = pg_config
#PGSQL_CFLAGS = $(shell $(PG_CONFIG) --cflags)
#PGSQL_INCLUDE_DIR = $(shell $(PG_CONFIG) --includedir-server)
#PGSQL_LDFLAGS = $(shell $(PG_CONFIG) --ldflags)
#PGSQL_LIB_DIR = $(shell $(PG_CONFIG) --libdir)
#PGSQL_PKGLIB_DIR = $(shell $(PG_CONFIG) --pkglibdir)
#PGSQL_BIN_DIR = $(shell $(PG_CONFIG) --bindir)

# FIX: Manually linking some of the Win32 specific object files,
# so the path to the full source tree of postgres (containing all .o files) has
# to be manually specified in PGSQL_SRC_DIR
PGSQL_SRC_DIR = /home/user/postgresql-16.1/src
PGSQL_OBJ_DIR = ${PGSQL_SRC_DIR}/port/

# Requires pg_config to have valid values
PG_CONFIG = pg_config
PGSQL_CFLAGS = $(shell $(PG_CONFIG) --cflags)
PGSQL_LDFLAGS = $(shell $(PG_CONFIG) --ldflags)
PGSQL_INCLUDE_DIR2 = $(shell $(PG_CONFIG) --includedir-server)
PGSQL_INCLUDE_DIR = $(shell cygpath -u ${PGSQL_INCLUDE_DIR2})
PGSQL_LIB_DIR2 = $(shell $(PG_CONFIG) --libdir)
PGSQL_LIB_DIR = $(shell cygpath -u ${PGSQL_LIB_DIR2})
PGSQL_PKGLIB_DIR2 = $(shell $(PG_CONFIG) --pkglibdir)
PGSQL_PKGLIB_DIR = $(shell cygpath -u ${PGSQL_PKGLIB_DIR2})
PGSQL_BIN_DIR2 = $(shell $(PG_CONFIG) --bindir)
PGSQL_BIN_DIR = $(shell cygpath -u ${PGSQL_BIN_DIR2})
PGSQL_WIN32_OBJ_FILES = ${PGSQL_OBJ_DIR}pgsleep.o ${PGSQL_OBJ_DIR}strerror.o ${PGSQL_OBJ_DIR}snprintf.o ${PGSQL_OBJ_DIR}pgstrcasecmp.o \
${PGSQL_OBJ_DIR}path.o ${PGSQL_OBJ_DIR}preadv.o ${PGSQL_OBJ_DIR}pwritev.o ${PGSQL_OBJ_DIR}explicit_bzero.o \
${PGSQL_OBJ_DIR}getpeereid.o ${PGSQL_OBJ_DIR}inet_aton.o ${PGSQL_OBJ_DIR}mkdtemp.o ${PGSQL_OBJ_DIR}strlcat.o \
${PGSQL_OBJ_DIR}strlcpy.o ${PGSQL_OBJ_DIR}strtof.o ${PGSQL_OBJ_DIR}getopt.o ${PGSQL_OBJ_DIR}getopt_long.o \
${PGSQL_OBJ_DIR}dirmod.o ${PGSQL_OBJ_DIR}kill.o ${PGSQL_OBJ_DIR}open.o ${PGSQL_OBJ_DIR}system.o \
${PGSQL_OBJ_DIR}win32common.o ${PGSQL_OBJ_DIR}win32dlopen.o ${PGSQL_OBJ_DIR}win32env.o ${PGSQL_OBJ_DIR}win32error.o \
${PGSQL_OBJ_DIR}win32fdatasync.o ${PGSQL_OBJ_DIR}win32getrusage.o ${PGSQL_OBJ_DIR}win32link.o ${PGSQL_OBJ_DIR}win32ntdll.o \
${PGSQL_OBJ_DIR}win32pread.o ${PGSQL_OBJ_DIR}win32pwrite.o ${PGSQL_OBJ_DIR}win32security.o ${PGSQL_OBJ_DIR}win32setlocale.o \
${PGSQL_OBJ_DIR}win32stat.o


DISTFILES= README.md Makefile pg_hexedit.c pg_filenodemapdata.c
TESTFILES= t/1249 t/2685 t/expected_attributes.tags \
	t/expected_attributes_idx.tags t/expected_empty_lsn.tags \
	t/expected_leaf_idx.tags t/expected_no_attributes.tags \
	t/expected_no_attributes_idx.tags t/test_pg_hexedit

all: pg_hexedit pg_filenodemapdata

pg_hexedit: pg_hexedit.o
	${CC} ${PGSQL_LDFLAGS} ${LDFLAGS} -o pg_hexedit pg_hexedit.o -L${PGSQL_LIB_DIR} -L${PGSQL_PKGLIB_DIR} -lpgport -lpgcommon ${PGSQL_WIN32_OBJ_FILES}

pg_filenodemapdata: pg_filenodemapdata.o
	${CC} ${PGSQL_LDFLAGS} ${LDFLAGS} -o pg_filenodemapdata pg_filenodemapdata.o -L${PGSQL_LIB_DIR} -L${PGSQL_PKGLIB_DIR} -lpgport ${PGSQL_WIN32_OBJ_FILES}

pg_hexedit.o: pg_hexedit.c
	${CC} ${PGSQL_CFLAGS} ${CFLAGS} -I${PGSQL_INCLUDE_DIR} -I${PGSQL_INCLUDE_DIR}/port/win32 pg_hexedit.c ${PGSQL_WIN32_OBJ_FILES} -c

pg_filenodemapdata.o: pg_filenodemapdata.c
	${CC} ${PGSQL_CFLAGS} ${CFLAGS} -I${PGSQL_INCLUDE_DIR} -I${PGSQL_INCLUDE_DIR}/port/win32 pg_filenodemapdata.c ${PGSQL_WIN32_OBJ_FILES} -c

check:
	t/test_pg_hexedit

dist:
	rm -rf pg_hexedit-${HEXEDIT_VERSION} pg_hexedit-${HEXEDIT_VERSION}.tar.gz
	mkdir pg_hexedit-${HEXEDIT_VERSION}
	cp -p ${DISTFILES} pg_hexedit-${HEXEDIT_VERSION}
	mkdir pg_hexedit-${HEXEDIT_VERSION}/t
	cp -p ${TESTFILES} pg_hexedit-${HEXEDIT_VERSION}/t
	tar cfz pg_hexedit-${HEXEDIT_VERSION}.tar.gz pg_hexedit-${HEXEDIT_VERSION}
	rm -rf pg_hexedit-${HEXEDIT_VERSION}

install:
	mkdir -p $(DESTDIR)$(PGSQL_BIN_DIR)
	install pg_hexedit $(DESTDIR)$(PGSQL_BIN_DIR)
	install pg_filenodemapdata $(DESTDIR)$(PGSQL_BIN_DIR)

uninstall:
	rm -f '$(DESTDIR)$(PGSQL_BIN_DIR)/pg_hexedit$(X)'
	rm -f '$(DESTDIR)$(PGSQL_BIN_DIR)/pg_filenodemapdata$(X)'

clean:
	rm -f *.o pg_hexedit pg_filenodemapdata
	rm -f t/*diff
	rm -f t/output*tags

distclean:
	rm -f *.o pg_hexedit pg_filenodemapdata
	rm -f t/*diff
	rm -f t/output*tags
	rm -rf pg_hexedit-${HEXEDIT_VERSION} pg_hexedit-${HEXEDIT_VERSION}.tar.gz
