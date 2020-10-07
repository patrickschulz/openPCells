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
    (luaL_dofile(L, OPC_HOME "/" "load.lua"));
    return 0;
}
