PROGNAME=opc

CC=gcc

PPFLAGS=-DLUA_USE_LINUX -DCMDOPTIONS_ENABLE_TERM_WIDTH

CFLAGS=-std=c99 -O3 -Wall -Wextra -Wstrict-prototypes -pthread $(PPFLAGS)
ifeq ($(DEBUG), 1)
    CFLAGS=-std=c99 -O0 -g -Wall -Wextra -Wstrict-prototypes -pthread $(PPFLAGS)
endif
ifeq ($(DEBUGANALYZE), 1)
    CFLAGS=-std=c99 -O0 -g -fanalyzer -fsanitize=address -fsanitize=leak -fsanitize=undefined -Wall -Wextra -Werror=return-type -Werror=implicit-function-declaration -Werror=int-conversion -Wno-analyzer-deref-before-check -Werror=discarded-qualifiers -Wstrict-prototypes -pthread $(PPFLAGS)
endif

OPCOBJ:= cmdoptions.o export_common.o export.o export_writer.o filesystem.o gdsexport.o gdsparser.o geometry.o geometry_triangulate.o graphics.o hashmap.o info.o lcheck.o ldebug.o ldir.o lgenerics.o lgeometry.o lobject.o lplacement.o lplacer_classic.o lplacer_common.o lplacer_nonoverlapping.o lplacer.o lplacer_rand.o lpoint.o lpostprocess.o lrouter_field.o lrouter_min_heap.o lrouter_moves.o lrouter_net.o lrouter.o lrouter_queue.o lrouter_route.o lua_util.o lutil.o main.api_help.o main.cell.o main.functions.o main.gds.o main.verilog.o object.o pcell.o placement.o point.o polygon.o postprocess.o shape.o tagged_value.o technology.o terminal_colors.o transformationmatrix.o union.o util.o vector.o

.PHONY: default
default: $(PROGNAME)

$(PROGNAME): main.c lua/liblua.a modulemanager.h modulemanager.c scriptmanager.h scriptmanager.c $(OPCOBJ)
	$(CC) $(CFLAGS) -o $(PROGNAME) main.c $(OPCOBJ) modulemanager.c scriptmanager.c lua/liblua.a -lm -ldl

opc.1: cmdoptions_def.c generate_manpage
	./generate_manpage > opc.1

generate_manpage: cmdoptions.h cmdoptions.c generate_manpage.c
	$(CC) $(CFLAGS) generate_manpage.c cmdoptions.c vector.c util.c -o generate_manpage

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
	./embed_compiled_lua_file --module modules/check.lua module_load check modulemanager.c
	./embed_compiled_lua_file --module modules/gdsparser.lua module_load gdsparser modulemanager.c
	./embed_compiled_lua_file --module modules/generator.lua module_load generator modulemanager.c
	./embed_compiled_lua_file --module modules/globals.lua module_load globals modulemanager.c
	./embed_compiled_lua_file --module modules/graphics.lua module_load graphics modulemanager.c
	./embed_compiled_lua_file --module modules/layouthelpers.lua module_load layouthelpers modulemanager.c
	./embed_compiled_lua_file --module modules/load.lua module_load load modulemanager.c
	./embed_compiled_lua_file --module modules/pcell.lua module_load pcell modulemanager.c
	./embed_compiled_lua_file --module modules/placement.lua module_load placement modulemanager.c
	./embed_compiled_lua_file --module modules/routing.lua module_load routing modulemanager.c
	./embed_compiled_lua_file --module modules/stack.lua module_load stack modulemanager.c
	./embed_compiled_lua_file --module modules/util.lua module_load util modulemanager.c
	./embed_compiled_lua_file --module modules/verilog.lua module_load verilog modulemanager.c
	./embed_compiled_lua_file --module modules/verilogprocessor.lua module_load verilogprocessor modulemanager.c

