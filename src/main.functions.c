#include "main.functions.h"

#include <stdlib.h>
#include <string.h>

#include "lua/lauxlib.h"

#include "lua_util.h"

int main_lua_pcall(lua_State* L, int nargs, int nresults)
{
    lua_pushcfunction(L, util_msghandler);
    lua_insert(L, -2 - nargs);
    int status = lua_pcall(L, nargs, nresults, 1);

    // pop msghandler (first it has to be put on top)
    if(status == LUA_OK)
    {
        lua_rotate(L, -1 - nresults, nresults);
        lua_pop(L, 1);
    }
    else
    {
        lua_rotate(L, -2, 1);
    }
    lua_pop(L, 1);
    return status;
}

int main_call_lua_program(lua_State* L, const char* filename)
{
    int status = luaL_loadfile(L, filename);
    if(status == LUA_OK)
    {
        lua_pushcfunction(L, util_msghandler);
        lua_insert(L, 1);
        status = lua_pcall(L, 0, 1, 1);
    }
    if(status != LUA_OK) 
    {
        const char* msg = lua_tostring(L, -1);
        fprintf(stderr, "%s\n", msg);
        lua_pop(L, 1);
        return LUA_ERRRUN;
    }
    return LUA_OK;
}

int main_call_lua_program_from_buffer(lua_State* L, const unsigned char* data, size_t len, const char* name)
{
    int status = luaL_loadbuffer(L, (const char*)data, len, name);
    if(status == LUA_OK)
    {
        lua_pushcfunction(L, util_msghandler);
        lua_insert(L, 1);
        status = lua_pcall(L, 0, 1, 1);
    }
    if(status != LUA_OK)
    {
        const char* msg = lua_tostring(L, -1);
        fprintf(stderr, "%s\n", msg);
        lua_pop(L, 1);
        return LUA_ERRRUN;
    }
    // pop msghandler (which is at the bottom of the stack)
    // the number of returned values is 1 (therefore one call to lua_insert)
    lua_insert(L, 1);
    lua_pop(L, 1);
    return LUA_OK;
}

int main_load_module(lua_State* L, const unsigned char* data, size_t len, const char* name, const char* chunkname)
{
    int status = main_call_lua_program_from_buffer(L, data, len, chunkname);
    if(status == LUA_OK)
    {
        if(!lua_isnil(L, -1))
        {
            lua_setglobal(L, name);
        }
        else
        {
            lua_pop(L, 1);
        }
    }
    return LUA_OK;
}

