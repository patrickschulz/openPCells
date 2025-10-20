#include "limport.h"

#include "lua/lauxlib.h"

#include "cdl_parser.h"
#include "netlist.h"

static int limport_read_CDL_netlist(lua_State* L)
{
    const char* filename = luaL_checkstring(L, 1);
    struct netlist* netlist = cdlparser_parse(filename);
    netlist_create_lua_representation(netlist, L);
    netlist_destroy(netlist);
    return 1; // netlist_create_lua_representation creates a table
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

