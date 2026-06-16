#include "pcell.h"

#include "lua/lauxlib.h"

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#include "cells.h"

#include "ldebug.h"
#include "ldir.h"
#include "lobject.h"
#include "lua_util.h"
#include "main.functions.h"
#include "main.lua.h"
#include "timeperf.h"
#include "util.h"

#include "pcell.common.h"
#define OPC_PCELL_IMPLEMENTATION
#include "pcell.def.h"
#undef OPC_PCELL_IMPLEMENTATION

#include "_scriptmanager.h"
#include "_modulemanager.h"

static struct object* _process_object(lua_State* L, int retval)
{
    if(retval != LUA_OK)
    {
        const char* errmsg = lua_tostring(L, -1);
        fprintf(stderr, "%s\n", errmsg);
        return NULL;
    }
    int success = lua_toboolean(L, -2);
    if(success)
    {
        struct lobject* lobject = lobject_check_soft(L, -1);
        struct object* toplevel = lobject_get_unchecked(lobject);
        lobject_disown(lobject);
        return toplevel;
    }
    else
    {
        const char* msg = lua_tostring(L, -1);
        fprintf(stderr, "%s\n", msg);
        return NULL;
    }
}

static lua_State* _prepare_layout_generation(struct pcell_state* pcell_state, struct technology_state* techstate)
{
    lua_State* L = util_create_basic_lua_state();
    main_load_opc_libraries(L);

    // register techstate
    if(techstate)
    {
        lua_pushlightuserdata(L, techstate);
        lua_setfield(L, LUA_REGISTRYINDEX, "techstate");
    }

    // load main modules
    module_load_alignmentgroup(L);
    module_load_aux(L);
    module_load_check(L);
    module_load_globals(L);
    module_load_graphics(L);
    module_load_load(L);
    module_load_placement(L);
    module_load_routing(L);
    module_load_util(L);
    module_load_layouthelpers(L);
    module_load_profiler(L);

    int ret = pcellcommon_load_pcell_library(L, pcell_state);
    if(!ret)
    {
        lua_close(L);
        return NULL;
    }

    return L;
}

struct object* pcell_create_layout_from_script(struct pcell_state* pcell_state, struct technology_state* techstate, const char* scriptname, const char* toplevelname, struct const_vector* cellargs, const char *cellenvfilename, int dodebug)
{
    (void)toplevelname;
    lua_State* L = _prepare_layout_generation(pcell_state, techstate);
    if(timeperf_is_enabled())
    {
        lua_getglobal(L, "profiler");
        lua_getfield(L, -1, "start");
        lua_call(L, 0, 0);
        lua_pop(L, 1);
    }
    struct object* toplevel = NULL;
    if(!L)
    {
        return NULL;
    }
    lua_getglobal(L, "pcell");
    lua_getfield(L, -1, "create_layout_from_script_wrapper");
    lua_pushstring(L, scriptname);
    // cell arguments
    lua_newtable(L);
    for(unsigned int i = 0; i < const_vector_size(cellargs); ++i)
    {
        const char* str = const_vector_get(cellargs, i);
        lua_pushstring(L, str);
        lua_rawseti(L, -2, i + 1);
    }
    // load cell environment
    if(!pcellcommon_load_cellenv(L, cellenvfilename))
    {
        fprintf(stderr, "could not load cell environment in '%s'\n", cellenvfilename);
        goto create_layout_from_script_finish;
    }
    // gather debug info?
    lua_pushboolean(L, dodebug);
    // arguments:
    // (1) scriptpath
    // (2) args
    // (3) cellenv
    // (4) dodebug
    int retval = main_lua_pcall(L, 4, 2);
    toplevel = _process_object(L, retval);
create_layout_from_script_finish:
    if(timeperf_is_enabled())
    {
        lua_getglobal(L, "profiler");
        lua_getfield(L, -1, "stop");
        lua_call(L, 0, 0);
        lua_getfield(L, -1, "display");
        lua_call(L, 0, 0);
        lua_pop(L, 1);
    }
    lua_close(L);
    return toplevel;
}

struct object* pcell_create_layout_env(struct pcell_state* pcell_state, struct technology_state* techstate, const char* cellname, const char* toplevelname, const char* cellenvfilename, int dodebug)
{
    lua_State* L = _prepare_layout_generation(pcell_state, techstate);
    if(!L)
    {
        return NULL;
    }
    struct object* toplevel = NULL;
    // get function
    lua_getglobal(L, "pcell");
    lua_getfield(L, -1, "create_layout_env_wrapper");
    // push arguments: cellname and object name
    lua_pushstring(L, cellname);
    lua_pushstring(L, toplevelname);
    // assemble cell arguments
    lua_newtable(L);
    if(!pcellcommon_load_pfiles(pcell_state, L))
    {
        fputs("could not load pfiles\n", stderr);
        goto create_layout_finish;
    }
    // load cell environment
    if(!pcellcommon_load_cellenv(L, cellenvfilename))
    {
        fprintf(stderr, "could not load cell environment in '%s'\n", cellenvfilename);
        goto create_layout_finish;
    }
    // gather debug info?
    lua_pushboolean(L, dodebug);
    // call layout generation function
    // arguments:
    // (1) cellname
    // (2) name
    // (3) cellargs
    // (4) env
    // (5) dodebug
    int retval = main_lua_pcall(L, 5, 2);
    // check for errors and retrieve object in C
    toplevel = _process_object(L, retval);
create_layout_finish:
    lua_close(L);
    return toplevel;
}

