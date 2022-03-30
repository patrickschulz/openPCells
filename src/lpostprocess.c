#include "lpostprocess.h"

#include "lua/lauxlib.h"
#include <stdlib.h>
#include <string.h>

#include "lobject.h"
#include "postprocess.h"
#include "pcell.h"

int lpostprocess_merge_shapes(lua_State* L)
{
    lobject_t* lobject = lua_touserdata(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    postprocess_merge_shapes(lobject->object, layermap);
    for(unsigned int i = 0; i < pcell_get_reference_count(); ++i)
    {
        object_t* cell = pcell_get_indexed_cell_reference(i)->cell;
        postprocess_merge_shapes(cell, layermap);
    }
    return 0;
}

int lpostprocess_filter(lua_State* L)
{
    lobject_t* lobject = lua_touserdata(L, 1);
    lua_len(L, 2);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    const char** layernames = calloc(len, sizeof(*layernames));
    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 2, i);
        layernames[i - 1] = lua_tostring(L, -1);
        lua_pop(L, 1);
    }
    const char* what = lua_tostring(L, 3);
    if(strcmp(what, "include") == 0)
    {
        postprocess_filter_include(lobject->object, layernames, len);
        for(unsigned int i = 0; i < pcell_get_reference_count(); ++i)
        {
            object_t* cell = pcell_get_indexed_cell_reference(i)->cell;
            postprocess_filter_include(cell, layernames, len);
        }
    }
    else
    {
        postprocess_filter_exclude(lobject->object, layernames, len);
        for(unsigned int i = 0; i < pcell_get_reference_count(); ++i)
        {
            object_t* cell = pcell_get_indexed_cell_reference(i)->cell;
            postprocess_filter_exclude(cell, layernames, len);
        }
    }
    free(layernames);
    return 0;
}

int open_lpostprocess_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "merge_shapes", lpostprocess_merge_shapes },
        { "filter",       lpostprocess_filter       },
        { NULL,           NULL                      }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "postprocess");
    return 0;
}
