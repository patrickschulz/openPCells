#include "graphics.h"

#include <stdlib.h>
#include <stdio.h>

#include "lpoint.h"
#include "vector.h"

static point_t* _midpoint(point_t* p1, point_t* p2)
{
    return point_create((p1->x + p2->x) / 2, (p1->y + p2->y) / 2);
}

static void _subdivide(struct vector* points, struct vector* l, struct vector* r)
{
    point_t* l1 = _midpoint(pointarray_get(points, 0), pointarray_get(points, 1));
    point_t* m = _midpoint(pointarray_get(points, 1), pointarray_get(points, 2));
    point_t* r2 = _midpoint(pointarray_get(points, 2), pointarray_get(points, 3));
    point_t* l2 = _midpoint(l1, m);
    point_t* r1 = _midpoint(m, r2);
    point_t* l3r0 = _midpoint(l2, r1);

    vector_append(l, point_copy(pointarray_get(points, 0)));
    vector_append(l, l1);
    vector_append(l, l2);
    vector_append(l, l3r0);

    vector_append(r, l3r0);
    vector_append(r, r1);
    vector_append(r, r2);
    vector_append(r, point_copy(pointarray_get(points, 3)));
}

//static int _is_sufficiently_flat(struct vector* points)
static int _is_sufficiently_flat(struct pointarray* points)
{
    double ux = 3.0 * pointarray_get(points, 1)->x - 2.0 * pointarray_get(points, 0)->x - pointarray_get(points, 3)->x; ux *= ux;
    double uy = 3.0 * pointarray_get(points, 1)->y - 2.0 * pointarray_get(points, 0)->y - pointarray_get(points, 3)->y; uy *= uy;
    double vx = 3.0 * pointarray_get(points, 2)->x - 2.0 * pointarray_get(points, 3)->x - pointarray_get(points, 0)->x; vx *= vx;
    double vy = 3.0 * pointarray_get(points, 2)->y - 2.0 * pointarray_get(points, 3)->y - pointarray_get(points, 0)->y; vy *= vy;
    if (ux < vx) ux = vx;
    if (uy < vy) uy = vy;
    double tolerance = 1;
    return (ux + uy <= (16 * tolerance * tolerance));
}

static void _flatten_curve(struct vector* points, struct vector* result)
{
    if(_is_sufficiently_flat(points))
    {
        vector_append(result, point_create(pointarray_get(points, 0)->x, pointarray_get(points, 0)->y));
        vector_append(result, point_create(pointarray_get(points, vector_size(points) - 1)->x, pointarray_get(points, vector_size(points) - 1)->y));
    }
    else
    {
        struct vector* l = vector_create();
        struct vector* r = vector_create();
        _subdivide(points, l, r);
        _flatten_curve(l, result);
        _flatten_curve(r, result);
        vector_destroy(l, NULL);
        vector_destroy(r, NULL);
    }
}

#define iabs(x) ((x) < 0 ? -(x) : (x))

static struct curve* _raster_line(int x1, int y1, int x2, int y2, unsigned int grid, int allow45)
{
    int sx = (x2 > x1) ? grid : -grid;
    int sy = (y2 > y1) ? grid : -grid;

    int x = x1;
    int y = y1;

    //struct curve* result = _create(100);

    /*
    while(1)
    {
        _append_point(result, x, y);
        if(x == x2 && y == y2)
        {
            break;
        }
        int exy = (y + sy - y1) * (x2 - x1) - (x + sx - x1) * (y2 - y1);
        int ex  = (y + sy - y1) * (x2 - x1) - (x +  0 - x1) * (y2 - y1);
        int ey  = (y +  0 - y1) * (x2 - x1) - (x + sx - x1) * (y2 - y1);
        if(allow45)
        {
            if(iabs(exy) < iabs(ex))
            {
                x = x + sx;
            }
            if(iabs(exy) < iabs(ey))
            {
                y = y + sy;
            }
        }
        else
        {
            if(iabs(ex) < iabs(ey))
            {
                y = y + sy;
            }
            {
                x = x + sx;
            }
        }
    }
    */
    //return result;
}

/*
static int line(lua_State* L)
{
    lpoint_t* pt1 = lua_touserdata(L, 1);
    lpoint_t* pt2 = lua_touserdata(L, 2);
    int grid = lua_tointeger(L, 3);
    int allow45 = lua_toboolean(L, 4);

    struct curve* result = _raster_line(pt1->point->x, pt1->point->y, pt2->point->x, pt2->point->y, grid, allow45);

    lua_newtable(L);
    for(unsigned int i = 0; i < result->size; ++i)
    {
        lua_pushinteger(L, result->points[i].x);
        lua_pushinteger(L, result->points[i].y);
        lpoint_create(L);
        lua_rawseti(L, -2, i + 1);
    }

    _destroy(result);

    return 1;
}
*/

struct vector* graphics_cubic_bezier(struct vector* curve)
{
    struct vector* result = vector_create();
    _flatten_curve(curve, result);
    return result;
}

