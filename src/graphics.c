#include "graphics.h"

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "lpoint.h"
#include "vector.h"

static point_t* _midpoint(const point_t* p1, const point_t* p2)
{
    return point_create((p1->x + p2->x) / 2, (p1->y + p2->y) / 2);
}

static void _subdivide(const struct const_vector* points, struct const_vector* l, struct const_vector* r)
{
    point_t* l1 = _midpoint(cpointarray_get(points, 0), cpointarray_get(points, 1));
    point_t* m = _midpoint(cpointarray_get(points, 1), cpointarray_get(points, 2));
    point_t* r2 = _midpoint(cpointarray_get(points, 2), cpointarray_get(points, 3));
    point_t* l2 = _midpoint(l1, m);
    point_t* r1 = _midpoint(m, r2);
    point_t* l3r0 = _midpoint(l2, r1);

    const_vector_append(l, point_copy(cpointarray_get(points, 0)));
    const_vector_append(l, l1);
    const_vector_append(l, l2);
    const_vector_append(l, l3r0);

    const_vector_append(r, l3r0);
    const_vector_append(r, r1);
    const_vector_append(r, r2);
    const_vector_append(r, point_copy(cpointarray_get(points, 3)));
}

//static int _is_sufficiently_flat(struct vector* points)
static int _is_sufficiently_flat(const struct cpointarray* points)
{
    double ux = 3.0 * cpointarray_get(points, 1)->x - 2.0 * cpointarray_get(points, 0)->x - cpointarray_get(points, 3)->x; ux *= ux;
    double uy = 3.0 * cpointarray_get(points, 1)->y - 2.0 * cpointarray_get(points, 0)->y - cpointarray_get(points, 3)->y; uy *= uy;
    double vx = 3.0 * cpointarray_get(points, 2)->x - 2.0 * cpointarray_get(points, 3)->x - cpointarray_get(points, 0)->x; vx *= vx;
    double vy = 3.0 * cpointarray_get(points, 2)->y - 2.0 * cpointarray_get(points, 3)->y - cpointarray_get(points, 0)->y; vy *= vy;
    if (ux < vx) ux = vx;
    if (uy < vy) uy = vy;
    double tolerance = 1;
    return (ux + uy <= (16 * tolerance * tolerance));
}

static void _flatten_curve(const struct const_vector* points, struct vector* result)
{
    if(_is_sufficiently_flat(points))
    {
        vector_append(result, point_create(cpointarray_get(points, 0)->x, cpointarray_get(points, 0)->y));
        vector_append(result, point_create(cpointarray_get(points, const_vector_size(points) - 1)->x, cpointarray_get(points, const_vector_size(points) - 1)->y));
    }
    else
    {
        struct const_vector* l = const_vector_create(32);
        struct const_vector* r = const_vector_create(32);
        _subdivide(points, l, r);
        _flatten_curve(l, result);
        _flatten_curve(r, result);
        const_vector_destroy(l);
        const_vector_destroy(r);
    }
}

struct vector* graphics_cubic_bezier(const struct const_vector* curve)
{
    struct vector* result = vector_create(128);
    _flatten_curve(curve, result);
    return result;
}

#define iabs(x) ((x) < 0 ? -(x) : (x))

void graphics_raster_line_segment(point_t* startpt, point_t* endpt, unsigned int grid, int allow45, struct vector* result)
{
    coordinate_t x1 = startpt->x;
    coordinate_t y1 = startpt->y;
    coordinate_t x2 = endpt->x;
    coordinate_t y2 = endpt->y;

    int sx = (x2 > x1) ? grid : -grid;
    int sy = (y2 > y1) ? grid : -grid;

    if(x1 == x2 || y1 == y2)
    {
        vector_append(result, point_create(x1, y1));
        vector_append(result, point_create(x2, y2));
        return;
    }

    coordinate_t x = x1;
    coordinate_t y = y1;

    while(1)
    {
        vector_append(result, point_create(x, y));
        if(x == x2 && y == y2)
        //if(x == x2)
        {
            break;
        }
        coordinate_t exy = (y + sy - y1) * (x2 - x1) - (x + sx - x1) * (y2 - y1);
        coordinate_t ex  = (y + sy - y1) * (x2 - x1) - (x +  0 - x1) * (y2 - y1);
        coordinate_t ey  = (y +  0 - y1) * (x2 - x1) - (x + sx - x1) * (y2 - y1);
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
            else
            {
                x = x + sx;
            }
        }
    }
}

