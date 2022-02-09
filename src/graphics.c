#include "graphics.h"

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

#include "lua/lauxlib.h"

#include "point.h"

struct curve
{
    point_t* points;
    size_t size;
    size_t capacity;
};

static struct curve* _create(size_t initial_capacity)
{
    struct curve* c = malloc(sizeof(*c));
    c->size = 0;
    c->capacity = initial_capacity;
    if(initial_capacity > 0)
    {
        c->points = calloc(initial_capacity, sizeof(*c->points));
    }
    return c;
}

static void _destroy(struct curve* c)
{
    if(c->capacity > 0)
    {
        free(c->points);
    }
    free(c);
}

static void _append_point(struct curve* c, int x, int y)
{
    if(c->size + 1 > c->capacity)
    {
        c->capacity = ((2 * c->capacity) > (c->size + 1)) ? (2 * c->capacity) : (c->size + 1);
        point_t* ptr = realloc(c->points, c->capacity * sizeof(*ptr));
        c->points = ptr;
    }
    c->points[c->size].x = x;
    c->points[c->size].y = y;
    c->size += 1;
}

static point_t _midpoint(point_t p1, point_t p2)
{
    point_t p = { .x = (p1.x + p2.x) / 2, .y = (p1.y + p2.y) / 2 };
    return p;
}

static void _subdivide(struct curve* c, struct curve* l, struct curve* r)
{
    point_t l1 = _midpoint(c->points[0], c->points[1]);
    point_t m = _midpoint(c->points[1], c->points[2]);
    point_t r2 = _midpoint(c->points[2], c->points[3]);
    point_t l2 = _midpoint(l1, m);
    point_t r1 = _midpoint(m, r2);
    point_t l3r0 = _midpoint(l2, r1);
    l->points[0] = c->points[0];
    l->points[1] = l1;
    l->points[2] = l2;
    l->points[3] = l3r0;
    l->size = 4;
    r->points[0] = l3r0;
    r->points[1] = r1;
    r->points[2] = r2;
    r->points[3] = c->points[3];
    r->size = 4;
}

static int _is_sufficiently_flat(struct curve* c)
{
    double ux = 3.0 * c->points[1].x - 2.0 * c->points[0].x - c->points[3].x; ux *= ux;
    double uy = 3.0 * c->points[1].y - 2.0 * c->points[0].y - c->points[3].y; uy *= uy;
    double vx = 3.0 * c->points[2].x - 2.0 * c->points[3].x - c->points[0].x; vx *= vx;
    double vy = 3.0 * c->points[2].y - 2.0 * c->points[3].y - c->points[0].y; vy *= vy;
    if (ux < vx) ux = vx;
    if (uy < vy) uy = vy;
    double tolerance = 1;
    return (ux + uy <= (16 * tolerance * tolerance));
}

static void _flatten_curve(struct curve* c, struct curve* result)
{
    if(_is_sufficiently_flat(c))
    {
        _append_point(result, c->points[0].x, c->points[0].y);
        _append_point(result, c->points[c->size - 1].x, c->points[c->size - 1].y);
    }
    else
    {
        struct curve* l = _create(4);
        struct curve* r = _create(4);
        _subdivide(c, l, r);
        _flatten_curve(l, result);
        _flatten_curve(r, result);
        _destroy(l);
        _destroy(r);
    }
}

static void _raster_line(int x0, int y0, int x1, int y1, struct curve* result)
{
    int dx = (x1 > x0) ? (x1 - x0) : (x0 - x1);
    int dy = (y1 < y0) ? (y1 - y0) : (y0 - y1);
    int sx = (x1 > x0) ? 1 : -1;
    int sy = (y1 > y0) ? 1 : -1;
    int err = dx + dy;

    while(1)
    {
        _append_point(result, x0, y0);
        if((2 * err) >= dy)
        {
            if(x0 == x1) break;
            err += dy;
            x0 += sx;
        }
        if((2 * err) <= dx)
        {
            if(y0 == y1) break;
            err += dx;
            y0 += sy;
        }
    }
}

int flatten_cubic_bezier(lua_State* L)
{
    int x1 = lua_tonumber(L, 1);
    int y1 = lua_tonumber(L, 2);
    int x2 = lua_tonumber(L, 3);
    int y2 = lua_tonumber(L, 4);
    int x3 = lua_tonumber(L, 5);
    int y3 = lua_tonumber(L, 6);
    int x4 = lua_tonumber(L, 7);
    int y4 = lua_tonumber(L, 8);
    struct curve* c = _create(4);
    _append_point(c, x1, y1);
    _append_point(c, x2, y2);
    _append_point(c, x3, y3);
    _append_point(c, x4, y4);

    struct curve* result = _create(100);
    _flatten_curve(c, result);

    lua_newtable(L);
    for(unsigned int i = 0; i < result->size; ++i)
    {
        lua_pushnumber(L, result->points[i].x);
        lua_rawseti(L, -2, 2 * i + 1);
        lua_pushnumber(L, result->points[i].y);
        lua_rawseti(L, -2, 2 * i + 2);
    }

    _destroy(result);

    _destroy(c);

    return 1;
}

int open_lgraphics_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "flatten_cubic_bezier", flatten_cubic_bezier },
        { NULL, NULL }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LGRAPHICSMODULE);
    return 0;
}

