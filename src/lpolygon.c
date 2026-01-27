#include "lpolygon.h"

#include <stdlib.h>

#include "lua/lauxlib.h"

#include "polygon.h"
#include "lpoint.h"

struct simple_polygon* lpolygon_create_simple_polygon(lua_State* L, int idx)
{
    lua_len(L, idx);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    struct simple_polygon* result = simple_polygon_create();
    for(size_t i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, idx, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        simple_polygon_append(result, point_copy(lpoint_get(pt)));
        lua_pop(L, 1);
    }
    return result;
}

static int lpolygon_rectangle_intersects_polygon(lua_State* L)
{
    struct lpoint* lbl = lpoint_checkpoint(L, 1);
    struct lpoint* ltr = lpoint_checkpoint(L, 2);
    //_check_rectangle_points(L, lbl, ltr, "polygon.rectangle_intersects_polygon");
    const struct point* bl = lpoint_get(lbl);
    const struct point* tr = lpoint_get(ltr);
    coordinate_t blx = point_getx(bl);
    coordinate_t bly = point_gety(bl);
    coordinate_t trx = point_getx(tr);
    coordinate_t try = point_gety(tr);
    struct simple_polygon* poly = lpolygon_create_simple_polygon(L, 3);
    int intersects = simple_polygon_intersects_rectangle(poly, blx, bly, trx, try);
    lua_pushboolean(L, intersects);
    return 1;
}

int open_lpolygon_lib(lua_State* L)
{
    static const luaL_Reg funcs[] = {
        { "rectangle_intersects_polygon",           lpolygon_rectangle_intersects_polygon   },
        { NULL,                                     NULL                                    }
    };
    lua_newtable(L);
    luaL_setfuncs(L, funcs, 0);
    lua_setglobal(L, "polygon");
    return 0;
}
