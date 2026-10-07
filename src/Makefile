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
	cpu.o \
	foreach.o \
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
    object.anchors.o \
    object.base.o \
    object.common.o \
    object.full.o \
    object.ports.o \
    object.proxy.o \
    object.public.o \
    object.util.o \
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

# header dependencies are written by the compiler (-MMD -MP) as .d files next to the object files
DEPFLAGS=-MMD -MP

# generated files that are included by some sources
# (order-only, the real dependencies are tracked by the .d files once they exist)
GENERATED_HEADERS=_modulemanager.h _scriptmanager.h

.PHONY: default
default: $(PROGNAME) $(PROGNAME)-debug

$(PROGNAME): release/$(PROGNAME)
	cp release/$(PROGNAME) $(PROGNAME)

$(PROGNAME)-lint: lint/$(PROGNAME)
	cp lint/$(PROGNAME) $(PROGNAME)-lint

$(PROGNAME)-debug: debug/$(PROGNAME)
	cp debug/$(PROGNAME) $(PROGNAME)-debug

release/lua lint/lua debug/lua:
	mkdir -p $@

release/$(PROGNAME): release/main.o liblua_release.a _modulemanager.c _scriptmanager.c $(RELEASEOBJS)
	$(CC) $(CFLAGS) $(OPTFLAGS) -DNDEBUG -o release/$(PROGNAME) release/main.o $(RELEASEOBJS) _modulemanager.c _scriptmanager.c liblua_release.a -lm -ldl

release/%.o: %.c | release/lua $(GENERATED_HEADERS)
	$(CC) -c $(CFLAGS) $(OPTFLAGS) -DNDEBUG $(DEPFLAGS) -o $@ $<

lint/$(PROGNAME): lint/main.o liblua_lint.a _modulemanager.c _scriptmanager.c $(LINTOBJS)
	$(CC) $(CFLAGS) $(OPTFLAGS) -DOPC_LINT -o lint/$(PROGNAME) lint/main.o $(LINTOBJS) _modulemanager.c _scriptmanager.c liblua_lint.a -lm -ldl

lint/%.o: %.c | lint/lua $(GENERATED_HEADERS)
	$(CC) -c $(CFLAGS) $(OPTFLAGS) -DOPC_LINT $(DEPFLAGS) -o $@ $<

debug/$(PROGNAME): debug/main.o liblua_debug.a _modulemanager.c _scriptmanager.c $(DEBUGOBJS)
	$(CC) $(CFLAGS) -O0 -g -o debug/$(PROGNAME) debug/main.o $(DEBUGOBJS) _modulemanager.c _scriptmanager.c liblua_debug.a -lm -ldl

debug/%.o: %.c | debug/lua $(GENERATED_HEADERS)
	$(CC) -c $(CFLAGS) -DOPC_DEBUG -O0 -g $(DEPFLAGS) -o $@ $<

