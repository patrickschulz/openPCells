#include "lgeometry.h"

#include "lua/lauxlib.h"
#include <stdlib.h>
#include <string.h>

#include "geometry.h"
#include "lobject.h"
#include "lpoint.h"

int lgeometry_rectanglebltr(lua_State* L)
{
    lobject_t* cell = lua_touserdata(L, 1);
    generics_t* layer = lua_touserdata(L, 2);
    lpoint_t* bl = lua_touserdata(L, 3);
    lpoint_t* tr = lua_touserdata(L, 4);
    geometry_rectanglebltr(cell->object, layer, bl->point, tr->point);
    return 0;
}

int lgeometry_rectangle(lua_State* L)
{
    lobject_t* cell = lua_touserdata(L, 1);
    generics_t* layer = lua_touserdata(L, 2);
    coordinate_t width = lua_tointeger(L, 3);
    coordinate_t height = lua_tointeger(L, 4);
    coordinate_t xshift = luaL_optinteger(L, 5, 0);
    coordinate_t yshift = luaL_optinteger(L, 6, 0);
    geometry_rectangle(cell->object, layer, width, height, xshift, yshift);
    return 0;
}

int lgeometry_rectanglepoints(lua_State* L)
{
    lobject_t* cell = lua_touserdata(L, 1);
    generics_t* layer = lua_touserdata(L, 2);
    lpoint_t* pt1 = lua_touserdata(L, 3);
    lpoint_t* pt2 = lua_touserdata(L, 4);
    geometry_rectanglepoints(cell->object, layer, pt1->point, pt2->point);
    return 0;
}

int lgeometry_polygon(lua_State* L)
{
    lobject_t* cell = lua_touserdata(L, 1);
    generics_t* layer = lua_touserdata(L, 2);
    lua_len(L, 3);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);

    point_t** points = calloc(len, sizeof(*points));
    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        lpoint_t* pt = lua_touserdata(L, -1);
        points[i - 1] = pt->point;
        lua_pop(L, 1);
    }
    geometry_polygon(cell->object, layer, points, len);
    return 0;
}

int lgeometry_path(lua_State* L)
{
    lobject_t* cell = lua_touserdata(L, 1);
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
        lpoint_t* pt = lua_touserdata(L, -1);
        points[i - 1] = pt->point;
        lua_pop(L, 1);
    }
    geometry_path(cell->object, layer, points, len, width, bgnext, endext);
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
        { NULL,              NULL                      }
    };
    luaL_setfuncs(L, modfuncs, 0);

    lua_setglobal(L, LGEOMETRYMODULE);
    return 0;
}
