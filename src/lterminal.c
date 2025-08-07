#include "lterminal.h"

#include "lua/lauxlib.h"

#include "terminal.h"

int lterminal_set_foreground_color(lua_State* L)
{
    int r = luaL_checkinteger(L, 1);
    int g = luaL_checkinteger(L, 2);
    int b = luaL_checkinteger(L, 3);
    terminal_set_foreground_color_RGB(r, g, b);
    return 0;
}

int lterminal_set_background_color(lua_State* L)
{
    int r = luaL_checkinteger(L, 1);
    int g = luaL_checkinteger(L, 2);
    int b = luaL_checkinteger(L, 3);
    terminal_set_background_color_RGB(r, g, b);
    return 0;
}

int lterminal_reset_color(lua_State* L)
{
    (void)L;
    terminal_reset_color();
    return 0;
}

int open_lterminal_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "set_foreground_color",   lterminal_set_foreground_color  },
        { "set_background_color",   lterminal_set_background_color  },
        { "reset_color",            lterminal_reset_color           },
        { NULL,                     NULL                            }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LTERMINALMODULE);
    return 0;
}

