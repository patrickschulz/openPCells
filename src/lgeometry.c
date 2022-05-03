#include "lgeometry.h"

#include "lua/lauxlib.h"
#include <stdlib.h>
#include <string.h>

#include "geometry.h"
#include "lobject.h"
#include "lpoint.h"
#include "graphics.h"

static void* _check_generics(lua_State* L, int idx)
{
    if(lua_type(L, idx) != LUA_TLIGHTUSERDATA)
    {
        lua_pushfstring(L, "expected light userdata at argument #%d, got %s\n", idx, lua_typename(L, lua_type(L, idx)));
        lua_error(L);
    }
    void *p = lua_touserdata(L, idx);
    if(!p)
    {
        lua_pushfstring(L, "expected generic layer at argument #%d, got NULL\n", idx);
        lua_error(L);
    }
    return p;
}

static void _check_rectangle_points(lua_State* L, lpoint_t* bl, lpoint_t* tr, const char* context)
{
    if(bl->point->x > tr->point->x || bl->point->y > tr->point->y)
    {
        if(context)
        {
            lua_pushfstring(L, "%s: rectangle points are not in order: (%d, %d) and (%d, %d)", context, bl->point->x, bl->point->y, tr->point->x, tr->point->y);
        }
        else
        {
            lua_pushfstring(L, "rectangle points are not in order: (%d, %d) and (%d, %d)", bl->point->x, bl->point->y, tr->point->x, tr->point->y);
        }
        lua_error(L);
    }
}

static int lgeometry_rectanglebltr(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = _check_generics(L, 2);
    lpoint_t* bl = lpoint_checkpoint(L, 3);
    lpoint_t* tr = lpoint_checkpoint(L, 4);
    _check_rectangle_points(L, bl, tr, "geometry.rectanglebltr");
    ucoordinate_t xrep = luaL_optinteger(L, 5, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 6, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 7, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 8, 0);
    geometry_rectanglebltr(cell->object, layer, bl->point, tr->point, xrep, yrep, xpitch, ypitch);
    return 0;
}

