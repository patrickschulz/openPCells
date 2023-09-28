#include "graphics.h"

#include <stdlib.h>

#include "math.h"
#include "vector.h"

#define pointarray_get(p, i) ((point_t*)vector_get_const(p, i))

static point_t* _midpoint(const point_t* p1, const point_t* p2)
{
    return point_create((p1->x + p2->x) / 2, (p1->y + p2->y) / 2);
}

static void _subdivide(const struct vector* points, struct vector* l, struct vector* r)
{
    point_t* l1 = _midpoint(pointarray_get(points, 0), pointarray_get(points, 1));
    point_t* m = _midpoint(pointarray_get(points, 1), pointarray_get(points, 2));
    point_t* r2 = _midpoint(pointarray_get(points, 2), pointarray_get(points, 3));
    point_t* l2 = _midpoint(l1, m);
    point_t* r1 = _midpoint(m, r2);
    point_t* l3r0 = _midpoint(l2, r1);
    point_destroy(m);

    vector_append(l, point_copy(pointarray_get(points, 0)));
    vector_append(l, l1);
    vector_append(l, l2);
    vector_append(l, l3r0);

    vector_append(r, point_copy(l3r0)); // l3r0 is in both vectors, copy it once or deallocation fails
    vector_append(r, r1);
    vector_append(r, r2);
    vector_append(r, point_copy(pointarray_get(points, 3)));
}

static int _is_sufficiently_flat(const struct vector* points)
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

static void _flatten_curve(const struct vector* points, unsigned int grid, int allow45, struct vector* result)
{
    if(_is_sufficiently_flat(points))
    {
        point_t* startpt = point_create(pointarray_get(points, 0)->x, pointarray_get(points, 0)->y);
        startpt->x = (startpt->x / grid) * grid;
        startpt->y = (startpt->y / grid) * grid;
        point_t* endpt = point_create(pointarray_get(points, vector_size(points) - 1)->x, pointarray_get(points, vector_size(points) - 1)->y);
        endpt->x = (endpt->x / grid) * grid;
        endpt->y = (endpt->y / grid) * grid;
        graphics_rasterize_line_segment(startpt, endpt, grid, allow45, result);
        point_destroy(startpt);
        point_destroy(endpt);
    }
    else
    {
        struct vector* l = vector_create(32, point_destroy);
        struct vector* r = vector_create(32, point_destroy);
        _subdivide(points, l, r);
        _flatten_curve(l, grid, allow45, result);
        _flatten_curve(r, grid, allow45, result);
        vector_destroy(l);
        vector_destroy(r);
    }
}

void graphics_rasterize_cubic_bezier_segment(const point_t* startpt, const point_t* cpt1, const point_t* cpt2, const point_t* endpt, unsigned int grid, int allow45, struct vector* result)
{
    struct vector* curve = vector_create(4, point_destroy);
    vector_append(curve, point_copy(startpt));
    vector_append(curve, point_copy(cpt1));
    vector_append(curve, point_copy(cpt2));
    vector_append(curve, point_copy(endpt));
    _flatten_curve(curve, grid, allow45, result);
    vector_destroy(curve);
}

#define iabs(x) ((x) < 0 ? -(x) : (x))

void graphics_rasterize_line_segment(const point_t* startpt, const point_t* endpt, unsigned int grid, int allow45, struct vector* result)
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
    struct vector* pts = vector_create(128, point_destroy);
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
    if(startquadrant == endquadrant)
    {
        quadrants[0] = startquadrant;
        return;
    }
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

    vector_destroy(quarterpoints);
}

void graphics_rasterize_arc_segment(point_t* startpt, double startangle, double endangle, coordinate_t radius, int clockwise, unsigned int grid, int allow45, struct vector* result)
{
    coordinate_t cx = startpt->x - cos(startangle * M_PI / 180) * radius;
    coordinate_t cy = startpt->y - sin(startangle * M_PI / 180) * radius;
    _circle(cx, cy, radius, startangle, endangle, clockwise, grid, allow45, result);
}

