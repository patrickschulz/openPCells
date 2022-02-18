#include "lgenerics.h"

#include "lua/lauxlib.h"

static int lgenerics_create_metal(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    generics_t* layer = generics_create_metal(num);
    lua_pushlightuserdata(L, layer);
    return 1;
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
        { "metal", lgenerics_create_metal },
        { NULL,    NULL                   }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LGENERICSMODULE);

    return 0;
}
