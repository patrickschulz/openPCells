#include "lgeometry.h"

#include "lua/lauxlib.h"
#include <stdlib.h>
#include <string.h>

#include "geometry.h"
#include "lobject.h"
#include "lpoint.h"

int lgeometry_rectanglebltr(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = lua_touserdata(L, 2);
    lpoint_t* bl = lpoint_checkpoint(L, 3);
    lpoint_t* tr = lpoint_checkpoint(L, 4);
    ucoordinate_t xrep = luaL_optinteger(L, 5, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 6, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 7, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 8, 0);
    geometry_rectanglebltr(cell->object, layer, bl->point, tr->point, xrep, yrep, xpitch, ypitch);
    return 0;
}

int lgeometry_rectangle(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = lua_touserdata(L, 2);
    coordinate_t width = lua_tointeger(L, 3);
    coordinate_t height = lua_tointeger(L, 4);
    coordinate_t xshift = luaL_optinteger(L, 5, 0);
    coordinate_t yshift = luaL_optinteger(L, 6, 0);
    ucoordinate_t xrep = luaL_optinteger(L, 7, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 8, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 9, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 10, 0);
    geometry_rectangle(cell->object, layer, width, height, xshift, yshift, xrep, yrep, xpitch, ypitch);
    return 0;
}

int lgeometry_rectanglepoints(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = lua_touserdata(L, 2);
    lpoint_t* pt1 = lpoint_checkpoint(L, 3);
    lpoint_t* pt2 = lpoint_checkpoint(L, 4);
    ucoordinate_t xrep = luaL_optinteger(L, 5, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 6, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 7, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 8, 0);
    geometry_rectanglepoints(cell->object, layer, pt1->point, pt2->point, xrep, yrep, xpitch, ypitch);
    return 0;
}

int lgeometry_polygon(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = lua_touserdata(L, 2);
    lua_len(L, 3);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);

    point_t** points = calloc(len, sizeof(*points));
    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        lpoint_t* pt = lpoint_checkpoint(L, -1);
        points[i - 1] = pt->point;
        lua_pop(L, 1);
    }
    geometry_polygon(cell->object, layer, points, len);
    free(points);
    return 0;
}

int lgeometry_path(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = lua_touserdata(L, 2);
    lua_len(L, 3);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    coordinate_t width = lua_tointeger(L, 4);

    unsigned int bgnext = 0;
    unsigned int endext = 0;
    if(lua_gettop(L) == 5)
    {
        if(lua_type(L, 5) == LUA_TSTRING)
        {
            const char* exttype = lua_tostring(L, 5);
            if(strcmp(exttype, "butt") == 0)
            {
                bgnext = 0;
                endext = 0;
            }
        }
        else if(lua_type(L, 5) == LUA_TNUMBER)
        {
            bgnext = endext = lua_tointeger(L, 5);
        }
        else if(lua_type(L, 5) == LUA_TTABLE)
        {
            lua_rawgeti(L, 5, 1);
            bgnext = lua_tointeger(L, -1);
            lua_pop(L, 1);
            lua_rawgeti(L, 5, 2);
            endext = lua_tointeger(L, -1);
            lua_pop(L, 1);
        }
    }

    point_t** points = calloc(len, sizeof(*points));
    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        lpoint_t* pt = lpoint_checkpoint(L, -1);
        points[i - 1] = pt->point;
        lua_pop(L, 1);
    }
    geometry_path(cell->object, layer, points, len, width, bgnext, endext);
    free(points);
    return 0;
}

int lgeometry_viabltr(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    lpoint_t* bl = lpoint_checkpoint(L, 4);
    lpoint_t* tr = lpoint_checkpoint(L, 5);
    ucoordinate_t xrep = luaL_optinteger(L, 6, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 7, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 8, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 9, 0);
    geometry_viabltr(cell->object, metal1, metal2, bl->point, tr->point, xrep, yrep, xpitch, ypitch);
    return 0;
}

int lgeometry_via(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    ucoordinate_t width = luaL_checkinteger(L, 4);
    ucoordinate_t height = luaL_checkinteger(L, 5);
    coordinate_t xshift = luaL_optinteger(L, 6, 0);
    coordinate_t yshift = luaL_optinteger(L, 7, 0);
    ucoordinate_t xrep = luaL_optinteger(L, 8, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 9, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 10, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 11, 0);
    geometry_via(cell->object, metal1, metal2, width, height, xshift, yshift, xrep, yrep, xpitch, ypitch);
    return 0;
}

int lgeometry_contactbltr(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    const char* region = luaL_checkstring(L, 2);
    lpoint_t* bl = lpoint_checkpoint(L, 3);
    lpoint_t* tr = lpoint_checkpoint(L, 4);
    ucoordinate_t xrep = luaL_optinteger(L, 5, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 6, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 7, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 8, 0);
    geometry_contactbltr(cell->object, region, bl->point, tr->point, xrep, yrep, xpitch, ypitch);
    return 0;
}

int lgeometry_contact(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    const char* region = luaL_checkstring(L, 2);
    ucoordinate_t width = luaL_checkinteger(L, 3);
    ucoordinate_t height = luaL_checkinteger(L, 4);
    coordinate_t xshift = luaL_optinteger(L, 5, 0);
    coordinate_t yshift = luaL_optinteger(L, 6, 0);
    ucoordinate_t xrep = luaL_optinteger(L, 7, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 8, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 9, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 10, 0);
    geometry_contact(cell->object, region, width, height, xshift, yshift, xrep, yrep, xpitch, ypitch);
    return 0;
}

int lgeometry_cross(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = lua_touserdata(L, 2);
    ucoordinate_t width = luaL_checkinteger(L, 3);
    ucoordinate_t height = luaL_checkinteger(L, 4);
    ucoordinate_t crosssize = luaL_checkinteger(L, 5);
    geometry_cross(cell->object, layer, width, height, crosssize);
    return 0;
}

int lgeometry_ring(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = lua_touserdata(L, 2);
    ucoordinate_t width = luaL_checkinteger(L, 3);
    ucoordinate_t height = luaL_checkinteger(L, 4);
    ucoordinate_t ringwidth = luaL_checkinteger(L, 5);
    geometry_ring(cell->object, layer, width, height, ringwidth);
    return 0;
}

int lgeometry_unequal_ring(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = lua_touserdata(L, 2);
    ucoordinate_t width = luaL_checkinteger(L, 3);
    ucoordinate_t height = luaL_checkinteger(L, 4);
    ucoordinate_t ringwidth = luaL_checkinteger(L, 5);
    ucoordinate_t ringheight = luaL_checkinteger(L, 6);
    geometry_unequal_ring(cell->object, layer, width, height, ringwidth, ringheight);
    return 0;
}

int open_lgeometry_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "rectanglebltr",   lgeometry_rectanglebltr   },
        { "rectangle",       lgeometry_rectangle       },
        { "rectanglepoints", lgeometry_rectanglepoints },
        { "polygon",         lgeometry_polygon         },
        { "path",            lgeometry_path            },
        { "viabltr",         lgeometry_viabltr         },
        { "via",             lgeometry_via             },
        { "contactbltr",     lgeometry_contactbltr     },
        { "contact",         lgeometry_contact         },
        { "cross",           lgeometry_cross           },
        { "ring",            lgeometry_ring            },
        { "unequal_ring",    lgeometry_unequal_ring    },
        { NULL,              NULL                      }
    };
    luaL_setfuncs(L, modfuncs, 0);

    lua_setglobal(L, LGEOMETRYMODULE);
    return 0;
}
