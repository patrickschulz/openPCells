#include "pcell.h"

#include "lua/lauxlib.h"
#include <stdlib.h>
#include <string.h>

#include "cells.h"

#include "util.h"
#include "lua_util.h"
#include "ldir.h"

#include "scriptmanager.h"
#include "modulemanager.h"

struct pcell_state {
    struct vector* cellpaths;
    //int enable_dprint;
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
    return pcell_state;
}

void pcell_destroy_state(struct pcell_state* pcell_state)
{
    vector_destroy(pcell_state->cellpaths);
    free(pcell_state);
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
    int ret = layout_func(cell, techstate, pcell_state);
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
    lua_getfield(L, LUA_REGISTRYINDEX, "pcellstate");
    struct pcell_state* pcell_state = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop pcell state
    const char* cellname = luaL_checkstring(L, 1);
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
    lua_newtable(L);
    lua_pushfstring(L, "could not find cell '%s' in:\n", cellname);
    for(unsigned int i = 0; i < vector_size(pcell_state->cellpaths); ++i)
    {
        lua_pushstring(L, "  ");
        const char* path = vector_get_const(pcell_state->cellpaths, i);
        lua_pushstring(L, path);
        if(i < vector_size(pcell_state->cellpaths) - 1)
        {
            lua_pushstring(L, "\n");
        }
    }
    lua_concat(L, 3 * vector_size(pcell_state->cellpaths));
    lua_error(L);
    return 0;
}

static int lpcell_append_cellpath(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "pcellstate");
    struct pcell_state* pcell_state = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop pcell state
    const char* path = luaL_checkstring(L, 1);
    vector_append(pcell_state->cellpaths, util_strdup(path));
    return 0;
}

int open_lpcell_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "get_cell_filename",       lpcell_get_cell_filename       },
        { "append_cellpath",         lpcell_append_cellpath         },
        { NULL,                      NULL                           }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "pcell");
    return 0;
}

