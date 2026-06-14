#include "lpolygon.h"

#include <stdlib.h>

#include "lua/lauxlib.h"

#include "bltrshape.h"
#include "polygon.h"
#include "lpoint.h"

struct simple_polygon* lpolygon_create_simple_polygon(lua_State* L, int idx)
{
    if(!lua_istable(L, idx))
    {
        lua_pushfstring(L,
            "lpolygon_create_simple_polygon: expected table, got '%s'",
            lua_typename(L, lua_type(L, idx))
        );
        lua_error(L);
    }
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

static int lpolygon_is_rectilinear_polygon(lua_State* L)
{
    struct simple_polygon* simple_polygon = lpolygon_create_simple_polygon(L, 1);
    int is_rectilinear = simple_polygon_is_rectilinear(simple_polygon);
    lua_pushboolean(L, is_rectilinear);
    simple_polygon_destroy(simple_polygon);
    return 1;
}

static int lpolygon_split_rectilinear_polygon(lua_State* L)
{
    struct simple_polygon* simple_polygon = lpolygon_create_simple_polygon(L, 1);
    struct vector* rects = simple_polygon_split_rectilinear_polygon(simple_polygon);
    simple_polygon_destroy(simple_polygon);
    lua_newtable(L);
    for(size_t i = 0; i < vector_size(rects); ++i)
    {
        struct bltrshape* bltrshape = vector_get(rects, i);
        bltrshape_push_table(L, bltrshape);
        lua_rawseti(L, -2, i + 1);
    }
    free(rects);
    return 1;
}

static int lpolygon_rectangle_intersects_polygon(lua_State* L)
{
    if(!lua_istable(L, 1))
    {
        lua_pushfstring(L,
            "polygon.rectangle_intersects_polygon: expected table as first parameter, got '%s'",
            lua_typename(L, lua_type(L, 1))
        );
        lua_error(L);
    }
    lua_getfield(L, 1, "bl");
    struct lpoint* lbl = lpoint_checkpoint(L, -1);
    lua_pop(L, 1);
    lua_getfield(L, 1, "tr");
    struct lpoint* ltr = lpoint_checkpoint(L, -1);
    lua_pop(L, 1);
    const struct point* bl = lpoint_get(lbl);
    const struct point* tr = lpoint_get(ltr);
    coordinate_t blx = point_getx(bl);
    coordinate_t bly = point_gety(bl);
    coordinate_t trx = point_getx(tr);
    coordinate_t try = point_gety(tr);
    struct simple_polygon* simple_polygon = lpolygon_create_simple_polygon(L, 2);
    int intersects = simple_polygon_intersects_rectangle(
        simple_polygon,
        blx, bly,
        trx, try
    );
    simple_polygon_destroy(simple_polygon);
    lua_pushboolean(L, intersects);
    return 1;
}

int open_lpolygon_lib(lua_State* L)
{
    static const luaL_Reg funcs[] = {
        { "is_rectilinear_polygon",                 lpolygon_is_rectilinear_polygon      },
        { "split_rectilinear_polygon",              lpolygon_split_rectilinear_polygon      },
        { "rectangle_intersects_polygon",           lpolygon_rectangle_intersects_polygon   },
        { NULL,                                     NULL                                    }
    };
    lua_newtable(L);
    luaL_setfuncs(L, funcs, 0);
    lua_setglobal(L, "polygon");
    return 0;
}
