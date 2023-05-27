#include "lua/lua.h"
#include "lua/lauxlib.h"

#include "lrouter_moves.h"

static void _create(lua_State* L, const char* type)
{
    lua_newtable(L);
    lua_pushstring(L, type);
    lua_setfield(L, -2, "type");
}

void moves_create_port(lua_State *L, const char *name, const char *port)
{
    _create(L, "point");
    lua_pushfstring(L, "cells[\"%s\"]:get_anchor(\"%s\"):translate(bp.routingwidth / 2, bp.routingwidth / 2)", name, port);
    lua_setfield(L, -2, "where");
    lua_pushboolean(L, 1);
    lua_setfield(L, -2, "nodraw");
}

void moves_create_via(lua_State *L, int z)
{
    _create(L, "via");
    lua_pushinteger(L, z);
    lua_setfield(L, -2, "z");
    lua_pushboolean(L, 0);
    lua_setfield(L, -2, "nodraw");
}

void moves_create_via_nodraw(lua_State *L, int z)
{
    _create(L, "via");
    lua_pushinteger(L, z);
    lua_setfield(L, -2, "z");
    lua_pushboolean(L, 1);
    lua_setfield(L, -2, "nodraw");
}


void moves_create_delta(lua_State *L, dir_t dir, int dist)
{
    _create(L, "delta");
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
    _create(L, "shift");
    lua_pushinteger(L, x);
    lua_setfield(L, -2, "x");
    lua_pushinteger(L, y);
    lua_setfield(L, -2, "y");
}

