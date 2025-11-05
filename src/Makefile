PROGNAME=opc

CC=gcc

# Preprocessor definitions
PPFLAGS=-DLUA_USE_LINUX -DLUA_USE_JUMPTABLE=0 -DTERMOGRAPHY_ENABLE_TERM_WIDTH

# Warnings
# (Not all of these are turned on by default, as I want to support older gcc versions without modifications to this file)
WARNFLAGS=-Wall -Wextra -pedantic -Werror=pedantic -pedantic-errors
# other useful warnings not turned on by -Wall or -Wextra are:
# -Wstrict-prototypes 
# -Wno-analyzer-deref-before-check 
# Warnings that I consider errors:
# -Werror=strict-prototypes
# -Werror=return-type
# -Werror=implicit-function-declaration
# -Werror=int-conversion
# -Werror=discarded-qualifiers

# Other things
COMMONFLAGS=-pthread

# Optimization
OPTFLAGS=-O3
# for final program, takes longer to compile
#OPTFLAGS=-O3 -flto -fwhole-program

# Code analyzer
#ANALYZEFLAGS= -fanalyzer -fsanitize=address -fsanitize=leak -fsanitize=undefined

# All flags without optimization flags
CFLAGS=-std=c99 $(WARNFLAGS) $(COMMONFLAGS) $(PPFLAGS) $(ANALYZEFLAGS)

########################################################################################################################

OBJS:= bltrshape.o buffer.o cdl_parser.o cdl_tokenlist.o cells.o cmdoptions.o error.o export_common.o export.o export_writer.o filesystem.o gdsexport.o gdsparser.o geometry.o geometry_triangulate.o graphics.o hashmap.o info.o lcheck.o ldebug.o ldir.o lgenerics.o lgeometry.o limport.o lobject.o lplacement.o lplacer_classic.o lplacer_common.o lplacer_nonoverlapping.o lplacer.o lplacer_rand.o lpoint.o lpostprocess.o lrouter_field.o lrouter_min_heap.o lrouter_moves.o lrouter_net.o lrouter.o lrouter_queue.o lrouter_route.o lterminal.o lua_util.o lutil.o main.api_help.o main.assistant.o main.cell.o main.functions.o main.gds.o main.tutorial.o main.import.o netlist.o object.o pcell.o placement.o point.o polygon.o postprocess.o print.o shape.o skillexport.o string.o strprint.o tagged_value.o technology.o terminal.o transformationmatrix.o union.o util_cmodule.o util.o vector.o
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
	$(CC) $(CFLAGS) $(OPTFLAGS) -o release/$(PROGNAME) main.c $(RELEASEOBJS) _modulemanager.c _scriptmanager.c liblua_release.a -lm -ldl

release/%.o: %.c
	$(CC) -c $(CFLAGS) $(OPTFLAGS) -o $@ $<

lint:
	mkdir -p lint
	mkdir -p lint/lua

lint/$(PROGNAME): lint cmdoptions_def.c version.h main.c liblua_lint.a _modulemanager.h _modulemanager.c _scriptmanager.h _scriptmanager.c $(LINTOBJS)
	$(CC) $(CFLAGS) $(OPTFLAGS) -DOPC_LINT -o lint/$(PROGNAME) main.c $(LINTOBJS) _modulemanager.c _scriptmanager.c liblua_lint.a -lm -ldl

lint/%.o: %.c
	$(CC) -c $(CFLAGS) $(OPTFLAGS) -DOPC_LINT -o $@ $<

debug:
	mkdir -p debug
	mkdir -p debug/lua

debug/$(PROGNAME): debug cmdoptions_def.c version.h main.c liblua_debug.a _modulemanager.h _modulemanager.c _scriptmanager.h _scriptmanager.c $(DEBUGOBJS)
	$(CC) $(CFLAGS) -O0 -g -o debug/$(PROGNAME) main.c $(DEBUGOBJS) _modulemanager.c _scriptmanager.c liblua_debug.a -lm -ldl

debug/%.o: %.c
	$(CC) -c $(CFLAGS) -O0 -g -o $@ $<

.PHONY: check
check:
	clang-tidy *.h *.c

