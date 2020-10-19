PROGNAME=opc

CC= gcc -std=gnu99
CFLAGS= -O2 -Wall -Wextra $(SYSCFLAGS) $(MYCFLAGS)
LDFLAGS= $(SYSLDFLAGS) $(MYLDFLAGS)
LIBS= -lm $(SYSLIBS) $(MYLIBS)

AR= ar rcu
RANLIB= ranlib
RM= rm -f
UNAME= uname

SYSCFLAGS=
SYSLDFLAGS=
SYSLIBS=

default:
	@echo Guessing `$(UNAME)`
	@$(MAKE) `$(UNAME)`

$(PROGNAME): config.h main.c lua/liblua.a lpoint.c lpoint.h lbind.h lbind.c lload.h lload.c 
	@gcc -Wall -Wextra -DLUA_COMPAT_5_3 -DLUA_USE_LINUX -o $(PROGNAME) main.c lbind.c lpoint.c lload.c lua/liblua.a -lm -ldl

test: config.h test.c lua/liblua.a lpoint.c lpoint.h lbind.h lbind.c lload.h lload.c 
	@gcc -Wall -Wextra -DLUA_COMPAT_5_3 -DLUA_USE_LINUX -o test test.c lbind.c lpoint.c lload.c lua/liblua.a -lm -ldl

lua/liblua.a: lua/*.c lua/*.h
	@$(MAKE) -s -C lua liblua.a

config.h:
	echo '#define OPC_HOME "$(CURDIR)"' > config.h

.PHONY:
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