modulemanager.h: modules/*.lua
	@echo '#ifndef OPC_MODULEMANAGER_H' > modulemanager.h
	@echo '#define OPC_MODULEMANAGER_H' >> modulemanager.h
	@echo '#include "lua/lua.h"' >> modulemanager.h
	@echo 'int module_load_aux(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_check(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_gdsparser(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_generator(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_globals(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_graphics(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_layouthelpers(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_load(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_pcell(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_placement(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_routing(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_stack(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_util(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_verilog(lua_State* L);' >> modulemanager.h
	@echo 'int module_load_verilogprocessor(lua_State* L);' >> modulemanager.h
	@echo '#endif // OPC_MODULEMANAGER_H' >> modulemanager.h

embed_compiled_lua_file: embed_compiled_lua_file.c lua/liblua.a
	$(CC) $(CFLAGS) embed_compiled_lua_file.c lua/liblua.a -o embed_compiled_lua_file -lm

create_latex_API_doc: create_latex_API_doc.c main.api_help.c main.api_help.h vector.c vector.h util.c util.h terminal_colors.c terminal_colors.h
	$(CC) $(CFLAGS) create_latex_API_doc.c main.api_help.c vector.c util.c terminal_colors.c -o create_latex_API_doc

.PHONY: clean
clean:
	rm -f lua/liblua.a $(LUA_CORE_O) $(LUA_LIB_O)
	rm -f $(PROGNAME)
	rm -f embed_compiled_lua_file
	rm -f generate_manpage
	rm -f modulemanager.h modulemanager.c
	rm -f scriptmanager.h scriptmanager.c
	rm -f scriptmanager.h scriptmanager.c
	rm -f $(OPCOBJ)
	rm -f lua/*.o lua/liblua.a

# generated by gcc -MM -MG *.c
# the following files are removed manually:
# * cmdoptions_def.o
# * create_latex_API_doc.o
# * embed_compiled_lua_file.o
# * generate_manpage.o
# * modulemanager.o
# * scriptmanager.o
# * main.o
cmdoptions.o: cmdoptions.c cmdoptions.h
cpu.o: cpu.c cpu.h
export_common.o: export_common.c export_common.h object.h hashmap.h \
 polygon.h point.h shape.h transformationmatrix.h technology.h lua/lua.h \
 lua/luaconf.h vector.h
export_writer.o: export_writer.c export_writer.h lua/lua.h lua/luaconf.h \
 export_common.h object.h hashmap.h polygon.h point.h shape.h \
 transformationmatrix.h technology.h vector.h tagged_value.h util.h \
 ldebug.h
filesystem.o: filesystem.c filesystem.h lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h
gdsexport.o: gdsexport.c gdsexport.h export_common.h object.h hashmap.h \
 polygon.h point.h shape.h transformationmatrix.h technology.h lua/lua.h \
 lua/luaconf.h vector.h math.h tagged_value.h geometry.h
gdsparser.o: gdsparser.c gdsparser.h lua/lua.h lua/luaconf.h vector.h \
 lua/lauxlib.h lua/lua.h math.h filesystem.h point.h hashmap.h lua_util.h \
 util.h
gencall.o: gencall.c
geometry.o: geometry.c geometry.h technology.h lua/lua.h lua/luaconf.h \
 vector.h hashmap.h object.h polygon.h point.h shape.h \
 transformationmatrix.h math.h
geometry_triangulate.o: geometry_triangulate.c math.h point.h vector.h
graphics.o: graphics.c graphics.h point.h vector.h math.h
hashmap.o: hashmap.c hashmap.h util.h
info.o: info.c info.h object.h hashmap.h polygon.h point.h shape.h \
 transformationmatrix.h technology.h lua/lua.h lua/luaconf.h vector.h
lcheck.o: lcheck.c lcheck.h lua/lua.h lua/luaconf.h
ldebug.o: ldebug.c ldebug.h lua/lua.h lua/luaconf.h
ldir.o: ldir.c ldir.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lua.h \
 util.h
lgenerics.o: lgenerics.c lgenerics.h lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h technology.h vector.h hashmap.h
lgeometry.o: lgeometry.c lgeometry.h lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h geometry.h technology.h vector.h hashmap.h \
 object.h polygon.h point.h shape.h transformationmatrix.h graphics.h \
 lcheck.h lobject.h lplacement.h lpoint.h lutil.h placement.h
lobject.o: lobject.c lobject.h lua/lua.h lua/luaconf.h object.h hashmap.h \
 polygon.h point.h shape.h transformationmatrix.h technology.h vector.h \
 lua/lauxlib.h lua/lua.h lpoint.h lcheck.h
lplacement.o: lplacement.c lplacement.h lua/lua.h lua/luaconf.h polygon.h \
 point.h lua/lauxlib.h lua/lua.h lcheck.h lobject.h object.h hashmap.h \
 shape.h transformationmatrix.h technology.h vector.h lpoint.h lutil.h \
 placement.h
lplacer.o: lplacer.c lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lua.h \
 lplacer_nonoverlapping.h lplacer_classic.h
lplacer_classic.o: lplacer_classic.c lplacer_classic.h lua/lua.h \
 lua/luaconf.h lplacer_common.h hashmap.h lplacer_rand.h math.h util.h
lplacer_common.o: lplacer_common.c lplacer_common.h lua/lua.h \
 lua/luaconf.h hashmap.h
lplacer_nonoverlapping.o: lplacer_nonoverlapping.c \
 lplacer_nonoverlapping.h lua/lua.h lua/luaconf.h lplacer_common.h \
 hashmap.h lplacer_rand.h
lplacer_rand.o: lplacer_rand.c lplacer_rand.h lua/lua.h lua/luaconf.h
lpoint.o: lpoint.c lpoint.h lua/lua.h lua/luaconf.h point.h lua/lauxlib.h \
 lua/lua.h math.h
lpostprocess.o: lpostprocess.c lpostprocess.h lua/lua.h lua/luaconf.h \
	postprocess.h
lrouter.o: lrouter.c lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lua.h \
 lrouter_net.h lrouter_field.h vector.h lrouter_route.h lrouter_moves.h
lrouter_field.o: lrouter_field.c lrouter_field.h
lrouter_min_heap.o: lrouter_min_heap.c lrouter_field.h lrouter_min_heap.h
lrouter_moves.o: lrouter_moves.c lua/lua.h lua/luaconf.h lua/lauxlib.h \
 lua/lua.h lrouter_moves.h
lrouter_net.o: lrouter_net.c lrouter_net.h lrouter_field.h vector.h \
 util.h
lrouter_queue.o: lrouter_queue.c lrouter_queue.h lrouter_field.h
lrouter_route.o: lrouter_route.c lrouter_route.h lrouter_net.h \
 lrouter_field.h vector.h lrouter_min_heap.h
lua_util.o: lua_util.c lua_util.h lua/lua.h lua/luaconf.h lua/lauxlib.h \
 lua/lua.h lua/lualib.h
lutil.o: lutil.c lutil.h lua/lua.h lua/luaconf.h polygon.h point.h \
 lpoint.h
main.api_help.o: main.api_help.c main.api_help.h terminal_colors.h util.h \
 vector.h main.api_help/aux.c main.api_help/curve.c \
 main.api_help/generics.c main.api_help/geometry.c main.api_help/global.c \
 main.api_help/graphics.c main.api_help/layouthelpers.c \
 main.api_help/object.c main.api_help/pcell.c main.api_help/placement.c \
 main.api_help/placer.c main.api_help/point.c main.api_help/router.c \
 main.api_help/routing.c main.api_help/technology.c main.api_help/util.c
main.cell.o: main.cell.c main.cell.h hashmap.h cmdoptions.h lua/lauxlib.h \
 lua/luaconf.h lua/lua.h export.h object.h polygon.h point.h shape.h \
 transformationmatrix.h technology.h lua/lua.h vector.h filesystem.h \
 gdsparser.h geometry.h info.h pcell.h postprocess.h util.h ldir.h \
 lgenerics.h lgeometry.h lobject.h lplacement.h lplacer.h lpoint.h \
 lrouter.h lua_util.h config.h main.functions.h modulemanager.h \
 scriptmanager.h
main.functions.o: main.functions.c main.functions.h lua/lua.h \
 lua/luaconf.h lua/lauxlib.h lua/lua.h lua_util.h
main.gds.o: main.gds.c main.gds.h cmdoptions.h main.functions.h lua/lua.h \
 lua/luaconf.h lua_util.h gdsparser.h vector.h scriptmanager.h \
 modulemanager.h
main.verilog.o: main.verilog.c main.verilog.h vector.h lua/lua.h \
 lua/luaconf.h lua/lauxlib.h lua/lua.h filesystem.h lplacement.h \
 polygon.h point.h lplacer.h lrouter.h lua_util.h modulemanager.h util.h \
 main.functions.h
object.o: object.c object.h hashmap.h polygon.h point.h shape.h \
 transformationmatrix.h technology.h lua/lua.h lua/luaconf.h vector.h \
 util.h
pcell.o: pcell.c pcell.h lua/lua.h lua/luaconf.h vector.h lua/lauxlib.h \
 lua/lua.h util.h lua_util.h ldir.h scriptmanager.h modulemanager.h
placement.o: placement.c placement.h object.h hashmap.h polygon.h point.h \
 shape.h transformationmatrix.h technology.h lua/lua.h lua/luaconf.h \
 vector.h util.h
point.o: point.c point.h
polygon.o: polygon.c polygon.h point.h vector.h
postprocess.o: postprocess.c postprocess.h object.h hashmap.h polygon.h \
 point.h shape.h transformationmatrix.h technology.h lua/lua.h \
 lua/luaconf.h vector.h union.h
shape.o: shape.c shape.h point.h transformationmatrix.h technology.h \
 lua/lua.h lua/luaconf.h vector.h hashmap.h math.h graphics.h geometry.h \
 object.h polygon.h
tagged_value.o: tagged_value.c tagged_value.h util.h
technology.o: technology.c technology.h lua/lua.h lua/luaconf.h vector.h \
 hashmap.h lua/lauxlib.h lua/lua.h util.h lua_util.h tagged_value.h
terminal_colors.o: terminal_colors.c terminal_colors.h
transformationmatrix.o: transformationmatrix.c transformationmatrix.h \
 point.h
union.o: union.c union.h vector.h point.h shape.h transformationmatrix.h \
 technology.h lua/lua.h lua/luaconf.h hashmap.h
util.o: util.c util.h
vector.o: vector.c vector.h

# lua object files and build rules
LUA_CORE_O= lua/lapi.o lua/lcode.o lua/lctype.o lua/ldebug.o lua/ldo.o lua/ldump.o lua/lfunc.o lua/lgc.o lua/llex.o lua/lmem.o lua/lobject.o lua/lopcodes.o lua/lparser.o lua/lstate.o lua/lstring.o lua/ltable.o lua/ltm.o lua/lundump.o lua/lvm.o lua/lzio.o
LUA_LIB_O=	lua/lauxlib.o lua/lbaselib.o lua/lcorolib.o lua/ldblib.o lua/liolib.o lua/lmathlib.o lua/loadlib.o lua/loslib.o lua/lstrlib.o lua/ltablib.o lua/linit.o

lua/liblua.a: $(LUA_CORE_O) $(LUA_LIB_O)
	ar rcu $@ $(LUA_CORE_O) $(LUA_LIB_O)
	ranlib $@

lua/lapi.o: lua/lapi.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lundump.h lua/lvm.h
lua/lauxlib.o: lua/lauxlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h
lua/lbaselib.o: lua/lbaselib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lua/lcode.o: lua/lcode.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lcode.h lua/llex.h lua/lobject.h lua/llimits.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/lstate.h lua/ltm.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
lua/lcorolib.o: lua/lcorolib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lua/lctype.o: lua/lctype.c lua/lprefix.h lua/lctype.h lua/lua.h lua/luaconf.h lua/llimits.h
lua/ldblib.o: lua/ldblib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lua/ldebug.o: lua/ldebug.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lcode.h lua/llex.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/ltable.h lua/lvm.h
lua/ldo.o: lua/ldo.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lopcodes.h lua/lparser.h lua/lstring.h lua/ltable.h lua/lundump.h lua/lvm.h
lua/ldump.o: lua/ldump.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lobject.h lua/llimits.h lua/lstate.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lundump.h
lua/lfunc.o: lua/lfunc.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h
lua/lgc.o: lua/lgc.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lstring.h lua/ltable.h
lua/linit.o: lua/linit.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lualib.h lua/lauxlib.h
lua/liolib.o: lua/liolib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lua/llex.o: lua/llex.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lctype.h lua/llimits.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/llex.h lua/lparser.h lua/lstring.h lua/ltable.h
lua/lmathlib.o: lua/lmathlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lua/lmem.o: lua/lmem.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h
lua/loadlib.o: lua/loadlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lua/lobject.o: lua/lobject.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lctype.h lua/llimits.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lstring.h lua/lgc.h lua/lvm.h
lua/lopcodes.o: lua/lopcodes.c lua/lprefix.h lua/lopcodes.h lua/llimits.h lua/lua.h lua/luaconf.h
lua/loslib.o: lua/loslib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lua/lparser.o: lua/lparser.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lcode.h lua/llex.h lua/lobject.h lua/llimits.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/lstate.h lua/ltm.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/ltable.h
lua/lstate.o: lua/lstate.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/llex.h lua/lstring.h lua/ltable.h
lua/lstring.o: lua/lstring.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lstring.h lua/lgc.h
lua/lstrlib.o: lua/lstrlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lua/ltable.o: lua/ltable.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
lua/ltablib.o: lua/ltablib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lua/ltm.o: lua/ltm.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
lua/lua.o: lua/lua.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lua/luac.o: lua/luac.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lopnames.h lua/lundump.h
lua/lundump.o: lua/lundump.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/lundump.h
lua/lvm.o: lua/lvm.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lopcodes.h lua/lstring.h lua/ltable.h lua/lvm.h lua/ljumptab.h
lua/lzio.o: lua/lzio.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/llimits.h lua/lmem.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h

