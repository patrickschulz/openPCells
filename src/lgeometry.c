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
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
    struct lpoint* bl = lpoint_checkpoint(L, 3);
    struct lpoint* tr = lpoint_checkpoint(L, 4);
    _check_rectangle_points(L, bl, tr, "geometry.rectanglebltr");
    ucoordinate_t xrep = luaL_optinteger(L, 5, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 6, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 7, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 8, 0);
    geometry_rectanglebltr(lobject_get(cell), layer, lpoint_get(bl), lpoint_get(tr), xrep, yrep, xpitch, ypitch);
    return 0;
}

static int lgeometry_rectangle(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
    coordinate_t width = lua_tointeger(L, 3);
    coordinate_t height = lua_tointeger(L, 4);
    coordinate_t xshift = luaL_optinteger(L, 5, 0);
    coordinate_t yshift = luaL_optinteger(L, 6, 0);
    ucoordinate_t xrep = luaL_optinteger(L, 7, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 8, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 9, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 10, 0);
    geometry_rectangle(lobject_get(cell), layer, width, height, xshift, yshift, xrep, yrep, xpitch, ypitch);
    return 0;
}

static int lgeometry_rectanglepoints(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
    struct lpoint* pt1 = lpoint_checkpoint(L, 3);
    struct lpoint* pt2 = lpoint_checkpoint(L, 4);
    ucoordinate_t xrep = luaL_optinteger(L, 5, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 6, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 7, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 8, 0);
    geometry_rectanglepoints(lobject_get(cell), layer, lpoint_get(pt1), lpoint_get(pt2), xrep, yrep, xpitch, ypitch);
    return 0;
}

static int lgeometry_polygon(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
    lua_len(L, 3);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);

    const point_t** points = calloc(len, sizeof(*points));
    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        points[i - 1] = lpoint_get(pt);
        lua_pop(L, 1);
    }
    geometry_polygon(lobject_get(cell), layer, points, len);
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
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
    lua_len(L, 3);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    coordinate_t width = luaL_checkinteger(L, 4);
    if(width == 0)
    {
        lua_pushstring(L, "geometry.path: width can't be zero");
        lua_error(L);
    }
    if(width % 2 != 0)
    {
        lua_pushfstring(L, "geometry.path: width is odd (%d)", width);
        lua_error(L);
    }

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 5, &bgnext, &endext);

    const point_t** points = calloc(len, sizeof(*points));
    for(unsigned int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        points[i - 1] = lpoint_get(pt);
        lua_pop(L, 1);
    }
    geometry_path(lobject_get(cell), layer, points, len, width, bgnext, endext);
    free(points);
    return 0;
}

static int lgeometry_rectanglepath(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
    struct lpoint* pt1 = lpoint_checkpoint(L, 3);
    struct lpoint* pt2 = lpoint_checkpoint(L, 4);
    coordinate_t width = lua_tointeger(L, 5);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 6, &bgnext, &endext);

    const point_t* points[2] = {
        lpoint_get(pt1),
        lpoint_get(pt2),
    };
    geometry_path(lobject_get(cell), layer, points, 2, width, bgnext, endext);
    return 0;
}

static int lgeometry_path_manhatten(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
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
    struct lpoint* pt = lpoint_checkpoint(L, -1);
    points[0] = point_create(lpoint_get(pt)->x, lpoint_get(pt)->y);
    //coordinate_t lastx = lpoint_get(pt)->x;
    coordinate_t lasty = lpoint_get(pt)->y;
    lua_pop(L, 1);

    for(unsigned int i = 2; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        points[2 * (i - 2) + 1] = point_create(lpoint_get(pt)->x, lasty);
        points[2 * (i - 2) + 2] = point_create(lpoint_get(pt)->x, lpoint_get(pt)->y);
        //lastx = lpoint_get(pt)->x;
        lasty = lpoint_get(pt)->y;
        lua_pop(L, 1);
    }

    geometry_path(lobject_get(cell), layer, (const point_t**)points, numpoints, width, bgnext, endext);
    for(unsigned int i = 0; i < numpoints; ++i)
    {
        point_destroy(points[i]);
    }
    free(points);
    return 0;
}

