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
#include "util_cmodule.h"

#include "main.functions.h"

void main_verilog_import(const char* scriptname, const struct const_vector* args)
{
    lua_State* L = util_create_basic_lua_state();
    open_lutil_cmodule_lib(L);
    module_load_globals(L);
    module_load_check(L);
    module_load_aux(L);
    module_load_util(L);
    module_load_verilog(L);
    module_load_verilogprocessor(L);
    open_lplacer_lib(L);
    open_lplacement_lib(L);
    module_load_placement(L);
    open_lrouter_lib(L);
    module_load_routing(L);
    open_lfilesystem_lib(L);
    module_load_generator(L);

    // script args
    lua_newtable(L);
    for(unsigned int i = 0; i < const_vector_size(args); ++i)
    {
        lua_pushstring(L, const_vector_get(args, i));
        lua_rawseti(L, -2, i + 1);
    }
    lua_setglobal(L, "args");

    main_call_lua_program(L, scriptname);
    lua_close(L);
}