opc.1: cmdoptions_def.c generate_manpage
	./generate_manpage > opc.1

generate_manpage: cmdoptions.h cmdoptions.c print.c generate_manpage.c
	$(CC) $(CFLAGS) generate_manpage.c cmdoptions.c print.c vector.c util.c -o generate_manpage

_scriptmanager.c: _embed_compiled_lua_file scripts/*.lua
	@echo '#include "_scriptmanager.h"' > __scriptmanager.c
	@echo '#include <stddef.h>' >> __scriptmanager.c
	@echo '#include "main.functions.h"' >> __scriptmanager.c
	./_embed_compiled_lua_file --script scripts/list_cells.lua script_call list_cells __scriptmanager.c
	./_embed_compiled_lua_file --script scripts/list_parameters.lua script_call list_parameters __scriptmanager.c
	./_embed_compiled_lua_file --script scripts/list_anchors.lua script_call list_anchors __scriptmanager.c
	./_embed_compiled_lua_file --script scripts/templates.lua script_call templates __scriptmanager.c
	./_embed_compiled_lua_file --script scripts/check_technology.lua script_call check_technology __scriptmanager.c
	@mv __scriptmanager.c _scriptmanager.c

_scriptmanager.h:
	@echo '#ifndef OPC_SCRIPTMANAGER_H' > __scriptmanager.h
	@echo '#define OPC_SCRIPTMANAGER_H' >> __scriptmanager.h
	@echo '#include "lua/lua.h"' >> __scriptmanager.h
	@echo 'int script_call_list_cells(lua_State* L);' >> __scriptmanager.h
	@echo 'int script_call_list_parameters(lua_State* L);' >> __scriptmanager.h
	@echo 'int script_call_list_anchors(lua_State* L);' >> __scriptmanager.h
	@echo 'int script_call_templates(lua_State* L);' >> __scriptmanager.h
	@echo 'int script_call_check_technology(lua_State* L);' >> __scriptmanager.h
	@echo '#endif // OPC_SCRIPTMANAGER_H' >> __scriptmanager.h
	@mv __scriptmanager.h _scriptmanager.h

_modulemanager.c: _embed_compiled_lua_file modules/*.lua
	@echo '#include "_modulemanager.h"' > _modulemanager.c
	@echo '#include <stddef.h>' >> _modulemanager.c
	@echo '#include "main.functions.h"' >> _modulemanager.c
	./_embed_compiled_lua_file --module modules/alignmentgroup.lua module_load alignmentgroup _modulemanager.c
	./_embed_compiled_lua_file --module modules/aux.lua module_load aux _modulemanager.c
	./_embed_compiled_lua_file --module modules/check.lua module_load check _modulemanager.c
	./_embed_compiled_lua_file --module modules/generator.lua module_load generator _modulemanager.c
	./_embed_compiled_lua_file --module modules/globals.lua module_load globals _modulemanager.c
	./_embed_compiled_lua_file --module modules/graphics.lua module_load graphics _modulemanager.c
	./_embed_compiled_lua_file --module modules/layouthelpers.lua module_load layouthelpers _modulemanager.c
	./_embed_compiled_lua_file --module modules/load.lua module_load load _modulemanager.c
	./_embed_compiled_lua_file --module modules/pcell.lua module_load pcell _modulemanager.c
	./_embed_compiled_lua_file --module modules/placement.lua module_load placement _modulemanager.c
	./_embed_compiled_lua_file --module modules/routing.lua module_load routing _modulemanager.c
	./_embed_compiled_lua_file --module modules/stack.lua module_load stack _modulemanager.c
	./_embed_compiled_lua_file --module modules/util.lua module_load util _modulemanager.c
	./_embed_compiled_lua_file --module modules/verilog.lua module_load verilog _modulemanager.c
	./_embed_compiled_lua_file --module modules/verilogprocessor.lua module_load verilogprocessor _modulemanager.c

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

_embed_compiled_lua_file: embed_compiled_lua_file.c
	$(CC) $(CFLAGS) $(PPFLAGS) embed_compiled_lua_file.c lua/lapi.c lua/lauxlib.c lua/lbaselib.c lua/lcode.c lua/lcorolib.c lua/lctype.c lua/ldblib.c lua/ldebug.c lua/ldo.c lua/ldump.c lua/lfunc.c lua/lgc.c lua/linit.c lua/liolib.c lua/llex.c lua/lmathlib.c lua/lmem.c lua/loadlib.c lua/lobject.c lua/lopcodes.c lua/loslib.c lua/lparser.c lua/lstate.c lua/lstring.c lua/lstrlib.c lua/ltable.c lua/ltablib.c lua/ltm.c lua/lundump.c lua/lvm.c lua/lzio.c -o _embed_compiled_lua_file -lm

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
	rm -f _embed_compiled_lua_file
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
bltrshape.o: bltrshape.c bltrshape.h point.h
buffer.o: buffer.c buffer.h
cdl_parser.o: cdl_parser.c cdl_parser.h buffer.h string.h \
 cdl_tokenlist.h vector.h
cdl_tokenlist.o: cdl_tokenlist.c cdl_tokenlist.h string.h \
 vector.h
cells.o: cells.c pcell.h lua/lua.h lua/luaconf.h \
 object.h hashmap.h polygon.h point.h shape.h \
 technology.h vector.h transformationmatrix.h geometry.h \
 cells/powergrid.c
cmdoptions.o: cmdoptions.c cmdoptions.h print.h
cmdoptions_def.o: cmdoptions_def.c
cpu.o: cpu.c cpu.h
error.o: error.h error.c
export.o: export.c export.h object.h hashmap.h \
 polygon.h point.h shape.h technology.h lua/lua.h \
 lua/luaconf.h vector.h transformationmatrix.h \
 lua/lauxlib.h lua/lua.h export_common.h export_writer.h \
 filesystem.h gdsexport.h lua_util.h skillexport.h \
 util.h
export_common.o: export_common.c export_common.h object.h \
 hashmap.h polygon.h point.h shape.h technology.h \
 lua/lua.h lua/luaconf.h vector.h transformationmatrix.h
export_writer.o: export_writer.c export_writer.h lua/lua.h \
 lua/luaconf.h export_common.h object.h hashmap.h \
 polygon.h point.h shape.h technology.h vector.h \
 transformationmatrix.h tagged_value.h util.h
filesystem.o: filesystem.c filesystem.h lua/lua.h \
 lua/luaconf.h lua/lauxlib.h lua/lua.h
gdsexport.o: gdsexport.c gdsexport.h export_common.h \
 object.h hashmap.h polygon.h point.h shape.h \
 technology.h lua/lua.h lua/luaconf.h vector.h \
 transformationmatrix.h math.h tagged_value.h geometry.h \
 util.h
gdsparser.o: gdsparser.c gdsparser.h lua/lua.h \
 lua/luaconf.h vector.h lua/lauxlib.h lua/lua.h \
 math.h filesystem.h point.h hashmap.h lua_util.h \
 util.h
geometry.o: geometry.c geometry.h technology.h lua/lua.h \
 lua/luaconf.h vector.h hashmap.h object.h polygon.h \
 point.h shape.h transformationmatrix.h math.h
geometry_triangulate.o: geometry_triangulate.c math.h point.h \
 vector.h
graphics.o: graphics.c graphics.h point.h vector.h \
 math.h
hashmap.o: hashmap.c hashmap.h util.h
info.o: info.c info.h object.h hashmap.h polygon.h \
 point.h shape.h technology.h lua/lua.h lua/luaconf.h \
 vector.h transformationmatrix.h
lcheck.o: lcheck.c lcheck.h lua/lua.h lua/luaconf.h
ldebug.o: ldebug.c ldebug.h lua/lua.h lua/luaconf.h
ldir.o: ldir.c ldir.h lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h util.h
lgenerics.o: lgenerics.c lgenerics.h lua/lua.h \
 lua/luaconf.h lua/lauxlib.h lua/lua.h technology.h \
 vector.h hashmap.h
lgeometry.o: lgeometry.c lgeometry.h lua/lua.h \
 lua/luaconf.h lua/lauxlib.h lua/lua.h geometry.h \
 technology.h vector.h hashmap.h object.h polygon.h \
 point.h shape.h transformationmatrix.h graphics.h \
 lcheck.h lgenerics.h lobject.h lplacement.h lpoint.h \
 lutil.h placement.h
limport.o: limport.c limport.h lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h import.h
lobject.o: lobject.c lobject.h lua/lua.h lua/luaconf.h \
 object.h hashmap.h polygon.h point.h shape.h \
 technology.h vector.h transformationmatrix.h \
 lua/lauxlib.h lua/lua.h bltrshape.h lpoint.h \
 lcheck.h
lplacement.o: lplacement.c lplacement.h lua/lua.h \
 lua/luaconf.h polygon.h point.h lua/lauxlib.h \
 lua/lua.h lcheck.h lgenerics.h lobject.h object.h \
 hashmap.h shape.h technology.h vector.h \
 transformationmatrix.h lpoint.h lutil.h placement.h
lplacer.o: lplacer.c lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h lplacer_nonoverlapping.h \
 lplacer_classic.h
lplacer_classic.o: lplacer_classic.c lplacer_classic.h \
 lua/lua.h lua/luaconf.h lplacer_common.h hashmap.h \
 lplacer_rand.h math.h util.h
lplacer_common.o: lplacer_common.c lplacer_common.h lua/lua.h \
 lua/luaconf.h hashmap.h
lplacer_nonoverlapping.o: lplacer_nonoverlapping.c \
 lplacer_nonoverlapping.h lua/lua.h lua/luaconf.h \
 lplacer_common.h hashmap.h lplacer_rand.h
lplacer_rand.o: lplacer_rand.c lplacer_rand.h lua/lua.h \
 lua/luaconf.h
lpoint.o: lpoint.c lpoint.h lua/lua.h lua/luaconf.h \
 point.h lua/lauxlib.h lua/lua.h math.h
lpostprocess.o: lpostprocess.c lpostprocess.h lua/lua.h \
 lua/luaconf.h lua/lauxlib.h lua/lua.h postprocess.h \
 object.h hashmap.h polygon.h point.h shape.h \
 technology.h vector.h transformationmatrix.h lobject.h
lrouter.o: lrouter.c lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h lrouter_net.h lrouter_field.h \
 vector.h lrouter_route.h lrouter_moves.h
lrouter_field.o: lrouter_field.c lrouter_field.h
lrouter_min_heap.o: lrouter_min_heap.c lrouter_field.h \
 lrouter_min_heap.h
lrouter_moves.o: lrouter_moves.c lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h lrouter_moves.h
lrouter_net.o: lrouter_net.c lrouter_net.h lrouter_field.h \
 vector.h util.h
lrouter_queue.o: lrouter_queue.c lrouter_queue.h \
 lrouter_field.h
lrouter_route.o: lrouter_route.c lrouter_route.h \
 lrouter_net.h lrouter_field.h vector.h \
 lrouter_min_heap.h
lterminal.o: lterminal.c lterminal.h lua/lua.h \
 lua/luaconf.h terminal.h
lua_util.o: lua_util.c lua_util.h lua/lua.h lua/luaconf.h \
 lua/lauxlib.h lua/lua.h lua/lualib.h
lutil.o: lutil.c lutil.h lua/lua.h lua/luaconf.h \
 polygon.h point.h lpoint.h
main.api_help.o: main.api_help.c main.api_help.h \
 terminal.h print.h util.h vector.h \
 main.api_help/aux.c main.api_help/curve.c \
 main.api_help/generics.c main.api_help/geometry.c \
 main.api_help/global.c main.api_help/graphics.c \
 main.api_help/layouthelpers.c main.api_help/object.c \
 main.api_help/pcell.c main.api_help/placement.c \
 main.api_help/placer.c main.api_help/point.c \
 main.api_help/router.c main.api_help/routing.c \
 main.api_help/technology.c main.api_help/util.c
main.assistant.o: main.assistant.c lua_util.h lua/lua.h \
 lua/luaconf.h
main.cell.o: main.cell.c main.cell.h hashmap.h \
 cmdoptions.h lua/lauxlib.h lua/luaconf.h lua/lua.h \
 export.h object.h polygon.h point.h shape.h \
 technology.h lua/lua.h vector.h transformationmatrix.h \
 filesystem.h gdsparser.h geometry.h info.h \
 main.functions.h pcell.h postprocess.h util_cmodule.h \
 util.h _config.h
main.functions.o: main.functions.c main.functions.h lua/lua.h \
 lua/luaconf.h technology.h vector.h hashmap.h \
 lua/lauxlib.h lua/lua.h lua_util.h filesystem.h \
 pcell.h object.h polygon.h point.h shape.h \
 transformationmatrix.h util_cmodule.h ldir.h lgenerics.h \
 lgeometry.h lobject.h lplacement.h lplacer.h \
 lpoint.h lpostprocess.h lrouter.h
main.gds.o: main.gds.c main.gds.h cmdoptions.h \
 main.functions.h lua/lua.h lua/luaconf.h technology.h \
 vector.h hashmap.h gdsparser.h
main.import.o: main.import.c main.import.h vector.h \
 lua/lua.h lua/luaconf.h lua/lauxlib.h lua/lua.h \
 cdl_parser.h filesystem.h lplacement.h polygon.h \
 point.h lplacer.h lrouter.h lua_util.h \
 main.functions.h technology.h hashmap.h _modulemanager.h \
 util_cmodule.h util.h
main.tutorial.o: main.tutorial.c main.tutorial.h print.h \
 terminal.h
netlist.o: netlist.c netlist.h
object.o: object.c object.h hashmap.h polygon.h \
 point.h shape.h technology.h lua/lua.h lua/luaconf.h \
 vector.h transformationmatrix.h bltrshape.h util.h
pcell.o: pcell.c pcell.h lua/lua.h lua/luaconf.h \
 object.h hashmap.h polygon.h point.h shape.h \
 technology.h vector.h transformationmatrix.h \
 lua/lauxlib.h lua/lua.h cells.h main.functions.h \
 util.h lua_util.h ldir.h lobject.h ldebug.h \
 _scriptmanager.h _modulemanager.h
placement.o: placement.c placement.h object.h hashmap.h \
 polygon.h point.h shape.h technology.h lua/lua.h \
 lua/luaconf.h vector.h transformationmatrix.h geometry.h \
 util.h
point.o: point.c point.h
polygon.o: polygon.c polygon.h point.h vector.h
postprocess.o: postprocess.c postprocess.h object.h \
 hashmap.h polygon.h point.h shape.h technology.h \
 lua/lua.h lua/luaconf.h vector.h transformationmatrix.h \
 union.h
print.o: print.c
shape.o: shape.c shape.h point.h polygon.h \
 technology.h lua/lua.h lua/luaconf.h vector.h \
 hashmap.h transformationmatrix.h math.h graphics.h \
 geometry.h object.h
skillexport.o: skillexport.c skillexport.h export_common.h \
 object.h hashmap.h polygon.h point.h shape.h \
 technology.h lua/lua.h lua/luaconf.h vector.h \
 transformationmatrix.h tagged_value.h util.h
spectre_parser.o: spectre_parser.c parser.h buffer.h device.h \
 string.h tokenlist.h vector.h
spectre_tokenlist.o: spectre_tokenlist.c tokenlist.h vector.h
string.o: string.c string.h
strprint.o: strprint.c string.h
tagged_value.o: tagged_value.c tagged_value.h util.h
technology.o: technology.c technology.h lua/lua.h \
 lua/luaconf.h vector.h hashmap.h lua/lauxlib.h \
 lua/lua.h util.h lua_util.h tagged_value.h ldebug.h
terminal.o: terminal.c terminal.h
transformationmatrix.o: transformationmatrix.c \
 transformationmatrix.h point.h
union.o: union.c union.h point.h vector.h shape.h \
 polygon.h technology.h lua/lua.h lua/luaconf.h \
 hashmap.h transformationmatrix.h
util.o: util.c util.h
util_cmodule.o: util_cmodule.c util_cmodule.h lua/lua.h \
 lua/luaconf.h lua/lauxlib.h lua/lua.h lua/lualib.h \
 lpoint.h point.h union.h vector.h
vector.o: vector.c vector.h
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