static int lgeometry_rectangle(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = _check_generics(L, 2);
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

static int lgeometry_rectanglepoints(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = _check_generics(L, 2);
    lpoint_t* pt1 = lpoint_checkpoint(L, 3);
    lpoint_t* pt2 = lpoint_checkpoint(L, 4);
    ucoordinate_t xrep = luaL_optinteger(L, 5, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 6, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 7, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 8, 0);
    geometry_rectanglepoints(cell->object, layer, pt1->point, pt2->point, xrep, yrep, xpitch, ypitch);
    return 0;
}

static int lgeometry_polygon(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = _check_generics(L, 2);
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

void _get_path_extension(lua_State* L, int idx, int* bgnext, int* endext)
{
    if(lua_gettop(L) == idx)
    {
        if(lua_type(L, idx) == LUA_TSTRING)
        {
            const char* exttype = lua_tostring(L, idx);
            if(strcmp(exttype, "butt") == 0)
            {
                *bgnext = 0;
                *endext = 0;
            }
        }
        else if(lua_type(L, idx) == LUA_TNUMBER)
        {
            *bgnext = *endext = lua_tointeger(L, idx);
        }
        else if(lua_type(L, idx) == LUA_TTABLE)
        {
            lua_rawgeti(L, idx, 1);
            *bgnext = lua_tointeger(L, -1);
            lua_pop(L, 1);
            lua_rawgeti(L, idx, 2);
            *endext = lua_tointeger(L, -1);
            lua_pop(L, 1);
        }
    }

}

static int lgeometry_path(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = _check_generics(L, 2);
    lua_len(L, 3);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    coordinate_t width = lua_tointeger(L, 4);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 5, &bgnext, &endext);

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

static int lgeometry_path_manhatten(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = _check_generics(L, 2);
    lua_len(L, 3);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    coordinate_t width = lua_tointeger(L, 4);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 5, &bgnext, &endext);

    size_t numpoints = 2 * (len - 2) + 3;
    point_t** points = calloc(numpoints, sizeof(*points));

    lua_rawgeti(L, 3, 1);
    lpoint_t* pt = lpoint_checkpoint(L, -1);
    points[0] = point_create(pt->point->x, pt->point->y);
    //coordinate_t lastx = pt->point->x;
    coordinate_t lasty = pt->point->y;
    lua_pop(L, 1);

    for(unsigned int i = 2; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        lpoint_t* pt = lpoint_checkpoint(L, -1);
        points[2 * (i - 2) + 1] = point_create(pt->point->x, lasty);
        points[2 * (i - 2) + 2] = point_create(pt->point->x, pt->point->y);
        //lastx = pt->point->x;
        lasty = pt->point->y;
        lua_pop(L, 1);
    }

    geometry_path(cell->object, layer, points, numpoints, width, bgnext, endext);
    for(unsigned int i = 0; i < numpoints; ++i)
    {
        point_destroy(points[i]);
    }
    free(points);
    return 0;
}

static int lgeometry_path_3x(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = _check_generics(L, 2);
    lua_len(L, 3);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    coordinate_t width = lua_tointeger(L, 4);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 5, &bgnext, &endext);

    size_t numpoints = 2 * (len - 2) + 3;
    point_t** points = calloc(numpoints, sizeof(*points));

    lua_rawgeti(L, 3, 1);
    lpoint_t* pt = lpoint_checkpoint(L, -1);
    points[0] = point_create(pt->point->x, pt->point->y);
    //coordinate_t lastx = pt->point->x;
    coordinate_t lasty = pt->point->y;
    lua_pop(L, 1);

    for(unsigned int i = 2; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        lpoint_t* pt = lpoint_checkpoint(L, -1);
        points[2 * (i - 2) + 1] = point_create(pt->point->x, lasty);
        points[2 * (i - 2) + 2] = point_create(pt->point->x, pt->point->y);
        //lastx = pt->point->x;
        lasty = pt->point->y;
        lua_pop(L, 1);
    }

    geometry_path(cell->object, layer, points, numpoints, width, bgnext, endext);
    for(unsigned int i = 0; i < numpoints; ++i)
    {
        point_destroy(points[i]);
    }
    free(points);
    return 0;
}

static int lgeometry_path_cshape(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = _check_generics(L, 2);
    lpoint_t* ptstart = lpoint_checkpoint(L, 3);
    lpoint_t* ptend = lpoint_checkpoint(L, 4);
    lpoint_t* ptoffset = lpoint_checkpoint(L, 5);
    coordinate_t offset = ptoffset->point->x;
    coordinate_t width = lua_tointeger(L, 6);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 7, &bgnext, &endext);

    point_t* points[4];
    points[0] = ptstart->point;
    points[1] = point_create(offset, ptstart->point->y);
    points[2] = point_create(offset, ptend->point->y);
    points[3] = ptend->point;
    geometry_path(cell->object, layer, points, 4, width, bgnext, endext);
    point_destroy(points[1]);
    point_destroy(points[2]);
    return 0;
}

static int lgeometry_path_ushape(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = _check_generics(L, 2);
    lpoint_t* ptstart = lpoint_checkpoint(L, 3);
    lpoint_t* ptend = lpoint_checkpoint(L, 4);
    lpoint_t* ptoffset = lpoint_checkpoint(L, 5);
    coordinate_t offset = ptoffset->point->y;
    coordinate_t width = lua_tointeger(L, 6);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 7, &bgnext, &endext);

    point_t* points[4];
    points[0] = ptstart->point;
    points[1] = point_create(ptstart->point->x, offset);
    points[2] = point_create(ptend->point->x, offset);
    points[3] = ptend->point;
    geometry_path(cell->object, layer, points, 4, width, bgnext, endext);
    point_destroy(points[1]);
    point_destroy(points[2]);
    return 0;
}

