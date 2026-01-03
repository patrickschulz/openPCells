#include "lgeometry.h"

#include "lua/lauxlib.h"
#include <stdlib.h>
#include <string.h>

#include "geometry.h"
#include "graphics.h"
#include "lcheck.h"
#include "lgenerics.h"
#include "lobject.h"
#include "lplacement.h"
#include "lpoint.h"
#include "lutil.h"
#include "placement.h"

static void _check_rectangle_points(lua_State* L, struct lpoint* bl, struct lpoint* tr, const char* context)
{
    if(lpoint_get(bl)->x > lpoint_get(tr)->x || lpoint_get(bl)->y > lpoint_get(tr)->y)
    {
        if(context)
        {
            lua_pushfstring(L, "%s: rectangle points are not in order: (%d, %d) and (%d, %d)", context, lpoint_get(bl)->x, lpoint_get(bl)->y, lpoint_get(tr)->x, lpoint_get(tr)->y);
        }
        else
        {
            lua_pushfstring(L, "rectangle points are not in order: (%d, %d) and (%d, %d)", lpoint_get(bl)->x, lpoint_get(bl)->y, lpoint_get(tr)->x, lpoint_get(tr)->y);
        }
        lua_error(L);
    }
}

static int lgeometry_rectanglebltr(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "geometry.rectanglebltr");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* bl = lpoint_checkpoint(L, 3);
    struct lpoint* tr = lpoint_checkpoint(L, 4);
    _check_rectangle_points(L, bl, tr, "geometry.rectanglebltr");
    geometry_rectanglebltr(lobject_get_full(L, cell), layer, lpoint_get(bl), lpoint_get(tr));
    return 0;
}

static int lgeometry_rectangleblwh(lua_State* L)
{
    lcheck_check_numargs1(L, 5, "geometry.rectangleblwh");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* bl = lpoint_checkpoint(L, 3);
    coordinate_t width = lpoint_checkcoordinate(L, 4, "width");
    coordinate_t height = lpoint_checkcoordinate(L, 5, "height");
    geometry_rectangleblwh(lobject_get_full(L, cell), layer, lpoint_get(bl), width, height);
    return 0;
}

static int lgeometry_rectanglepoints(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "geometry.rectanglepoints");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* pt1 = lpoint_checkpoint(L, 3);
    struct lpoint* pt2 = lpoint_checkpoint(L, 4);
    geometry_rectanglepoints(lobject_get_full(L, cell), layer, lpoint_get(pt1), lpoint_get(pt2));
    return 0;
}

static int lgeometry_rectangleareaanchor(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "geometry.rectangleareaanchor");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    const char* anchor = luaL_checkstring(L, 3);
    geometry_rectangleareaanchor(lobject_get_full(L, cell), layer, anchor);
    return 0;
}

static int lgeometry_rectanglearray(lua_State* L)
{
    lcheck_check_numargs1(L, 10, "geometry.rectanglearray");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    coordinate_t width = lpoint_checkcoordinate(L, 3, "width");
    coordinate_t height = lpoint_checkcoordinate(L, 4, "height");
    coordinate_t xshift = lpoint_checkcoordinate(L, 5, "xshift");
    coordinate_t yshift = lpoint_checkcoordinate(L, 6, "yshift");
    unsigned int xrep = luaL_checkinteger(L, 7);
    unsigned int yrep = luaL_checkinteger(L, 8);
    coordinate_t xpitch = lpoint_checkcoordinate(L, 9, "xpitch");
    coordinate_t ypitch = lpoint_checkcoordinate(L, 10, "ypitch");
    geometry_rectanglearray(lobject_get_full(L, cell), layer, width, height, xshift, yshift, xrep, yrep, xpitch, ypitch);
    return 0;
}

static int lgeometry_slotted_rectangle(lua_State* L)
{
    lcheck_check_numargs1(L, 10, "geometry.slotted_rectangle");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* pt1 = lpoint_checkpoint(L, 3);
    struct lpoint* pt2 = lpoint_checkpoint(L, 4);
    coordinate_t slotwidth = lpoint_checkcoordinate(L, 5, "slotwidth");
    coordinate_t slotheight = lpoint_checkcoordinate(L, 6, "slotheight");
    coordinate_t slotxspace = lpoint_checkcoordinate(L, 7, "slotxspace");
    coordinate_t slotyspace = lpoint_checkcoordinate(L, 8, "slotyspace");
    coordinate_t slotminedgexspace = lpoint_checkcoordinate(L, 9, "slotedgexspace");
    coordinate_t slotminedgeyspace = lpoint_checkcoordinate(L, 10, "slotedgeyspace");
    geometry_slotted_rectangle(
        lobject_get_full(L, cell),
        layer,
        lpoint_get(pt1), lpoint_get(pt2),
        slotwidth, slotheight,
        slotxspace, slotyspace,
        slotminedgexspace, slotminedgeyspace
    );
    return 0;
}

static int lgeometry_polygon(lua_State* L)
{
    lcheck_check_numargs1(L, 3, "geometry.polygon");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    lua_len(L, 3);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);

    const struct point** points = calloc(len, sizeof(*points));
    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        points[i - 1] = lpoint_get(pt);
        lua_pop(L, 1);
    }
    geometry_polygon(lobject_get_full(L, cell), layer, points, len);
    free(points);
    return 0;
}

