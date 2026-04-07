PROGNAME=opc

CC=gcc

# Preprocessor definitions
PPFLAGS=-DLUA_USE_LINUX -DLUA_USE_JUMPTABLE=0 -DTERMOGRAPHY_ENABLE_TERM_WIDTH -DOPC_ENABLE_TIMING

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

OBJS:= \
	arith.o \
	bltrshape.o \
	buffer.o \
	cdl_parser.o \
	cdl_tokenlist.o \
	cells.o \
	cmdoptions.o \
	error.o \
	export_common.o \
	export.o \
	export_writer.o \
	filesystem.o \
	gdsexport.o \
	gdsparser.o \
	geometry.o \
	geometry_triangulate.o \
	graphics.o \
	hashmap.o \
	info.o \
	layouthelpers_cmodule.o \
	lcheck.o \
	ldebug.o \
	ldir.o \
	lgenerics.o \
	lgeometry.o \
	limport.o \
	lobject.o \
	lplacement.o \
	lplacer_classic.o \
	lplacer_common.o \
	lplacer_nonoverlapping.o \
	lplacer.o \
	lplacer_rand.o \
	lpoint.o \
	lpolygon.o \
	lpostprocess.o \
	lrouter_field.o \
	lrouter_min_heap.o \
	lrouter_moves.o \
	lrouter_net.o \
	lrouter.o \
	lrouter_queue.o \
	lrouter_route.o \
	lterminal.o \
	lua_util.o \
	lutil.o \
	main.api_help.o \
	main.assistant.o \
	main.cell.o \
	main.cellbase.o \
	main.config.o \
	main.functions.o \
	main.gds.o \
	main.lua.o \
	main.tutorial.o \
	main.import.o \
	netlist.o \
	object.o \
	pcell.o \
	pcell.common.o \
	pcell.state.o \
	placement.o \
	point.o \
	polygon.o \
	postprocess.o \
	print.o \
	shape.o \
	skillexport.o \
	string.o \
	strprint.o \
	tagged_value.o \
	technology.o \
	terminal.o \
	timeperf.o \
	transformationmatrix.o \
	tuple.o \
	union.o \
	util_cmodule.o \
	util.o \
	vector.o

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
	$(CC) $(CFLAGS) $(OPTFLAGS) -DNDEBUG -o release/$(PROGNAME) main.c $(RELEASEOBJS) _modulemanager.c _scriptmanager.c liblua_release.a -lm -ldl

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
	$(CC) -c $(CFLAGS) -DOPC_DEBUG -O0 -g -o $@ $<

.PHONY: check
check:
	clang-tidy $(patsubst %.o,%.c,$(OBJS)) $(wildcard *.h)

opc.1: cmdoptions_def.c generate_manpage
	./generate_manpage > opc.1

generate_manpage: cmdoptions.h cmdoptions.c print.c generate_manpage.c
	$(CC) $(CFLAGS) generate_manpage.c cmdoptions.c print.c vector.c util.c -o generate_manpage

