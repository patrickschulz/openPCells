PROGNAME=opc

CC=gcc

PPFLAGS=-DLUA_USE_LINUX -DTERMOGRAPHY_ENABLE_TERM_WIDTH
#WARNFLAGS=-Wall -Wextra -Wstrict-prototypes -Werror=strict-prototypes -Werror=return-type -Werror=implicit-function-declaration -Werror=int-conversion -Wno-analyzer-deref-before-check -Werror=discarded-qualifiers
WARNFLAGS=-Wall -Wextra
COMMONFLAGS=-pthread

CFLAGS=-std=c99 $(WARNFLAGS) $(COMMONFLAGS) $(PPFLAGS)
ifeq ($(DEBUGANALYZE), 1)
    CFLAGS=-std=c99 -O0 -g -fanalyzer -fsanitize=address -fsanitize=leak -fsanitize=undefined $(WARNFLAGS) $(COMMONFLAGS) $(PPFLAGS)
endif

OBJS:= bltrshape.o cells.o cmdoptions.o export_common.o export.o export_writer.o filesystem.o gdsexport.o gdsparser.o geometry.o geometry_triangulate.o graphics.o hashmap.o info.o lcheck.o ldebug.o ldir.o lgenerics.o lgeometry.o lobject.o lplacement.o lplacer_classic.o lplacer_common.o lplacer_nonoverlapping.o lplacer.o lplacer_rand.o lpoint.o lpostprocess.o lrouter_field.o lrouter_min_heap.o lrouter_moves.o lrouter_net.o lrouter.o lrouter_queue.o lrouter_route.o lterminal.o lua_util.o lutil.o main.api_help.o main.cell.o main.functions.o main.gds.o main.tutorial.o main.verilog.o object.o pcell.o placement.o point.o polygon.o postprocess.o print.o shape.o skillexport.o tagged_value.o technology.o terminal.o transformationmatrix.o union.o util_cmodule.o util.o vector.o
RELEASEOBJS = $(addprefix release/, $(OBJS))
LINTOBJS = $(addprefix lint/, $(OBJS))
DEBUGOBJS = $(addprefix debug/, $(OBJS))

.PHONY: default
default: $(PROGNAME) $(PROGNAME)-debug

$(PROGNAME): release/$(PROGNAME)
	cp release/$(PROGNAME) $(PROGNAME)

$(PROGNAME)-lint: lint/$(PROGNAME)
	cp lint/$(PROGNAME) $(PROGNAME)-lint

$(PROGNAME)-debug: debug/$(PROGNAME)
	cp debug/$(PROGNAME) $(PROGNAME)-debug

release:
	mkdir -p release
	mkdir -p release/lua

release/$(PROGNAME): release cmdoptions_def.c version.h main.c liblua_release.a _modulemanager.h _modulemanager.c _scriptmanager.h _scriptmanager.c $(RELEASEOBJS)
	$(CC) $(CFLAGS) -O3 -o release/$(PROGNAME) main.c $(RELEASEOBJS) _modulemanager.c _scriptmanager.c liblua_release.a -lm -ldl

release/%.o: %.c
	$(CC) -c $(CFLAGS) -O3 -o $@ $<

lint:
	mkdir -p lint
	mkdir -p lint/lua

lint/$(PROGNAME): lint cmdoptions_def.c version.h main.c liblua_lint.a _modulemanager.h _modulemanager.c _scriptmanager.h _scriptmanager.c $(LINTOBJS)
	$(CC) $(CFLAGS) -DOPC_LINT -O3 -o lint/$(PROGNAME) main.c $(LINTOBJS) _modulemanager.c _scriptmanager.c liblua_lint.a -lm -ldl

lint/%.o: %.c
	$(CC) -c $(CFLAGS) -DOPC_LINT -O3 -o $@ $<

debug:
	mkdir -p debug
	mkdir -p debug/lua

debug/$(PROGNAME): debug cmdoptions_def.c version.h main.c liblua_debug.a _modulemanager.h _modulemanager.c _scriptmanager.h _scriptmanager.c $(DEBUGOBJS)
	$(CC) $(CFLAGS) -O0 -g -o debug/$(PROGNAME) main.c $(DEBUGOBJS) _modulemanager.c _scriptmanager.c liblua_debug.a -lm -ldl

debug/%.o: %.c
	$(CC) -c $(CFLAGS) -O0 -g -o $@ $<

opc.1: cmdoptions_def.c generate_manpage
	./generate_manpage > opc.1

generate_manpage: cmdoptions.h cmdoptions.c generate_manpage.c
	$(CC) $(CFLAGS) generate_manpage.c cmdoptions.c vector.c util.c -o generate_manpage

