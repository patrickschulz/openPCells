#include "main.functions.h"

#include <stdlib.h>
#include <string.h>

#include "lua/lauxlib.h"

#include "lua_util.h"

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

int main_call_lua_program_from_buffer(lua_State* L, const char* data, size_t len, const char* name)
{
    int status = luaL_loadbuffer(L, data, len, name);
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

int main_load_module(lua_State* L, const char* data, size_t len, const char* name, const char* chunkname)
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

