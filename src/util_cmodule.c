#include "util_cmodule.h"

#include <stdlib.h>

#include "lua/lauxlib.h"
#include "lua/lualib.h"

#include "lpoint.h"
#include "union.h"

int lrectangle_union(lua_State* L)
{
    struct lpoint* bl1 = lpoint_checkpoint(L, 1);
    struct lpoint* tr1 = lpoint_checkpoint(L, 2);
    struct lpoint* bl2 = lpoint_checkpoint(L, 3);
    struct lpoint* tr2 = lpoint_checkpoint(L, 4);
    coordinate_t blx, bly, trx, try;
    int status = rectangle_union(
        point_getx(lpoint_get(bl1)),
        point_gety(lpoint_get(bl1)),
        point_getx(lpoint_get(tr1)),
        point_gety(lpoint_get(tr1)),
        point_getx(lpoint_get(bl2)),
        point_gety(lpoint_get(bl2)),
        point_getx(lpoint_get(tr2)),
        point_gety(lpoint_get(tr2)),
        &blx, &bly, &trx, &try
    );
    if(!status)
    {
        lua_pushnil(L);
    }
    else
    {
        lua_newtable(L);
        lua_pushstring(L, "bl");
        lpoint_create_internal(L, blx, bly);
        lua_rawset(L, -3);
        lua_pushstring(L, "tr");
        lpoint_create_internal(L, trx, try);
        lua_rawset(L, -3);
    }
    return 1;
}

int open_lutil_cmodule_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "rectangle_union",  lrectangle_union },
        { NULL,               NULL             }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "util");
    return 0;
}

