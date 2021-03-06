BLDFLAGS                  = -Wall -Wextra -pedantic -std=c99
COMMONFLAGS               = -D__STDC_CONSTANT_MACROS -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE=1
CFLAGS                    = -O3
CDFLAGS                   = -DDEBUG=1 -g -O0 -fno-inline
CPFLAGS                   = -pg
LIBS                      = -lpthread
INCLUDES                 := -iquote"${PWD}"
DISTDIR                   = ../bin
OBJDIR                    = objects
WRAPPERDIR                = wrappers
PROG                      = convert2bed
SOURCE                    = convert2bed.c
SFLAGS                    = -static

all: setup build

.PHONY: setup build build_debug build_gprof clean

setup:
	mkdir -p $(DISTDIR)
	mkdir -p $(OBJDIR)

build: setup
	$(CC) $(BLDFLAGS) $(COMMONFLAGS) $(CFLAGS) -c $(SOURCE) -o $(OBJDIR)/$(PROG).o $(INCLUDES)
	$(CC) $(BLDFLAGS) $(COMMONFLAGS) $(CFLAGS) $(SFLAGS) $(OBJDIR)/$(PROG).o -o $(DISTDIR)/$(PROG) $(LIBS)

build_debug: setup
	$(CC) $(BLDFLAGS) $(COMMONFLAGS) $(CDFLAGS) -c $(SOURCE) -o $(OBJDIR)/$(PROG).o $(INCLUDES)
	$(CC) $(BLDFLAGS) $(COMMONFLAGS) $(CDFLAGS) $(SFLAGS) $(OBJDIR)/$(PROG).o -o $(DISTDIR)/debug.$(PROG) $(LIBS)

build_gprof: setup
	$(CC) -shared -fPIC gprof-helper.c -o gprof-helper.so $(LIBS) -ldl
	$(CC) $(BLDFLAGS) $(COMMONFLAGS) $(CPFLAGS) -c $(SOURCE) -o $(OBJDIR)/$(PROG).o $(INCLUDES)
	$(CC) $(BLDFLAGS) $(COMMONFLAGS) $(CPFLAGS) $(SFLAGS)  $(OBJDIR)/$(PROG).o -o $(DISTDIR)/gprof.$(PROG) $(LIBS)
	@echo "\nNote: To profile convert2bed with gprof/pthreads, run:\n\t$$ LD_PRELOAD=/path/to/gprof-helper.so convert2bed"

clean:
	rm -rf $(DISTDIR)
	rm -rf $(OBJDIR)
	rm -rf  *.so *~
