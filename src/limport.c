#include "limport.h"

#include "lua/lauxlib.h"

#include "limport.h"

static int limport_read_CDL_netlist(lua_State* L)
{
    return 0;
}

int open_limport_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "read_CDL_netlist",       limport_read_CDL_netlist    },
        { NULL,                     NULL                        }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LIMPORTMODULE);
    return 0;
}