static struct vector* _rasterize_quartercircle(coordinate_t radius, unsigned int grid, int allow45)
{
    coordinate_t x = radius;
    coordinate_t y = 0;
    int sx = -grid;
    int sy = grid;
    struct vector* pts = vector_create(128);
    while(1)
    {
        vector_append(pts, point_create(x, y));
        if(x == 0 && y == (coordinate_t)radius)
        {
            break;
        }
        int64_t exy = ((x + sx) * (x + sx) + (y + sy) * (y + sy) - radius * radius) * radius * radius;
        int64_t ex  = (x * x + (y + sy) * (y + sy) - radius * radius) * radius * radius;
        int64_t ey  = ((x + sx) * (x + sx) + y * y - radius * radius) * radius * radius;
        if(allow45)
        {
            if(iabs(exy) < iabs(ex)) { x = x + sx; }
            if(iabs(exy) < iabs(ey)) { y = y + sy; }
        }
        else
        {
            if(iabs(ex) < iabs(ey)) { y = y + sy; }
            else { x = x + sx; }
        }
    }
    return pts;
}

/*
static struct vector* _rasterize_quarterellipse(coordinate_t xradius, coordinate_t yradius, unsigned int grid, int allow45)
{
    coordinate_t x = xradius;
    coordinate_t y = 0;
    int sx = -grid;
    int sy = grid;
    struct vector* pts = vector_create(128);
    while(1)
    {
        vector_append(pts, point_create(x, y));
        if(x == 0 && y == (coordinate_t)yradius)
        {
            break;
        }
        int64_t exy = (x + sx) * (x + sx) * xradius * xradius + (y + sy) * (y + sy) * yradius * yradius - xradius * xradius * yradius * yradius;
        int64_t ex  = x * x * xradius * xradius + (y + sy) * (y + sy) * yradius * yradius - xradius * xradius * yradius * yradius;
        int64_t ey  = (x + sx) * (x + sx) * xradius * xradius + y * y * yradius * yradius - xradius * xradius * yradius * yradius;
        if(allow45)
        {
            if(iabs(exy) < iabs(ex)) { x = x + sx; }
            if(iabs(exy) < iabs(ey)) { y = y + sy; }
        }
        else
        {
            if(iabs(ex) < iabs(ey)) { y = y + sy; }
            else { x = x + sx; }
        }
    }
    return pts;
}
*/

static unsigned int _map_xy_to_quadrant(coordinate_t x, coordinate_t y)
{
    if(x >= 0)
    {
        if(y >= 0)
        {
            return 1;
        }
        else
        {
            return 4;
        }
    }
    else
    {
        if(y >= 0)
        {
            return 2;
        }
        else
        {
            return 3;
        }
    }
}

static void _get_quadrant_list(unsigned int startquadrant, unsigned int endquadrant, int clockwise, unsigned int* quadrants)
{
    unsigned int i = startquadrant;
    int stop = 0;
    unsigned int idx = 0;
    while(1)
    {
        quadrants[idx] = i;
        ++idx;
        if(stop)
        {
            break;
        }
        if(clockwise)
        {
            if(i == 1) { i = 4; }
            else { i = i - 1; }
        }
        else
        {
            if(i == 4) { i = 1; }
            else { i = i + 1; }
        }
        if(i == endquadrant)
        {
            stop = 1;
        }
    }
}

static int _xsign(unsigned int quadrant)
{
    if(quadrant == 1)
    {
        return 1;
    }
    else if(quadrant == 2)
    {
        return -1;
    }
    else if(quadrant == 3)
    {
        return -1;
    }
    else if(quadrant == 4)
    {
        return 1;
    }
    return 1; // never reached
}

static int _ysign(unsigned int quadrant)
{
    if(quadrant == 1)
    {
        return 1;
    }
    else if(quadrant == 2)
    {
        return 1;
    }
    else if(quadrant == 3)
    {
        return -1;
    }
    else if(quadrant == 4)
    {
        return -1;
    }
    return 1; // never reached
}

static int _check_startquadrant(unsigned int quadrant, coordinate_t x, coordinate_t y, coordinate_t xstart, coordinate_t ystart, int clockwise)
{
    if((!clockwise && quadrant == 1) || (clockwise && quadrant == 3))
    {
        if(x <= xstart && y >= ystart)
        {
            return 1;
        }
        return 0;
    }
    else if((!clockwise && quadrant == 2) || (clockwise && quadrant == 4))
    {
        if(x <= xstart && y <= ystart)
        {
            return 1;
        }
        return 0;
    }
    else if((!clockwise && quadrant == 3) || (clockwise && quadrant == 1))
    {
        if(x >= xstart && y <= ystart)
        {
            return 1;
        }
        return 0;
    }
    else if((!clockwise && quadrant == 4) || (clockwise && quadrant == 2))
    {
        if(x >= xstart && y >= ystart)
        {
            return 1;
        }
        return 0;
    }
    return 0; // never reached
}