_scriptmanager.c: _embed_compiled_lua_file scripts/*.lua
	@echo '#include "_scriptmanager.h"' > __scriptmanager.c
	@echo '#include <stddef.h>' >> __scriptmanager.c
	@echo '#include "main.lua.h"' >> __scriptmanager.c
	./_embed_compiled_lua_file --script scripts/show_cell_info.lua script_call show_cell_info __scriptmanager.c
	./_embed_compiled_lua_file --script scripts/create_cell_documentation.lua script_call create_cell_documentation __scriptmanager.c
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
	@echo 'int script_call_show_cell_info(lua_State* L);' >> __scriptmanager.h
	@echo 'int script_call_create_cell_documentation(lua_State* L);' >> __scriptmanager.h
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
	@echo '#include "main.lua.h"' >> _modulemanager.c
	./_embed_compiled_lua_file --module modules/alignmentgroup.lua module_load alignmentgroup _modulemanager.c
	./_embed_compiled_lua_file --module modules/aux.lua module_load aux _modulemanager.c
	./_embed_compiled_lua_file --module modules/check.lua module_load check _modulemanager.c
	./_embed_compiled_lua_file --module modules/generator.lua module_load generator _modulemanager.c
	./_embed_compiled_lua_file --module modules/globals.lua module_load globals _modulemanager.c
	./_embed_compiled_lua_file --module modules/graphics.lua module_load graphics _modulemanager.c
	./_embed_compiled_lua_file --module modules/import.lua module_load import _modulemanager.c
	./_embed_compiled_lua_file --module modules/generics.lua module_load generics _modulemanager.c
	./_embed_compiled_lua_file --module modules/layouthelpers.lua module_load layouthelpers _modulemanager.c
	./_embed_compiled_lua_file --module modules/load.lua module_load load _modulemanager.c
	./_embed_compiled_lua_file --module modules/pcell.lua module_load pcell _modulemanager.c
	./_embed_compiled_lua_file --module modules/placement.lua module_load placement _modulemanager.c
	./_embed_compiled_lua_file --module modules/profiler.lua module_load profiler _modulemanager.c
	./_embed_compiled_lua_file --module modules/routing.lua module_load routing _modulemanager.c
	./_embed_compiled_lua_file --module modules/tools.lua module_load tools _modulemanager.c
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
	@echo 'int module_load_import(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_generics(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_layouthelpers(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_load(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_pcell(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_placement(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_profiler(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_routing(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_tools(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_util(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_verilog(lua_State* L);' >> _modulemanager.h
	@echo 'int module_load_verilogprocessor(lua_State* L);' >> _modulemanager.h
	@echo '#endif // OPC_MODULEMANAGER_H' >> _modulemanager.h

_embed_compiled_lua_file: embed_compiled_lua_file.c
	$(CC) $(CFLAGS) $(PPFLAGS) embed_compiled_lua_file.c lua/lapi.c lua/lauxlib.c lua/lbaselib.c lua/lcode.c lua/lcorolib.c lua/lctype.c lua/ldblib.c lua/ldebug.c lua/ldo.c lua/ldump.c lua/lfunc.c lua/lgc.c lua/linit.c lua/liolib.c lua/llex.c lua/lmathlib.c lua/lmem.c lua/loadlib.c lua/lobject.c lua/lopcodes.c lua/loslib.c lua/lparser.c lua/lstate.c lua/lstring.c lua/lstrlib.c lua/ltable.c lua/ltablib.c lua/ltm.c lua/lundump.c lua/lvm.c lua/lzio.c -o _embed_compiled_lua_file -lm -ldl

create_latex_API_doc: create_latex_API_doc.c main.api_help.c main.api_help.h vector.c vector.h util.c util.h terminal.c terminal.h
	$(CC) $(CFLAGS) create_latex_API_doc.c main.api_help.c print.c terminal.c util.c vector.c -o create_latex_API_doc

create_HTML_API_doc: create_HTML_API_doc.c main.api_help.c main.api_help/*.c main.api_help.h vector.c vector.h util.c util.h terminal.c terminal.h
	$(CC) $(CFLAGS) create_HTML_API_doc.c main.api_help.c print.c string.c terminal.c util.c vector.c -o create_HTML_API_doc

create_cell_documentation: create_cell_documentation.c main.config.c main.lua.c main.cellbase.c cmdoptions.c lua_util.c print.c filesystem.h filesystem.c error.c hashmap.c vector.c util.c string.c strprint.c pcell.info.c pcell.state.c pcell.common.c ldir.c _scriptmanager.c _modulemanager.c liblua_release.a
	$(CC) $(CFLAGS) create_cell_documentation.c main.config.c main.lua.c main.cellbase.c cmdoptions.c lua_util.c print.c filesystem.c error.c hashmap.c vector.c util.c string.c strprint.c pcell.info.c pcell.state.c pcell.common.c ldir.c _scriptmanager.c _modulemanager.c liblua_release.a -o create_cell_documentation -lm

include recipes.mk
include lua.mk

.PHONY: clean
clean:
	@rm -rf release lint debug
	@rm -f $(PROGNAME)
	@rm -f $(PROGNAME)-lint
	@rm -f $(PROGNAME)-debug
	@rm -f liblua_release.a $(LUA_CORE_RELEASEOBJS) $(LUA_LIB_RELEASEOBJS)
	@rm -f liblua_lint.a $(LUA_CORE_LINTOBJS) $(LUA_LIB_LINTOBJS)
	@rm -f liblua_debug.a $(LUA_CORE_DEBUGOBJS) $(LUA_LIB_DEBUGOBJS)
	@rm -f _embed_compiled_lua_file
	@rm -f generate_manpage
	@rm -f create_latex_API_doc
	@rm -f create_HTML_API_doc
	@rm -f create_cell_documentation
	@rm -f _modulemanager.h _modulemanager.c
	@rm -f _scriptmanager.h _scriptmanager.c
	@rm -f _scriptmanager.h _scriptmanager.c