void pcell_show_cell_info(struct pcell_state* pcell_state, const char* cellname)
{
    lua_State* L = _prepare_layout_generation(pcell_state, NULL);

    // assemble cell arguments
    lua_newtable(L);
    // cell name
    lua_pushstring(L, cellname);
    lua_setfield(L, -2, "cell");
    lua_setglobal(L, "args");

    int retval = script_call_show_cell_info(L);
    if(retval != LUA_OK)
    {
        puts("error while running show_cell_info.lua");
    }
    lua_close(L);
}

void pcell_list_cellpaths(const struct pcell_state* pcell_state)
{
    for(unsigned int i = 0; i < vector_size(pcell_state->cellpaths); ++i)
    {
        puts(vector_get(pcell_state->cellpaths, i));
    }
}

void pcell_list_cells(struct const_vector* cellnames, struct pcell_state* pcell_state, const char* listformat)
{
    lua_State* L = util_create_basic_lua_state();
    module_load_aux(L);
    if(!lua_isnil(L, -1))
    {
        lua_setglobal(L, "aux");
    }
    open_ldir_lib(L);

    lua_newtable(L); // args
    // cell paths
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(pcell_state->cellpaths); ++i)
    {
        lua_pushstring(L, vector_get_const(pcell_state->cellpaths, i));
        lua_rawseti(L, -2, i + 1);
    }
    lua_setfield(L, -2, "cellpaths");
    // list format
    if(listformat)
    {
        lua_pushstring(L, listformat);
        lua_setfield(L, -2, "listformat");
    }
    // cellnames names
    size_t numposargs = 0;
    lua_newtable(L);
    for(size_t i = 0; i < const_vector_size(cellnames); ++i)
    {
        lua_pushstring(L, const_vector_get(cellnames, i));
        lua_rawseti(L, -2, numposargs + 1);
        ++numposargs;
    }
    if(numposargs > 0)
    {
        lua_setfield(L, -2, "cellnames");
    }
    else
    {
        lua_pop(L, 1);
    }
    lua_setglobal(L, "args");
    script_call_list_cells(L);
    lua_close(L);
}

static cell_layout_func _get_layout_function(struct pcell_state* pcell_state, const char* cellname)
{
    // FIXME
    (void)pcell_state;
    (void)cellname;
    return cell_powergrid_layout;
}

struct object* pcell_create_layout(const char* cellname, struct technology_state* techstate, struct pcell_state* pcell_state)
{
    cell_layout_func layout_func = _get_layout_function(pcell_state, cellname);
    struct object* cell = object_create("__EMPTY__");
    int ret = layout_func(pcell_state, techstate, cell);
    if(!ret)
    {
        // FIXME: error message, clean up
        object_destroy(cell);
        return NULL;
    }
    return cell;
}

void pcell_list_parameters(struct pcell_state* pcell_state, struct technology_state* techstate, const char* cellname, const char* parametersformat, struct const_vector* parameternames)
{
    lua_State* L = _prepare_layout_generation(pcell_state, techstate);

    // assemble cell arguments
    lua_newtable(L);
    // cell name
    lua_pushstring(L, cellname);
    lua_setfield(L, -2, "cell");
    // format
    if(parametersformat)
    {
        lua_pushstring(L, parametersformat);
        lua_setfield(L, -2, "parametersformat");
    }
    lua_pushboolean(L, techstate ? 0 : 1);
    lua_setfield(L, -2, "generictech");
    // parameter names
    size_t numposargs = 0;
    lua_newtable(L);
    for(size_t i = 0; i < const_vector_size(parameternames); ++i)
    {
        lua_pushstring(L, const_vector_get(parameternames, i));
        lua_rawseti(L, -2, numposargs + 1);
        ++numposargs;
    }
    if(numposargs > 0)
    {
        lua_setfield(L, -2, "parameternames");
    }
    else
    {
        lua_pop(L, 1);
    }
    lua_setglobal(L, "args");

    int retval = script_call_list_parameters(L);
    if(retval != LUA_OK)
    {
        puts("error while running list_parameters.lua");
    }
    lua_close(L);
}

void pcell_list_anchors(struct pcell_state* pcell_state, const char* cellname, const char* anchorsformat, struct const_vector* anchornames)
{
    lua_State* L = _prepare_layout_generation(pcell_state, NULL); // don't need technology

    // assemble cell arguments
    lua_newtable(L);
    // cell name
    lua_pushstring(L, cellname);
    lua_setfield(L, -2, "cell");
    // format
    if(anchorsformat)
    {
        lua_pushstring(L, anchorsformat);
        lua_setfield(L, -2, "anchorsformat");
    }
    // anchor names
    size_t numposargs = 0;
    lua_newtable(L);
    for(size_t i = 0; i < const_vector_size(anchornames); ++i)
    {
        lua_pushstring(L, const_vector_get(anchornames, i));
        lua_rawseti(L, -2, numposargs + 1);
        ++numposargs;
    }
    if(numposargs > 0)
    {
        lua_setfield(L, -2, "anchornames");
    }
    else
    {
        lua_pop(L, 1);
    }
    lua_setglobal(L, "args");

    int retval = script_call_list_anchors(L);
    if(retval != LUA_OK)
    {
        puts("error while running list_anchors.lua");
    }
    lua_close(L);
}
