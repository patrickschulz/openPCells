#include "pcell.h"

#include "lua/lauxlib.h"
#include <stdlib.h>
#include <string.h>

#include "cells.h"

#include "main.functions.h"
#include "util.h"
#include "lua_util.h"
#include "ldir.h"
#include "lobject.h"
#include "main.functions.h"
#include "ldebug.h"

#include "scriptmanager.h"
#include "modulemanager.h"

struct pcell_state {
    struct vector* cellpaths;
    int enable_dprint;
    int enable_debug;
};

/*
 * https://c-faq.com/varargs/handoff.html
 * use va_list
void pcell_dprint(struct pcell_state* pcell_state, const char* fmt, ...)
{
    if(pcell_state->enable_dprint)
    {
        printf(fmt, ...);
    }
}
*/

struct pcell_state* pcell_initialize_state(struct vector* cellpaths_to_prepend, struct vector* cellpaths_to_append)
{
    struct pcell_state* pcell_state = malloc(sizeof(*pcell_state));
    pcell_state->cellpaths = vector_create(64, free);
    if(cellpaths_to_prepend)
    {
        for(unsigned int i = 0; i < vector_size(cellpaths_to_prepend); ++i)
        {
            pcell_prepend_cellpath(pcell_state, vector_get_const(cellpaths_to_prepend, i));
        }
    }
    if(cellpaths_to_append)
    {
        for(unsigned int i = 0; i < vector_size(cellpaths_to_append); ++i)
        {
            pcell_append_cellpath(pcell_state, vector_get_const(cellpaths_to_append, i));
        }
    }
    pcell_state->enable_dprint = 0;
    pcell_state->enable_debug = 0;
    return pcell_state;
}

void pcell_destroy_state(struct pcell_state* pcell_state)
{
    vector_destroy(pcell_state->cellpaths);
    free(pcell_state);
}

void pcell_enable_debug(struct pcell_state* pcell_state)
{
    pcell_state->enable_debug = 1;
}

void pcell_enable_dprint(struct pcell_state* pcell_state)
{
    pcell_state->enable_dprint = 1;
}

// lua bridge
struct lpcell {
    struct pcell_state* pcell_state;
};

static void _create_lua_state(lua_State* L, struct pcell_state* pcell_state);
static int _open_lpcell_lib(lua_State* L);

static lua_State* _prepare_layout_generation(struct pcell_state* pcell_state, struct technology_state* techstate)
{
    lua_State* L = main_create_and_initialize_lua();

    // register techstate
    lua_pushlightuserdata(L, techstate);
    lua_setfield(L, LUA_REGISTRYINDEX, "techstate");

    // load main modules
    module_load_aux(L);
    module_load_check(L);
    module_load_globals(L);
    module_load_graphics(L);
    module_load_load(L);
    module_load_stack(L); // must be loaded before pcell (FIXME: explicitly create the lua pcell state)
    module_load_pcell(L);
    module_load_placement(L);
    module_load_routing(L);
    module_load_util(L);
    module_load_layouthelpers(L);

    _open_lpcell_lib(L);

    lua_getglobal(L, "pcell");
    lua_getfield(L, -1, "register_pcell_state");
    _create_lua_state(L, pcell_state);
    int retval = main_lua_pcall(L, 1, 0);
    if(retval != LUA_OK)
    {
        fputs("could not initialize pcell state\n", stderr);
        lua_close(L);
        return NULL;
    }

    /*
    // assemble cell arguments
    lua_newtable(L);

    // object name
    lua_pushstring(L, name);
    lua_setfield(L, -2, "toplevelname");

    // input args
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(cellargs); ++i)
    {
        lua_pushstring(L, vector_get(cellargs, i));
        lua_rawseti(L, -2, i + 1);
    }
    lua_setfield(L, -2, "additionalargs");
    */

    /*
    // pfiles
    lua_newtable(L);
    if(pfilenames)
    {
        for(unsigned int i = 0; i < const_vector_size(pfilenames); ++i)
        {
            const char* pfilename = const_vector_get(pfilenames, i);
            _read_table_from_file(L, pfilename); // don't stop on error
            lua_pushnil(L);
            while(lua_next(L, -2) != 0)
            {
                if(lua_type(L, -1) == LUA_TTABLE)
                {
                    puts("no nested tables are allowed in parameter files");
                    lua_close(L);
                    return NULL;
                }
                if(lua_type(L, -2) != LUA_TSTRING)
                {
                    puts("non-string keys in parameter files are prohibited");
                    lua_close(L);
                    return NULL;
                }
                lua_pushvalue(L, -2);
                lua_pushvalue(L, -2);
                lua_rawset(L, -6);
                lua_pop(L, 1);
            }
            lua_pop(L, 1);
        }
    }
    lua_setfield(L, -2, "cellargs");
    */

    /*
    // cell environment
    if(cellenvfilename)
    {
        if(!_read_table_from_file(L, cellenvfilename))
        {
            lua_close(L);
            return NULL;
        }
    }
    else
    {
        lua_newtable(L);
    }
    lua_setfield(L, -2, "cellenv");
    */

    /*
    // register args
    lua_setglobal(L, "args");
    */

    return L;
}

