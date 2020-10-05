#ifndef LLOAD_H
#define LLOAD_H

#include "config.h"

#define LLOAD_BUFSIZE 200

int opc_get_home(lua_State* L)
{
    lua_pushstring(L, OPC_HOME);
    return 1;
}

int opc_load_module(lua_State* L)
{
    const char* name = lua_tostring(L, -1);
    char filename[LLOAD_BUFSIZE];
    snprintf(filename, LLOAD_BUFSIZE, "%s/%s.lua", OPC_HOME, name);
    /* TODO: add error checks */
    int status = luaL_loadfile(L, filename);
    if(status == LUA_OK)
    {
        lua_pcall(L, 0, LUA_MULTRET, 0);
        return 1;
    }
    else
    {
        printf("syntax error while loading module '%s'\n", name);
        return 0;
    }
}

#endif // LLOAD_H