/*
static int lgeometry_path_3x(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
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
    struct lpoint* pt = lpoint_checkpoint(L, -1);
    points[0] = point_create(lpoint_get(pt)->x, lpoint_get(pt)->y);
    //coordinate_t lastx = lpoint_get(pt)->x;
    coordinate_t lasty = lpoint_get(pt)->y;
    lua_pop(L, 1);

    for(unsigned int i = 2; i <= len; ++i)
    {
        lua_rawgeti(L, 3, i);
        struct lpoint* pt = lpoint_checkpoint(L, -1);
        points[2 * (i - 2) + 1] = point_create(lpoint_get(pt)->x, lasty);
        points[2 * (i - 2) + 2] = point_create(lpoint_get(pt)->x, lpoint_get(pt)->y);
        //lastx = lpoint_get(pt)->x;
        lasty = lpoint_get(pt)->y;
        lua_pop(L, 1);
    }

    geometry_path(lobject_get(cell), layer, points, numpoints, width, bgnext, endext);
    for(unsigned int i = 0; i < numpoints; ++i)
    {
        point_destroy(points[i]);
    }
    free(points);
    return 0;
}
*/

static int lgeometry_path_2x(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    coordinate_t width = luaL_checkinteger(L, 5);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 6, &bgnext, &endext);

    point_t* pts1 = point_create(lpoint_get(ptend)->x, lpoint_get(ptstart)->y);
    const point_t* points[4];
    points[0] = lpoint_get(ptstart);
    points[1] = pts1;
    points[2] = lpoint_get(ptend);
    geometry_path(lobject_get(cell), layer, points, 3, width, bgnext, endext);
    point_destroy(pts1);
    return 0;
}

static int lgeometry_path_2y(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    coordinate_t width = luaL_checkinteger(L, 5);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 6, &bgnext, &endext);

    point_t* pts1 = point_create(lpoint_get(ptstart)->x, lpoint_get(ptend)->y);
    const point_t* points[4];
    points[0] = lpoint_get(ptstart);
    points[1] = pts1;
    points[2] = lpoint_get(ptend);
    geometry_path(lobject_get(cell), layer, points, 3, width, bgnext, endext);
    point_destroy(pts1);
    return 0;
}

static int lgeometry_path_cshape(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    struct lpoint* ptoffset = lpoint_checkpoint(L, 5);
    coordinate_t offset = lpoint_get(ptoffset)->x;
    coordinate_t width = luaL_checkinteger(L, 6);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 7, &bgnext, &endext);

    point_t* pts1 = point_create(offset, lpoint_get(ptstart)->y);
    point_t* pts2 = point_create(offset, lpoint_get(ptend)->y);
    const point_t* points[4];
    points[0] = lpoint_get(ptstart);
    points[1] = pts1;
    points[2] = pts2;
    points[3] = lpoint_get(ptend);
    geometry_path(lobject_get(cell), layer, points, 4, width, bgnext, endext);
    point_destroy(pts1);
    point_destroy(pts2);
    return 0;
}

static int lgeometry_path_ushape(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
    struct lpoint* ptstart = lpoint_checkpoint(L, 3);
    struct lpoint* ptend = lpoint_checkpoint(L, 4);
    struct lpoint* ptoffset = lpoint_checkpoint(L, 5);
    coordinate_t offset = lpoint_get(ptoffset)->y;
    coordinate_t width = lua_tointeger(L, 6);

    int bgnext = 0;
    int endext = 0;
    _get_path_extension(L, 7, &bgnext, &endext);

    point_t* pts1 = point_create(lpoint_get(ptstart)->x, offset);
    point_t* pts2 = point_create(lpoint_get(ptend)->x, offset);
    const point_t* points[4];
    points[0] = lpoint_get(ptstart);
    points[1] = pts1;
    points[2] = pts2;
    points[3] = lpoint_get(ptend);
    geometry_path(lobject_get(cell), layer, points, 4, width, bgnext, endext);
    point_destroy(pts1);
    point_destroy(pts2);
    return 0;
}

void _get_viacontact_properties(lua_State* L, int idx, int* xcont, int* ycont, int* equal_pitch)
{
    if(lua_type(L, idx) == LUA_TTABLE)
    {
        lua_getfield(L, idx, "xcontinuous");
        *xcont = lua_toboolean(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, idx, "ycontinuous");
        *ycont = lua_toboolean(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, idx, "equal_pitch");
        *equal_pitch = lua_toboolean(L, -1);
        lua_pop(L, 1);
    }
}

static int lgeometry_viabltr(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    int metal1 = luaL_checkinteger(L, 2);
    int metal2 = luaL_checkinteger(L, 3);
    struct lpoint* bl = lpoint_checkpoint(L, 4);
    struct lpoint* tr = lpoint_checkpoint(L, 5);
    _check_rectangle_points(L, bl, tr, "geometry.viabltr");
    ucoordinate_t xrep = luaL_optinteger(L, 6, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 7, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 8, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 9, 0);
    int xcont = 0;
    int ycont = 0;
    int equal_pitch = 0;
    _get_viacontact_properties(L, 10, &xcont, &ycont, &equal_pitch);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_viabltr(lobject_get(cell), techstate, metal1, metal2, lpoint_get(bl), lpoint_get(tr), xrep, yrep, xpitch, ypitch, xcont, ycont, equal_pitch);
    if(!res)
    {
        lua_pushfstring(L, "geometry.viabltr: could not fit via from metal %d to metal %d. Area: (%d, %d) and (%d, %d)", metal1, metal2, lpoint_get(bl)->x, lpoint_get(bl)->y, lpoint_get(tr)->x, lpoint_get(tr)->y);
        lua_error(L);
    }
    return 0;
}

