##### Available defines for CJSON_CFLAGS #####
##
## USE_INTERNAL_ISINF:      Workaround for Solaris platforms missing isinf().
## DISABLE_CJSON_GLOBAL:    Do not store module is "cjson" global.
## DISABLE_INVALID_NUMBERS: Permanently disable invalid JSON numbers:
##                          NaN, Infinity, hex.
##
## Optional built-in number conversion uses the following defines:
## USE_INTERNAL_DTOA:       Use builtin strtod/dtoa for numeric conversions.
## IEEE_BIG_ENDIAN:         Required on big endian architectures.

##### Build defaults #####
LUA_VERSION =       5.1
TARGET =            cjson.so
PREFIX =            /usr/local
#CFLAGS =            -g -Wall -pedantic -fno-inline
CFLAGS =            -O3 -Wall -pedantic -DNDEBUG
CJSON_CFLAGS =      -fpic
CJSON_LDFLAGS =     -shared
LUA_INCLUDE_DIR = $(INCLUDE_LUA)
LUA_INCLUDE_DIR ?= $(PREFIX)/include
LUA_CMODULE_DIR =   $(PREFIX)/lib/lua/$(LUA_VERSION)
LUA_MODULE_DIR =    $(PREFIX)/share/lua/$(LUA_VERSION)
LUA_BIN_DIR =       $(PREFIX)/bin

##### Platform overrides #####
##
## Tweak one of the platform sections below to suit your situation.
##
## See http://lua-users.org/wiki/BuildingModules for further platform
## specific details.

## Linux

## FreeBSD
#LUA_INCLUDE_DIR =   $(PREFIX)/include/lua51

## MacOSX (Macports)
#PREFIX =            /opt/local
#CJSON_LDFLAGS =     -bundle -undefined dynamic_lookup

## Solaris
#CJSON_CFLAGS =      -fpic -DUSE_INTERNAL_ISINF

## Windows (MinGW)
#TARGET =            cjson.dll
#PREFIX =            /home/user/opt
#CJSON_CFLAGS =      -DDISABLE_INVALID_NUMBERS
#CJSON_LDFLAGS =     -shared -L$(PREFIX)/lib -llua51
#LUA_BIN_SUFFIX =    .lua

##### Use built in number conversion (optional) #####

## Enable built in number conversion
#FPCONV_OBJS =       g_fmt.o dtoa.o
#CJSON_CFLAGS +=     -DUSE_INTERNAL_DTOA

## Compile built in number conversion for big endian architectures
#CJSON_CFLAGS +=     -DIEEE_BIG_ENDIAN

## Compile built in number conversion to support multi-threaded
## applications (recommended)
#CJSON_CFLAGS +=     -pthread -DMULTIPLE_THREADS
#CJSON_LDFLAGS +=    -pthread

##### End customisable sections #####

TEST_FILES =        README bench.lua genutf8.pl test.lua octets-escaped.dat \
                    example1.json example2.json example3.json example4.json \
                    example5.json numbers.json rfc-example1.json \
                    rfc-example2.json types.json
DATAPERM =          644
EXECPERM =          755

BUILD_CFLAGS =      -I$(LUA_INCLUDE_DIR) $(CJSON_CFLAGS)
FPCONV_OBJS ?=      fpconv.o
OBJS :=             lua_cjson.o strbuf.o $(FPCONV_OBJS)

.PHONY: all clean install install-extra doc

all: $(TARGET)

doc: manual.html

.c.o:
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $(BUILD_CFLAGS) -o $@ $<

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) $(CJSON_LDFLAGS) -o $@ $(OBJS)

install: $(TARGET)
	cp $(TARGET) $(ROOT)/luaclib/

install-extra:
	mkdir -p $(DESTDIR)/$(LUA_MODULE_DIR)/cjson/tests \
		$(DESTDIR)/$(LUA_BIN_DIR)
	cp lua/cjson/util.lua $(DESTDIR)/$(LUA_MODULE_DIR)/cjson
	chmod $(DATAPERM) $(DESTDIR)/$(LUA_MODULE_DIR)/cjson/util.lua
	cp lua/lua2json.lua $(DESTDIR)/$(LUA_BIN_DIR)/lua2json$(LUA_BIN_SUFFIX)
	chmod $(EXECPERM) $(DESTDIR)/$(LUA_BIN_DIR)/lua2json$(LUA_BIN_SUFFIX)
	cp lua/json2lua.lua $(DESTDIR)/$(LUA_BIN_DIR)/json2lua$(LUA_BIN_SUFFIX)
	chmod $(EXECPERM) $(DESTDIR)/$(LUA_BIN_DIR)/json2lua$(LUA_BIN_SUFFIX)
	cd tests; cp $(TEST_FILES) $(DESTDIR)/$(LUA_MODULE_DIR)/cjson/tests
	cd tests; chmod $(DATAPERM) $(TEST_FILES); chmod $(EXECPERM) *.lua *.pl

manual.html: manual.txt
	asciidoc -n -a toc manual.txt

clean:
	rm -f *.o $(TARGET)
