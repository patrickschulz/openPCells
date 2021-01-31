#include "lbinary.h"

#include "lua/lua.h"
#include "lua/lauxlib.h"

static int lbinary_split_in_bytes(lua_State* L)
{
    if(lua_gettop(L) < 2)
    {
        lua_pushstring(L, "split_in_bytes: two arguments expected");
        lua_error(L);
    }
    unsigned int bits = 8;
    int num = lua_tointeger(L, 1);
    unsigned int bytes = lua_tointeger(L, 2);
    lua_createtable(L, bytes, 0);
    if(num < 0)
    {
        for(unsigned int i = bytes; i > 0; --i)
        {
            int byte = num >> (bits * (i - 1));
            lua_pushinteger(L, byte);
            lua_rawseti(L, -2, i);
            num = num - (byte << (bits * (i - 1)));
        }
        lua_rawgeti(L, -1, 4);
        lua_pushinteger(L, lua_tointeger(L, -1) + 256);
        lua_rawseti(L, -3, 4);
        lua_pop(L, 1);
    }
    else
    {
        for(unsigned int i = bytes; i > 0; --i)
        {
            int byte = num >> (bits * (i - 1));
            lua_pushinteger(L, byte);
            lua_rawseti(L, -2, i);
            num = num - (byte << (bits * (i - 1)));
        }
    }
    return 1;
}

int open_lbinary_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "split_in_bytes",        lbinary_split_in_bytes       },
        { NULL,            NULL                }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LBINARYMODULE);
    return 0;
}
