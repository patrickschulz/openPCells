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
    int sign = num < 0;
    for(unsigned int i = bytes; i > 0; --i)
    {
        int byte = num >> (bits * (i - 1));
        lua_pushinteger(L, byte);
        lua_rawseti(L, -2, bytes - i + 1);
        num = num - (byte << (bits * (i - 1)));
    }
    if(sign)
    {
        lua_rawgeti(L, -1, 1);
        lua_pushinteger(L, lua_tointeger(L, -1) + 256);
        lua_rawseti(L, -3, 1);
        lua_pop(L, 1);
    }
    return 1;
}

static int lbinary_assemble(lua_State* L)
{
    /*
    local args = { ... }
    local t = {}
    for _, data in ipairs(args) do
        for _, datum in ipairs(data) do
            table.insert(t, string.char(datum))
        end
    end
    return table.concat(t)
    */
    int nargs = lua_gettop(L);
    for(int i = 1; i <= nargs; ++i)
    {

    }
    return 1;
}

int open_lbinary_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "split_in_bytes", lbinary_split_in_bytes },
        { "assemble",       lbinary_assemble       },
        { NULL,             NULL                   }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LBINARYMODULE);
    return 0;
}
