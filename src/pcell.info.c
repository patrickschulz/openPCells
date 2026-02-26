#include "pcell.common.h"

#include <stdio.h>

#include "_scriptmanager.h"

void pcell_create_cell_documentation(struct pcell_state* pcell_state, const char* cellname)
{
    lua_State* L = pcellcommon_prepare_layout_generation(pcell_state, NULL); // no technology state needed

    // assemble cell arguments
    lua_newtable(L);
    // cell name
    lua_pushstring(L, cellname);
    lua_setfield(L, -2, "cell");

    int retval = script_call_create_cell_documentation(L);
    if(retval != LUA_OK)
    {
        puts("error while running create_cell_documentation.lua");
    }
    lua_close(L);
}