static int lgeometry_viabltr(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    lpoint_t* bl = lpoint_checkpoint(L, 4);
    lpoint_t* tr = lpoint_checkpoint(L, 5);
    _check_rectangle_points(L, bl, tr, "geometry.viabltr");
    ucoordinate_t xrep = luaL_optinteger(L, 6, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 7, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 8, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 9, 0);
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    geometry_viabltr(cell->object, layermap, techstate, metal1, metal2, bl->point, tr->point, xrep, yrep, xpitch, ypitch);
    return 0;
}

static int lgeometry_via(lua_State* L)
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
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    geometry_via(cell->object, layermap, techstate, metal1, metal2, width, height, xshift, yshift, xrep, yrep, xpitch, ypitch);
    return 0;
}

static int lgeometry_contactbltr(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    const char* region = luaL_checkstring(L, 2);
    lpoint_t* bl = lpoint_checkpoint(L, 3);
    lpoint_t* tr = lpoint_checkpoint(L, 4);
    _check_rectangle_points(L, bl, tr, "geometry.contactbltr");
    ucoordinate_t xrep = luaL_optinteger(L, 5, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 6, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 7, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 8, 0);
    int xcont = 0;
    int ycont = 0;
    if(lua_type(L, 9) == LUA_TTABLE) // properties table
    {
        lua_getfield(L, 9, "xcontinuous");
        xcont = lua_toboolean(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, 9, "ycontinuous");
        ycont = lua_toboolean(L, -1);
        lua_pop(L, 1);
    }

    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    geometry_contactbltr(
        cell->object,
        layermap, techstate,
        region,
        bl->point, tr->point,
        xrep, yrep,
        xpitch, ypitch,
        xcont, ycont
    );
    return 0;
}

static int lgeometry_contact(lua_State* L)
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
    int xcont = 0;
    int ycont = 0;
    if(lua_type(L, 11) == LUA_TTABLE) // properties table
    {
        lua_getfield(L, 11, "xcontinuous");
        xcont = lua_toboolean(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, 11, "ycontinuous");
        ycont = lua_toboolean(L, -1);
        lua_pop(L, 1);
    }
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    geometry_contact(
        cell->object,
        layermap, techstate,
        region,
        width, height,
        xshift, yshift,
        xrep, yrep,
        xpitch, ypitch,
        xcont, ycont
    );
    return 0;
}

static int lgeometry_cross(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = _check_generics(L, 2);
    ucoordinate_t width = luaL_checkinteger(L, 3);
    ucoordinate_t height = luaL_checkinteger(L, 4);
    ucoordinate_t crosssize = luaL_checkinteger(L, 5);
    geometry_cross(cell->object, layer, width, height, crosssize);
    return 0;
}

static int lgeometry_ring(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = _check_generics(L, 2);
    ucoordinate_t width = luaL_checkinteger(L, 3);
    ucoordinate_t height = luaL_checkinteger(L, 4);
    ucoordinate_t ringwidth = luaL_checkinteger(L, 5);
    geometry_ring(cell->object, layer, width, height, ringwidth);
    return 0;
}

static int lgeometry_unequal_ring(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = _check_generics(L, 2);
    ucoordinate_t width = luaL_checkinteger(L, 3);
    ucoordinate_t height = luaL_checkinteger(L, 4);
    ucoordinate_t ringwidth = luaL_checkinteger(L, 5);
    ucoordinate_t ringheight = luaL_checkinteger(L, 6);
    geometry_unequal_ring(cell->object, layer, width, height, ringwidth, ringheight);
    return 0;
}

static int lgeometry_cubic_bezier(lua_State* L)
{
    lobject_t* cell = lobject_check(L, 1);
    generics_t* layer = _check_generics(L, 2);
    lua_len(L, 3);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);

    if(len != 4)
    {
        lua_pushstring(L, "geometry.cubic_bezier: expecting a multiple of four points");
        lua_error(L);
    }

    struct vector* curve = vector_create();
    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        lpoint_t* pt = lpoint_checkpoint(L, -1);
        vector_append(curve, pt->point);
        lua_pop(L, 1);
    }

    struct vector* points = graphics_cubic_bezier(curve);
    vector_destroy(curve, NULL);

    point_t** polypoints = calloc(vector_size(points), sizeof(*polypoints));
    for(unsigned int i = 0; i < vector_size(points); ++i)
    {
        polypoints[i] = vector_get(points, i);
    }
    geometry_polygon(cell->object, layer, polypoints, vector_size(points));
    free(polypoints);
    vector_destroy(points, NULL);
    return 0;
}

