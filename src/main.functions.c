#include "main.functions.h"

#include <stdlib.h>
#include <string.h>

#include "lua/lauxlib.h"

#include "lua_util.h"

#include "filesystem.h"
#include "pcell.h"
#include "util_cmodule.h"

#include "ldir.h"
#include "lgenerics.h"
#include "lgeometry.h"
#include "lobject.h"
#include "lplacement.h"
#include "lplacer.h"
#include "lpoint.h"
#include "lpostprocess.h"
#include "lrouter.h"
#include "lua_util.h"

lua_State* main_create_and_initialize_lua(void)
{
    lua_State* L = util_create_basic_lua_state();
    // opc libraries
    open_ldir_lib(L);
    open_lfilesystem_lib(L);
    open_lpoint_lib(L);
    open_lgeometry_lib(L);
    open_lgenerics_lib(L);
    open_ltechnology_lib(L);
    open_lobject_lib(L);
    open_lplacement_lib(L);
    open_lpostprocess(L);
    open_lutil_cmodule_lib(L);
    // FIXME: these libraries are probably not needed for cell creation (they are used in place & route scripts)
    open_lplacer_lib(L);
    open_lrouter_lib(L);
    return L;
}

int main_lua_pcall(lua_State* L, int nargs, int nresults)
{
    lua_pushcfunction(L, util_msghandler);
    int msghandlerpos = -1 - nargs - 1; // put below arguments: -1 (top position) - nargs (arguments are on top) - 1 (called function is below arguments)
    lua_insert(L, msghandlerpos);
    int status = lua_pcall(L, nargs, nresults, -1 - nargs - 1);
    if(status != LUA_OK) 
    {
        const char* msg = lua_tostring(L, -1);
        fprintf(stderr, "%s\n", msg);
        lua_pop(L, 1); // pop error message
        lua_pop(L, 1); // pop message handler
        return LUA_ERRRUN;
    }
    return LUA_OK;
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

