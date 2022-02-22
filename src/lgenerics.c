#include "lgenerics.h"

#include "lua/lauxlib.h"

#include "generics.h"

static void _create_layer_table(lua_State* L, struct layer_collection* layers)
{
    lua_newtable(L);
    for(unsigned int i = 0; i < layers->size; ++i)
    {
        lua_pushlightuserdata(L, layers->layers[i]);
        lua_rawseti(L, -2, i + 1);
    }
}

static int lgenerics_create_metal(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    struct layer_collection* layers = generics_create_metal(num, L);
    _create_layer_table(L, layers);
    return 1;
}

static int lgenerics_create_other(lua_State* L)
{
    size_t len;
    const char* str = luaL_checklstring(L, 1, &len);
    struct layer_collection* layers = generics_create_other(str, len, L);
    _create_layer_table(L, layers);
    return 1;
}

static int lgenerics_resolve_premapped_layers(lua_State* L)
{
    const char* exportname = luaL_checkstring(L, 1);
    generics_resolve_premapped_layers(exportname);
    return 0;
}

int open_lgenerics_lib(lua_State* L)
{
    /*
    // create metatable for generics
    luaL_newmetatable(L, LGENERICSMODULE);

    // set methods
    static const luaL_Reg metafuncs[] =
    {
        { NULL,         NULL               }
    };
    luaL_setfuncs(L, metafuncs, 0);
    */

    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "metal",                    lgenerics_create_metal             },
        { "other",                    lgenerics_create_other             },
        { "resolve_premapped_layers", lgenerics_resolve_premapped_layers },
        { NULL,                       NULL                               }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LGENERICSMODULE);

    return 0;
}
