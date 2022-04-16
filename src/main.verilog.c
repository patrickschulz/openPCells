#include "lua/lua.h"

#include <stdio.h>

#include "lua/lauxlib.h"

#include "util.h"
#include "lua_util.h"
#include "modulemanager.h"
#include "filesystem.h"
#include "lplacer.h"
#include "lrouter.h"

void main_verilog_import(const char* scriptname)
{
    lua_State* L = util_create_basic_lua_state();
    module_load_globals(L);
    if(!lua_isnil(L, -1))
    {
        lua_setglobal(L, "globals");
    }
    module_load_aux(L);
    if(!lua_isnil(L, -1))
    {
        lua_setglobal(L, "aux");
    }
    module_load_verilog(L);
    if(!lua_isnil(L, -1))
    {
        lua_setglobal(L, "verilog");
    }
    module_load_verilogprocessor(L);
    if(!lua_isnil(L, -1))
    {
        lua_setglobal(L, "verilogprocessor");
    }
    open_lplacer_lib(L);
    module_load_placement(L);
    if(!lua_isnil(L, -1))
    {
        lua_setglobal(L, "placement");
    }
    open_lrouter_lib(L);
    module_load_routing(L);
    if(!lua_isnil(L, -1))
    {
        lua_setglobal(L, "routing");
    }
    open_lfilesystem_lib(L);
    module_load_generator(L);
    if(!lua_isnil(L, -1))
    {
        lua_setglobal(L, "generator");
    }
    int ret = luaL_dofile(L, scriptname);
    if(ret != LUA_OK)
    {
        const char* msg = lua_tostring(L, -1);
        printf("errors while loading verilog import script:\n    %s\n", msg);
    }
    lua_close(L);
}