-include $(wildcard release/*.d release/lua/*.d lint/*.d lint/lua/*.d debug/*.d debug/lua/*.d)

.PHONY: check
check:
	clang-tidy $(patsubst %.o,%.c,$(OBJS)) $(wildcard *.h)

opc.1: cmdoptions_def.c generate_manpage
	./generate_manpage > opc.1

generate_manpage: cmdoptions.h cmdoptions.c print.c generate_manpage.c
	$(CC) $(CFLAGS) generate_manpage.c cmdoptions.c print.c vector.c util.c -o generate_manpage

# embedded lua files
# scripts/<name>.lua is available as script_call_<name>, modules/<name>.lua as module_load_<name>
EMBEDDED_SCRIPTS:= \
	show_cell_info \
	create_cell_documentation \
	list_cells \
	list_parameters \
	list_anchors \
	templates \
	check_technology

EMBEDDED_MODULES:= \
	alignmentgroup \
	aux \
	check \
	generator \
	globals \
	graphics \
	import \
	generics \
	layouthelpers \
	load \
	pcell \
	placement \
	profiler \
	routing \
	tools \
	util \
	verilog \
	verilogprocessor

# the headers only depend on the lists above, they are regenerated on every run,
# but only replaced if their content changed (so that dependent objects are not rebuilt unnecessarily)
.PHONY: FORCE
FORCE:

_scriptmanager.h: FORCE
	@echo '#ifndef OPC_SCRIPTMANAGER_H' > $@.tmp
	@echo '#define OPC_SCRIPTMANAGER_H' >> $@.tmp
	@echo '#include "lua/lua.h"' >> $@.tmp
	@for name in $(EMBEDDED_SCRIPTS); do echo "int script_call_$$name(lua_State* L);" >> $@.tmp; done
	@echo '#endif // OPC_SCRIPTMANAGER_H' >> $@.tmp
	@cmp -s $@.tmp $@ && rm $@.tmp || mv $@.tmp $@

_modulemanager.h: FORCE
	@echo '#ifndef OPC_MODULEMANAGER_H' > $@.tmp
	@echo '#define OPC_MODULEMANAGER_H' >> $@.tmp
	@echo '#include "lua/lua.h"' >> $@.tmp
	@for name in $(EMBEDDED_MODULES); do echo "int module_load_$$name(lua_State* L);" >> $@.tmp; done
	@echo '#endif // OPC_MODULEMANAGER_H' >> $@.tmp
	@cmp -s $@.tmp $@ && rm $@.tmp || mv $@.tmp $@

# the header is a prerequisite, as it changes when the list of embedded files changes
_scriptmanager.c: _embed_compiled_lua_file _scriptmanager.h $(addprefix scripts/, $(addsuffix .lua, $(EMBEDDED_SCRIPTS)))
	@echo '#include "_scriptmanager.h"' > $@.tmp
	@echo '#include <stddef.h>' >> $@.tmp
	@echo '#include "main.lua.h"' >> $@.tmp
	@for name in $(EMBEDDED_SCRIPTS); do \
		echo "./_embed_compiled_lua_file --script scripts/$$name.lua script_call $$name $@"; \
		./_embed_compiled_lua_file --script scripts/$$name.lua script_call $$name $@.tmp || exit 1; \
	done
	@mv $@.tmp $@

_modulemanager.c: _embed_compiled_lua_file _modulemanager.h $(addprefix modules/, $(addsuffix .lua, $(EMBEDDED_MODULES)))
	@echo '#include "_modulemanager.h"' > $@.tmp
	@echo '#include <stddef.h>' >> $@.tmp
	@echo '#include "main.lua.h"' >> $@.tmp
	@for name in $(EMBEDDED_MODULES); do \
		echo "./_embed_compiled_lua_file --module modules/$$name.lua module_load $$name $@"; \
		./_embed_compiled_lua_file --module modules/$$name.lua module_load $$name $@.tmp || exit 1; \
	done
	@mv $@.tmp $@

_embed_compiled_lua_file: embed_compiled_lua_file.c
	$(CC) $(CFLAGS) $(PPFLAGS) embed_compiled_lua_file.c lua/lapi.c lua/lauxlib.c lua/lbaselib.c lua/lcode.c lua/lcorolib.c lua/lctype.c lua/ldblib.c lua/ldebug.c lua/ldo.c lua/ldump.c lua/lfunc.c lua/lgc.c lua/linit.c lua/liolib.c lua/llex.c lua/lmathlib.c lua/lmem.c lua/loadlib.c lua/lobject.c lua/lopcodes.c lua/loslib.c lua/lparser.c lua/lstate.c lua/lstring.c lua/lstrlib.c lua/ltable.c lua/ltablib.c lua/ltm.c lua/lundump.c lua/lvm.c lua/lzio.c -o _embed_compiled_lua_file -lm -ldl

create_latex_API_doc: create_latex_API_doc.c main.api_help.c main.api_help.h vector.c vector.h util.c util.h terminal.c terminal.h
	$(CC) $(CFLAGS) create_latex_API_doc.c main.api_help.c print.c terminal.c util.c vector.c -o create_latex_API_doc

create_HTML_API_doc: create_HTML_API_doc.c main.api_help.c main.api_help/*.c main.api_help.h vector.c vector.h util.c util.h terminal.c terminal.h
	$(CC) $(CFLAGS) create_HTML_API_doc.c main.api_help.c print.c string.c terminal.c util.c vector.c -o create_HTML_API_doc

create_cell_documentation: create_cell_documentation.c main.config.c main.lua.c main.cellbase.c cmdoptions.c lua_util.c print.c filesystem.h filesystem.c error.c hashmap.c vector.c util.c string.c strprint.c pcell.info.c pcell.state.c pcell.common.c ldir.c _scriptmanager.c _modulemanager.c liblua_release.a
	$(CC) $(CFLAGS) create_cell_documentation.c main.config.c main.lua.c main.cellbase.c cmdoptions.c lua_util.c print.c filesystem.c error.c hashmap.c vector.c util.c string.c strprint.c pcell.info.c pcell.state.c pcell.common.c ldir.c _scriptmanager.c _modulemanager.c liblua_release.a -o create_cell_documentation -lm -ldl

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