_scriptmanager.c: _embed_compiled_lua_file_release scripts/*.lua
	@echo '#include "_scriptmanager.h"' > _scriptmanager.c
	@echo '#include <stddef.h>' >> _scriptmanager.c
	@echo '#include "main.functions.h"' >> _scriptmanager.c
	./_embed_compiled_lua_file_release --script scripts/list_cells.lua script_call list_cells _scriptmanager.c
	./_embed_compiled_lua_file_release --script scripts/assistant.lua script_call assistant _scriptmanager.c
	./_embed_compiled_lua_file_release --script scripts/list_parameters.lua script_call list_parameters _scriptmanager.c
	./_embed_compiled_lua_file_release --script scripts/list_anchors.lua script_call list_anchors _scriptmanager.c
	./_embed_compiled_lua_file_release --script scripts/templates.lua script_call templates _scriptmanager.c
	./_embed_compiled_lua_file_release --script scripts/check_technology.lua script_call check_technology _scriptmanager.c

_scriptmanager.h:
	@echo '#ifndef OPC_SCRIPTMANAGER_H' > _scriptmanager.h
	@echo '#define OPC_SCRIPTMANAGER_H' >> _scriptmanager.h
	@echo '#include "lua/lua.h"' >> _scriptmanager.h
	@echo 'int script_call_list_cells(lua_State* L);' >> _scriptmanager.h
	@echo 'int script_call_assistant(lua_State* L);' >> _scriptmanager.h
	@echo 'int script_call_list_parameters(lua_State* L);' >> _scriptmanager.h
	@echo 'int script_call_list_anchors(lua_State* L);' >> _scriptmanager.h
	@echo 'int script_call_templates(lua_State* L);' >> _scriptmanager.h
	@echo 'int script_call_check_technology(lua_State* L);' >> _scriptmanager.h
	@echo '#endif // OPC_SCRIPTMANAGER_H' >> _scriptmanager.h

_modulemanager.c: _embed_compiled_lua_file_release modules/*.lua
	@echo '#include "_modulemanager.h"' > _modulemanager.c
	@echo '#include <stddef.h>' >> _modulemanager.c
	@echo '#include "main.functions.h"' >> _modulemanager.c
	./_embed_compiled_lua_file_release --module modules/alignmentgroup.lua module_load alignmentgroup _modulemanager.c
	./_embed_compiled_lua_file_release --module modules/aux.lua module_load aux _modulemanager.c
	./_embed_compiled_lua_file_release --module modules/check.lua module_load check _modulemanager.c
	./_embed_compiled_lua_file_release --module modules/generator.lua module_load generator _modulemanager.c
	./_embed_compiled_lua_file_release --module modules/globals.lua module_load globals _modulemanager.c
	./_embed_compiled_lua_file_release --module modules/graphics.lua module_load graphics _modulemanager.c
	./_embed_compiled_lua_file_release --module modules/layouthelpers.lua module_load layouthelpers _modulemanager.c
	./_embed_compiled_lua_file_release --module modules/load.lua module_load load _modulemanager.c
	./_embed_compiled_lua_file_release --module modules/pcell.lua module_load pcell _modulemanager.c
	./_embed_compiled_lua_file_release --module modules/placement.lua module_load placement _modulemanager.c
	./_embed_compiled_lua_file_release --module modules/routing.lua module_load routing _modulemanager.c
	./_embed_compiled_lua_file_release --module modules/stack.lua module_load stack _modulemanager.c
	./_embed_compiled_lua_file_release --module modules/util.lua module_load util _modulemanager.c
	./_embed_compiled_lua_file_release --module modules/verilog.lua module_load verilog _modulemanager.c
	./_embed_compiled_lua_file_release --module modules/verilogprocessor.lua module_load verilogprocessor _modulemanager.c

_modulemanager.h: modules/*.lua
	@echo '#ifndef OPC_MODULEMANAGER_H' > _modulemanager.h
	@echo '#define OPC_MODULEMANAGER_H' >> _modulemanager.h
	@echo '#include "lua/lua.h"' >> _modulemanager.h
	@echo 'int module_load_alignmentgroup(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_aux(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_check(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_generator(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_globals(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_graphics(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_layouthelpers(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_load(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_pcell(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_placement(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_routing(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_stack(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_util(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_verilog(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_verilogprocessor(lua_State* L);' >> _modulemanager.h
	@echo '#endif // OPC_MODULEMANAGER_H' >> _modulemanager.h

_embed_compiled_lua_file_release: embed_compiled_lua_file.c liblua_release.a
	$(CC) $(CFLAGS) embed_compiled_lua_file.c liblua_release.a -o _embed_compiled_lua_file_release -lm

_embed_compiled_lua_file_lint: embed_compiled_lua_file.c liblua_lint.a
	$(CC) $(CFLAGS) embed_compiled_lua_file.c liblua_lint.a -o _embed_compiled_lua_file_lint -lm

_embed_compiled_lua_file_debug: embed_compiled_lua_file.c liblua_debug.a
	$(CC) $(CFLAGS) embed_compiled_lua_file.c liblua_debug.a -o _embed_compiled_lua_file_debug -lm

create_latex_API_doc: create_latex_API_doc.c main.api_help.c main.api_help.h vector.c vector.h util.c util.h terminal.c terminal.h
	$(CC) $(CFLAGS) create_latex_API_doc.c main.api_help.c vector.c util.c terminal.c -o create_latex_API_doc

.PHONY: clean
clean:
	rm -rf release lint debug
	rm -f $(PROGNAME)
	rm -f $(PROGNAME)-lint
	rm -f $(PROGNAME)-debug
	rm -f liblua_release.a $(LUA_CORE_RELEASEOBJS) $(LUA_LIB_RELEASEOBJS)
	rm -f liblua_lint.a $(LUA_CORE_LINTOBJS) $(LUA_LIB_LINTOBJS)
	rm -f liblua_debug.a $(LUA_CORE_DEBUGOBJS) $(LUA_LIB_DEBUGOBJS)
	rm -f _embed_compiled_lua_file_release
	rm -f _embed_compiled_lua_file_lint
	rm -f _embed_compiled_lua_file_debug
	rm -f generate_manpage
	rm -f create_latex_API_doc
	rm -f _modulemanager.h _modulemanager.c
	rm -f _scriptmanager.h _scriptmanager.c
	rm -f _scriptmanager.h _scriptmanager.c

#############################################################
# generated by gcc -MM -MG *.c
# the following files are removed manually:
# * create_latex_API_doc.o
# * _embed_compiled_lua_file.o
# * generate_manpage.o
# * _modulemanager.o
# * _scriptmanager.o
# * main.o
bltrshape.o: src/bltrshape.c src/bltrshape.h src/point.h
cells.o: src/cells.c src/pcell.h src/lua/lua.h src/lua/luaconf.h \
 src/object.h src/hashmap.h src/polygon.h src/point.h src/shape.h \
 src/technology.h src/vector.h src/transformationmatrix.h src/geometry.h \
 src/cells/powergrid.c
cmdoptions.o: src/cmdoptions.c src/cmdoptions.h src/print.h
cmdoptions_def.o: src/cmdoptions_def.c
cpu.o: src/cpu.c src/cpu.h
export.o: src/export.c src/export.h src/object.h src/hashmap.h \
 src/polygon.h src/point.h src/shape.h src/technology.h src/lua/lua.h \
 src/lua/luaconf.h src/vector.h src/transformationmatrix.h \
 src/lua/lauxlib.h src/lua/lua.h src/export_common.h src/export_writer.h \
 src/filesystem.h src/gdsexport.h src/lua_util.h src/skillexport.h \
 src/util.h
export_common.o: src/export_common.c src/export_common.h src/object.h \
 src/hashmap.h src/polygon.h src/point.h src/shape.h src/technology.h \
 src/lua/lua.h src/lua/luaconf.h src/vector.h src/transformationmatrix.h
export_writer.o: src/export_writer.c src/export_writer.h src/lua/lua.h \
 src/lua/luaconf.h src/export_common.h src/object.h src/hashmap.h \
 src/polygon.h src/point.h src/shape.h src/technology.h src/vector.h \
 src/transformationmatrix.h src/tagged_value.h src/util.h
filesystem.o: src/filesystem.c src/filesystem.h src/lua/lua.h \
 src/lua/luaconf.h src/lua/lauxlib.h src/lua/lua.h
gdsexport.o: src/gdsexport.c src/gdsexport.h src/export_common.h \
 src/object.h src/hashmap.h src/polygon.h src/point.h src/shape.h \
 src/technology.h src/lua/lua.h src/lua/luaconf.h src/vector.h \
 src/transformationmatrix.h src/math.h src/tagged_value.h src/geometry.h \
 src/util.h
gdsparser.o: src/gdsparser.c src/gdsparser.h src/lua/lua.h \
 src/lua/luaconf.h src/vector.h src/lua/lauxlib.h src/lua/lua.h \
 src/math.h src/filesystem.h src/point.h src/hashmap.h src/lua_util.h \
 src/util.h
geometry.o: src/geometry.c src/geometry.h src/technology.h src/lua/lua.h \
 src/lua/luaconf.h src/vector.h src/hashmap.h src/object.h src/polygon.h \
 src/point.h src/shape.h src/transformationmatrix.h src/math.h
geometry_triangulate.o: src/geometry_triangulate.c src/math.h src/point.h \
 src/vector.h
graphics.o: src/graphics.c src/graphics.h src/point.h src/vector.h \
 src/math.h
hashmap.o: src/hashmap.c src/hashmap.h src/util.h
info.o: src/info.c src/info.h src/object.h src/hashmap.h src/polygon.h \
 src/point.h src/shape.h src/technology.h src/lua/lua.h src/lua/luaconf.h \
 src/vector.h src/transformationmatrix.h
lcheck.o: src/lcheck.c src/lcheck.h src/lua/lua.h src/lua/luaconf.h
ldebug.o: src/ldebug.c src/ldebug.h src/lua/lua.h src/lua/luaconf.h
ldir.o: src/ldir.c src/ldir.h src/lua/lua.h src/lua/luaconf.h \
 src/lua/lauxlib.h src/lua/lua.h src/util.h
lgenerics.o: src/lgenerics.c src/lgenerics.h src/lua/lua.h \
 src/lua/luaconf.h src/lua/lauxlib.h src/lua/lua.h src/technology.h \
 src/vector.h src/hashmap.h
lgeometry.o: src/lgeometry.c src/lgeometry.h src/lua/lua.h \
 src/lua/luaconf.h src/lua/lauxlib.h src/lua/lua.h src/geometry.h \
 src/technology.h src/vector.h src/hashmap.h src/object.h src/polygon.h \
 src/point.h src/shape.h src/transformationmatrix.h src/graphics.h \
 src/lcheck.h src/lgenerics.h src/lobject.h src/lplacement.h src/lpoint.h \
 src/lutil.h src/placement.h
lobject.o: src/lobject.c src/lobject.h src/lua/lua.h src/lua/luaconf.h \
 src/object.h src/hashmap.h src/polygon.h src/point.h src/shape.h \
 src/technology.h src/vector.h src/transformationmatrix.h \
 src/lua/lauxlib.h src/lua/lua.h src/bltrshape.h src/lpoint.h \
 src/lcheck.h
lplacement.o: src/lplacement.c src/lplacement.h src/lua/lua.h \
 src/lua/luaconf.h src/polygon.h src/point.h src/lua/lauxlib.h \
 src/lua/lua.h src/lcheck.h src/lgenerics.h src/lobject.h src/object.h \
 src/hashmap.h src/shape.h src/technology.h src/vector.h \
 src/transformationmatrix.h src/lpoint.h src/lutil.h src/placement.h
lplacer.o: src/lplacer.c src/lua/lua.h src/lua/luaconf.h \
 src/lua/lauxlib.h src/lua/lua.h src/lplacer_nonoverlapping.h \
 src/lplacer_classic.h
lplacer_classic.o: src/lplacer_classic.c src/lplacer_classic.h \
 src/lua/lua.h src/lua/luaconf.h src/lplacer_common.h src/hashmap.h \
 src/lplacer_rand.h src/math.h src/util.h
lplacer_common.o: src/lplacer_common.c src/lplacer_common.h src/lua/lua.h \
 src/lua/luaconf.h src/hashmap.h
lplacer_nonoverlapping.o: src/lplacer_nonoverlapping.c \
 src/lplacer_nonoverlapping.h src/lua/lua.h src/lua/luaconf.h \
 src/lplacer_common.h src/hashmap.h src/lplacer_rand.h
lplacer_rand.o: src/lplacer_rand.c src/lplacer_rand.h src/lua/lua.h \
 src/lua/luaconf.h
lpoint.o: src/lpoint.c src/lpoint.h src/lua/lua.h src/lua/luaconf.h \
 src/point.h src/lua/lauxlib.h src/lua/lua.h src/math.h
lpostprocess.o: src/lpostprocess.c src/lpostprocess.h src/lua/lua.h \
 src/lua/luaconf.h src/lua/lauxlib.h src/lua/lua.h src/postprocess.h \
 src/object.h src/hashmap.h src/polygon.h src/point.h src/shape.h \
 src/technology.h src/vector.h src/transformationmatrix.h src/lobject.h
lrouter.o: src/lrouter.c src/lua/lua.h src/lua/luaconf.h \
 src/lua/lauxlib.h src/lua/lua.h src/lrouter_net.h src/lrouter_field.h \
 src/vector.h src/lrouter_route.h src/lrouter_moves.h
lrouter_field.o: src/lrouter_field.c src/lrouter_field.h
lrouter_min_heap.o: src/lrouter_min_heap.c src/lrouter_field.h \
 src/lrouter_min_heap.h
lrouter_moves.o: src/lrouter_moves.c src/lua/lua.h src/lua/luaconf.h \
 src/lua/lauxlib.h src/lua/lua.h src/lrouter_moves.h
lrouter_net.o: src/lrouter_net.c src/lrouter_net.h src/lrouter_field.h \
 src/vector.h src/util.h
lrouter_queue.o: src/lrouter_queue.c src/lrouter_queue.h \
 src/lrouter_field.h
lrouter_route.o: src/lrouter_route.c src/lrouter_route.h \
 src/lrouter_net.h src/lrouter_field.h src/vector.h \
 src/lrouter_min_heap.h
lterminal.o: src/lterminal.c src/lterminal.h src/lua/lua.h \
 src/lua/luaconf.h src/terminal.h
lua_util.o: src/lua_util.c src/lua_util.h src/lua/lua.h src/lua/luaconf.h \
 src/lua/lauxlib.h src/lua/lua.h src/lua/lualib.h
lutil.o: src/lutil.c src/lutil.h src/lua/lua.h src/lua/luaconf.h \
 src/polygon.h src/point.h src/lpoint.h
main.api_help.o: src/main.api_help.c src/main.api_help.h \
 src/terminal.h src/print.h src/util.h src/vector.h \
 src/main.api_help/aux.c src/main.api_help/curve.c \
 src/main.api_help/generics.c src/main.api_help/geometry.c \
 src/main.api_help/global.c src/main.api_help/graphics.c \
 src/main.api_help/layouthelpers.c src/main.api_help/object.c \
 src/main.api_help/pcell.c src/main.api_help/placement.c \
 src/main.api_help/placer.c src/main.api_help/point.c \
 src/main.api_help/router.c src/main.api_help/routing.c \
 src/main.api_help/technology.c src/main.api_help/util.c
main.cell.o: src/main.cell.c src/main.cell.h src/hashmap.h \
 src/cmdoptions.h src/lua/lauxlib.h src/lua/luaconf.h src/lua/lua.h \
 src/export.h src/object.h src/polygon.h src/point.h src/shape.h \
 src/technology.h src/lua/lua.h src/vector.h src/transformationmatrix.h \
 src/filesystem.h src/gdsparser.h src/geometry.h src/info.h \
 src/main.functions.h src/pcell.h src/postprocess.h src/util_cmodule.h \
 src/util.h src/_config.h
main.functions.o: src/main.functions.c src/main.functions.h src/lua/lua.h \
 src/lua/luaconf.h src/technology.h src/vector.h src/hashmap.h \
 src/lua/lauxlib.h src/lua/lua.h src/lua_util.h src/filesystem.h \
 src/pcell.h src/object.h src/polygon.h src/point.h src/shape.h \
 src/transformationmatrix.h src/util_cmodule.h src/ldir.h src/lgenerics.h \
 src/lgeometry.h src/lobject.h src/lplacement.h src/lplacer.h \
 src/lpoint.h src/lpostprocess.h src/lrouter.h
main.gds.o: src/main.gds.c src/main.gds.h src/cmdoptions.h \
 src/main.functions.h src/lua/lua.h src/lua/luaconf.h src/technology.h \
 src/vector.h src/hashmap.h src/gdsparser.h
main.import.o: src/main.import.c src/main.import.h src/vector.h \
 src/lua/lua.h src/lua/luaconf.h src/lua/lauxlib.h src/lua/lua.h \
 src/cdl_parser.h src/filesystem.h src/lplacement.h src/polygon.h \
 src/point.h src/lplacer.h src/lrouter.h src/lua_util.h \
 src/main.functions.h src/technology.h src/hashmap.h src/_modulemanager.h \
 src/util_cmodule.h src/util.h
main.tutorial.o: src/main.tutorial.c src/main.tutorial.h src/print.h \
 src/terminal.h
object.o: src/object.c src/object.h src/hashmap.h src/polygon.h \
 src/point.h src/shape.h src/technology.h src/lua/lua.h src/lua/luaconf.h \
 src/vector.h src/transformationmatrix.h src/bltrshape.h src/util.h
pcell.o: src/pcell.c src/pcell.h src/lua/lua.h src/lua/luaconf.h \
 src/object.h src/hashmap.h src/polygon.h src/point.h src/shape.h \
 src/technology.h src/vector.h src/transformationmatrix.h \
 src/lua/lauxlib.h src/lua/lua.h src/cells.h src/main.functions.h \
 src/util.h src/lua_util.h src/ldir.h src/lobject.h src/ldebug.h \
 src/_scriptmanager.h src/_modulemanager.h
placement.o: src/placement.c src/placement.h src/object.h src/hashmap.h \
 src/polygon.h src/point.h src/shape.h src/technology.h src/lua/lua.h \
 src/lua/luaconf.h src/vector.h src/transformationmatrix.h src/geometry.h \
 src/util.h
point.o: src/point.c src/point.h
polygon.o: src/polygon.c src/polygon.h src/point.h src/vector.h
postprocess.o: src/postprocess.c src/postprocess.h src/object.h \
 src/hashmap.h src/polygon.h src/point.h src/shape.h src/technology.h \
 src/lua/lua.h src/lua/luaconf.h src/vector.h src/transformationmatrix.h \
 src/union.h
print.o: src/print.c
shape.o: src/shape.c src/shape.h src/point.h src/polygon.h \
 src/technology.h src/lua/lua.h src/lua/luaconf.h src/vector.h \
 src/hashmap.h src/transformationmatrix.h src/math.h src/graphics.h \
 src/geometry.h src/object.h
skillexport.o: src/skillexport.c src/skillexport.h src/export_common.h \
 src/object.h src/hashmap.h src/polygon.h src/point.h src/shape.h \
 src/technology.h src/lua/lua.h src/lua/luaconf.h src/vector.h \
 src/transformationmatrix.h src/tagged_value.h src/util.h
string.o: src/string.c src/string.h
tagged_value.o: src/tagged_value.c src/tagged_value.h src/util.h
technology.o: src/technology.c src/technology.h src/lua/lua.h \
 src/lua/luaconf.h src/vector.h src/hashmap.h src/lua/lauxlib.h \
 src/lua/lua.h src/util.h src/lua_util.h src/tagged_value.h src/ldebug.h
terminal.o: src/terminal.c src/terminal.h
transformationmatrix.o: src/transformationmatrix.c \
 src/transformationmatrix.h src/point.h
union.o: src/union.c src/union.h src/point.h src/vector.h src/shape.h \
 src/polygon.h src/technology.h src/lua/lua.h src/lua/luaconf.h \
 src/hashmap.h src/transformationmatrix.h
util.o: src/util.c src/util.h
util_cmodule.o: src/util_cmodule.c src/util_cmodule.h src/lua/lua.h \
 src/lua/luaconf.h src/lua/lauxlib.h src/lua/lua.h src/lua/lualib.h \
 src/lpoint.h src/point.h src/union.h src/vector.h
vector.o: src/vector.c src/vector.h
#############################################################

# lua object files and build rules
LUA_CORE_O= lua/lapi.o lua/lcode.o lua/lctype.o lua/ldebug.o lua/ldo.o lua/ldump.o lua/lfunc.o lua/lgc.o lua/llex.o lua/lmem.o lua/lobject.o lua/lopcodes.o lua/lparser.o lua/lstate.o lua/lstring.o lua/ltable.o lua/ltm.o lua/lundump.o lua/lvm.o lua/lzio.o
LUA_LIB_O=	lua/lauxlib.o lua/lbaselib.o lua/lcorolib.o lua/ldblib.o lua/liolib.o lua/lmathlib.o lua/loadlib.o lua/loslib.o lua/lstrlib.o lua/ltablib.o lua/linit.o
LUA_CORE_RELEASEOBJS = $(addprefix release/, $(LUA_CORE_O))
LUA_CORE_LINTOBJS = $(addprefix lint/, $(LUA_CORE_O))
LUA_CORE_DEBUGOBJS = $(addprefix debug/, $(LUA_CORE_O))
LUA_LIB_RELEASEOBJS = $(addprefix release/, $(LUA_LIB_O))
LUA_LIB_LINTOBJS = $(addprefix lint/, $(LUA_LIB_O))
LUA_LIB_DEBUGOBJS = $(addprefix debug/, $(LUA_LIB_O))

liblua_release.a: release $(LUA_CORE_RELEASEOBJS) $(LUA_LIB_RELEASEOBJS)
	ar rcu $@ $(LUA_CORE_RELEASEOBJS) $(LUA_LIB_RELEASEOBJS)
	ranlib $@

liblua_lint.a: lint $(LUA_CORE_LINTOBJS) $(LUA_LIB_LINTOBJS)
	ar rcu $@ $(LUA_CORE_LINTOBJS) $(LUA_LIB_LINTOBJS)
	ranlib $@

liblua_debug.a: debug $(LUA_CORE_DEBUGOBJS) $(LUA_LIB_DEBUGOBJS)
	ar rcu $@ $(LUA_CORE_DEBUGOBJS) $(LUA_LIB_DEBUGOBJS)
	ranlib $@

# lua object files rules
# these are copied from the original lua makefile
# the paths are hard-coded, there is probably a better and
# more automated way to do this, but this works well and
# this will also not change
release/lua/lapi.o: lua/lapi.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lundump.h lua/lvm.h
release/lua/lauxlib.o: lua/lauxlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h
release/lua/lbaselib.o: lua/lbaselib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/lcode.o: lua/lcode.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lcode.h lua/llex.h lua/lobject.h lua/llimits.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/lstate.h lua/ltm.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
release/lua/lcorolib.o: lua/lcorolib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/lctype.o: lua/lctype.c lua/lprefix.h lua/lctype.h lua/lua.h lua/luaconf.h lua/llimits.h
release/lua/ldblib.o: lua/ldblib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/ldebug.o: lua/ldebug.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lcode.h lua/llex.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/ltable.h lua/lvm.h
release/lua/ldo.o: lua/ldo.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lopcodes.h lua/lparser.h lua/lstring.h lua/ltable.h lua/lundump.h lua/lvm.h
release/lua/ldump.o: lua/ldump.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lobject.h lua/llimits.h lua/lstate.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lundump.h
release/lua/lfunc.o: lua/lfunc.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h
release/lua/lgc.o: lua/lgc.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lstring.h lua/ltable.h
release/lua/linit.o: lua/linit.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lualib.h lua/lauxlib.h
release/lua/liolib.o: lua/liolib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/llex.o: lua/llex.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lctype.h lua/llimits.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/llex.h lua/lparser.h lua/lstring.h lua/ltable.h
release/lua/lmathlib.o: lua/lmathlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/lmem.o: lua/lmem.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h
release/lua/loadlib.o: lua/loadlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/lobject.o: lua/lobject.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lctype.h lua/llimits.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lstring.h lua/lgc.h lua/lvm.h
release/lua/lopcodes.o: lua/lopcodes.c lua/lprefix.h lua/lopcodes.h lua/llimits.h lua/lua.h lua/luaconf.h
release/lua/loslib.o: lua/loslib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/lparser.o: lua/lparser.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lcode.h lua/llex.h lua/lobject.h lua/llimits.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/lstate.h lua/ltm.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/ltable.h
release/lua/lstate.o: lua/lstate.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/llex.h lua/lstring.h lua/ltable.h
release/lua/lstring.o: lua/lstring.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lstring.h lua/lgc.h
release/lua/lstrlib.o: lua/lstrlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/ltable.o: lua/ltable.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
release/lua/ltablib.o: lua/ltablib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/ltm.o: lua/ltm.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
release/lua/lua.o: lua/lua.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
release/lua/luac.o: lua/luac.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lopnames.h lua/lundump.h
release/lua/lundump.o: lua/lundump.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/lundump.h
release/lua/lvm.o: lua/lvm.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lopcodes.h lua/lstring.h lua/ltable.h lua/lvm.h lua/ljumptab.h
release/lua/lzio.o: lua/lzio.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/llimits.h lua/lmem.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h

lint/lua/lapi.o: lua/lapi.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lundump.h lua/lvm.h
lint/lua/lauxlib.o: lua/lauxlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h
lint/lua/lbaselib.o: lua/lbaselib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/lcode.o: lua/lcode.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lcode.h lua/llex.h lua/lobject.h lua/llimits.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/lstate.h lua/ltm.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
lint/lua/lcorolib.o: lua/lcorolib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/lctype.o: lua/lctype.c lua/lprefix.h lua/lctype.h lua/lua.h lua/luaconf.h lua/llimits.h
lint/lua/ldblib.o: lua/ldblib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/ldebug.o: lua/ldebug.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lcode.h lua/llex.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/ltable.h lua/lvm.h
lint/lua/ldo.o: lua/ldo.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lopcodes.h lua/lparser.h lua/lstring.h lua/ltable.h lua/lundump.h lua/lvm.h
lint/lua/ldump.o: lua/ldump.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lobject.h lua/llimits.h lua/lstate.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lundump.h
lint/lua/lfunc.o: lua/lfunc.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h
lint/lua/lgc.o: lua/lgc.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lstring.h lua/ltable.h
lint/lua/linit.o: lua/linit.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lualib.h lua/lauxlib.h
lint/lua/liolib.o: lua/liolib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/llex.o: lua/llex.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lctype.h lua/llimits.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/llex.h lua/lparser.h lua/lstring.h lua/ltable.h
lint/lua/lmathlib.o: lua/lmathlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/lmem.o: lua/lmem.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h
lint/lua/loadlib.o: lua/loadlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/lobject.o: lua/lobject.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lctype.h lua/llimits.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lstring.h lua/lgc.h lua/lvm.h
lint/lua/lopcodes.o: lua/lopcodes.c lua/lprefix.h lua/lopcodes.h lua/llimits.h lua/lua.h lua/luaconf.h
lint/lua/loslib.o: lua/loslib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/lparser.o: lua/lparser.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lcode.h lua/llex.h lua/lobject.h lua/llimits.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/lstate.h lua/ltm.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/ltable.h
lint/lua/lstate.o: lua/lstate.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/llex.h lua/lstring.h lua/ltable.h
lint/lua/lstring.o: lua/lstring.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lstring.h lua/lgc.h
lint/lua/lstrlib.o: lua/lstrlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/ltable.o: lua/ltable.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
lint/lua/ltablib.o: lua/ltablib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/ltm.o: lua/ltm.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
lint/lua/lua.o: lua/lua.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
lint/lua/luac.o: lua/luac.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lopnames.h lua/lundump.h
lint/lua/lundump.o: lua/lundump.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/lundump.h
lint/lua/lvm.o: lua/lvm.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lopcodes.h lua/lstring.h lua/ltable.h lua/lvm.h lua/ljumptab.h
lint/lua/lzio.o: lua/lzio.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/llimits.h lua/lmem.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h

debug/lua/lapi.o: lua/lapi.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lundump.h lua/lvm.h
debug/lua/lauxlib.o: lua/lauxlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h
debug/lua/lbaselib.o: lua/lbaselib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/lcode.o: lua/lcode.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lcode.h lua/llex.h lua/lobject.h lua/llimits.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/lstate.h lua/ltm.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
debug/lua/lcorolib.o: lua/lcorolib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/lctype.o: lua/lctype.c lua/lprefix.h lua/lctype.h lua/lua.h lua/luaconf.h lua/llimits.h
debug/lua/ldblib.o: lua/ldblib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/ldebug.o: lua/ldebug.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lcode.h lua/llex.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/ltable.h lua/lvm.h
debug/lua/ldo.o: lua/ldo.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lopcodes.h lua/lparser.h lua/lstring.h lua/ltable.h lua/lundump.h lua/lvm.h
debug/lua/ldump.o: lua/ldump.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lobject.h lua/llimits.h lua/lstate.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lundump.h
debug/lua/lfunc.o: lua/lfunc.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h
debug/lua/lgc.o: lua/lgc.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lstring.h lua/ltable.h
debug/lua/linit.o: lua/linit.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lualib.h lua/lauxlib.h
debug/lua/liolib.o: lua/liolib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/llex.o: lua/llex.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lctype.h lua/llimits.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/llex.h lua/lparser.h lua/lstring.h lua/ltable.h
debug/lua/lmathlib.o: lua/lmathlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/lmem.o: lua/lmem.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h
debug/lua/loadlib.o: lua/loadlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/lobject.o: lua/lobject.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lctype.h lua/llimits.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lstring.h lua/lgc.h lua/lvm.h
debug/lua/lopcodes.o: lua/lopcodes.c lua/lprefix.h lua/lopcodes.h lua/llimits.h lua/lua.h lua/luaconf.h
debug/lua/loslib.o: lua/loslib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/lparser.o: lua/lparser.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lcode.h lua/llex.h lua/lobject.h lua/llimits.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lparser.h lua/ldebug.h lua/lstate.h lua/ltm.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/ltable.h
debug/lua/lstate.o: lua/lstate.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lapi.h lua/llimits.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldebug.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/llex.h lua/lstring.h lua/ltable.h
debug/lua/lstring.o: lua/lstring.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lstring.h lua/lgc.h
debug/lua/lstrlib.o: lua/lstrlib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/ltable.o: lua/ltable.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
debug/lua/ltablib.o: lua/ltablib.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/ltm.o: lua/ltm.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lgc.h lua/lstring.h lua/ltable.h lua/lvm.h
debug/lua/lua.o: lua/lua.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lualib.h
debug/lua/luac.o: lua/luac.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/lauxlib.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/lopcodes.h lua/lopnames.h lua/lundump.h
debug/lua/lundump.o: lua/lundump.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lstring.h lua/lgc.h lua/lundump.h
debug/lua/lvm.o: lua/lvm.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/ldebug.h lua/lstate.h lua/lobject.h lua/llimits.h lua/ltm.h lua/lzio.h lua/lmem.h lua/ldo.h lua/lfunc.h lua/lgc.h lua/lopcodes.h lua/lstring.h lua/ltable.h lua/lvm.h lua/ljumptab.h
debug/lua/lzio.o: lua/lzio.c lua/lprefix.h lua/lua.h lua/luaconf.h lua/llimits.h lua/lmem.h lua/lstate.h lua/lobject.h lua/ltm.h lua/lzio.h
