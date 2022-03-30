#include "info.h"

#include <stdio.h>

#include "lua/lauxlib.h"

#include "lobject.h"

int info_cellinfo(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    printf("number of shapes: %ld\n", cell->object->shapes_size);

    //print("used layers:")
    //for _, lpp in cell:layers() do
    //    print(string.format("  %s", lpp:str()))
    //end
    return 0;
}

int open_info_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "cellinfo", info_cellinfo },
        { NULL,       NULL          }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "info");
    return 0;
}
