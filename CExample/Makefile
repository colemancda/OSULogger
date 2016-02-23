RM=rm
OS=$(shell uname -s | tr [A-Z] [a-z])
PWD=$(shell pwd)

ifeq ($(OS),darwin)
SO_EXT = dylib
else
SO_EXT = so
endif

OSULOGGER_BUILD_DIR = $(PWD)/../.build/debug
OSULOGGER_LIBRARY = $(OSULOGGER_BUILD_DIR)/libOSULogger.$(SO_EXT)

CFLAGS = -I ../Headers -g

LIBS = -L$(OSULOGGER_BUILD_DIR) -lOSULogger
ifneq ($(OS),darwin)
LIBS += -L/usr/lib/swift/$(OS)/ -Wl,-rpath,/usr/lib/swift/$(OS)/
LIBS += -Wl,-rpath,$(OSULOGGER_BUILD_DIR)
endif

all: ctest

clean:
	$(RM) -rf ctest

$(OSULOGGER_LIBRARY):
	(cd .. ; swift build -c debug)

ctest: ctest.c $(OSULOGGER_LIBRARY)
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS) $(LIBS)

