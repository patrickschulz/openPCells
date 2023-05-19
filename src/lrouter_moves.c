#include "lua/lua.h"
#include "lua/lauxlib.h"

#include "lrouter_moves.h"

void moves_create_port(lua_State *L, const char *name, const char *port)
{
    lua_pushfstring(L, "cells[\"%s\"]:get_anchor(\"%s\"):translate(bp.routingwidth / 2, bp.routingwidth / 2)", name, port);

    lua_setfield(L, -2, "where");

    lua_pushstring(L, "true");
    lua_setfield(L, -2, "nodraw");
    
    lua_pushstring(L, "point");
    lua_setfield(L, -2, "type");

}

void moves_create_via(lua_State *L, int z, int is_draw)
{
    lua_pushstring(L, "via");
    lua_setfield(L, -2, "type");
    lua_pushinteger(L, z);
    lua_setfield(L, -2, "z");

    if (!is_draw)
    {
        lua_pushstring(L, "true");
        lua_setfield(L, -2, "nodraw");
    }
    else
    {
        lua_pushstring(L, "false");
        lua_setfield(L, -2, "nodraw");
    }
}

void moves_create_delta(lua_State *L, dir_t dir, int dist)
{
    lua_pushstring(L, "delta");
    lua_setfield(L, -2, "type");
    lua_pushinteger(L, -dist);
    if(dir == X_DIR)
    {
        lua_setfield(L, -2, "x");
    }
    else if(dir == Y_DIR)
    {
        lua_setfield(L, -2, "y");
    }
}

void moves_create_shift(lua_State *L, int x, int y)
{
    lua_pushstring(L, "shift");
    lua_setfield(L, -2, "type");

    lua_pushinteger(L, x);
    lua_setfield(L, -2, "x");

    lua_pushinteger(L, y);
    lua_setfield(L, -2, "y");
}
