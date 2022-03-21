#include "lreduce.h"

#include "lua/lauxlib.h"

#include "lobject.h"
#include "reduce.h"

int lreduce_merge_shapes(lua_State* L)
{
    lobject_t* lobject = lua_touserdata(L, 1);
    reduce_merge_shapes(lobject->object);
    return 0;
}

int open_lreduce_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "merge_shapes", lreduce_merge_shapes },
        { NULL,           NULL                 }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "reduce");
    return 0;
}