struct object* pcell_create_layout_from_script(struct pcell_state* pcell_state, struct technology_state* techstate, const char* scriptname, const char* name, struct vector* cellargs)
{
    lua_State* L = _prepare_layout_generation(pcell_state, techstate);
    if(!L)
    {
        return NULL;
    }
    lua_getglobal(L, "pcell");
    lua_getfield(L, -1, "create_layout_from_script");
    lua_pushstring(L, scriptname);
    // cell arguments
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(cellargs); ++i)
    {
        lua_pushstring(L, vector_get(cellargs, i));
        lua_rawseti(L, -2, i + 1);
    }
    int retval = main_lua_pcall(L, 2, 1);
    if(retval != LUA_OK)
    {
        lua_close(L);
        return NULL;
    }
    struct lobject* lobject = lobject_check_soft(L, -1);
    if(!lobject)
    {
        fputs("cell/cellscript did not return an object\n", stderr);
        lua_close(L);
        return NULL;
    }
    struct object* toplevel = lobject_get_unchecked(lobject);
    lobject_disown(lobject);
    lua_pop(L, 1); // pop pcell table
    lua_close(L);
    return toplevel;
}

struct object* pcell_create_layout_env(struct pcell_state* pcell_state, struct technology_state* techstate, const char* cellname, const char* toplevelname)
{
    lua_State* L = _prepare_layout_generation(pcell_state, techstate);
    if(!L)
    {
        return NULL;
    }
    //cell = pcell.create_layout_env(args.cell, args.toplevelname, args.cellargs, args.cellenv)
    lua_getglobal(L, "pcell");
    lua_getfield(L, -1, "create_layout_env");
    lua_pushstring(L, cellname);
    lua_pushstring(L, toplevelname);
    lua_pushnil(L); // FIXME: args.cellargs
    lua_pushnil(L); // FIXME: args.cellenv
    int retval = main_lua_pcall(L, 4, 1);
    if(retval != LUA_OK)
    {
        lua_close(L);
        return NULL;
    }
    struct lobject* lobject = lobject_check_soft(L, -1);
    if(!lobject)
    {
        fputs("cell/cellscript did not return an object\n", stderr);
        lua_close(L);
        return NULL;
    }
    struct object* toplevel = lobject_get_unchecked(lobject);
    lobject_disown(lobject);
    lua_pop(L, 1); // pop pcell table
    lua_close(L);
    return toplevel;
}

void pcell_prepend_cellpath(struct pcell_state* pcell_state, const char* path)
{
    vector_prepend(pcell_state->cellpaths, util_strdup(path));
}

void pcell_append_cellpath(struct pcell_state* pcell_state, const char* path)
{
    vector_append(pcell_state->cellpaths, util_strdup(path));
}