void _get_path_extension(lua_State* L, int idx, int* bgnext, int* endext, coordinate_t width)
{
    if(lua_type(L, idx) == LUA_TSTRING)
    {
        const char* exttype = lua_tostring(L, idx);
        if(strcmp(exttype, "butt") == 0)
        {
            *bgnext = 0;
            *endext = 0;
        }
        else if(strcmp(exttype, "rect") == 0)
        {
            *bgnext = width / 2;
            *endext = width / 2;
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

static int lgeometry_path(lua_State* L)
{
    lcheck_check_numargs2(L, 4, 5, "geometry.path");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    if(!lua_istable(L, 3))
    {
        lua_pushfstring(L, "geometry.path: list of points (third argument) is not a table (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    lua_len(L, 3);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    coordinate_t width = luaL_checkinteger(L, 4);
    if(width == 0)
    {
        lua_pushfstring(L, "geometry.path: width can't be zero (object: \"%s\"", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    if(width % 2 != 0)
    {
        lua_pushfstring(L, "geometry.path: width is odd (%d) (object: \"%s\"", width, object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 5, &bgnext, &endext, width);

    struct vector* points = vector_create(len, NULL); // non-owning
    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        vector_append(points, (struct point*)lpoint_get(pt));
        lua_pop(L, 1);
    }
    lobject_check_proxy(L, cell);
    geometry_path(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    vector_destroy(points);
    return 0;
}

static int lgeometry_rectanglepath(lua_State* L)
{
    lcheck_check_numargs2(L, 5, 6, "geometry.rectanglepath");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* pt1 = lpoint_checkpoint(L, 3);
    struct lpoint* pt2 = lpoint_checkpoint(L, 4);
    coordinate_t width = lua_tointeger(L, 5);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 6, &bgnext, &endext, width);

    struct vector* points = vector_create(2, NULL); // non-owning
    vector_append(points, (struct point*)lpoint_get(pt1));
    vector_append(points, (struct point*)lpoint_get(pt2));
    geometry_path(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    vector_destroy(points);
    return 0;
}

static int lgeometry_path_manhatten(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    lua_len(L, 3);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    coordinate_t width = lua_tointeger(L, 4);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 5, &bgnext, &endext, width);

    size_t numpoints = 2 * (len - 2) + 3;
    struct vector* points = vector_create(numpoints, point_destroy);

    lua_rawgeti(L, 3, 1);
    struct lpoint* startpt = lpoint_checkpoint(L, -1);
    vector_append(points, point_create(lpoint_get(startpt)->x, lpoint_get(startpt)->y));
    //coordinate_t lastx = lpoint_get(startpt)->x;
    coordinate_t lasty = lpoint_get(startpt)->y;
    lua_pop(L, 1);

    for(unsigned int i = 2; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        vector_append(points, point_create(lpoint_get(pt)->x, lasty));
        vector_append(points, point_create(lpoint_get(pt)->x, lpoint_get(pt)->y));
        //lastx = lpoint_get(pt)->x;
        lasty = lpoint_get(pt)->y;
        lua_pop(L, 1);
    }

    geometry_path(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    vector_destroy(points);
    return 0;
}

static int lgeometry_rectanglelines_vertical(lua_State* L)
{
    lcheck_check_numargs1(L, 6, "geometry.rectanglevlines");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* pt1 = lpoint_checkpoint(L, 3);
    struct lpoint* pt2 = lpoint_checkpoint(L, 4);
    int numlines = luaL_checkinteger(L, 5);
    double ratio = luaL_checknumber(L, 6);

    if(numlines <= 0)
    {
        lua_pushfstring(L, "geometry.rectanglevlines: number of lines must be greater than zero (got %d) (object: \"%s\")", numlines, object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }

    if(ratio <= 0)
    {
        lua_pushfstring(L, "geometry.rectanglevlines: ratio must be greater than zero (got %f) (object: \"%s\")", ratio, object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }

    const struct point* bl = lpoint_get(pt1);
    const struct point* tr = lpoint_get(pt2);

    ucoordinate_t totalwidth = point_xdifference(tr, bl);
    // ensure that the width and the space of the lines is even
    unsigned int correction = 0;
    while(totalwidth % ((ucoordinate_t)(numlines * 4 * (ratio + 1))) != 0)
    {
        --totalwidth;
        ++correction;
    }

    ucoordinate_t height = point_ydifference(tr, bl);
    ucoordinate_t pitch = totalwidth / numlines;
    ucoordinate_t space = pitch / (ratio + 1);
    ucoordinate_t width = pitch - space;

    coordinate_t offset = (correction + space) / 2;

    geometry_rectanglearray(
        lobject_get_full(L, cell),
        layer,
        width, height,
        bl->x + offset, bl->y,  // xshift, yshift
        numlines, 1,            // xrep, yrep
        pitch, 0                // xpitch, ypitch
    );

    return 0;
}

static int lgeometry_rectanglelines_vertical_width_space(lua_State* L)
{
    lcheck_check_numargs1(L, 6, "geometry.rectanglevlines_width_space");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* pt1 = lpoint_checkpoint(L, 3);
    struct lpoint* pt2 = lpoint_checkpoint(L, 4);
    coordinate_t widthtarget = luaL_checkinteger(L, 5);
    coordinate_t spacetarget = luaL_checkinteger(L, 6);

    const struct point* bl = lpoint_get(pt1);
    const struct point* tr = lpoint_get(pt2);

    coordinate_t totalwidth = point_xdifference(tr, bl);
    unsigned int numlines = totalwidth / (widthtarget + spacetarget);
    coordinate_t width = widthtarget;
    coordinate_t space = spacetarget;
    coordinate_t height = point_ydifference(tr, bl);
    coordinate_t offset = (totalwidth - numlines * (width + space) + space) / 2;

    geometry_rectanglearray(
        lobject_get_full(L, cell),
        layer,
        width, height,
        bl->x + offset, bl->y,  // xshift, yshift
        numlines, 1,            // xrep, yrep
        width + space, 0        // xpitch, ypitch
    );

    return 5;
}

static int lgeometry_rectanglelines_vertical_numlines_width(lua_State* L)
{
    lcheck_check_numargs1(L, 6, "geometry.rectanglevlines_numlines_width");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* pt1 = lpoint_checkpoint(L, 3);
    struct lpoint* pt2 = lpoint_checkpoint(L, 4);
    int numlines = luaL_checkinteger(L, 5);
    coordinate_t widthtarget = luaL_checkinteger(L, 6);

    if(numlines <= 0)
    {
        lua_pushfstring(L, "geometry.rectanglevlines_numlines_width: number of lines must be greater than zero (got %d) (object: \"%s\")", numlines, object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }

    const struct point* bl = lpoint_get(pt1);
    const struct point* tr = lpoint_get(pt2);

    ucoordinate_t totalwidth = point_xdifference(tr, bl);
    // ensure that the width and the space of the lines is even
    unsigned int correction = 0;
    /*
    while(totalwidth % ((ucoordinate_t)(numlines * 4 * (ratio + 1))) != 0)
    {
        --totalwidth;
        ++correction;
    }
    */

    ucoordinate_t height = point_ydifference(tr, bl);
    ucoordinate_t pitch = totalwidth / numlines;
    ucoordinate_t width = widthtarget;
    ucoordinate_t space = pitch - width;

    coordinate_t offset = (correction + space) / 2;

    geometry_rectanglearray(
        lobject_get_full(L, cell),
        layer,
        width, height,
        bl->x + offset, bl->y,  // xshift, yshift
        numlines, 1,            // xrep, yrep
        pitch, 0                // xpitch, ypitch
    );

    return 0;
}

static int lgeometry_rectanglelines_vertical_settings(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "geometry.rectanglevlines_settings");
    struct lpoint* pt1 = lpoint_checkpoint(L, 1);
    struct lpoint* pt2 = lpoint_checkpoint(L, 2);
    int numlines = luaL_checkinteger(L, 3);
    double ratio = luaL_checknumber(L, 4);

    if(numlines <= 0)
    {
        lua_pushfstring(L, "geometry.rectanglevlines_settings: number of lines must be greater than zero (got %d)", numlines);
        lua_error(L);
    }

    if(ratio <= 0)
    {
        lua_pushfstring(L, "geometry.rectanglevlines_settings: ratio must be greater than zero (got %f)", ratio);
        lua_error(L);
    }

    const struct point* bl = lpoint_get(pt1);
    const struct point* tr = lpoint_get(pt2);

    ucoordinate_t totalwidth = point_xdifference(tr, bl);
    // ensure that the width and the space of the lines is even
    unsigned int correction = 0;
    while(totalwidth % ((ucoordinate_t)(numlines * 4 * (ratio + 1))) != 0)
    {
        --totalwidth;
        ++correction;
    }

    ucoordinate_t height = point_ydifference(tr, bl);
    ucoordinate_t pitch = totalwidth / numlines;
    ucoordinate_t space = pitch / (ratio + 1);
    ucoordinate_t width = pitch - space;

    coordinate_t offset = (correction + space) / 2;

    lua_pushinteger(L, width);
    lua_pushinteger(L, height);
    lua_pushinteger(L, space);
    lua_pushinteger(L, offset);
    lua_pushinteger(L, numlines);

    return 5;
}

static int lgeometry_rectanglelines_vertical_width_space_settings(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "geometry.rectanglevlines_height_space_settings");
    struct lpoint* pt1 = lpoint_checkpoint(L, 1);
    struct lpoint* pt2 = lpoint_checkpoint(L, 2);
    coordinate_t widthtarget = luaL_checkinteger(L, 3);
    coordinate_t spacetarget = luaL_checkinteger(L, 4);

    const struct point* bl = lpoint_get(pt1);
    const struct point* tr = lpoint_get(pt2);

    coordinate_t totalwidth = point_xdifference(tr, bl);
    unsigned int numlines = totalwidth / (widthtarget + spacetarget);
    coordinate_t width = widthtarget;
    coordinate_t space = spacetarget;
    coordinate_t height = point_ydifference(tr, bl);
    coordinate_t offset = (totalwidth - numlines * (width + space) + space) / 2;

    lua_pushinteger(L, width);
    lua_pushinteger(L, height);
    lua_pushinteger(L, space);
    lua_pushinteger(L, offset);
    lua_pushinteger(L, numlines);

    return 5;
}

static int lgeometry_rectanglelines_vertical_numlines_width_settings(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "geometry.rectanglevlines_numlines_width_settings");
    struct lpoint* pt1 = lpoint_checkpoint(L, 1);
    struct lpoint* pt2 = lpoint_checkpoint(L, 2);
    int numlines = luaL_checkinteger(L, 3);
    coordinate_t widthtarget = luaL_checkinteger(L, 4);

    if(numlines <= 0)
    {
        lua_pushfstring(L, "geometry.rectanglevlines_numlines_width_settings: number of lines must be greater than zero (got %d)", numlines);
        lua_error(L);
    }

    const struct point* bl = lpoint_get(pt1);
    const struct point* tr = lpoint_get(pt2);

    ucoordinate_t totalwidth = point_xdifference(tr, bl);
    // ensure that the width and the space of the lines is even
    unsigned int correction = 0;
    /*
    while(totalwidth % ((ucoordinate_t)(numlines * 4 * (ratio + 1))) != 0)
    {
        --totalwidth;
        ++correction;
    }
    */

    ucoordinate_t height = point_ydifference(tr, bl);
    ucoordinate_t pitch = totalwidth / numlines;
    ucoordinate_t width = widthtarget;
    ucoordinate_t space = pitch - width;

    coordinate_t offset = (correction + space) / 2;

    lua_pushinteger(L, width);
    lua_pushinteger(L, height);
    lua_pushinteger(L, space);
    lua_pushinteger(L, offset);
    lua_pushinteger(L, numlines);

    return 5;
}

static int lgeometry_rectanglelines_horizontal(lua_State* L)
{
    lcheck_check_numargs1(L, 6, "geometry.rectanglehlines");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* pt1 = lpoint_checkpoint(L, 3);
    struct lpoint* pt2 = lpoint_checkpoint(L, 4);
    int numlines = luaL_checkinteger(L, 5);
    double ratio = luaL_checknumber(L, 6);

    if(numlines <= 0)
    {
        lua_pushfstring(L, "geometry.rectanglehlines: number of lines must be greater than zero (got %d) (object: \"%s\")", numlines, object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }

    if(ratio <= 0)
    {
        lua_pushfstring(L, "geometry.rectanglehlines: ratio must be greater than zero (got %f) (object: \"%s\")", ratio, object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }

    const struct point* bl = lpoint_get(pt1);
    const struct point* tr = lpoint_get(pt2);

    ucoordinate_t totalheight = point_ydifference(tr, bl);
    // ensure that the width and the space of the lines is even
    unsigned int correction = 0;
    while(totalheight % ((ucoordinate_t)(numlines * 4 * (ratio + 1))) != 0)
    {
        --totalheight;
        ++correction;
    }

    ucoordinate_t width = point_xdifference(tr, bl);
    ucoordinate_t pitch = totalheight / numlines;
    ucoordinate_t space = pitch / (ratio + 1);
    ucoordinate_t height = pitch - space;

    coordinate_t offset = (correction + space) / 2;

    geometry_rectanglearray(
        lobject_get_full(L, cell),
        layer,
        width, height,
        bl->x, bl->y + offset,  // xshift, yshift
        1, numlines,            // xrep, yrep
        0, pitch                // xpitch, ypitch
    );

    return 0;
}

static int lgeometry_rectanglelines_horizontal_height_space(lua_State* L)
{
    lcheck_check_numargs1(L, 6, "geometry.rectanglehlines_height_space");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* pt1 = lpoint_checkpoint(L, 3);
    struct lpoint* pt2 = lpoint_checkpoint(L, 4);
    coordinate_t heighttarget = luaL_checkinteger(L, 5);
    coordinate_t spacetarget = luaL_checkinteger(L, 6);

    const struct point* bl = lpoint_get(pt1);
    const struct point* tr = lpoint_get(pt2);

    coordinate_t totalheight = point_ydifference(tr, bl);
    unsigned int numlines = totalheight / (heighttarget + spacetarget);
    coordinate_t height = heighttarget;
    coordinate_t space = spacetarget;
    coordinate_t width = point_xdifference(tr, bl);
    coordinate_t offset = (totalheight - numlines * (height + space) + space) / 2;

    geometry_rectanglearray(
        lobject_get_full(L, cell),
        layer,
        width, height,
        bl->x, bl->y + offset,  // xshift, yshift
        1, numlines,            // xrep, yrep
        0, height + space       // xpitch, ypitch
    );

    return 5;
}

static int lgeometry_rectanglelines_horizontal_settings(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "geometry.rectanglehlines_settings");
    struct lpoint* pt1 = lpoint_checkpoint(L, 1);
    struct lpoint* pt2 = lpoint_checkpoint(L, 2);
    int numlines = luaL_checkinteger(L, 3);
    double ratio = luaL_checknumber(L, 4);

    if(numlines <= 0)
    {
        lua_pushfstring(L, "geometry.rectanglehlines_settings: number of lines must be greater than zero (got %d)", numlines);
        lua_error(L);
    }

    if(ratio <= 0)
    {
        lua_pushfstring(L, "geometry.rectanglehlines_settings: ratio must be greater than zero (got %f)", ratio);
        lua_error(L);
    }

    const struct point* bl = lpoint_get(pt1);
    const struct point* tr = lpoint_get(pt2);

    ucoordinate_t totalheight = point_ydifference(tr, bl);
    // ensure that the width and the space of the lines is even
    unsigned int correction = 0;
    while(totalheight % ((ucoordinate_t)(numlines * 4 * (ratio + 1))) != 0)
    {
        --totalheight;
        ++correction;
    }

    ucoordinate_t width = point_xdifference(tr, bl);
    ucoordinate_t pitch = totalheight / numlines;
    ucoordinate_t space = pitch / (ratio + 1);
    ucoordinate_t height = pitch - space;

    coordinate_t offset = (correction + space) / 2;

    lua_pushinteger(L, width);
    lua_pushinteger(L, height);
    lua_pushinteger(L, space);
    lua_pushinteger(L, offset);
    lua_pushinteger(L, numlines);

    return 5;
}

static int lgeometry_rectanglelines_horizontal_height_space_settings(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "geometry.rectanglehlines_height_space_settings");
    struct lpoint* pt1 = lpoint_checkpoint(L, 1);
    struct lpoint* pt2 = lpoint_checkpoint(L, 2);
    coordinate_t heighttarget = luaL_checkinteger(L, 3);
    coordinate_t spacetarget = luaL_checkinteger(L, 4);

    const struct point* bl = lpoint_get(pt1);
    const struct point* tr = lpoint_get(pt2);

    coordinate_t totalheight = point_ydifference(tr, bl);
    unsigned int numlines = totalheight / (heighttarget + spacetarget);
    coordinate_t height = heighttarget;
    coordinate_t space = spacetarget;
    coordinate_t width = point_xdifference(tr, bl);
    coordinate_t offset = (totalheight - numlines * (height + space) + space) / 2;

    lua_pushinteger(L, width);
    lua_pushinteger(L, height);
    lua_pushinteger(L, space);
    lua_pushinteger(L, offset);
    lua_pushinteger(L, numlines);

    return 5;
}

static int lgeometry_rectanglelines_horizontal_numlines_height_settings(lua_State* L)
{
    lcheck_check_numargs1(L, 4, "geometry.rectanglehlines_numlines_height_settings");
    struct lpoint* pt1 = lpoint_checkpoint(L, 1);
    struct lpoint* pt2 = lpoint_checkpoint(L, 2);
    int numlines = luaL_checkinteger(L, 3);
    coordinate_t heighttarget = luaL_checkinteger(L, 4);

    if(numlines <= 0)
    {
        lua_pushfstring(L, "geometry.rectanglehlines_numlines_height_settings: number of lines must be greater than zero (got %d)", numlines);
        lua_error(L);
    }

    const struct point* bl = lpoint_get(pt1);
    const struct point* tr = lpoint_get(pt2);

    ucoordinate_t totalheight = point_ydifference(tr, bl);
    // ensure that the height and the space of the lines is even
    unsigned int correction = 0;
    /*
    while(totalheight % ((ucoordinate_t)(numlines * 4 * (ratio + 1))) != 0)
    {
        --totalheight;
        ++correction;
    }
    */

    ucoordinate_t width = point_xdifference(tr, bl);
    ucoordinate_t pitch = totalheight / numlines;
    ucoordinate_t height = heighttarget;
    ucoordinate_t space = pitch - height;

    coordinate_t offset = (correction + space) / 2;

    lua_pushinteger(L, width);
    lua_pushinteger(L, height);
    lua_pushinteger(L, space);
    lua_pushinteger(L, offset);
    lua_pushinteger(L, numlines);

    return 5;
}

static int lgeometry_rectangle_fill_in_boundary(lua_State* L)
{
    lcheck_check_numargs2(L, 9, 10, "geometry.rectangle_fill_in_boundary");

    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);

    coordinate_t width = luaL_checkinteger(L, 3);
    coordinate_t height = luaL_checkinteger(L, 4);
    coordinate_t xpitch = luaL_checkinteger(L, 5);
    coordinate_t ypitch = luaL_checkinteger(L, 6);
    coordinate_t xstartshift = luaL_checkinteger(L, 7);
    coordinate_t ystartshift = luaL_checkinteger(L, 8);

    // read target area and excludes
    struct simple_polygon* targetarea = lutil_create_simple_polygon(L, 9);
    struct polygon_container* excludes;
    lplacement_create_exclude_vectors(L, &excludes, 10);

    // calculate origins
    struct vector* origins = placement_calculate_origins_centered(width, height, xpitch, ypitch, xstartshift, ystartshift, targetarea, excludes);

    simple_polygon_destroy(targetarea);
    if(excludes)
    {
        polygon_container_destroy(excludes);
    }

    struct vector_const_iterator* origin_it = vector_const_iterator_create(origins);
    while(vector_const_iterator_is_valid(origin_it))
    {
        const struct point* origin = vector_const_iterator_get(origin_it);
        geometry_rectanglebltrxy(
            lobject_get_full(L, cell),
            layer,
            point_getx(origin) - width / 2, point_gety(origin) - height / 2,
            point_getx(origin) + width / 2, point_gety(origin) + height / 2
        );
        vector_const_iterator_next(origin_it);
    }
    vector_const_iterator_destroy(origin_it);
    vector_destroy(origins);
    return 0;
}

static int lgeometry_path_2x(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    coordinate_t width = luaL_checkinteger(L, 5);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 6, &bgnext, &endext, width);

    struct point* pts1 = point_create(lpoint_get(ptend)->x, lpoint_get(ptstart)->y);
    struct vector* points = vector_create(3, NULL); // non-owning
    vector_append(points, (struct point*)lpoint_get(ptstart));
    vector_append(points, pts1);
    vector_append(points, (struct point*)lpoint_get(ptend));
    geometry_path(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    point_destroy(pts1);
    vector_destroy(points);
    return 0;
}

static int lgeometry_path_2x_polygon(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    coordinate_t width = luaL_checkinteger(L, 5);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 6, &bgnext, &endext, width);

    struct point* pts1 = point_create(lpoint_get(ptend)->x, lpoint_get(ptstart)->y);
    struct vector* points = vector_create(3, NULL); // non-owning
    vector_append(points, (struct point*)lpoint_get(ptstart));
    vector_append(points, pts1);
    vector_append(points, (struct point*)lpoint_get(ptend));
    geometry_path_polygon(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    point_destroy(pts1);
    vector_destroy(points);
    return 0;
}

static int lgeometry_path_2y(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    coordinate_t width = luaL_checkinteger(L, 5);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 6, &bgnext, &endext, width);

    struct point* pts1 = point_create(lpoint_get(ptstart)->x, lpoint_get(ptend)->y);
    struct vector* points = vector_create(3, NULL); // non-owning
    vector_append(points, (struct point*)lpoint_get(ptstart));
    vector_append(points, pts1);
    vector_append(points, (struct point*)lpoint_get(ptend));
    geometry_path(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    point_destroy(pts1);
    vector_destroy(points);
    return 0;
}

static int lgeometry_path_2y_polygon(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    coordinate_t width = luaL_checkinteger(L, 5);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 6, &bgnext, &endext, width);

    struct point* pts1 = point_create(lpoint_get(ptstart)->x, lpoint_get(ptend)->y);
    struct vector* points = vector_create(3, NULL); // non-owning
    vector_append(points, (struct point*)lpoint_get(ptstart));
    vector_append(points, pts1);
    vector_append(points, (struct point*)lpoint_get(ptend));
    geometry_path_polygon(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    point_destroy(pts1);
    vector_destroy(points);
    return 0;
}

static int lgeometry_path_3x(lua_State* L)
{
    lcheck_check_numargs2(L, 6, 7, "geometry.path_3x");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    coordinate_t width = luaL_checkinteger(L, 5);
    double posfactor = luaL_checknumber(L, 6);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 7, &bgnext, &endext, width);

    struct point* pts1 = point_create(lpoint_get(ptstart)->x + (lpoint_get(ptend)->x - lpoint_get(ptstart)->x) * posfactor, lpoint_get(ptstart)->y);
    struct point* pts2 = point_create(lpoint_get(ptstart)->x + (lpoint_get(ptend)->x - lpoint_get(ptstart)->x) * posfactor, lpoint_get(ptend)->y);
    struct vector* points = vector_create(3, NULL); // non-owning
    vector_append(points, (struct point*)lpoint_get(ptstart));
    vector_append(points, pts1);
    vector_append(points, pts2);
    vector_append(points, (struct point*)lpoint_get(ptend));
    geometry_path(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    point_destroy(pts1);
    point_destroy(pts2);
    vector_destroy(points);
    return 0;
}

static int lgeometry_path_3x_polygon(lua_State* L)
{
    lcheck_check_numargs2(L, 6, 7, "geometry.path_3x");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    coordinate_t width = luaL_checkinteger(L, 5);
    double posfactor = luaL_checknumber(L, 6);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 7, &bgnext, &endext, width);

    struct point* pts1 = point_create(lpoint_get(ptstart)->x + (lpoint_get(ptend)->x - lpoint_get(ptstart)->x) * posfactor, lpoint_get(ptstart)->y);
    struct point* pts2 = point_create(lpoint_get(ptstart)->x + (lpoint_get(ptend)->x - lpoint_get(ptstart)->x) * posfactor, lpoint_get(ptend)->y);
    struct vector* points = vector_create(3, NULL); // non-owning
    vector_append(points, (struct point*)lpoint_get(ptstart));
    vector_append(points, pts1);
    vector_append(points, pts2);
    vector_append(points, (struct point*)lpoint_get(ptend));
    geometry_path_polygon(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    point_destroy(pts1);
    point_destroy(pts2);
    vector_destroy(points);
    return 0;
}

static int lgeometry_path_3x_diagonal(lua_State* L)
{
    lcheck_check_numargs2(L, 6, 7, "geometry.path_3x_diagonal");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    coordinate_t width = luaL_checkinteger(L, 5);
    double posfactor = luaL_checknumber(L, 6);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 7, &bgnext, &endext, width);

    coordinate_t diff = coordinate_abs(point_gety(lpoint_get(ptstart)) - point_gety(lpoint_get(ptend)));
    if(point_getx(lpoint_get(ptstart)) < point_getx(lpoint_get(ptend)))
    {
        diff = -diff;
    }
    struct point* pts1 = point_create(
        lpoint_get(ptstart)->x + (lpoint_get(ptend)->x - lpoint_get(ptstart)->x) * posfactor + diff / 2,
        lpoint_get(ptstart)->y
    );
    struct point* pts2 = point_create(
        lpoint_get(ptstart)->x + (lpoint_get(ptend)->x - lpoint_get(ptstart)->x) * posfactor - diff / 2,
        lpoint_get(ptend)->y
    );
    struct vector* points = vector_create(3, NULL); // non-owning
    vector_append(points, (struct point*)lpoint_get(ptstart));
    vector_append(points, pts1);
    vector_append(points, pts2);
    vector_append(points, (struct point*)lpoint_get(ptend));
    geometry_path(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    point_destroy(pts1);
    point_destroy(pts2);
    vector_destroy(points);
    return 0;
}

static int lgeometry_path_3x_diagonal_polygon(lua_State* L)
{
    lcheck_check_numargs2(L, 6, 7, "geometry.path_3x_diagonal");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    coordinate_t width = luaL_checkinteger(L, 5);
    double posfactor = luaL_checknumber(L, 6);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 7, &bgnext, &endext, width);

    coordinate_t diff = coordinate_abs(point_gety(lpoint_get(ptstart)) - point_gety(lpoint_get(ptend)));
    if(point_getx(lpoint_get(ptstart)) < point_getx(lpoint_get(ptend)))
    {
        diff = -diff;
    }
    struct point* pts1 = point_create(
        lpoint_get(ptstart)->x + (lpoint_get(ptend)->x - lpoint_get(ptstart)->x) * posfactor + diff / 2,
        lpoint_get(ptstart)->y
    );
    struct point* pts2 = point_create(
        lpoint_get(ptstart)->x + (lpoint_get(ptend)->x - lpoint_get(ptstart)->x) * posfactor - diff / 2,
        lpoint_get(ptend)->y
    );
    struct vector* points = vector_create(3, NULL); // non-owning
    vector_append(points, (struct point*)lpoint_get(ptstart));
    vector_append(points, pts1);
    vector_append(points, pts2);
    vector_append(points, (struct point*)lpoint_get(ptend));
    geometry_path_polygon(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    point_destroy(pts1);
    point_destroy(pts2);
    vector_destroy(points);
    return 0;
}

static int lgeometry_path_3y(lua_State* L)
{
    lcheck_check_numargs2(L, 6, 7, "geometry.path_3y");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    coordinate_t width = luaL_checkinteger(L, 5);
    double posfactor = luaL_checknumber(L, 6);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 7, &bgnext, &endext, width);

    struct point* pts1 = point_create(lpoint_get(ptstart)->x, lpoint_get(ptstart)->y + (lpoint_get(ptend)->y - lpoint_get(ptstart)->y) * posfactor);
    struct point* pts2 = point_create(lpoint_get(ptend)->x, lpoint_get(ptstart)->y + (lpoint_get(ptend)->y - lpoint_get(ptstart)->y) * posfactor);
    struct vector* points = vector_create(3, NULL); // non-owning
    vector_append(points, (struct point*)lpoint_get(ptstart));
    vector_append(points, pts1);
    vector_append(points, pts2);
    vector_append(points, (struct point*)lpoint_get(ptend));
    geometry_path(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    point_destroy(pts1);
    point_destroy(pts2);
    vector_destroy(points);
    return 0;
}

static int lgeometry_path_3y_polygon(lua_State* L)
{
    lcheck_check_numargs2(L, 6, 7, "geometry.path_3y");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    coordinate_t width = luaL_checkinteger(L, 5);
    double posfactor = luaL_checknumber(L, 6);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 7, &bgnext, &endext, width);

    struct point* pts1 = point_create(lpoint_get(ptstart)->x, lpoint_get(ptstart)->y + (lpoint_get(ptend)->y - lpoint_get(ptstart)->y) * posfactor);
    struct point* pts2 = point_create(lpoint_get(ptend)->x, lpoint_get(ptstart)->y + (lpoint_get(ptend)->y - lpoint_get(ptstart)->y) * posfactor);
    struct vector* points = vector_create(3, NULL); // non-owning
    vector_append(points, (struct point*)lpoint_get(ptstart));
    vector_append(points, pts1);
    vector_append(points, pts2);
    vector_append(points, (struct point*)lpoint_get(ptend));
    geometry_path_polygon(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    point_destroy(pts1);
    point_destroy(pts2);
    vector_destroy(points);
    return 0;
}

static int lgeometry_path_3y_diagonal(lua_State* L)
{
    lcheck_check_numargs2(L, 6, 7, "geometry.path_3y_diagonal");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    coordinate_t width = luaL_checkinteger(L, 5);
    double posfactor = luaL_checknumber(L, 6);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 7, &bgnext, &endext, width);

    coordinate_t diff = coordinate_abs(point_getx(lpoint_get(ptstart)) - point_getx(lpoint_get(ptend)));
    if(point_gety(lpoint_get(ptstart)) < point_gety(lpoint_get(ptend)))
    {
        diff = -diff;
    }
    struct point* pts1 = point_create(
        lpoint_get(ptstart)->x,
        lpoint_get(ptstart)->y + (lpoint_get(ptend)->y - lpoint_get(ptstart)->y) * posfactor + diff / 2
    );
    struct point* pts2 = point_create(
        lpoint_get(ptend)->x,
        lpoint_get(ptstart)->y + (lpoint_get(ptend)->y - lpoint_get(ptstart)->y) * posfactor - diff / 2
    );
    struct vector* points = vector_create(3, NULL); // non-owning
    vector_append(points, (struct point*)lpoint_get(ptstart));
    vector_append(points, pts1);
    vector_append(points, pts2);
    vector_append(points, (struct point*)lpoint_get(ptend));
    geometry_path(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    point_destroy(pts1);
    point_destroy(pts2);
    vector_destroy(points);
    return 0;
}

static int lgeometry_path_3y_diagonal_polygon(lua_State* L)
{
    lcheck_check_numargs2(L, 6, 7, "geometry.path_3y_diagonal");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    coordinate_t width = luaL_checkinteger(L, 5);
    double posfactor = luaL_checknumber(L, 6);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 7, &bgnext, &endext, width);

    coordinate_t diff = coordinate_abs(point_getx(lpoint_get(ptstart)) - point_getx(lpoint_get(ptend)));
    if(point_gety(lpoint_get(ptstart)) < point_gety(lpoint_get(ptend)))
    {
        diff = -diff;
    }
    struct point* pts1 = point_create(
        lpoint_get(ptstart)->x,
        lpoint_get(ptstart)->y + (lpoint_get(ptend)->y - lpoint_get(ptstart)->y) * posfactor + diff / 2
    );
    struct point* pts2 = point_create(
        lpoint_get(ptend)->x,
        lpoint_get(ptstart)->y + (lpoint_get(ptend)->y - lpoint_get(ptstart)->y) * posfactor - diff / 2
    );
    struct vector* points = vector_create(3, NULL); // non-owning
    vector_append(points, (struct point*)lpoint_get(ptstart));
    vector_append(points, pts1);
    vector_append(points, pts2);
    vector_append(points, (struct point*)lpoint_get(ptend));
    geometry_path_polygon(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    point_destroy(pts1);
    point_destroy(pts2);
    vector_destroy(points);
    return 0;
}

static int lgeometry_path_cshape(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    struct lpoint* ptoffset = lpoint_checkpoint(L, 5);
    coordinate_t offset = lpoint_get(ptoffset)->x;
    coordinate_t width = luaL_checkinteger(L, 6);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 7, &bgnext, &endext, width);

    struct point* pts1 = point_create(offset, lpoint_get(ptstart)->y);
    struct point* pts2 = point_create(offset, lpoint_get(ptend)->y);
    struct vector* points = vector_create(3, NULL); // non-owning
    vector_append(points, (struct point*)lpoint_get(ptstart));
    vector_append(points, pts1);
    vector_append(points, pts2);
    vector_append(points, (struct point*)lpoint_get(ptend));
    geometry_path(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    point_destroy(pts1);
    point_destroy(pts2);
    vector_destroy(points);
    return 0;
}

static int lgeometry_path_ushape(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    struct lpoint* ptoffset = lpoint_checkpoint(L, 5);
    coordinate_t offset = lpoint_get(ptoffset)->y;
    coordinate_t width = luaL_checkinteger(L, 6);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 7, &bgnext, &endext, width);

    struct point* pts1 = point_create(lpoint_get(ptstart)->x, offset);
    struct point* pts2 = point_create(lpoint_get(ptend)->x, offset);
    struct vector* points = vector_create(4, NULL); // non-owning
    vector_append(points, (struct point*)lpoint_get(ptstart));
    vector_append(points, pts1);
    vector_append(points, pts2);
    vector_append(points, (struct point*)lpoint_get(ptend));
    geometry_path(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    point_destroy(pts1);
    point_destroy(pts2);
    vector_destroy(points);
    return 0;
}

static int lgeometry_path_polygon(lua_State* L)
{
    lcheck_check_numargs2(L, 4, 5, "geometry.path_polygon");
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    if(!lua_istable(L, 3))
    {
        lua_pushfstring(L, "geometry.path_polygon: list of points (third argument) is not a table (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    lua_len(L, 3);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    coordinate_t width = luaL_checkinteger(L, 4);
    if(width == 0)
    {
        lua_pushfstring(L, "geometry.path_polygon: width can't be zero (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
    if(width % 2 != 0)
    {
        lua_pushfstring(L, "geometry.path_polygon: width is odd (%d) (object: \"%s\")", width, object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 5, &bgnext, &endext, width);

    struct vector* points = vector_create(len, point_destroy);
    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        vector_append(points, point_copy(lpoint_get(pt)));
        lua_pop(L, 1);
    }
    geometry_path_polygon(lobject_get_full(L, cell), layer, points, width, bgnext, endext);
    vector_destroy(points);
    return 0;
}

static void _path_points(lua_State* L, int xnoty)
{
    struct lpoint* startpt = lpoint_checkpoint(L, 1);
    lua_len(L, 2);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    coordinate_t lastx = point_getx(lpoint_get(startpt));
    coordinate_t lasty = point_gety(lpoint_get(startpt));
    lua_newtable(L);
    lpoint_create_internal_xy(L, lastx, lasty);
    lua_rawseti(L, -2, 1);
    size_t idx = 2;
    for(size_t i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 2, i);
        if(lpoint_is_point(L, -1))
        {
            struct lpoint* pt = lpoint_checkpoint(L, -1);
            coordinate_t x = point_getx(lpoint_get(pt));
            coordinate_t y = point_gety(lpoint_get(pt));
            if(xnoty)
            {
                lpoint_create_internal_xy(L, x, lasty);
                lua_rawseti(L, -3, idx);
                idx += 1;
            }
            else
            {
                lpoint_create_internal_xy(L, lastx, y);
                lua_rawseti(L, -3, idx);
                idx += 1;
            }
            lastx = x;
            lasty = y;
            xnoty = !xnoty;
        }
        else
        {
            coordinate_t mov = lua_tointeger(L, -1);
            if(xnoty)
            {
                lastx = lastx + mov;
            }
            else
            {
                lasty = lasty + mov;
            }
        }
        lua_pop(L, 1);
        lpoint_create_internal_xy(L, lastx, lasty);
        lua_rawseti(L, -2, idx);
        idx += 1;
        xnoty = !xnoty;
    }
}

static int lgeometry_path_points_xy(lua_State* L)
{
    int xnoty = 1;
    _path_points(L, xnoty);
    return 1;
}

static int lgeometry_path_points_yx(lua_State* L)
{
    int xnoty = 0;
    _path_points(L, xnoty);
    return 1;
}

void _get_viacontact_properties(lua_State* L, int idx, int* xcont, int* ycont, coordinate_t* minxspace, coordinate_t* minyspace, int* equal_pitch, coordinate_t* widthclass)
{
    if(lua_type(L, idx) == LUA_TTABLE)
    {
        if(xcont)
        {
            lua_getfield(L, idx, "xcontinuous");
            *xcont = lua_toboolean(L, -1);
            lua_pop(L, 1);
        }
        if(ycont)
        {
            lua_getfield(L, idx, "ycontinuous");
            *ycont = lua_tointeger(L, -1);
            lua_pop(L, 1);
        }
        if(minxspace)
        {
            lua_getfield(L, idx, "minxspace");
            *minxspace = lua_tointeger(L, -1);
            lua_pop(L, 1);
        }
        if(minyspace)
        {
            lua_getfield(L, idx, "minyspace");
            *minyspace = lua_toboolean(L, -1);
            lua_pop(L, 1);
        }
        if(equal_pitch)
        {
            lua_getfield(L, idx, "equal_pitch");
            *equal_pitch = lua_toboolean(L, -1);
            lua_pop(L, 1);
        }
        if(widthclass)
        {
            lua_getfield(L, idx, "widthclass");
            *widthclass = lua_tointeger(L, -1);
            lua_pop(L, 1);
        }
    }
    else if(lua_type(L, idx) != LUA_TNONE)
    {
        lua_pushfstring(L, "via/contact properties: expected table, got %s", lua_typename(L, lua_type(L, idx)));
        lua_error(L);
    }
}

static int lgeometry_check_viabltr(lua_State* L)
{
    lcheck_check_numargs2(L, 4, 5, "geometry.check_viabltr");
    int metal1 = luaL_checkinteger(L, 1);
    int metal2 = luaL_checkinteger(L, 2);
    struct lpoint* bl = lpoint_checkpoint(L, 3);
    struct lpoint* tr = lpoint_checkpoint(L, 4);
    _check_rectangle_points(L, bl, tr, "geometry.check_viabltr");
    int xcont = 0;
    int ycont = 0;
    coordinate_t minxspace = 0;
    coordinate_t minyspace = 0;
    int equal_pitch = 0;
    coordinate_t widthclass = 0;
    _get_viacontact_properties(L, 5, &xcont, &ycont, &minxspace, &minyspace, &equal_pitch, &widthclass);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_check_viabltr(techstate, metal1, metal2, lpoint_get(bl), lpoint_get(tr), xcont, ycont, equal_pitch, widthclass);
    lua_pushboolean(L, res);
    return 1;
}

static int lgeometry_check_viabltrov(lua_State* L)
{
    lcheck_check_numargs1(L, 6, "geometry.check_viabltrov");
    int metal1 = luaL_checkinteger(L, 1);
    int metal2 = luaL_checkinteger(L, 2);
    struct lpoint* bl1 = lpoint_checkpoint(L, 3);
    struct lpoint* tr1 = lpoint_checkpoint(L, 4);
    struct lpoint* bl2 = lpoint_checkpoint(L, 5);
    struct lpoint* tr2 = lpoint_checkpoint(L, 6);
    _check_rectangle_points(L, bl1, tr1, "geometry.check_viabltrov");
    _check_rectangle_points(L, bl2, tr2, "geometry.check_viabltrov");
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_check_viabltrov(techstate, metal1, metal2, lpoint_get(bl1), lpoint_get(tr1), lpoint_get(bl2), lpoint_get(tr2));
    lua_pushboolean(L, res);
    return 1;
}

static int lgeometry_calculate_viabltr(lua_State* L)
{
    lcheck_check_numargs2(L, 6, 7, "geometry.calculate_viabltr");
    int metal1 = luaL_checkinteger(L, 1);
    int metal2 = luaL_checkinteger(L, 2);
    struct lpoint* bl = lpoint_checkpoint(L, 3);
    struct lpoint* tr = lpoint_checkpoint(L, 4);
    _check_rectangle_points(L, bl, tr, "geometry.calculate_viabltr");
    coordinate_t minxspace = luaL_checkinteger(L, 5);
    coordinate_t minyspace = luaL_checkinteger(L, 6);
    int xcont = 0;
    int ycont = 0;
    int equal_pitch = 0;
    coordinate_t widthclass = 0;
    _get_viacontact_properties(L, 7, &xcont, &ycont, NULL, NULL, &equal_pitch, &widthclass);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    struct vector* result = geometry_calculate_viabltr(techstate, metal1, metal2, lpoint_get(bl), lpoint_get(tr), minxspace, minyspace, xcont, ycont, equal_pitch, widthclass);
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(result); ++i)
    {
        lua_newtable(L);
        struct viaarray* array = vector_get(result, i);
        lua_pushinteger(L, array->width);
        lua_setfield(L, -2, "width");
        lua_pushinteger(L, array->height);
        lua_setfield(L, -2, "height");
        lua_pushinteger(L, array->xrep);
        lua_setfield(L, -2, "xrep");
        lua_pushinteger(L, array->yrep);
        lua_setfield(L, -2, "yrep");
        lua_pushinteger(L, array->xpitch - array->width);
        lua_setfield(L, -2, "xspace");
        lua_pushinteger(L, array->ypitch - array->height);
        lua_setfield(L, -2, "yspace");
        lua_pushinteger(L, array->xoffset);
        lua_setfield(L, -2, "xoffset");
        lua_pushinteger(L, array->yoffset);
        lua_setfield(L, -2, "yoffset");
        lua_pushlightuserdata(L, (void*)array->layer);
        lua_setfield(L, -2, "layer");
        lua_rawseti(L, -2, i + 1);
    }
    vector_destroy(result);
    return 1;
}

static int lgeometry_calculate_viabltr2(lua_State* L)
{
    lcheck_check_numargs2(L, 8, 9, "geometry.calculate_viabltr");
    int metal1 = luaL_checkinteger(L, 1);
    int metal2 = luaL_checkinteger(L, 2);
    struct lpoint* bl1 = lpoint_checkpoint(L, 3);
    struct lpoint* tr1 = lpoint_checkpoint(L, 4);
    struct lpoint* bl2 = lpoint_checkpoint(L, 5);
    struct lpoint* tr2 = lpoint_checkpoint(L, 6);
    _check_rectangle_points(L, bl1, tr1, "geometry.calculate_viabltr2");
    _check_rectangle_points(L, bl2, tr2, "geometry.calculate_viabltr2");
    coordinate_t minxspace = luaL_checkinteger(L, 7);
    coordinate_t minyspace = luaL_checkinteger(L, 8);
    int xcont = 0;
    int ycont = 0;
    int equal_pitch = 0;
    coordinate_t widthclass = 0;
    _get_viacontact_properties(L, 9, &xcont, &ycont, NULL, NULL, &equal_pitch, &widthclass);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    struct vector* result = geometry_calculate_viabltr2(techstate, metal1, metal2, lpoint_get(bl1), lpoint_get(tr1), lpoint_get(bl2), lpoint_get(tr2), minxspace, minyspace, widthclass);
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(result); ++i)
    {
        lua_newtable(L);
        struct viaarray* array = vector_get(result, i);
        lua_pushinteger(L, array->width);
        lua_setfield(L, -2, "width");
        lua_pushinteger(L, array->height);
        lua_setfield(L, -2, "height");
        lua_pushinteger(L, array->xrep);
        lua_setfield(L, -2, "xrep");
        lua_pushinteger(L, array->yrep);
        lua_setfield(L, -2, "yrep");
        lua_pushinteger(L, array->xpitch - array->width);
        lua_setfield(L, -2, "xspace");
        lua_pushinteger(L, array->ypitch - array->height);
        lua_setfield(L, -2, "yspace");
        lua_pushinteger(L, array->xoffset);
        lua_setfield(L, -2, "xoffset");
        lua_pushinteger(L, array->yoffset);
        lua_setfield(L, -2, "yoffset");
        lua_pushlightuserdata(L, (void*)array->layer);
        lua_setfield(L, -2, "layer");
        lua_rawseti(L, -2, i + 1);
    }
    vector_destroy(result);
    return 1;
}

static int lgeometry_viabltr(lua_State* L)
{
    lcheck_check_numargs_range(L, 5, 7, "geometry.viabltr");
    struct lobject* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    struct lpoint* bl = lpoint_checkpoint(L, 4);
    struct lpoint* tr = lpoint_checkpoint(L, 5);
    const char* debugstring = lua_tostring(L, 6);
#ifdef OPC_LINT
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.viabltr called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    _check_rectangle_points(L, bl, tr, "geometry.viabltr");
    int xcont = 0;
    int ycont = 0;
    coordinate_t minxspace = 0;
    coordinate_t minyspace = 0;
    int equal_pitch = 0;
    coordinate_t widthclass = 0;
    _get_viacontact_properties(L, 7, &xcont, &ycont, &minxspace, &minyspace, &equal_pitch, &widthclass);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_viabltr(lobject_get_full(L, cell), techstate, metal1, metal2, lpoint_get(bl), lpoint_get(tr), minxspace, minyspace, xcont, ycont, equal_pitch, widthclass);
    if(!res)
    {
        coordinate_t blx = point_getx(lpoint_get(bl));
        coordinate_t bly = point_gety(lpoint_get(bl));
        coordinate_t trx = point_getx(lpoint_get(tr));
        coordinate_t try = point_gety(lpoint_get(tr));
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.viabltr: could not fit via from metal %d to metal %d. Area: %d x %d\ndebug info: %s (object: \"%s\")", metal1, metal2, trx - blx, try - bly, debugstring, object_get_name(lobject_get_const(cell)));
        }
        else
        {
            lua_pushfstring(L, "geometry.viabltr: could not fit via from metal %d to metal %d. Area: %d x %d (object: \"%s\")", metal1, metal2, trx - blx, try - bly, object_get_name(lobject_get_const(cell)));
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_viabltrov(lua_State* L)
{
    lcheck_check_numargs2(L, 7, 8, "geometry.viabltrov");
    struct lobject* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    struct lpoint* bl1 = lpoint_checkpoint(L, 4);
    struct lpoint* tr1 = lpoint_checkpoint(L, 5);
    struct lpoint* bl2 = lpoint_checkpoint(L, 6);
    struct lpoint* tr2 = lpoint_checkpoint(L, 7);
    const char* debugstring = lua_tostring(L, 8);
#ifdef OPC_LINT
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.viabltrov called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    _check_rectangle_points(L, bl1, tr1, "geometry.viabltrov");
    _check_rectangle_points(L, bl2, tr2, "geometry.viabltrov");
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_viabltrov(lobject_get_full(L, cell), techstate, metal1, metal2, lpoint_get(bl1), lpoint_get(tr1), lpoint_get(bl2), lpoint_get(tr2));
    if(!res)
    {
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.viabltrov: could not fit via from metal %d to metal %d. Areas: (%d, %d)/(%d, %d) and (%d, %d)/(%d, %d)\ndebug info: %s (object: \"%s\")",
                metal1, metal2,
                lpoint_get(bl1)->x, lpoint_get(bl1)->y,
                lpoint_get(tr1)->x, lpoint_get(tr1)->y,
                lpoint_get(bl2)->x, lpoint_get(bl2)->y,
                lpoint_get(tr2)->x, lpoint_get(tr2)->y,
                debugstring,
                object_get_name(lobject_get_const(cell))
            );
        }
        else
        {
            lua_pushfstring(L, "geometry.viabltrov: could not fit via from metal %d to metal %d. Areas: (%d, %d)/(%d, %d) and (%d, %d)/(%d, %d) (object: \"%s\")",
                metal1, metal2,
                lpoint_get(bl1)->x, lpoint_get(bl1)->y,
                lpoint_get(tr1)->x, lpoint_get(tr1)->y,
                lpoint_get(bl2)->x, lpoint_get(bl2)->y,
                lpoint_get(tr2)->x, lpoint_get(tr2)->y,
                object_get_name(lobject_get_const(cell))
            );
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_viabltr2(lua_State* L)
{
    lcheck_check_numargs2(L, 7, 8, "geometry.viabltr2");
    struct lobject* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    struct lpoint* bl1 = lpoint_checkpoint(L, 4);
    struct lpoint* tr1 = lpoint_checkpoint(L, 5);
    struct lpoint* bl2 = lpoint_checkpoint(L, 6);
    struct lpoint* tr2 = lpoint_checkpoint(L, 7);
    const char* debugstring = lua_tostring(L, 8);
#ifdef OPC_LINT
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.viabltr2 called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    _check_rectangle_points(L, bl1, tr1, "geometry.viabltr2");
    _check_rectangle_points(L, bl2, tr2, "geometry.viabltr2");
    int xcont = 0;
    int ycont = 0;
    coordinate_t minxspace = 0;
    coordinate_t minyspace = 0;
    int equal_pitch = 0;
    coordinate_t widthclass = 0;
    _get_viacontact_properties(L, 9, &xcont, &ycont, &minxspace, &minyspace, &equal_pitch, &widthclass);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_viabltr2(lobject_get_full(L, cell), techstate, metal1, metal2, lpoint_get(bl1), lpoint_get(tr1), lpoint_get(bl2), lpoint_get(tr2), 0);
    if(!res)
    {
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.viabltr2: could not fit via from metal %d to metal %d. Areas: (%d, %d)/(%d, %d) and (%d, %d)/(%d, %d)\ndebug info: %s (object: \"%s\")",
                metal1, metal2,
                lpoint_get(bl1)->x, lpoint_get(bl1)->y,
                lpoint_get(tr1)->x, lpoint_get(tr1)->y,
                lpoint_get(bl2)->x, lpoint_get(bl2)->y,
                lpoint_get(tr2)->x, lpoint_get(tr2)->y,
                debugstring,
                object_get_name(lobject_get_const(cell))
            );
        }
        else
        {
            lua_pushfstring(L, "geometry.viabltr2: could not fit via from metal %d to metal %d. Areas: (%d, %d)/(%d, %d) and (%d, %d)/(%d, %d) (object: \"%s\")",
                metal1, metal2,
                lpoint_get(bl1)->x, lpoint_get(bl1)->y,
                lpoint_get(tr1)->x, lpoint_get(tr1)->y,
                lpoint_get(bl2)->x, lpoint_get(bl2)->y,
                lpoint_get(tr2)->x, lpoint_get(tr2)->y,
                object_get_name(lobject_get_const(cell))
            );
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_viabarebltr(lua_State* L)
{
    lcheck_check_numargs_range(L, 5, 7, "geometry.viabarebltr");
    struct lobject* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    struct lpoint* bl = lpoint_checkpoint(L, 4);
    struct lpoint* tr = lpoint_checkpoint(L, 5);
    const char* debugstring = lua_tostring(L, 6);
#ifdef OPC_LINT
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.viabarebltr called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    _check_rectangle_points(L, bl, tr, "geometry.viabarebltr");
    int xcont = 0;
    int ycont = 0;
    coordinate_t minxspace = 0;
    coordinate_t minyspace = 0;
    int equal_pitch = 0;
    coordinate_t widthclass = 0;
    _get_viacontact_properties(L, 7, &xcont, &ycont, &minxspace, &minyspace, &equal_pitch, &widthclass);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_viabarebltr(lobject_get_full(L, cell), techstate, metal1, metal2, lpoint_get(bl), lpoint_get(tr), minxspace, minyspace, xcont, ycont, equal_pitch, widthclass);
    if(!res)
    {
        coordinate_t blx = point_getx(lpoint_get(bl));
        coordinate_t bly = point_gety(lpoint_get(bl));
        coordinate_t trx = point_getx(lpoint_get(tr));
        coordinate_t try = point_gety(lpoint_get(tr));
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.viabarebltr: could not fit via from metal %d to metal %d. Area: %d x %d\ndebug info: %s (object: \"%s\")", metal1, metal2, trx - blx, try - bly, debugstring, object_get_name(lobject_get_const(cell)));
        }
        else
        {
            lua_pushfstring(L, "geometry.viabarebltr: could not fit via from metal %d to metal %d. Area: %d x %d (object: \"%s\")", metal1, metal2, trx - blx, try - bly, object_get_name(lobject_get_const(cell)));
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_viabarebltrov(lua_State* L)
{
    lcheck_check_numargs2(L, 7, 8, "geometry.viabarebltrov");
    struct lobject* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    struct lpoint* bl1 = lpoint_checkpoint(L, 4);
    struct lpoint* tr1 = lpoint_checkpoint(L, 5);
    struct lpoint* bl2 = lpoint_checkpoint(L, 6);
    struct lpoint* tr2 = lpoint_checkpoint(L, 7);
    const char* debugstring = lua_tostring(L, 8);
#ifdef opc_lint
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.viabarebltrov called without debug string (object: \"%s\")", object_get_name(lobject_get_const(celL)));
        lua_error(L);
    }
#endif
    _check_rectangle_points(L, bl1, tr1, "geometry.viabarebltrov");
    _check_rectangle_points(L, bl2, tr2, "geometry.viabarebltrov");
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_viabarebltrov(lobject_get_full(L, cell), techstate, metal1, metal2, lpoint_get(bl1), lpoint_get(tr1), lpoint_get(bl2), lpoint_get(tr2));
    if(!res)
    {
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.viabarebltrov: could not fit via from metal %d to metal %d. areas: (%d, %d)/(%d, %d) and (%d, %d)/(%d, %d)\ndebug info: %s (object: \"%s\")",
                metal1, metal2,
                lpoint_get(bl1)->x, lpoint_get(bl1)->y,
                lpoint_get(tr1)->x, lpoint_get(tr1)->y,
                lpoint_get(bl2)->x, lpoint_get(bl2)->y,
                lpoint_get(tr2)->x, lpoint_get(tr2)->y,
                debugstring,
                object_get_name(lobject_get_const(cell))
            );
        }
        else
        {
            lua_pushfstring(L, "geometry.viabarebltrov: could not fit via from metal %d to metal %d. areas: (%d, %d)/(%d, %d) and (%d, %d)/(%d, %d) (object: \"%s\")",
                metal1, metal2,
                lpoint_get(bl1)->x, lpoint_get(bl1)->y,
                lpoint_get(tr1)->x, lpoint_get(tr1)->y,
                lpoint_get(bl2)->x, lpoint_get(bl2)->y,
                lpoint_get(tr2)->x, lpoint_get(tr2)->y,
                object_get_name(lobject_get_const(cell))
            );
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_viabarebltr2(lua_State* L)
{
    lcheck_check_numargs2(L, 7, 8, "geometry.viabarebltr2");
    struct lobject* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    struct lpoint* bl1 = lpoint_checkpoint(L, 4);
    struct lpoint* tr1 = lpoint_checkpoint(L, 5);
    struct lpoint* bl2 = lpoint_checkpoint(L, 6);
    struct lpoint* tr2 = lpoint_checkpoint(L, 7);
    const char* debugstring = lua_tostring(L, 8);
#ifdef opc_lint
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.viabarebltr2 called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    _check_rectangle_points(L, bl1, tr1, "geometry.viabarebltr2");
    _check_rectangle_points(L, bl2, tr2, "geometry.viabarebltr2");
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_viabarebltr2(lobject_get_full(L, cell), techstate, metal1, metal2, lpoint_get(bl1), lpoint_get(tr1), lpoint_get(bl2), lpoint_get(tr2), 0);
    if(!res)
    {
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.viabarebltr2: could not fit via from metal %d to metal %d. areas: (%d, %d)/(%d, %d) and (%d, %d)/(%d, %d)\ndebug info: %s (object: \"%s\")",
                metal1, metal2,
                lpoint_get(bl1)->x, lpoint_get(bl1)->y,
                lpoint_get(tr1)->x, lpoint_get(tr1)->y,
                lpoint_get(bl2)->x, lpoint_get(bl2)->y,
                lpoint_get(tr2)->x, lpoint_get(tr2)->y,
                debugstring,
                object_get_name(lobject_get_const(cell))
            );
        }
        else
        {
            lua_pushfstring(L, "geometry.viabarebltr2: could not fit via from metal %d to metal %d. areas: (%d, %d)/(%d, %d) and (%d, %d)/(%d, %d) (object: \"%s\")",
                metal1, metal2,
                lpoint_get(bl1)->x, lpoint_get(bl1)->y,
                lpoint_get(tr1)->x, lpoint_get(tr1)->y,
                lpoint_get(bl2)->x, lpoint_get(bl2)->y,
                lpoint_get(tr2)->x, lpoint_get(tr2)->y,
                object_get_name(lobject_get_const(cell))
            );
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_viapoints(lua_State* L)
{
    lcheck_check_numargs_range(L, 5, 7, "geometry.viapoints");
    struct lobject* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    struct lpoint* pt1 = lpoint_checkpoint(L, 4);
    struct lpoint* pt2 = lpoint_checkpoint(L, 5);
    const char* debugstring = lua_tostring(L, 6);
#ifdef OPC_LINT
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.viapoints called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    int xcont = 0;
    int ycont = 0;
    coordinate_t minxspace = 0;
    coordinate_t minyspace = 0;
    int equal_pitch = 0;
    coordinate_t widthclass = 0;
    _get_viacontact_properties(L, 7, &xcont, &ycont, &minxspace, &minyspace, &equal_pitch, &widthclass);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_viapoints(lobject_get_full(L, cell), techstate, metal1, metal2, lpoint_get(pt1), lpoint_get(pt2), minxspace, minyspace, xcont, ycont, equal_pitch, widthclass);
    if(!res)
    {
        coordinate_t x1 = point_getx(lpoint_get(pt1));
        coordinate_t y1 = point_gety(lpoint_get(pt1));
        coordinate_t x2 = point_getx(lpoint_get(pt2));
        coordinate_t y2 = point_gety(lpoint_get(pt2));
        coordinate_t blx = COORD_MIN(x1, x2);
        coordinate_t bly = COORD_MAX(y1, y2);
        coordinate_t trx = COORD_MIN(x1, x2);
        coordinate_t try = COORD_MAX(y1, y2);
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.viapoints: could not fit via from metal %d to metal %d. Area: %d x %d\ndebug info: %s (object: \"%s\")", metal1, metal2, trx - blx, try - bly, debugstring, object_get_name(lobject_get_const(cell)));
        }
        else
        {
            lua_pushfstring(L, "geometry.viapoints: could not fit via from metal %d to metal %d. Area: %d x %d (object: \"%s\")", metal1, metal2, trx - blx, try - bly, object_get_name(lobject_get_const(cell)));
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_viabltr_xcontinuous(lua_State* L)
{
    lcheck_check_numargs_range(L, 5, 7, "geometry.viabltr_xcontinuous");
    struct lobject* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    struct lpoint* bl = lpoint_checkpoint(L, 4);
    struct lpoint* tr = lpoint_checkpoint(L, 5);
    const char* debugstring = lua_tostring(L, 6);
#ifdef OPC_LINT
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.viabltr_xcontinuous called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    _check_rectangle_points(L, bl, tr, "geometry.viabltr_xcontinuous");
    int xcont = 1;
    int ycont = 0;
    coordinate_t minxspace = 0;
    coordinate_t minyspace = 0;
    int equal_pitch = 0;
    coordinate_t widthclass = 0;
    _get_viacontact_properties(L, 7, NULL, NULL, &minxspace, &minyspace, &equal_pitch, &widthclass);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_viabltr(lobject_get_full(L, cell), techstate, metal1, metal2, lpoint_get(bl), lpoint_get(tr), minxspace, minyspace, xcont, ycont, equal_pitch, widthclass);
    if(!res)
    {
        coordinate_t blx = point_getx(lpoint_get(bl));
        coordinate_t bly = point_gety(lpoint_get(bl));
        coordinate_t trx = point_getx(lpoint_get(tr));
        coordinate_t try = point_gety(lpoint_get(tr));
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.viabltr_xcontinuous: could not fit via from metal %d to metal %d. Area: %d x %d\ndebug info: %s (object: \"%s\")", metal1, metal2, trx - blx, try - bly, debugstring, object_get_name(lobject_get_const(cell)));
        }
        else
        {
            lua_pushfstring(L, "geometry.viabltr_xcontinuous: could not fit via from metal %d to metal %d. Area: %d x %d (object: \"%s\")", metal1, metal2, trx - blx, try - bly, object_get_name(lobject_get_const(cell)));
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_viabltr_ycontinuous(lua_State* L)
{
    lcheck_check_numargs_range(L, 5, 7, "geometry.viabltr_ycontinuous");
    struct lobject* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    struct lpoint* bl = lpoint_checkpoint(L, 4);
    struct lpoint* tr = lpoint_checkpoint(L, 5);
    const char* debugstring = lua_tostring(L, 6);
#ifdef OPC_LINT
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.viabltr_ycontinuous called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    _check_rectangle_points(L, bl, tr, "geometry.viabltr_ycontinuous");
    int xcont = 0;
    int ycont = 1;
    coordinate_t minxspace = 0;
    coordinate_t minyspace = 0;
    int equal_pitch = 0;
    coordinate_t widthclass = 0;
    _get_viacontact_properties(L, 7, NULL, NULL, &minxspace, &minyspace, &equal_pitch, &widthclass);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_viabltr(lobject_get_full(L, cell), techstate, metal1, metal2, lpoint_get(bl), lpoint_get(tr), minxspace, minyspace, xcont, ycont, equal_pitch, widthclass);
    if(!res)
    {
        coordinate_t blx = point_getx(lpoint_get(bl));
        coordinate_t bly = point_gety(lpoint_get(bl));
        coordinate_t trx = point_getx(lpoint_get(tr));
        coordinate_t try = point_gety(lpoint_get(tr));
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.viabltr_ycontinuous: could not fit via from metal %d to metal %d. Area: %d x %d\ndebug info: %s (object: \"%s\")", metal1, metal2, trx - blx, try - bly, debugstring, object_get_name(lobject_get_const(cell)));
        }
        else
        {
            lua_pushfstring(L, "geometry.viabltr_ycontinuous: could not fit via from metal %d to metal %d. Area: %d x %d (object: \"%s\")", metal1, metal2, trx - blx, try - bly, object_get_name(lobject_get_const(cell)));
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_viabltr_continuous(lua_State* L)
{
    lcheck_check_numargs_range(L, 5, 7, "geometry.viabltr_continuous");
    struct lobject* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    struct lpoint* bl = lpoint_checkpoint(L, 4);
    struct lpoint* tr = lpoint_checkpoint(L, 5);
    const char* debugstring = lua_tostring(L, 6);
#ifdef OPC_LINT
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.viabltr_continuous called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    _check_rectangle_points(L, bl, tr, "geometry.viabltr_continuous");
    int xcont = 1;
    int ycont = 1;
    coordinate_t minxspace = 0;
    coordinate_t minyspace = 0;
    int equal_pitch = 0;
    coordinate_t widthclass = 0;
    _get_viacontact_properties(L, 7, NULL, NULL, &minxspace, &minyspace, &equal_pitch, &widthclass);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_viabltr(lobject_get_full(L, cell), techstate, metal1, metal2, lpoint_get(bl), lpoint_get(tr), minxspace, minyspace, xcont, ycont, equal_pitch, widthclass);
    if(!res)
    {
        coordinate_t blx = point_getx(lpoint_get(bl));
        coordinate_t bly = point_gety(lpoint_get(bl));
        coordinate_t trx = point_getx(lpoint_get(tr));
        coordinate_t try = point_gety(lpoint_get(tr));
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.viabltr_continuous: could not fit via from metal %d to metal %d. Area: %d x %d\ndebug info: %s (object: \"%s\")", metal1, metal2, trx - blx, try - bly, debugstring, object_get_name(lobject_get_const(cell)));
        }
        else
        {
            lua_pushfstring(L, "geometry.viabltr_continuous: could not fit via from metal %d to metal %d. Area: %d x %d (object: \"%s\")", metal1, metal2, trx - blx, try - bly, object_get_name(lobject_get_const(cell)));
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_viabarebltr_xcontinuous(lua_State* L)
{
    lcheck_check_numargs2(L, 5, 6, "geometry.viabarebltr_xcontinuous");
    struct lobject* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    struct lpoint* bl = lpoint_checkpoint(L, 4);
    struct lpoint* tr = lpoint_checkpoint(L, 5);
    const char* debugstring = lua_tostring(L, 6);
#ifdef OPC_LINT
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.viabarebltr_xcontinuous called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    _check_rectangle_points(L, bl, tr, "geometry.viabarebltr_xcontinuous");
    int xcont = 1;
    int ycont = 0;
    coordinate_t minxspace = 0;
    coordinate_t minyspace = 0;
    int equal_pitch = 0;
    coordinate_t widthclass = 0;
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_viabarebltr(lobject_get_full(L, cell), techstate, metal1, metal2, lpoint_get(bl), lpoint_get(tr), minxspace, minyspace, xcont, ycont, equal_pitch, widthclass);
    if(!res)
    {
        coordinate_t blx = point_getx(lpoint_get(bl));
        coordinate_t bly = point_gety(lpoint_get(bl));
        coordinate_t trx = point_getx(lpoint_get(tr));
        coordinate_t try = point_gety(lpoint_get(tr));
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.viabarebltr_xcontinuous: could not fit via from metal %d to metal %d. Area: %d x %d\ndebug info: %s (object: \"%s\")", metal1, metal2, trx - blx, try - bly, debugstring, object_get_name(lobject_get_const(cell)));
        }
        else
        {
            lua_pushfstring(L, "geometry.viabarebltr_xcontinuous: could not fit via from metal %d to metal %d. Area: %d x %d (object: \"%s\")", metal1, metal2, trx - blx, try - bly, object_get_name(lobject_get_const(cell)));
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_viabarebltr_ycontinuous(lua_State* L)
{
    lcheck_check_numargs2(L, 5, 6, "geometry.viabarebltr_ycontinuous");
    struct lobject* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    struct lpoint* bl = lpoint_checkpoint(L, 4);
    struct lpoint* tr = lpoint_checkpoint(L, 5);
    const char* debugstring = lua_tostring(L, 6);
#ifdef OPC_LINT
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.viabarebltr_ycontinuous called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    _check_rectangle_points(L, bl, tr, "geometry.viabarebltr_ycontinuous");
    int xcont = 0;
    int ycont = 1;
    coordinate_t minxspace = 0;
    coordinate_t minyspace = 0;
    int equal_pitch = 0;
    coordinate_t widthclass = 0;
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_viabarebltr(lobject_get_full(L, cell), techstate, metal1, metal2, lpoint_get(bl), lpoint_get(tr), minxspace, minyspace, xcont, ycont, equal_pitch, widthclass);
    if(!res)
    {
        coordinate_t blx = point_getx(lpoint_get(bl));
        coordinate_t bly = point_gety(lpoint_get(bl));
        coordinate_t trx = point_getx(lpoint_get(tr));
        coordinate_t try = point_gety(lpoint_get(tr));
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.viabarebltr_ycontinuous: could not fit via from metal %d to metal %d. Area: %d x %d\ndebug info: %s (object: \"%s\")", metal1, metal2, trx - blx, try - bly, debugstring, object_get_name(lobject_get_const(cell)));
        }
        else
        {
            lua_pushfstring(L, "geometry.viabarebltr_ycontinuous: could not fit via from metal %d to metal %d. Area: %d x %d (object: \"%s\")", metal1, metal2, trx - blx, try - bly, object_get_name(lobject_get_const(cell)));
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_viabarebltr_continuous(lua_State* L)
{
    lcheck_check_numargs2(L, 5, 6, "geometry.viabarebltr_continuous");
    struct lobject* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    struct lpoint* bl = lpoint_checkpoint(L, 4);
    struct lpoint* tr = lpoint_checkpoint(L, 5);
    const char* debugstring = lua_tostring(L, 6);
#ifdef OPC_LINT
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.viabarebltr_continuous called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    _check_rectangle_points(L, bl, tr, "geometry.viabarebltr_continuous");
    int xcont = 1;
    int ycont = 1;
    coordinate_t minxspace = 0;
    coordinate_t minyspace = 0;
    int equal_pitch = 0;
    coordinate_t widthclass = 0;
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_viabarebltr(lobject_get_full(L, cell), techstate, metal1, metal2, lpoint_get(bl), lpoint_get(tr), minxspace, minyspace, xcont, ycont, equal_pitch, widthclass);
    if(!res)
    {
        coordinate_t blx = point_getx(lpoint_get(bl));
        coordinate_t bly = point_gety(lpoint_get(bl));
        coordinate_t trx = point_getx(lpoint_get(tr));
        coordinate_t try = point_gety(lpoint_get(tr));
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.viabarebltr_continuous: could not fit via from metal %d to metal %d. Area: %d x %d\ndebug info: %s (object: \"%s\")", metal1, metal2, trx - blx, try - bly, debugstring, object_get_name(lobject_get_const(cell)));
        }
        else
        {
            lua_pushfstring(L, "geometry.viabarebltr_continuous: could not fit via from metal %d to metal %d. Area: %d x %d (object: \"%s\")", metal1, metal2, trx - blx, try - bly, object_get_name(lobject_get_const(cell)));
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_contactbltr(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* region = luaL_checkstring(L, 2);
    struct lpoint* bl = lpoint_checkpoint(L, 3);
    struct lpoint* tr = lpoint_checkpoint(L, 4);
    _check_rectangle_points(L, bl, tr, "geometry.contactbltr");
    const char* debugstring = lua_tostring(L, 5);
#ifdef OPC_LINT
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.contactbltr called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    int xcont = 0;
    int ycont = 0;
    coordinate_t minxspace = 0;
    coordinate_t minyspace = 0;
    int equal_pitch = 0;
    coordinate_t widthclass = 0;
    _get_viacontact_properties(L, 6, &xcont, &ycont, &minxspace, &minyspace, &equal_pitch, &widthclass);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_contactbltr(
        lobject_get_full(L, cell),
        techstate,
        region,
        lpoint_get(bl), lpoint_get(tr),
        xcont, ycont,
        equal_pitch,
        widthclass
    );
    if(!res)
    {
        const struct point* blp = lpoint_get(bl);
        const struct point* trp = lpoint_get(tr);
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.contactbltr: could not fit contact from %s to metal 1 (width = %d, height = %d)\ndebug info: %s (object: \"%s\")", region, trp->x - blp->x, trp->y - blp->y, debugstring, object_get_name(lobject_get_const(cell)));
        }
        else
        {
            lua_pushfstring(L, "geometry.contactbltr: could not fit contact from %s to metal 1 (width = %d, height = %d) (object: \"%s\")", region, trp->x - blp->x, trp->y - blp->y, object_get_name(lobject_get_const(cell)));
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_contactbltrov(lua_State* L)
{
    lcheck_check_numargs2(L, 6, 7, "geometry.contactbltrov");
    struct lobject* cell = lobject_check(L, 1);
    const char* region = luaL_checkstring(L, 2);
    struct lpoint* bl1 = lpoint_checkpoint(L, 3);
    struct lpoint* tr1 = lpoint_checkpoint(L, 4);
    struct lpoint* bl2 = lpoint_checkpoint(L, 5);
    struct lpoint* tr2 = lpoint_checkpoint(L, 6);
    const char* debugstring = lua_tostring(L, 7);
#ifdef OPC_LINT
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.contactbltrov called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    _check_rectangle_points(L, bl1, tr1, "geometry.contactbltrov");
    _check_rectangle_points(L, bl2, tr2, "geometry.contactbltrov");
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_contactbltrov(lobject_get_full(L, cell), techstate, region, lpoint_get(bl1), lpoint_get(tr1), lpoint_get(bl2), lpoint_get(tr2));
    if(!res)
    {
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.contactbltrov: could not fit contact from %s to metal 1. Areas: (%d, %d)/(%d, %d) and (%d, %d)/(%d, %d)\ndebug info: %s (object: \"%s\")",
                region,
                lpoint_get(bl1)->x, lpoint_get(bl1)->y,
                lpoint_get(tr1)->x, lpoint_get(tr1)->y,
                lpoint_get(bl2)->x, lpoint_get(bl2)->y,
                lpoint_get(tr2)->x, lpoint_get(tr2)->y,
                debugstring,
                object_get_name(lobject_get_const(cell))
            );
        }
        else
        {
            lua_pushfstring(L, "geometry.contactbltrov: could not fit contact from %s to metal 1. Areas: (%d, %d)/(%d, %d) and (%d, %d)/(%d, %d) (object: \"%s\")",
                region,
                lpoint_get(bl1)->x, lpoint_get(bl1)->y,
                lpoint_get(tr1)->x, lpoint_get(tr1)->y,
                lpoint_get(bl2)->x, lpoint_get(bl2)->y,
                lpoint_get(tr2)->x, lpoint_get(tr2)->y,
                object_get_name(lobject_get_const(cell))
            );
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_contactbltr2(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* region = luaL_checkstring(L, 2);
    struct lpoint* bl1 = lpoint_checkpoint(L, 3);
    struct lpoint* tr1 = lpoint_checkpoint(L, 4);
    struct lpoint* bl2 = lpoint_checkpoint(L, 5);
    struct lpoint* tr2 = lpoint_checkpoint(L, 6);
    _check_rectangle_points(L, bl1, tr1, "geometry.contactbltr2");
    _check_rectangle_points(L, bl2, tr2, "geometry.contactbltr2");
    const char* debugstring = lua_tostring(L, 7);
#ifdef OPC_LINT
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.contactbltr2 called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    coordinate_t minxspace = 0;
    coordinate_t minyspace = 0;
    coordinate_t widthclass = 0;
    _get_viacontact_properties(L, 8, NULL, NULL, &minxspace, &minyspace, NULL, &widthclass);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_contactbltr2(
        lobject_get_full(L, cell),
        techstate,
        region,
        lpoint_get(bl1), lpoint_get(tr1),
        lpoint_get(bl2), lpoint_get(tr2),
        widthclass
    );
    if(!res)
    {
        const struct point* blp1 = lpoint_get(bl1);
        const struct point* trp1 = lpoint_get(tr1);
        const struct point* blp2 = lpoint_get(bl2);
        const struct point* trp2 = lpoint_get(tr2);
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.contactbltr2: could not fit contact from %s to metal 1 (width1 = %d, height1 = %d, width2 = %d, height2 = %d)\ndebug info: %s (object: \"%s\")", region, trp1->x - blp1->x, trp1->y - blp1->y, trp2->x - blp2->x, trp2->y - blp2->y, debugstring, object_get_name(lobject_get_const(cell)));
        }
        else
        {
            lua_pushfstring(L, "geometry.contactbltr2: could not fit contact from %s to metal 1 (width1 = %d, height1 = %d, width2 = %d, height2 = %d) (object: \"%s\")", region, trp1->x - blp1->x, trp1->y - blp1->y, trp2->x - blp2->x, trp2->y - blp2->y, object_get_name(lobject_get_const(cell)));
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_contactbarebltr(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* region = luaL_checkstring(L, 2);
    struct lpoint* bl = lpoint_checkpoint(L, 3);
    struct lpoint* tr = lpoint_checkpoint(L, 4);
    _check_rectangle_points(L, bl, tr, "geometry.contactbarebltr");
    const char* debugstring = lua_tostring(L, 5);
#ifdef OPC_LINT
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.contactbarebltr called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    int xcont = 0;
    int ycont = 0;
    coordinate_t minxspace = 0;
    coordinate_t minyspace = 0;
    int equal_pitch = 0;
    coordinate_t widthclass = 0;
    _get_viacontact_properties(L, 6, &xcont, &ycont, &minxspace, &minyspace, &equal_pitch, &widthclass);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_contactbarebltr(
        lobject_get_full(L, cell),
        techstate,
        region,
        lpoint_get(bl), lpoint_get(tr),
        xcont, ycont,
        equal_pitch,
        widthclass
    );
    if(!res)
    {
        coordinate_t blx = point_getx(lpoint_get(bl));
        coordinate_t bly = point_gety(lpoint_get(bl));
        coordinate_t trx = point_getx(lpoint_get(tr));
        coordinate_t try = point_gety(lpoint_get(tr));
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.contactbarebltr: could not fit contact from %s to metal 1. Area: %d x %d\ndebug info: %s (object: \"%s\")", region, trx - blx, try - bly, debugstring, object_get_name(lobject_get_const(cell)));
        }
        else
        {
            lua_pushfstring(L, "geometry.contactbarebltr: could not fit contact from %s to metal 1. Area: %d x %d (object: \"%s\")", region, trx - blx, try - bly, object_get_name(lobject_get_const(cell)));
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_contactbarebltr2(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    const char* region = luaL_checkstring(L, 2);
    struct lpoint* bl1 = lpoint_checkpoint(L, 3);
    struct lpoint* tr1 = lpoint_checkpoint(L, 4);
    struct lpoint* bl2 = lpoint_checkpoint(L, 5);
    struct lpoint* tr2 = lpoint_checkpoint(L, 6);
    _check_rectangle_points(L, bl1, tr1, "geometry.contactbarebltr2");
    _check_rectangle_points(L, bl2, tr2, "geometry.contactbarebltr2");
    const char* debugstring = lua_tostring(L, 7);
#ifdef OPC_LINT
    if(!debugstring)
    {
        lua_pushfstring(L, "geometry.contactbarebltr2 called without debug string (object: \"%s\")", object_get_name(lobject_get_const(cell)));
        lua_error(L);
    }
#endif
    coordinate_t minxspace = 0;
    coordinate_t minyspace = 0;
    coordinate_t widthclass = 0;
    _get_viacontact_properties(L, 8, NULL, NULL, &minxspace, &minyspace, NULL, &widthclass);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_contactbarebltr2(
        lobject_get_full(L, cell),
        techstate,
        region,
        lpoint_get(bl1), lpoint_get(tr1),
        lpoint_get(bl2), lpoint_get(tr2),
        widthclass
    );
    if(!res)
    {
        const struct point* blp1 = lpoint_get(bl1);
        const struct point* trp1 = lpoint_get(tr1);
        const struct point* blp2 = lpoint_get(bl2);
        const struct point* trp2 = lpoint_get(tr2);
        if(debugstring)
        {
            lua_pushfstring(L, "geometry.contactbarebltr2: could not fit contact from %s to metal 1 (width1 = %d, height1 = %d, width2 = %d, height2 = %d)\ndebug info: %s (object: \"%s\")", region, trp1->x - blp1->x, trp1->y - blp1->y, trp2->x - blp2->x, trp2->y - blp2->y, debugstring, object_get_name(lobject_get_const(cell)));
        }
        else
        {
            lua_pushfstring(L, "geometry.contactbarebltr2: could not fit contact from %s to metal 1 (width1 = %d, height1 = %d, width2 = %d, height2 = %d) (object: \"%s\")", region, trp1->x - blp1->x, trp1->y - blp1->y, trp2->x - blp2->x, trp2->y - blp2->y, object_get_name(lobject_get_const(cell)));
        }
        lua_error(L);
    }
    return 0;
}

static int lgeometry_cross(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    ucoordinate_t width = luaL_checkinteger(L, 3);
    ucoordinate_t height = luaL_checkinteger(L, 4);
    ucoordinate_t crosssize = luaL_checkinteger(L, 5);
    geometry_cross(lobject_get_full(L, cell), layer, width, height, crosssize);
    return 0;
}

static int lgeometry_ring(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* center = lpoint_checkpoint(L, 3);
    ucoordinate_t width = luaL_checkinteger(L, 4);
    ucoordinate_t height = luaL_checkinteger(L, 5);
    ucoordinate_t ringwidth = luaL_checkinteger(L, 6);
    geometry_ring(lobject_get_full(L, cell), layer, lpoint_get(center)->x, lpoint_get(center)->y, width, height, ringwidth);
    return 0;
}

static int lgeometry_unequal_ring(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* center = lpoint_checkpoint(L, 3);
    ucoordinate_t width = luaL_checkinteger(L, 4);
    ucoordinate_t height = luaL_checkinteger(L, 5);
    ucoordinate_t leftwidth = luaL_checkinteger(L, 6);
    ucoordinate_t rightwidth = luaL_checkinteger(L, 7);
    ucoordinate_t topwidth = luaL_checkinteger(L, 8);
    ucoordinate_t bottomwidth = luaL_checkinteger(L, 9);
    geometry_unequal_ring(lobject_get_full(L, cell), layer, lpoint_get(center)->x, lpoint_get(center)->y, width, height, leftwidth, rightwidth, topwidth, bottomwidth);
    return 0;
}

static int lgeometry_unequal_ring_pts(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* outerbl = lpoint_checkpoint(L, 3);
    struct lpoint* outertr = lpoint_checkpoint(L, 4);
    struct lpoint* innerbl = lpoint_checkpoint(L, 5);
    struct lpoint* innertr = lpoint_checkpoint(L, 6);
    geometry_unequal_ring_pts(lobject_get_full(L, cell), layer, lpoint_get(outerbl), lpoint_get(outertr), lpoint_get(innerbl), lpoint_get(innertr));
    return 0;
}

static int lgeometry_curve(lua_State* L)
{
    struct lobject* lobject = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* origin = lpoint_checkpoint(L, 3);
    unsigned int grid = luaL_checkinteger(L, 5);
    int allow45 = lua_toboolean(L, 6);
    struct shape* S = shape_create_curve(layer, lpoint_get(origin)->x, lpoint_get(origin)->y, grid, allow45);

    lua_len(L, 4);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);

    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 4, i);
        lua_getfield(L, -1, "type");
        const char* type = lua_tostring(L, -1);
        if(strcmp(type, "lineto") == 0)
        {
            lua_getfield(L, -2, "pt");
            struct lpoint* pt = lpoint_checkpoint(L, -1);
            shape_curve_add_line_segment(S, lpoint_get(pt));
            lua_pop(L, 1); // pop points
        }
        else if(strcmp(type, "arcto") == 0)
        {
            lua_getfield(L, -2, "startangle");
            double startangle = lua_tonumber(L, -1);
            lua_getfield(L, -3, "endangle");
            double endangle = lua_tonumber(L, -1);
            lua_getfield(L, -4, "radius");
            coordinate_t radius = lua_tointeger(L, -1);
            lua_getfield(L, -5, "clockwise");
            int clockwise = lua_toboolean(L, -1);
            shape_curve_add_arc_segment(S, startangle, endangle, radius, clockwise);
            lua_pop(L, 3); // pop points
        }
        else if(strcmp(type, "cubicto") == 0)
        {
            lua_getfield(L, -2, "cpt1");
            struct lpoint* lcpt1 = lpoint_checkpoint(L, -1);
            const struct point* cpt1 = lpoint_get(lcpt1);
            lua_pop(L, 1);
            lua_getfield(L, -2, "cpt2");
            struct lpoint* lcpt2 = lpoint_checkpoint(L, -1);
            const struct point* cpt2 = lpoint_get(lcpt2);
            lua_pop(L, 1);
            lua_getfield(L, -2, "endpt");
            struct lpoint* lendpt = lpoint_checkpoint(L, -1);
            const struct point* endpt = lpoint_get(lendpt);
            lua_pop(L, 1);
            shape_curve_add_cubic_bezier_segment(S, cpt1, cpt2, endpt);
        }
        else
        {
            lua_pushfstring(L, "unknown curve segment: %s (object: \"%s\")", type, object_get_name(lobject_get_const(lobject)));
            lua_error(L);
        }
        lua_pop(L, 1); // pop type
        lua_pop(L, 1); // pop segment
    }

    object_add_shape(lobject_get_full(L, lobject), S);
    return 0;
}

static int lgeometry_curve_rasterized(lua_State* L)
{
    struct lobject* lobject = lobject_check(L, 1);
    struct generics* layer = generics_check_generics(L, 2);
    struct lpoint* origin = lpoint_checkpoint(L, 3);
    unsigned int grid = luaL_checkinteger(L, 5);
    int allow45 = lua_toboolean(L, 6);
    struct shape* S = shape_create_curve(layer, lpoint_get(origin)->x, lpoint_get(origin)->y, grid, allow45);

    lua_len(L, 4);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);

    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 4, i);
        lua_getfield(L, -1, "type");
        const char* type = lua_tostring(L, -1);
        if(strcmp(type, "lineto") == 0)
        {
            lua_getfield(L, -2, "pt");
            struct lpoint* pt = lpoint_checkpoint(L, -1);
            shape_curve_add_line_segment(S, lpoint_get(pt));
            lua_pop(L, 1); // pop points
        }
        else if(strcmp(type, "arcto") == 0)
        {
            lua_getfield(L, -2, "startangle");
            double startangle = lua_tonumber(L, -1);
            lua_getfield(L, -3, "endangle");
            double endangle = lua_tonumber(L, -1);
            lua_getfield(L, -4, "radius");
            coordinate_t radius = lua_tointeger(L, -1);
            lua_getfield(L, -5, "clockwise");
            int clockwise = lua_toboolean(L, -1);
            shape_curve_add_arc_segment(S, startangle, endangle, radius, clockwise);
            lua_pop(L, 3); // pop points
        }
        else if(strcmp(type, "cubicto") == 0)
        {
            lua_getfield(L, -2, "cpt1");
            struct lpoint* lcpt1 = lpoint_checkpoint(L, -1);
            const struct point* cpt1 = lpoint_get(lcpt1);
            lua_pop(L, 1);
            lua_getfield(L, -2, "cpt2");
            struct lpoint* lcpt2 = lpoint_checkpoint(L, -1);
            const struct point* cpt2 = lpoint_get(lcpt2);
            lua_pop(L, 1);
            lua_getfield(L, -2, "endpt");
            struct lpoint* lendpt = lpoint_checkpoint(L, -1);
            const struct point* endpt = lpoint_get(lendpt);
            lua_pop(L, 1);
            shape_curve_add_cubic_bezier_segment(S, cpt1, cpt2, endpt);
        }
        else
        {
            lua_pushfstring(L, "unknown curve segment: %s (object: \"%s\")", type, object_get_name(lobject_get_const(lobject)));
            lua_error(L);
        }
        lua_pop(L, 1); // pop type
        lua_pop(L, 1); // pop segment
    }

    shape_rasterize_curve_inline(S);

    object_add_shape(lobject_get_full(L, lobject), S);
    return 0;
}

static int lgeometry_get_side_path_points(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "geometry.get_side_path_points");
    if(!lua_istable(L, 1))
    {
        lua_pushfstring(L, "geometry.get_side_path_points: list of points (first argument) is not a table");
        lua_error(L);
    }
    lua_len(L, 1);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    coordinate_t width = luaL_checkinteger(L, 2);

    struct vector* points = vector_create(len, NULL); // non-owning vector
    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 1, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        vector_append(points, (void*)lpoint_get(pt)); // non-const, but vector is non-owning and points are not modified
        lua_pop(L, 1);
    }
    struct vector* newpts = geometry_get_side_path_points(points, width);
    vector_destroy(points);
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(newpts); ++i)
    {
        struct point* pt = vector_get(newpts, i);
        lpoint_create_internal_xy(L, point_getx(pt), point_gety(pt));
        lua_rawseti(L, -2, i + 1);
    }
    vector_destroy(newpts);
    return 1;
}

static int lgeometry_offset_polygon_points(lua_State* L)
{
    lcheck_check_numargs1(L, 2, "geometry.offset_polygon_points");
    if(!lua_istable(L, 1))
    {
        lua_pushstring(L, "geometry.offset_polygon_points: list of polygon points (first argument) is not a table");
        lua_error(L);
    }
    lua_len(L, 1);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    coordinate_t offset = luaL_checkinteger(L, 2);

    struct vector* points = vector_create(len, NULL); // non-owning vector
    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 1, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        vector_append(points, (void*)lpoint_get(pt)); // non-const, but vector is non-owning and points are not modified
        lua_pop(L, 1);
    }
    struct vector* newpts = geometry_offset_polygon_points(points, offset);
    vector_destroy(points);
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(newpts); ++i)
    {
        struct point* pt = vector_get(newpts, i);
        lpoint_create_internal_xy(L, point_getx(pt), point_gety(pt));
        lua_rawseti(L, -2, i + 1);
    }
    vector_destroy(newpts);
    return 1;
}

static int lgeometry_path_points_to_polygon(lua_State* L)
{
    lcheck_check_numargs2(L, 2, 3, "geometry.path_points_to_polygon");
    if(!lua_istable(L, 1))
    {
        lua_pushstring(L, "geometry.path_points_to_polygon: list of points (first argument) is not a table");
        lua_error(L);
    }
    lua_len(L, 1);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    if(len < 2)
    {
        lua_pushstring(L, "geometry.path_points_to_polygon: there must be at least two path points");
        lua_error(L);
    }
    coordinate_t width = luaL_checkinteger(L, 2);
    if(width == 0)
    {
        lua_pushstring(L, "geometry.path_points_to_polygon: width can't be zero");
        lua_error(L);
    }
    if(width % 2 != 0)
    {
        lua_pushfstring(L, "geometry.path_points_to_polygon: width is odd (%d)", width);
        lua_error(L);
    }

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 3, &bgnext, &endext, width);

    struct vector* points = vector_create(len, point_destroy);
    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 1, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        vector_append(points, point_copy(lpoint_get(pt)));
        lua_pop(L, 1);
    }

    struct vector* newpts = geometry_path_points_to_polygon(points, width, 1);
    vector_destroy(points);
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(newpts); ++i)
    {
        struct point* pt = vector_get(newpts, i);
        lpoint_create_internal_xy(L, point_getx(pt), point_gety(pt));
        lua_rawseti(L, -2, i + 1);
    }
    vector_destroy(newpts);
    return 1;
}

static int lcurve_lineto(lua_State* L)
{
    if(lua_gettop(L) == 1)
    {
        lua_newtable(L);
        lua_pushstring(L, "lineto");
        lua_setfield(L, -2, "type");
        lua_pushvalue(L, 1);
        lua_setfield(L, -2, "pt");
    }
    else
    {
        lua_newtable(L);
        lua_pushstring(L, "lineto");
        lua_setfield(L, -2, "type");
        coordinate_t x = lpoint_checkcoordinate(L, 1, "x");
        coordinate_t y = lpoint_checkcoordinate(L, 2, "y");
        lpoint_create_internal_xy(L, x, y);
        lua_setfield(L, -2, "pt");
    }
    return 1;
}

static int lcurve_arcto(lua_State* L)
{
    lua_newtable(L);
    lua_pushstring(L, "arcto");
    lua_setfield(L, -2, "type");
    lua_pushvalue(L, 1);
    lua_setfield(L, -2, "startangle");
    lua_pushvalue(L, 2);
    lua_setfield(L, -2, "endangle");
    lua_pushvalue(L, 3);
    lua_setfield(L, -2, "radius");
    lua_pushvalue(L, 4);
    lua_setfield(L, -2, "clockwise");
    return 1;
}

static int lcurve_cubicto(lua_State* L)
{
    lua_newtable(L);
    lua_pushstring(L, "cubicto");
    lua_setfield(L, -2, "type");
    lua_pushvalue(L, 1);
    lua_setfield(L, -2, "cpt1");
    lua_pushvalue(L, 2);
    lua_setfield(L, -2, "cpt2");
    lua_pushvalue(L, 3);
    lua_setfield(L, -2, "endpt");
    return 1;
}

int open_lgeometry_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "rectanglebltr",                              lgeometry_rectanglebltr                                         },
        { "rectangleblwh",                              lgeometry_rectangleblwh                                         },
        { "rectanglepoints",                            lgeometry_rectanglepoints                                       },
        { "rectangleareaanchor",                        lgeometry_rectangleareaanchor                                   },
        { "rectanglearray",                             lgeometry_rectanglearray                                        },
        { "slotted_rectangle",                          lgeometry_slotted_rectangle                                     },
        { "rectanglepath",                              lgeometry_rectanglepath                                         },
        { "rectanglevlines",                            lgeometry_rectanglelines_vertical                               },
        { "rectanglevlines_width_space",                lgeometry_rectanglelines_vertical_width_space                   },
        { "rectanglevlines_numlines_width",             lgeometry_rectanglelines_vertical_numlines_width                },
        { "rectanglevlines_settings",                   lgeometry_rectanglelines_vertical_settings                      },
        { "rectanglevlines_width_space_settings",       lgeometry_rectanglelines_vertical_width_space_settings          },
        { "rectanglevlines_numlines_width_settings",    lgeometry_rectanglelines_vertical_numlines_width_settings       },
        { "rectanglehlines",                            lgeometry_rectanglelines_horizontal                             },
        { "rectanglehlines_height_space",               lgeometry_rectanglelines_horizontal_height_space                },
        { "rectanglehlines_settings",                   lgeometry_rectanglelines_horizontal_settings                    },
        { "rectanglehlines_height_space_settings",      lgeometry_rectanglelines_horizontal_height_space_settings       },
        { "rectanglehlines_numlines_height_settings",   lgeometry_rectanglelines_horizontal_numlines_height_settings    },
        { "rectangle_fill_in_boundary",                 lgeometry_rectangle_fill_in_boundary                            },
        { "polygon",                                    lgeometry_polygon                                               },
        { "path",                                       lgeometry_path                                                  },
        { "path_manhatten",                             lgeometry_path_manhatten                                        },
        { "path_2x",                                    lgeometry_path_2x                                               },
        { "path_2x_polygon",                            lgeometry_path_2x_polygon                                       },
        { "path_2y",                                    lgeometry_path_2y                                               },
        { "path_2y_polygon",                            lgeometry_path_2y_polygon                                       },
        { "path_3x",                                    lgeometry_path_3x                                               },
        { "path_3x_polygon",                            lgeometry_path_3x_polygon                                       },
        { "path_3x_diagonal",                           lgeometry_path_3x_diagonal                                      },
        { "path_3x_diagonal_polygon",                   lgeometry_path_3x_diagonal_polygon                              },
        { "path_3y",                                    lgeometry_path_3y                                               },
        { "path_3y_polygon",                            lgeometry_path_3y_polygon                                       },
        { "path_3y_diagonal",                           lgeometry_path_3y_diagonal                                      },
        { "path_3y_diagonal_polygon",                   lgeometry_path_3y_diagonal_polygon                              },
        { "path_cshape",                                lgeometry_path_cshape                                           },
        { "path_ushape",                                lgeometry_path_ushape                                           },
        { "path_polygon",                               lgeometry_path_polygon                                          },
        { "path_points_xy",                             lgeometry_path_points_xy                                        },
        { "path_points_yx",                             lgeometry_path_points_yx                                        },
        { "check_viabltr",                              lgeometry_check_viabltr                                         },
        { "check_viabltrov",                            lgeometry_check_viabltrov                                       },
        { "calculate_viabltr",                          lgeometry_calculate_viabltr                                     },
        { "calculate_viabltr2",                         lgeometry_calculate_viabltr2                                    },
        { "viabltr",                                    lgeometry_viabltr                                               },
        { "viabltrov",                                  lgeometry_viabltrov                                             },
        { "viabltr2",                                   lgeometry_viabltr2                                              },
        { "viabarebltr",                                lgeometry_viabarebltr                                           },
        { "viabarebltrov",                              lgeometry_viabarebltrov                                         },
        { "viabarebltr2",                               lgeometry_viabarebltr2                                          },
        { "viapoints",                                  lgeometry_viapoints                                             },
        { "viabltr_xcontinuous",                        lgeometry_viabltr_xcontinuous                                   },
        { "viabltr_ycontinuous",                        lgeometry_viabltr_ycontinuous                                   },
        { "viabltr_continuous",                         lgeometry_viabltr_continuous                                    },
        { "viabarebltr_xcontinuous",                    lgeometry_viabarebltr_xcontinuous                               },
        { "viabarebltr_ycontinuous",                    lgeometry_viabarebltr_ycontinuous                               },
        { "viabarebltr_continuous",                     lgeometry_viabarebltr_continuous                                },
        { "contactbltr",                                lgeometry_contactbltr                                           },
        { "contactbltrov",                              lgeometry_contactbltrov                                         },
        { "contactbltr2",                               lgeometry_contactbltr2                                          },
        { "contactbarebltr2",                           lgeometry_contactbarebltr2                                      },
        { "contactbarebltr",                            lgeometry_contactbarebltr                                       },
        { "cross",                                      lgeometry_cross                                                 },
        { "ring",                                       lgeometry_ring                                                  },
        { "unequal_ring",                               lgeometry_unequal_ring                                          },
        { "unequal_ring_pts",                           lgeometry_unequal_ring_pts                                      },
        { "curve",                                      lgeometry_curve                                                 },
        { "curve_rasterized",                           lgeometry_curve_rasterized                                      },
        { "get_side_path_points",                       lgeometry_get_side_path_points                                  },
        { "offset_polygon_points",                      lgeometry_offset_polygon_points                                 },
        { "path_points_to_polygon",                     lgeometry_path_points_to_polygon                                },
        { NULL,                                         NULL                                                            }
    };
    luaL_setfuncs(L, modfuncs, 0);

    lua_setglobal(L, LGEOMETRYMODULE);

    lua_newtable(L);
    static const luaL_Reg curvefuncs[] =
    {
        { "lineto",  lcurve_lineto  },
        { "arcto",   lcurve_arcto   },
        { "cubicto", lcurve_cubicto },
        { NULL,      NULL           }
    };
    luaL_setfuncs(L, curvefuncs, 0);

    lua_setglobal(L, "curve");
    return 0;
}
