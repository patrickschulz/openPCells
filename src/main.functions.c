#include "main.functions.h"

#include <stdlib.h>
#include <string.h>

#include "lua/lauxlib.h"

#include "config.h"

static int msghandler (lua_State *L)
{
    const char *msg = lua_tostring(L, 1);
    if (msg == NULL) /* is error object not a string? */
    {
        if (luaL_callmeta(L, 1, "__tostring") &&  /* does it have a metamethod */
                lua_type(L, -1) == LUA_TSTRING)  /* that produces a string? */
        {
            return 1;  /* that is the message */
        }
        else
        {
            msg = lua_pushfstring(L, "(error object is a %s value)",
                    luaL_typename(L, 1));
        }
    }
    luaL_traceback(L, L, msg, 1);  /* append a standard traceback */
    return 1;  /* return the traceback */
}

int main_call_lua_program(lua_State* L, const char* filename)
{
    int status = luaL_loadfile(L, filename);
    if(status == LUA_OK)
    {
        lua_pushcfunction(L, msghandler);
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
        lua_pushcfunction(L, msghandler);
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

void main_load_lua_module(lua_State* L, const char* modname)
{
    size_t len = strlen(OPC_HOME) + strlen(modname) + 9; // +9: "/src/" + ".lua"
    char* path = malloc(len + 1);
    snprintf(path, len + 1, "%s/src/%s.lua", OPC_HOME, modname);
    main_call_lua_program(L, path);
    free(path);
}

