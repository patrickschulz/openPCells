#include "lload.h"
#include "config.h"

#include "lua/lauxlib.h"

static int opc_get_home(lua_State* L)
{
    lua_pushstring(L, OPC_HOME);
    return 1;
}

int open_lload_lib(lua_State* L)
{
    lua_pushcfunction(L, opc_get_home);
    lua_setglobal(L, "_get_opc_home");
    // _load_module is written in lua
    // no error checks, we know what we are doing
    (void) (luaL_loadfile(L, OPC_HOME "/" "load.lua") || lua_pcall(L, 0, LUA_MULTRET, 0));
    return 0;
}
