PROGNAME=opc

CC= gcc
CFLAGS= -std=gnu99 -O0 -g -Wall -Wextra -Wstrict-prototypes $(SYSCFLAGS) $(MYCFLAGS)
LDFLAGS= $(SYSLDFLAGS) $(MYLDFLAGS)
LIBS= -lm $(SYSLIBS) $(MYLIBS)

AR= ar rcu
RANLIB= ranlib
RM= rm -f
UNAME= uname

SYSCFLAGS=
SYSLDFLAGS=
SYSLIBS=

OPCOBJ:=util.o point.o transformationmatrix.o ltransformationmatrix.o shape.o object.o geometry.o keyvaluepairs.o generics.o lgenerics.o lgeometry.o ldir.o lpoint.o graphics.o lbind.o lload.o lbinary.o lshape.o lobject.o pcell.o lport.o lfilesystem.o lbytebuffer.o lplacer.o lplacer_rand.o lrouter.o lrouter_net.o lrouter_queue.o lrouter_field.o lrouter_route.o lutil.o gdsparser.o ldebug.o lexport.o lexport_common.o gdsexport.o

.PHONY: default
default:
	@echo Guessing `$(UNAME)`
	@$(MAKE) `$(UNAME)`

$(PROGNAME): main.c lua/liblua.a $(OPCOBJ)
	$(CC) $(CFLAGS) -DLUA_COMPAT_5_3 -DLUA_USE_LINUX -o $(PROGNAME) main.c $(OPCOBJ) lua/liblua.a -lm -ldl

util.o: util.h util.c
point.o: point.h point.c
transformationmatrix.o: transformationmatrix.h transformationmatrix.c
ltransformationmatrix.o: ltransformationmatrix.h ltransformationmatrix.c transformationmatrix.h transformationmatrix.c
shape.o: point.h shape.h shape.c generics.h generics.c
object.o: object.h object.c transformationmatrix.h shape.h
geometry.o: geometry.h geometry.c point.h point.c shape.h shape.c
keyvaluepairs.o: keyvaluepairs.h keyvaluepairs.c
generics.o: generics.h generics.c keyvaluepairs.h
lgenerics.o: lgenerics.h lgenerics.c generics.h generics.c keyvaluepairs.h
lgeometry.o: lgeometry.h lgeometry.c geometry.h geometry.c point.h point.c shape.h shape.c
lpoint.o: lpoint.h lpoint.c
graphics.o: graphics.h graphics.c
ldir.o: ldir.c ldir.h
lbind.o: lbind.h lbind.c
lload.o: lload.h lload.c
lbinary.o: lbinary.h lbinary.c
lshape.o: lshape.h lshape.c shape.h shape.c lpoint.h ltransformationmatrix.h
lobject.o: lobject.h lobject.c
pcell.o: pcell.c pcell.h
lexport.o: lexport.h lexport.c lexport_common.h lobject.h object.h pcell.h gdsexport.h
lport.o: lport.h lport.c
lfilesystem.o: lfilesystem.h lfilesystem.c
lutil.o: lutil.c lutil.h
lbytebuffer.o: lbytebuffer.h lbytebuffer.c

lplacer.o: lplacer.h lplacer.c
lplacer_rand.o: lplacer_rand.h lplacer_rand.c

lrouter.o: lrouter.c lrouter.h
lrouter_net.o: lrouter_net.h lrouter_net.c
lrouter_queue.o: lrouter_queue.h lrouter_queue.c
lrouter_field.o: lrouter_field.h lrouter_field.c
lrouter_route.o: lrouter_route.h lrouter_route.c

gdsparser.o: gdsparser.h gdsparser.c

ldebug.o: ldebug.h ldebug.c

lexport_common.o: lexport_common.h lexport_common.c
gdsexport.o: gdsexport.c gdsexport.h

lua/liblua.a: lua/*.c lua/*.h
	@$(MAKE) -C lua liblua.a

.PHONY: clean
clean:
	rm -f $(PROGNAME) config.h
	rm -f $(OPCOBJ)
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
