#include "main.verilog.h"

#include "lua/lua.h"

#include <stdio.h>

#include "lua/lauxlib.h"

#include "filesystem.h"
#include "lplacement.h"
#include "lplacer.h"
#include "lrouter.h"
#include "lua_util.h"
#include "modulemanager.h"
#include "util.h"

#include "main.functions.h"

void main_verilog_import(const char* scriptname, const struct vector* args)
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
    module_load_util(L);
    if(!lua_isnil(L, -1))
    {
        lua_setglobal(L, "util");
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
    open_lplacement_lib(L);
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

    // script args
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(args); ++i)
    {
        lua_pushstring(L, vector_get_const(args, i));
        lua_rawseti(L, -2, i + 1);
    }
    lua_setglobal(L, "args");

    main_call_lua_program(L, scriptname);
    lua_close(L);
}

