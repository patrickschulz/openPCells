PROGNAME=opc

CC=gcc
export CC

CFLAGS=-std=c99 -O3 -Wall -Wextra -Wstrict-prototypes -pthread -DLUA_USE_LINUX
ifeq ($(DEBUG), 1)
    CFLAGS=-std=c99 -O0 -g -Wall -Wextra -Wstrict-prototypes -pthread
endif
ifeq ($(DEBUGANALYZE), 1)
    CFLAGS=-std=c99 -O0 -g -fanalyzer -Wno-analyzer-deref-before-check -fsanitize=address -fsanitize=leak -fsanitize=undefined -Wall -Wextra -Werror=return-type -Werror=implicit-function-declaration -Werror=int-conversion -Werror=discarded-qualifiers -Wstrict-prototypes -pthread
endif
export CFLAGS

OPCOBJ:=cmdoptions.o export_common.o export.o export_writer.o filesystem.o gdsexport.o gdsparser.o geometry.o geometry_triangulate.o graphics.o hashmap.o info.o layout_util.o lcheck.o ldebug.o ldir.o lgenerics.o lgeometry.o lobject.o lplacer_classic.o lplacer_common.o lplacer_nonoverlapping.o lplacement.o lplacer.o lplacer_rand.o lpoint.o lrouter_field.o lrouter_min_heap.o lrouter_moves.o lrouter_net.o lrouter.o lrouter_queue.o lrouter_route.o lutil.o lua_util.o main.api_help.o main.cell.o main.functions.o main.gds.o main.verilog.o placement.o polygon.o object.o pcell.o point.o postprocess.o shape.o tagged_value.o technology.o terminal_colors.o transformationmatrix.o union.o util.o vector.o

.PHONY: default
default: $(PROGNAME)

$(PROGNAME): main.c lua/liblua.a modulemanager.h modulemanager.c scriptmanager.h scriptmanager.c $(OPCOBJ)
	$(CC) $(CFLAGS) -o $(PROGNAME) main.c $(OPCOBJ) modulemanager.c scriptmanager.c lua/liblua.a -lm -ldl

opc.1: cmdoptions_def.c generate_manpage
	./generate_manpage > opc.1

generate_manpage: cmdoptions.h cmdoptions.c generate_manpage.c
	$(CC) $(CFLAGS) generate_manpage.c cmdoptions.c vector.c util.c -o generate_manpage

