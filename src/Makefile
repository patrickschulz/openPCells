PROGNAME=opc

CC= gcc

CFLAGS= -std=c99 -O3 -Wall -Wextra -Wstrict-prototypes -pthread
ifeq ($(DEBUG), 1)
    CFLAGS= -std=c99 -O0 -g -Werror -fanalyzer -fsanitize=address -fsanitize=leak -fsanitize=undefined -Wall -Wextra -Werror=return-type -Werror=implicit-function-declaration -Werror=int-conversion -Werror=discarded-qualifiers -Wstrict-prototypes -pthread
endif

LDFLAGS= $(SYSLDFLAGS) $(MYLDFLAGS)
LIBS= -lm $(SYSLIBS) $(MYLIBS)

AR= ar rcu
RANLIB= ranlib
RM= rm -f
UNAME= uname

OPCOBJ:= cmdoptions.o export_common.o export.o export_writer.o filesystem.o gdsexport.o gdsparser.o geometry.o geometry_triangulate.o graphics.o hashmap.o info.o ldebug.o ldir.o lgenerics.o lgeometry.o lobject.o lplacer_classic.o lplacer_common.o lplacer_nonoverlapping.o lplacer.o lplacer_rand.o lpoint.o lrouter_field.o lrouter_min_heap.o lrouter_moves.o lrouter_net.o lrouter.o lrouter_queue.o lrouter_route.o lua_util.o main.api_help.o main.cell.o main.functions.o main.gds.o main.verilog.o object.o pcell.o point.o postprocess.o shape.o tagged_value.o technology.o terminal_colors.o transformationmatrix.o union.o util.o vector.o

.PHONY: default
default:
	@echo Guessing `$(UNAME)`
	@$(MAKE) `$(UNAME)`

$(PROGNAME): main.c lua/liblua.a modulemanager.h modulemanager.c scriptmanager.h scriptmanager.c $(OPCOBJ)
	$(CC) $(CFLAGS) -DLUA_COMPAT_5_3 -DLUA_USE_LINUX -o $(PROGNAME) main.c $(OPCOBJ) modulemanager.c scriptmanager.c lua/liblua.a -lm -ldl

opc.1: cmdoptions_def.c generate_manpage
	./generate_manpage > opc.1

generate_manpage: cmdoptions.h cmdoptions.c generate_manpage.c
	$(CC) $(CFLAGS) generate_manpage.c cmdoptions.c vector.c util.c -o generate_manpage

