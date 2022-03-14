#include "lobject.h"

#include "lua/lauxlib.h"

typedef struct
{

} lobject_t;

int open_lobject_lib(lua_State* L)
{
    // create metatable for objects
    luaL_newmetatable(L, LOBJECTMODULE);

    // set methods
    static const luaL_Reg metafuncs[] =
    {
        { NULL,                           NULL                                }
    };
    luaL_setfuncs(L, metafuncs, 0);

    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); 
    lua_rawset(L, -3);

    static const luaL_Reg modfuncs[] =
    {
        { NULL,                    NULL                         }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LOBJECTMODULE);

    return 0;
}
