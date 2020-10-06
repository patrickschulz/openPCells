#include "lua/lua.h"
#include "lua/lauxlib.h"

static int _lbind_call(lua_State *L)
{
    int callargs = lua_gettop(L);
    int pos = lua_tointeger(L, lua_upvalueindex(1)); // argument position
    lua_pushvalue(L, lua_upvalueindex(2)); // bound value
    lua_insert(L, pos); // put value at right position
    lua_pushvalue(L, lua_upvalueindex(3)); // function
    lua_insert(L, 1); // put function at bottom of stack
    lua_call(L, callargs + 1, LUA_MULTRET);
    return 1;
}

int lbind(lua_State* L)
{
    luaL_checktype(L, 1, LUA_TFUNCTION);
    luaL_checkinteger(L, 2);
    luaL_checkany(L, 3);
    lua_rotate(L, 1, 2);
    lua_pushcclosure(L, &_lbind_call, 3);
    return 1;
}

int open_lbind_lib(lua_State* L)
{
    lua_pushcfunction(L, lbind);
    lua_setglobal(L, "bind");
    return 0;
}