void pcell_list_cellpaths(const struct pcell_state* pcell_state)
{
    for(unsigned int i = 0; i < vector_size(pcell_state->cellpaths); ++i)
    {
        puts(vector_get(pcell_state->cellpaths, i));
    }
}

void pcell_list_cells(const struct pcell_state* pcell_state, const char* listformat)
{
    lua_State* L = util_create_basic_lua_state();
    module_load_aux(L);
    if(!lua_isnil(L, -1))
    {
        lua_setglobal(L, "aux");
    }
    open_ldir_lib(L);

    lua_newtable(L);
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(pcell_state->cellpaths); ++i)
    {
        lua_pushstring(L, vector_get_const(pcell_state->cellpaths, i));
        lua_rawseti(L, -2, i + 1);
    }
    lua_setfield(L, -2, "cellpaths");
    if(listformat)
    {
        lua_pushstring(L, listformat);
        lua_setfield(L, -2, "listformat");
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

static int lpcell_get_cell_filename(lua_State* L)
{
    struct lpcell* lpcell = luaL_checkudata(L, 1, "LPCELL");
    struct pcell_state* pcell_state = lpcell->pcell_state;
    const char* cellname = luaL_checkstring(L, 2);
    for(unsigned int i = 0; i < vector_size(pcell_state->cellpaths); ++i)
    {
        const char* path = vector_get_const(pcell_state->cellpaths, i);
        size_t len = strlen(path) + strlen(cellname) + 5; // '/' + ".lua"
        char* filename = malloc(len + 1);
        snprintf(filename, len + 1, "%s/%s.lua", path, cellname);
        if(util_file_exists(filename))
        {
            // first found matching cell is used
            lua_pushstring(L, filename);
            free(filename);
            return 1;
        }
        free(filename);
    }
    lua_pushfstring(L, "could not find cell '%s' in:\n", cellname);
    unsigned int num = 0;
    for(unsigned int i = 0; i < vector_size(pcell_state->cellpaths); ++i)
    {
        lua_pushstring(L, "  ");
        ++num;
        const char* path = vector_get_const(pcell_state->cellpaths, i);
        lua_pushstring(L, path);
        ++num;
        if(i < vector_size(pcell_state->cellpaths) - 1)
        {
            lua_pushstring(L, "\n");
            ++num;
        }
    }
    lua_concat(L, num + 1);
    lua_error(L);
    return 0;
}

static int lpcell_dprint(lua_State* L)
{
    struct pcell_state* pcell_state = lua_touserdata(L, 1);
    if(pcell_state->enable_dprint)
    {
        // taken from lbaselib.c:
        int n = lua_gettop(L);  /* number of arguments */
        // skip pcell state (first argument)
        for(int i = 2; i <= n; i++) 
        {  /* for each argument */
            size_t l;
            const char *s = luaL_tolstring(L, i, &l);  /* convert it to string */
            if (i > 2)  /* not the first element? */
                lua_writestring("\t", 1);  /* add a tab before it */
            lua_writestring(s, l);  /* print it */
            lua_pop(L, 1);  /* pop result */
        }
        lua_writeline();
    }
    return 0;
}

static void _create_lua_state(lua_State* L, struct pcell_state* pcell_state)
{
    struct lpcell* lpcell = lua_newuserdata(L, sizeof(*lpcell));
    lpcell->pcell_state = pcell_state;
    luaL_setmetatable(L, "LPCELL");
    // no return value, as the value on the stack is used
}

static int _open_lpcell_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] = {
        { "get_cell_filename",       lpcell_get_cell_filename       },
        { "dprint",                  lpcell_dprint                  },
        { NULL,                      NULL                           }
    };
    luaL_newmetatable(L, "LPCELL");
    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2);
    lua_rawset(L, -3);
    // register functions
    luaL_setfuncs(L, modfuncs, 0);
    lua_pop(L, 1);
    return 0;
}
