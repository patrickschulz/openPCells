#include <stdio.h>

#include "_scriptmanager.h"
#include "lua_util.h"
#include "pcell.common.h"
#include "ldir.h"

#define OPC_PCELL_IMPLEMENTATION
#include "pcell.def.h"
#undef OPC_PCELL_IMPLEMENTATION

void pcell_create_cell_documentation(struct pcell_state* pcell_state)
{
    lua_State* L = util_create_basic_lua_state();
    pcellcommon_load_pcell_library(L, pcell_state);
    open_ldir_lib(L);

    // assemble cell arguments
    lua_newtable(L);
    // cell paths
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(pcell_state->cellpaths); ++i)
    {
        lua_pushstring(L, vector_get_const(pcell_state->cellpaths, i));
        lua_rawseti(L, -2, i + 1);
    }
    lua_setfield(L, -2, "cellpaths");

    lua_setglobal(L, "args");

    int retval = script_call_create_cell_documentation(L);
    if(retval != LUA_OK)
    {
        puts("error while running create_cell_documentation.lua");
    }
    lua_close(L);
}