static int lgeometry_via(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
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
    int xcont = 0;
    int ycont = 0;
    int equal_pitch = 0;
    _get_viacontact_properties(L, 12, &xcont, &ycont, &equal_pitch);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_via(lobject_get(cell), techstate, metal1, metal2, width, height, xshift, yshift, xrep, yrep, xpitch, ypitch, xcont, ycont, equal_pitch);
    if(!res)
    {
        lua_pushfstring(L, "geometry.via: could not fit via from metal %d to metal %d. Area: (%d, %d) and (%d, %d)", metal1, metal2, xshift - width / 2, yshift - height / 2, xshift + width / 2, yshift + height / 2);
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
    ucoordinate_t xrep = luaL_optinteger(L, 5, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 6, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 7, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 8, 0);
    int xcont = 0;
    int ycont = 0;
    int equal_pitch = 0;
    _get_viacontact_properties(L, 9, &xcont, &ycont, &equal_pitch);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_contactbltr(
        lobject_get(cell),
        techstate,
        region,
        lpoint_get(bl), lpoint_get(tr),
        xrep, yrep,
        xpitch, ypitch,
        xcont, ycont,
        equal_pitch
    );
    if(!res)
    {
        const point_t* blp = lpoint_get(bl);
        const point_t* trp = lpoint_get(tr);
        lua_pushfstring(L, "geometry.contactbltr: could not fit contact from %s to metal 1 (width = %d, height = %d)", region, trp->x - blp->x, trp->y - blp->y);
        lua_error(L);
    }
    return 0;
}

static int lgeometry_contact(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
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
    int equal_pitch = 0;
    _get_viacontact_properties(L, 11, &xcont, &ycont, &equal_pitch);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_contact(
        lobject_get(cell),
        techstate,
        region,
        width, height,
        xshift, yshift,
        xrep, yrep,
        xpitch, ypitch,
        xcont, ycont,
        equal_pitch
    );
    if(!res)
    {
        lua_pushfstring(L, "geometry.contact: could not fit contact from %s to metal 1. Area: (%d, %d) and (%d, %d)", region, xshift - width / 2, yshift - height / 2, xshift + width / 2, yshift + height / 2);
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
    ucoordinate_t xrep = luaL_optinteger(L, 5, 1);
    ucoordinate_t yrep = luaL_optinteger(L, 6, 1);
    ucoordinate_t xpitch = luaL_optinteger(L, 7, 0);
    ucoordinate_t ypitch = luaL_optinteger(L, 8, 0);
    int xcont = 0;
    int ycont = 0;
    int equal_pitch = 0;
    _get_viacontact_properties(L, 9, &xcont, &ycont, &equal_pitch);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_contactbarebltr(
        lobject_get(cell),
        techstate,
        region,
        lpoint_get(bl), lpoint_get(tr),
        xrep, yrep,
        xpitch, ypitch,
        xcont, ycont,
        equal_pitch
    );
    if(!res)
    {
        lua_pushfstring(L, "geometry.contactbarebltr: could not fit contact from %s to metal 1. Area: (%d, %d) and (%d, %d)", region, lpoint_get(bl)->x, lpoint_get(bl)->y, lpoint_get(tr)->x, lpoint_get(tr)->y);
        lua_error(L);
    }
    return 0;
}

static int lgeometry_contactbare(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
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
    int equal_pitch;
    _get_viacontact_properties(L, 11, &xcont, &ycont, &equal_pitch);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int res = geometry_contactbare(
        lobject_get(cell),
        techstate,
        region,
        width, height,
        xshift, yshift,
        xrep, yrep,
        xpitch, ypitch,
        xcont, ycont,
        equal_pitch
    );
    if(!res)
    {
        lua_pushfstring(L, "geometry.contactbare: could not fit contact from %s to metal 1. Area: (%d, %d) and (%d, %d)", region, xshift - width / 2, yshift - height / 2, xshift + width / 2, yshift + height / 2);
        lua_error(L);
    }
    return 0;
}

static int lgeometry_cross(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
    ucoordinate_t width = luaL_checkinteger(L, 3);
    ucoordinate_t height = luaL_checkinteger(L, 4);
    ucoordinate_t crosssize = luaL_checkinteger(L, 5);
    geometry_cross(lobject_get(cell), layer, width, height, crosssize);
    return 0;
}

static int lgeometry_ring(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
    ucoordinate_t width = luaL_checkinteger(L, 3);
    ucoordinate_t height = luaL_checkinteger(L, 4);
    ucoordinate_t ringwidth = luaL_checkinteger(L, 5);
    geometry_ring(lobject_get(cell), layer, width, height, ringwidth);
    return 0;
}

static int lgeometry_unequal_ring(lua_State* L)
{
    struct lobject* cell = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
    ucoordinate_t width = luaL_checkinteger(L, 3);
    ucoordinate_t height = luaL_checkinteger(L, 4);
    ucoordinate_t leftwidth = luaL_checkinteger(L, 5);
    ucoordinate_t rightwidth = luaL_checkinteger(L, 6);
    ucoordinate_t topwidth = luaL_checkinteger(L, 7);
    ucoordinate_t bottomwidth = luaL_checkinteger(L, 8);
    geometry_unequal_ring(lobject_get(cell), layer, width, height, leftwidth, rightwidth, topwidth, bottomwidth);
    return 0;
}

static int lgeometry_curve(lua_State* L)
{
    struct lobject* lobject = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
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
            const point_t* cpt1 = lpoint_get(lcpt1);
            lua_pop(L, 1);
            lua_getfield(L, -2, "cpt2");
            struct lpoint* lcpt2 = lpoint_checkpoint(L, -1);
            const point_t* cpt2 = lpoint_get(lcpt2);
            lua_pop(L, 1);
            lua_getfield(L, -2, "endpt");
            struct lpoint* lendpt = lpoint_checkpoint(L, -1);
            const point_t* endpt = lpoint_get(lendpt);
            lua_pop(L, 1);
            shape_curve_add_cubic_bezier_segment(S, cpt1, cpt2, endpt);
        }
        else
        {
            lua_pushfstring(L, "unknown curve segment: %s", type);
            lua_error(L);
        }
        lua_pop(L, 1); // pop type
        lua_pop(L, 1); // pop segment
    }

    object_add_shape(lobject_get(lobject), S);
    return 0;
}

