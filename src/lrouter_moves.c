#include "lua/lua.h"
#include "lua/lauxlib.h"

#include "lrouter_moves.h"

void moves_create_port(lua_State *L, const char *name, const char *port)
{
    lua_pushstring(L, "anchor");
    lua_setfield(L, -2, "type");

    lua_pushstring(L, port);
    lua_setfield(L, -2, "anchor");

    lua_pushstring(L, name);
    lua_setfield(L, -2, "name");
}

void moves_create_via(lua_State *L, int z)
{
    lua_pushstring(L, "via");
    lua_setfield(L, -2, "type");
    lua_pushinteger(L, z);
    lua_setfield(L, -2, "z");
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