lua/liblua.a: lua/*.c lua/*.h
	@$(MAKE) -C lua liblua.a

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
	./embed_compiled_lua_file --module modules/globals.lua module_load globals modulemanager.c
	./embed_compiled_lua_file --module modules/graphics.lua module_load graphics modulemanager.c
	./embed_compiled_lua_file --module modules/load.lua module_load load modulemanager.c
	./embed_compiled_lua_file --module modules/pcell.lua module_load pcell modulemanager.c
	./embed_compiled_lua_file --module modules/placement.lua module_load placement modulemanager.c
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
# * embed_compiled_lua_file.o
# * generate_manpage.o
# * modulemanager.o
# * scriptmanager.o
# * main.o
cmdoptions.o: cmdoptions.c cmdoptions.h vector.h util.h
cpu.o: cpu.c cpu.h
export.o: export.c export.h object.h hashmap.h polygon.h vector.h shape.h \
 point.h transformationmatrix.h technology.h lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h export_common.h export_writer.h util.h \
 lua_util.h gdsexport.h filesystem.h
export_common.o: export_common.c export_common.h object.h hashmap.h \
 polygon.h vector.h shape.h point.h transformationmatrix.h technology.h \
 lua/lua.h lua/luaconf.h
export_writer.o: export_writer.c export_writer.h lua/lua.h lua/luaconf.h \
 export_common.h object.h hashmap.h polygon.h vector.h shape.h point.h \
 transformationmatrix.h technology.h tagged_value.h util.h ldebug.h
filesystem.o: filesystem.c filesystem.h lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h
gdsexport.o: gdsexport.c gdsexport.h export_common.h object.h hashmap.h \
 polygon.h vector.h shape.h point.h transformationmatrix.h technology.h \
 lua/lua.h lua/luaconf.h math.h tagged_value.h
gdsparser.o: gdsparser.c gdsparser.h lua/lua.h lua/luaconf.h vector.h \
 lua/lauxlib.h lua/lua.h math.h filesystem.h point.h hashmap.h lua_util.h \
 util.h
geometry.o: geometry.c geometry.h technology.h lua/lua.h lua/luaconf.h \
 vector.h hashmap.h object.h polygon.h shape.h point.h \
 transformationmatrix.h math.h
geometry_triangulate.o: geometry_triangulate.c math.h point.h vector.h
graphics.o: graphics.c graphics.h point.h vector.h math.h
hashmap.o: hashmap.c hashmap.h util.h
info.o: info.c info.h object.h hashmap.h polygon.h vector.h shape.h \
 point.h transformationmatrix.h technology.h lua/lua.h lua/luaconf.h
layout_util.o: layout_util.c layout_util.h point.h vector.h
lcheck.o: lcheck.c lcheck.h lua/lua.h lua/luaconf.h
ldebug.o: ldebug.c ldebug.h lua/lua.h lua/luaconf.h
ldir.o: ldir.c ldir.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lua.h \
 util.h
lgenerics.o: lgenerics.c lgenerics.h lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h technology.h vector.h hashmap.h
lgeometry.o: lgeometry.c lgeometry.h lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h geometry.h technology.h vector.h hashmap.h \
 object.h polygon.h shape.h point.h transformationmatrix.h graphics.h \
 layout_util.h lcheck.h lobject.h lpoint.h lutil.h placement.h
lobject.o: lobject.c lobject.h lua/lua.h lua/luaconf.h object.h hashmap.h \
 polygon.h vector.h shape.h point.h transformationmatrix.h technology.h \
 lua/lauxlib.h lua/lua.h lpoint.h lcheck.h
lplacement.o: lplacement.c lplacement.h lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h lobject.h object.h hashmap.h polygon.h vector.h \
 shape.h point.h transformationmatrix.h technology.h lpoint.h lutil.h \
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
lutil.o: lutil.c lutil.h lua/lua.h lua/luaconf.h vector.h lpoint.h \
 point.h
main.api_help.o: main.api_help.c main.api_help.h terminal_colors.h util.h \
 vector.h
main.cell.o: main.cell.c main.cell.h hashmap.h cmdoptions.h vector.h \
 lua/lauxlib.h lua/luaconf.h lua/lua.h export.h object.h polygon.h \
 shape.h point.h transformationmatrix.h technology.h lua/lua.h \
 filesystem.h gdsparser.h geometry.h info.h pcell.h postprocess.h util.h \
 ldir.h lgenerics.h lgeometry.h lobject.h lplacement.h lplacer.h lpoint.h \
 lrouter.h lua_util.h config.h main.functions.h modulemanager.h \
 scriptmanager.h
main.functions.o: main.functions.c main.functions.h lua/lua.h \
 lua/luaconf.h lua/lauxlib.h lua/lua.h lua_util.h
main.gds.o: main.gds.c main.gds.h cmdoptions.h vector.h main.functions.h \
 lua/lua.h lua/luaconf.h lua_util.h gdsparser.h scriptmanager.h \
 modulemanager.h
main.verilog.o: main.verilog.c main.verilog.h vector.h lua/lua.h \
 lua/luaconf.h lua/lauxlib.h lua/lua.h util.h lua_util.h modulemanager.h \
 filesystem.h lplacer.h lrouter.h main.functions.h
object.o: object.c object.h hashmap.h polygon.h vector.h shape.h point.h \
 transformationmatrix.h technology.h lua/lua.h lua/luaconf.h util.h
pcell.o: pcell.c pcell.h lua/lua.h lua/luaconf.h vector.h lua/lauxlib.h \
 lua/lua.h util.h lua_util.h lobject.h object.h hashmap.h polygon.h \
 shape.h point.h transformationmatrix.h technology.h ldir.h \
 scriptmanager.h modulemanager.h
placement.o: placement.c placement.h object.h hashmap.h polygon.h \
 vector.h shape.h point.h transformationmatrix.h technology.h lua/lua.h \
 lua/luaconf.h layout_util.h util.h
point.o: point.c point.h
polygon.o: polygon.c polygon.h vector.h point.h
postprocess.o: postprocess.c postprocess.h object.h hashmap.h polygon.h \
 vector.h shape.h point.h transformationmatrix.h technology.h lua/lua.h \
 lua/luaconf.h union.h
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