static int lgeometry_curve_rasterized(lua_State* L)
{
    struct lobject* lobject = lobject_check(L, 1);
    struct generics* layer = _check_generics(L, 2);
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
            const point_t* cpt1 = lpoint_get(lcpt1);
            lua_pop(L, 1);
            lua_getfield(L, -2, "cpt2");
            struct lpoint* lcpt2 = lpoint_checkpoint(L, -1);
            const point_t* cpt2 = lpoint_get(lcpt2);
            lua_pop(L, 1);
            lua_getfield(L, -2, "endpt");
            struct lpoint* lendpt = lpoint_checkpoint(L, -1);
            const point_t* endpt = lpoint_get(lendpt);
            lua_pop(L, 1);
            shape_curve_add_cubic_bezier_segment(S, cpt1, cpt2, endpt);
        }
        else
        {
            lua_pushfstring(L, "unknown curve segment: %s", type);
            lua_error(L);
        }
        lua_pop(L, 1); // pop type
        lua_pop(L, 1); // pop segment
    }

    shape_rasterize_curve_inline(S);

    object_add_shape(lobject_get(lobject), S);
    return 0;
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
        coordinate_t x = lpoint_checkcoordinate(L, 1);
        coordinate_t y = lpoint_checkcoordinate(L, 2);
        lpoint_create_internal(L, x, y);
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
        { "rectanglebltr",      lgeometry_rectanglebltr     },
        { "rectangle",          lgeometry_rectangle         },
        { "rectanglepoints",    lgeometry_rectanglepoints   },
        { "rectanglepath",      lgeometry_rectanglepath     },
        { "polygon",            lgeometry_polygon           },
        { "path",               lgeometry_path              },
        { "path_manhatten",     lgeometry_path_manhatten    },
        { "path_2x",            lgeometry_path_2x           },
        { "path_2y",            lgeometry_path_2y           },
        { "path_cshape",        lgeometry_path_cshape       },
        { "path_ushape",        lgeometry_path_ushape       },
        { "viabltr",            lgeometry_viabltr           },
        { "via",                lgeometry_via               },
        { "contactbltr",        lgeometry_contactbltr       },
        { "contact",            lgeometry_contact           },
        { "contactbarebltr",    lgeometry_contactbarebltr   },
        { "contactbare",        lgeometry_contactbare       },
        { "cross",              lgeometry_cross             },
        { "ring",               lgeometry_ring              },
        { "unequal_ring",       lgeometry_unequal_ring      },
        { "curve",              lgeometry_curve             },
        { "curve_rasterized",   lgeometry_curve_rasterized  },
        { NULL,                 NULL                        }
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