lua/liblua.a: lua/*.c lua/*.h
	@$(MAKE) -C lua liblua.a

lua/luac:
	@$(MAKE) -C lua luac

scriptmanager.c: embed_compiled_lua_file scripts/*.lua
	@echo '#include "scriptmanager.h"' > scriptmanager.c
	@echo '#include <stddef.h>' >> scriptmanager.c
	@echo '#include "main.functions.h"' >> scriptmanager.c
	./embed_compiled_lua_file --script scripts/create_cell.lua script_call create_cell scriptmanager.c
	./embed_compiled_lua_file --script scripts/list_cells.lua script_call list_cells scriptmanager.c
	./embed_compiled_lua_file --script scripts/assistant.lua script_call assistant scriptmanager.c
	./embed_compiled_lua_file --script scripts/show_gds_hierarchy.lua script_call show_gds_hierarchy scriptmanager.c
	./embed_compiled_lua_file --script scripts/list_parameters.lua script_call list_parameters scriptmanager.c

scriptmanager.h:
	@echo '#ifndef OPC_SCRIPTMANAGER_H' > scriptmanager.h
	@echo '#define OPC_SCRIPTMANAGER_H' >> scriptmanager.h
	@echo '#include "lua/lua.h"' >> scriptmanager.h
	@echo 'int script_call_create_cell(lua_State* L);' >> scriptmanager.h
	@echo 'int script_call_list_cells(lua_State* L);' >> scriptmanager.h
	@echo 'int script_call_assistant(lua_State* L);' >> scriptmanager.h
	@echo 'int script_call_show_gds_hierarchy(lua_State* L);' >> scriptmanager.h
	@echo 'int script_call_list_parameters(lua_State* L);' >> scriptmanager.h
	@echo '#endif // OPC_SCRIPTMANAGER_H' >> scriptmanager.h

modulemanager.c: embed_compiled_lua_file modules/*.lua
	@echo '#include "modulemanager.h"' > modulemanager.c
	@echo '#include <stddef.h>' >> modulemanager.c
	@echo '#include "main.functions.h"' >> modulemanager.c
	./embed_compiled_lua_file --module modules/aux.lua module_load aux modulemanager.c
	./embed_compiled_lua_file --module modules/gdsparser.lua module_load gdsparser modulemanager.c
	./embed_compiled_lua_file --module modules/generator.lua module_load generator modulemanager.c
	./embed_compiled_lua_file --module modules/geometry.lua module_load geometry modulemanager.c
	./embed_compiled_lua_file --module modules/globals.lua module_load globals modulemanager.c
	./embed_compiled_lua_file --module modules/graphics.lua module_load graphics modulemanager.c
	./embed_compiled_lua_file --module modules/load.lua module_load load modulemanager.c
	./embed_compiled_lua_file --module modules/pcell.lua module_load pcell modulemanager.c
	./embed_compiled_lua_file --module modules/placement.lua module_load placement modulemanager.c
	./embed_compiled_lua_file --module modules/point.lua module_load point modulemanager.c
	./embed_compiled_lua_file --module modules/routing.lua module_load routing modulemanager.c
	./embed_compiled_lua_file --module modules/stack.lua module_load stack modulemanager.c
	./embed_compiled_lua_file --module modules/util.lua module_load util modulemanager.c
	./embed_compiled_lua_file --module modules/verilog.lua module_load verilog modulemanager.c
	./embed_compiled_lua_file --module modules/verilogprocessor.lua module_load verilogprocessor modulemanager.c

modulemanager.h:
	@echo '#ifndef OPC_MODULEMANAGER_H' > modulemanager.h
	@echo '#define OPC_MODULEMANAGER_H' >> modulemanager.h
	@echo '#include "lua/lua.h"' >> modulemanager.h
	@echo 'int module_load_aux(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_gdsparser(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_generator(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_geometry(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_globals(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_graphics(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_load(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_pcell(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_placement(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_point(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_routing(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_stack(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_util(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_verilog(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_verilogprocessor(lua_State* L);' >> modulemanager.h
	@echo '#endif // OPC_MODULEMANAGER_H' >> modulemanager.h

embed_compiled_lua_file: embed_compiled_lua_file.c lua/liblua.a
	$(CC) $(CFLAGS) embed_compiled_lua_file.c lua/liblua.a -o embed_compiled_lua_file -lm

.PHONY: clean
clean:
	rm -f $(PROGNAME)
	rm -f config.h
	rm -f embed_compiled_lua_file
	rm -f generate_manpage
	rm -f modulemanager.h modulemanager.c
	rm -f scriptmanager.h scriptmanager.c
	rm -f scriptmanager.h scriptmanager.c
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

# generated by gcc -MM -MG *.c
# the following files are removed manually:
# * cmdoptions_def.o
# * embed_compiled_lua_file.o
# * generate_manpage.o
# * modulemanager.o
# * scriptmanager.o
# * main.o
cmdoptions.o: cmdoptions.c cmdoptions.h vector.h util.h
export.o: export.c export.h object.h transformationmatrix.h point.h \
 shape.h technology.h lua/lua.h lua/luaconf.h vector.h hashmap.h \
 lua/lauxlib.h lua/lua.h export_common.h export_writer.h util.h \
 lua_util.h gdsexport.h filesystem.h
export_common.o: export_common.c export_common.h object.h \
 transformationmatrix.h point.h shape.h technology.h lua/lua.h \
 lua/luaconf.h vector.h hashmap.h
export_writer.o: export_writer.c export_writer.h lua/lua.h lua/luaconf.h \
 export_common.h object.h transformationmatrix.h point.h shape.h \
 technology.h vector.h hashmap.h tagged_value.h util.h
filesystem.o: filesystem.c filesystem.h lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h
gdsexport.o: gdsexport.c gdsexport.h export_common.h object.h \
 transformationmatrix.h point.h shape.h technology.h lua/lua.h \
 lua/luaconf.h vector.h hashmap.h tagged_value.h
gdsparser.o: gdsparser.c gdsparser.h lua/lua.h lua/luaconf.h vector.h \
 lua/lauxlib.h lua/lua.h filesystem.h point.h hashmap.h lua_util.h
geometry.o: geometry.c geometry.h technology.h lua/lua.h lua/luaconf.h \
 vector.h hashmap.h object.h transformationmatrix.h point.h shape.h
geometry_triangulate.o: geometry_triangulate.c point.h vector.h
graphics.o: graphics.c graphics.h point.h vector.h
hashmap.o: hashmap.c hashmap.h
info.o: info.c info.h object.h transformationmatrix.h point.h shape.h \
 technology.h lua/lua.h lua/luaconf.h vector.h hashmap.h
ldebug.o: ldebug.c ldebug.h lua/lua.h lua/luaconf.h
ldir.o: ldir.c ldir.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lua.h
lgenerics.o: lgenerics.c lgenerics.h lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h technology.h vector.h hashmap.h
lgeometry.o: lgeometry.c lgeometry.h lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h geometry.h technology.h vector.h hashmap.h \
 object.h transformationmatrix.h point.h shape.h lobject.h lpoint.h \
 graphics.h
lobject.o: lobject.c lobject.h lua/lua.h lua/luaconf.h object.h \
 transformationmatrix.h point.h shape.h technology.h vector.h hashmap.h \
 lua/lauxlib.h lua/lua.h lpoint.h
lplacer.o: lplacer.c lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lua.h \
 lplacer_nonoverlapping.h lplacer_classic.h
lplacer_classic.o: lplacer_classic.c lplacer_classic.h lua/lua.h \
 lua/luaconf.h lplacer_common.h hashmap.h lplacer_rand.h util.h
lplacer_common.o: lplacer_common.c lplacer_common.h lua/lua.h \
 lua/luaconf.h hashmap.h
lplacer_nonoverlapping.o: lplacer_nonoverlapping.c \
 lplacer_nonoverlapping.h lua/lua.h lua/luaconf.h lplacer_common.h \
 hashmap.h lplacer_rand.h
lplacer_rand.o: lplacer_rand.c lplacer_rand.h lua/lua.h lua/luaconf.h
lpoint.o: lpoint.c lpoint.h lua/lua.h lua/luaconf.h point.h lua/lauxlib.h \
 lua/lua.h
lrouter.o: lrouter.c lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lua.h \
 lrouter_net.h lrouter_field.h vector.h lrouter_route.h lrouter_moves.h \
 ldebug.h
lrouter_field.o: lrouter_field.c lrouter_field.h
lrouter_min_heap.o: lrouter_min_heap.c lrouter_field.h lrouter_min_heap.h
lrouter_moves.o: lrouter_moves.c lua/lua.h lua/luaconf.h lua/lauxlib.h \
 lua/lua.h lrouter_moves.h
lrouter_net.o: lrouter_net.c lrouter_net.h lrouter_field.h vector.h \
 lrouter_queue.h util.h
lrouter_queue.o: lrouter_queue.c lrouter_queue.h lrouter_field.h
lrouter_route.o: lrouter_route.c lrouter_route.h lrouter_net.h \
 lrouter_field.h vector.h lrouter_queue.h lrouter_min_heap.h
lua_util.o: lua_util.c lua_util.h lua/lua.h lua/luaconf.h lua/lauxlib.h \
 lua/lua.h lua/lualib.h
main.api_help.o: main.api_help.c main.api_help.h terminal_colors.h \
 vector.h
main.cell.o: main.cell.c main.cell.h hashmap.h cmdoptions.h vector.h \
 lua/lauxlib.h lua/luaconf.h lua/lua.h lpoint.h lua/lua.h point.h \
 lgeometry.h lgenerics.h ldir.h lobject.h object.h transformationmatrix.h \
 shape.h technology.h filesystem.h lplacer.h lrouter.h gdsparser.h util.h \
 lua_util.h export.h info.h postprocess.h geometry.h pcell.h config.h \
 main.functions.h modulemanager.h scriptmanager.h
main.functions.o: main.functions.c main.functions.h lua/lua.h \
 lua/luaconf.h lua/lauxlib.h lua/lua.h lua_util.h
main.gds.o: main.gds.c main.gds.h cmdoptions.h vector.h main.functions.h \
 lua/lua.h lua/luaconf.h lua_util.h gdsparser.h scriptmanager.h \
 modulemanager.h
main.verilog.o: main.verilog.c lua/lua.h lua/luaconf.h lua/lauxlib.h \
 lua/lua.h util.h lua_util.h modulemanager.h filesystem.h lplacer.h \
 lrouter.h main.functions.h
object.o: object.c object.h transformationmatrix.h point.h shape.h \
 technology.h lua/lua.h lua/luaconf.h vector.h hashmap.h util.h
pcell.o: pcell.c pcell.h lua/lua.h lua/luaconf.h vector.h lua/lauxlib.h \
 lua/lua.h util.h lua_util.h lobject.h object.h transformationmatrix.h \
 point.h shape.h technology.h hashmap.h ldir.h scriptmanager.h \
 modulemanager.h
point.o: point.c point.h
postprocess.o: postprocess.c postprocess.h object.h \
 transformationmatrix.h point.h shape.h technology.h lua/lua.h \
 lua/luaconf.h vector.h hashmap.h union.h
shape.o: shape.c shape.h point.h transformationmatrix.h technology.h \
 lua/lua.h lua/luaconf.h vector.h hashmap.h graphics.h geometry.h \
 object.h
tagged_value.o: tagged_value.c tagged_value.h
technology.o: technology.c technology.h lua/lua.h lua/luaconf.h vector.h \
 hashmap.h lua/lauxlib.h lua/lua.h util.h lua_util.h tagged_value.h
terminal_colors.o: terminal_colors.c terminal_colors.h
transformationmatrix.o: transformationmatrix.c transformationmatrix.h \
 point.h
union.o: union.c union.h vector.h point.h shape.h transformationmatrix.h \
 technology.h lua/lua.h lua/luaconf.h hashmap.h
util.o: util.c util.h
vector.o: vector.c vector.h