static int _check_endquadrant(unsigned int quadrant, coordinate_t x, coordinate_t y, coordinate_t xend, coordinate_t yend, int clockwise)
{
    if((!clockwise && quadrant == 1) || (clockwise && quadrant == 3))
    {
        if(x >= xend && y <= yend)
        {
            return 1;
        }
        return 0;
    }
    else if((!clockwise && quadrant == 2) || (clockwise && quadrant == 4))
    {
        if(x >= xend && y >= yend)
        {
            return 1;
        }
        return 0;
    }
    else if((!clockwise && quadrant == 3) || (clockwise && quadrant == 1))
    {
        if(x <= xend && y >= yend)
        {
            return 1;
        }
        return 0;
    }
    else if((!clockwise && quadrant == 4) || (clockwise && quadrant == 2))
    {
        if(x <= xend && y <= yend)
        {
            return 1;
        }
        return 0;
    }
    return 0; // never reached
}

static void _assemble_circle_points(struct vector* quarterpoints, unsigned int* quadrants, coordinate_t xstart, coordinate_t ystart, coordinate_t xend, coordinate_t yend, coordinate_t xc, coordinate_t yc, int clockwise, struct vector* result)
{
    for(unsigned int i = 0; i < 4; ++i)
    {
        unsigned int q = quadrants[i];
        if(!q)
        {
            break;
        }
        unsigned int startj = (i == 0) ? 0 : 1;
        for(unsigned int j = startj; j < vector_size(quarterpoints); ++j)
        {
            unsigned int idx;
            if(clockwise)
            {
                idx = (q % 2 == 0) ? j : (vector_size(quarterpoints) - j - 1);
            }
            else
            {
                idx = (q % 2 == 0) ? (vector_size(quarterpoints) - j - 1) : j;
            }
            point_t* pt = vector_get(quarterpoints, idx);
            coordinate_t x = pt->x;
            coordinate_t y = pt->y;
            x = x * _xsign(q);
            y = y * _ysign(q);
            int insert = 0;
            if(i == 0) // start quadrant
            {
                insert = _check_startquadrant(q, x, y, xstart, ystart, clockwise);
            }
            else if(i == 3 || quadrants[i + 1] == 0) // end quadrant
            {
                insert = _check_endquadrant(q, x, y, xend, yend, clockwise);
            }
            else // insert every point of an intermediate quadrant
            {
                insert = 1;
            }
            if(insert)
            {
                vector_append(result, point_create(xc + x, yc + y));
            }
        }
    }
}

/*
static void _ellipse(coordinate_t ox, coordinate_t oy, ucoordinate_t xradius, ucoordinate_t yradius, double startangle, double endangle, int clockwise, unsigned int grid, int allow45, struct vector* result)
{
    //util.check_grid(grid, origin->x, origin->y, xradius, yradius)

    coordinate_t xstart = xradius * cos(startangle * M_PI / 180);
    coordinate_t xend = xradius * cos(endangle * M_PI / 180);
    coordinate_t ystart = yradius * sin(startangle * M_PI / 180);
    coordinate_t yend = yradius * sin(endangle * M_PI / 180);

    unsigned int startquadrant = _map_xy_to_quadrant(xstart, ystart);
    unsigned int endquadrant = _map_xy_to_quadrant(xend, yend);

    struct vector* quarterpoints = _rasterize_quarterellipse(xradius, yradius, grid, allow45);

    unsigned int quadrants[4] = { 0 };
    _get_quadrant_list(startquadrant, endquadrant, clockwise, quadrants);

    _assemble_circle_points(quarterpoints, quadrants, xstart, ystart, xend, yend, ox, oy, clockwise, result);
}
*/

static void _circle(coordinate_t ox, coordinate_t oy, ucoordinate_t radius, double startangle, double endangle, int clockwise, unsigned int grid, int allow45, struct vector* result)
{
    //util.check_grid(grid, origin->x, origin->y, xradius, yradius)

    coordinate_t xstart = radius * cos(startangle * M_PI / 180);
    coordinate_t xend = radius * cos(endangle * M_PI / 180);
    coordinate_t ystart = radius * sin(startangle * M_PI / 180);
    coordinate_t yend = radius * sin(endangle * M_PI / 180);

    unsigned int startquadrant = _map_xy_to_quadrant(xstart, ystart);
    unsigned int endquadrant = _map_xy_to_quadrant(xend, yend);

    struct vector* quarterpoints = _rasterize_quartercircle(radius, grid, allow45);

    unsigned int quadrants[4] = { 0 };
    _get_quadrant_list(startquadrant, endquadrant, clockwise, quadrants);

    _assemble_circle_points(quarterpoints, quadrants, xstart, ystart, xend, yend, ox, oy, clockwise, result);

    vector_destroy(quarterpoints, point_destroy);
}

void graphics_raster_arc_segment(point_t* startpt, double startangle, double endangle, coordinate_t radius, int clockwise, unsigned int grid, int allow45, struct vector* result)
{
    coordinate_t cx = startpt->x - cos(startangle * M_PI / 180) * radius;
    coordinate_t cy = startpt->y - sin(startangle * M_PI / 180) * radius;
    _circle(cx, cy, radius, startangle, endangle, clockwise, grid, allow45, result);
}

