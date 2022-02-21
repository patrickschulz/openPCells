#include "lgenerics.h"

#include "lua/lauxlib.h"

#include "generics.h"

static int lgenerics_create_metal(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    generics_t* layer = generics_create_metal(num, L);
    lua_newtable(L);
    lua_pushlightuserdata(L, layer);
    lua_rawseti(L, -2, 1);
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
        { "resolve_premapped_layers", lgenerics_resolve_premapped_layers },
        { NULL,                       NULL                               }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LGENERICSMODULE);

    return 0;
}