static int lgeometry_curve(lua_State* L)
{
    lobject_t* lobject = lobject_check(L, 1);
    generics_t* layer = _check_generics(L, 2);
    shape_t* S = shape_create_curve();
    S->layer = layer;

    lua_len(L, 3);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);

    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        lua_getfield(L, -1, "type");
        const char* type = lua_tostring(L, -1);
        if(strcmp(type, "linesegment") == 0)
        {
            lua_getfield(L, -2, "startpt");
            lpoint_t* startpt = lpoint_checkpoint(L, -1);
            lua_getfield(L, -3, "endpt");
            lpoint_t* endpt = lpoint_checkpoint(L, -1);
            shape_curve_add_line_segment(S, startpt->point, endpt->point);
            lua_pop(L, 2); // pop points
        }
        else
        {
            lua_getfield(L, -2, "firstpt");
            lpoint_t* firstpt = lpoint_checkpoint(L, -1);
            lua_getfield(L, -3, "centerpt");
            lpoint_t* centerpt = lpoint_checkpoint(L, -1);
            lua_getfield(L, -4, "lastpt");
            lpoint_t* lastpt = lpoint_checkpoint(L, -1);
            shape_curve_add_arc_segment(S, firstpt->point, centerpt->point, lastpt->point);
            lua_pop(L, 3); // pop points
        }
        lua_pop(L, 1); // pop type
        lua_pop(L, 1); // pop segment
    }

    object_add_shape(lobject->object, S);
    return 0;
}

static int lcurve_linesegment(lua_State* L)
{
    lua_newtable(L);
    lua_pushstring(L, "linesegment");
    lua_setfield(L, -2, "type");
    lua_pushvalue(L, 1);
    lua_setfield(L, -2, "startpt");
    lua_pushvalue(L, 2);
    lua_setfield(L, -2, "endpt");
    return 1;
}

static int lcurve_arcsegment(lua_State* L)
{
    lua_newtable(L);
    lua_pushstring(L, "arcsegment");
    lua_setfield(L, -2, "type");
    lua_pushvalue(L, 1);
    lua_setfield(L, -2, "firstpt");
    lua_pushvalue(L, 2);
    lua_setfield(L, -2, "centerpt");
    lua_pushvalue(L, 3);
    lua_setfield(L, -2, "lastpt");
    return 1;
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
        { "path_manhatten",  lgeometry_path_manhatten  },
        { "path_cshape",     lgeometry_path_cshape     },
        { "path_ushape",     lgeometry_path_ushape     },
        { "viabltr",         lgeometry_viabltr         },
        { "via",             lgeometry_via             },
        { "contactbltr",     lgeometry_contactbltr     },
        { "contact",         lgeometry_contact         },
        { "cubic_bezier",    lgeometry_cubic_bezier    },
        { "cross",           lgeometry_cross           },
        { "ring",            lgeometry_ring            },
        { "unequal_ring",    lgeometry_unequal_ring    },
        { "curve",           lgeometry_curve           },
        { NULL,              NULL                      }
    };
    luaL_setfuncs(L, modfuncs, 0);

    lua_setglobal(L, LGEOMETRYMODULE);

    lua_newtable(L);
    static const luaL_Reg curvefuncs[] =
    {
        { "linesegment", lcurve_linesegment },
        { "arcsegment",  lcurve_arcsegment },
        { NULL,          NULL               }
    };
    luaL_setfuncs(L, curvefuncs, 0);

    lua_setglobal(L, "curve");
    return 0;
}
