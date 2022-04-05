#include "lua/lua.h"
#include "lua/lauxlib.h"

#include "lplacer_nonoverlapping.h"
#include "lplacer_classic.h"

int lplacer_place_simulated_annealing(lua_State* L)
{
    lplacer_place_classic(L);
    return 1;
}

int open_lplacer_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "place_simulated_annealing", lplacer_place_simulated_annealing },
        { "place_nonoverlapping",      lplacer_place_nonoverlapping      },
        { "place_classic",             lplacer_place_classic             },
        { NULL,                        NULL                              }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "placer");
    return 0;
}
