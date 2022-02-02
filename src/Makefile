PROGNAME=opc

CC= gcc -std=gnu99
CFLAGS= -O0 -g -Wall -Wextra $(SYSCFLAGS) $(MYCFLAGS)
LDFLAGS= $(SYSLDFLAGS) $(MYLDFLAGS)
LIBS= -lm $(SYSLIBS) $(MYLIBS)

AR= ar rcu
RANLIB= ranlib
RM= rm -f
UNAME= uname

SYSCFLAGS=
SYSLDFLAGS=
SYSLIBS=

OPCOBJ:=ldir.o lpoint.o lbind.o lload.o lbinary.o lshape.o lfilesystem.o lbytebuffer.o lplacer.o lplacer_rand.o lrouter.o lrouter_net.o lrouter_queue.o lrouter_min_heap.o lrouter_field.o lrouter_route.o lutil.o

.PHONY: default
default:
	@echo Guessing `$(UNAME)`
	@$(MAKE) `$(UNAME)`

$(PROGNAME): main.c lua/liblua.a $(OPCOBJ)
	$(CC) $(CFLAGS) -DLUA_COMPAT_5_3 -DLUA_USE_LINUX -o $(PROGNAME) main.c $(OPCOBJ) lua/liblua.a -lm -ldl

lpoint.o: lpoint.h lpoint.c
ldir.o: ldir.c ldir.h
lbind.o: lbind.h lbind.c
lload.o: lload.h lload.c
lbinary.o: lbinary.h lbinary.c
lshape.o: lshape.h lshape.c
lfilesystem.o: lfilesystem.h lfilesystem.c
lutil.o: lutil.c lutil.h
lbytebuffer.o: lbytebuffer.h lbytebuffer.c

lplacer.o: lplacer.h lplacer.c
lplacer_rand.o: lplacer_rand.h lplacer_rand.c

lrouter.o: lrouter.c lrouter.h
lrouter_net.o: lrouter_net.h lrouter_net.c
lrouter_queue.o: lrouter_queue.h lrouter_queue.c
lrouter_min_heap.o: lrouter_min_heap.h lrouter_min_heap.c
lrouter_field.o: lrouter_field.h lrouter_field.c
lrouter_route.o: lrouter_route.h lrouter_route.c

lua/liblua.a: lua/*.c lua/*.h
	@$(MAKE) -C lua liblua.a

.PHONY: clean
clean:
	rm -f $(PROGNAME) config.h
	rm -f lua/*.o lua/liblua.a

AIX aix:
	@$(MAKE) $(ALL) CC="xlc" CFLAGS="-O2 -DLUA_USE_POSIX -DLUA_USE_DLOPEN" SYSLIBS="-ldl" SYSLDFLAGS="-brtl -bexpall"

bsd:
	@$(MAKE) $(ALL) SYSCFLAGS="-DLUA_USE_POSIX -DLUA_USE_DLOPEN" SYSLIBS="-Wl,-E"

c89:
	@$(MAKE) $(ALL) SYSCFLAGS="-DLUA_USE_C89" CC="gcc -std=c89"
	@echo ''
	@echo '*** C89 does not guarantee 64-bit integers for Lua.'
	@echo ''

FreeBSD NetBSD OpenBSD freebsd:
	@$(MAKE) $(ALL) SYSCFLAGS="-DLUA_USE_LINUX -DLUA_USE_READLINE -I/usr/include/edit" SYSLIBS="-Wl,-E -ledit" CC="cc"

generic: $(ALL)

Linux linux:	linux-noreadline

linux-noreadline:
	@$(MAKE) $(PROGNAME) SYSCFLAGS="-DLUA_USE_LINUX" SYSLIBS="-Wl,-E -ldl"

Darwin macos macosx:
	@$(MAKE) $(ALL) SYSCFLAGS="-DLUA_USE_MACOSX -DLUA_USE_READLINE" SYSLIBS="-lreadline"

mingw:
	@$(MAKE) "LUA_A=lua54.dll" "LUA_T=lua.exe" \
	"AR=$(CC) -shared -o" "RANLIB=strip --strip-unneeded" \
	"SYSCFLAGS=-DLUA_BUILD_AS_DLL" "SYSLIBS=" "SYSLDFLAGS=-s" lua.exe
	@$(MAKE) "LUAC_T=luac.exe" luac.exe

posix:
	@$(MAKE) $(ALL) SYSCFLAGS="-DLUA_USE_POSIX"

SunOS solaris:
	@$(MAKE) $(ALL) SYSCFLAGS="-DLUA_USE_POSIX -DLUA_USE_DLOPEN -D_REENTRANT" SYSLIBS="-ldl"

ifndef VERBOSE
.SILENT:
endif
