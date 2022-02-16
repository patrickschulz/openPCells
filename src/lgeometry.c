#include "lgeometry.h"

#include "lua/lauxlib.h"

#include "geometry.h"

int open_lgeometry_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { NULL, NULL }
    };
    luaL_setfuncs(L, modfuncs, 0);

    lua_setglobal(L, LGEOMETRYMODULE);
    return 0;
}
