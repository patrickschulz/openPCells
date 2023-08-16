#include "placement.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "util.h"

int _between(coordinate_t p, coordinate_t a, coordinate_t b)
{
    return (p >= a && p <= b) || (p <= a && p >= b);
}

int _is_point_in_polygon(coordinate_t x, coordinate_t y, const struct vector* polygon)
{
    int inside = 0;
    size_t i = vector_size(polygon) - 1;
    size_t j = 0;
    while(j < vector_size(polygon))
    {
        const point_t* A = vector_get_const(polygon, i);
        const point_t* B = vector_get_const(polygon, j);
        // corner cases
        if(((x == point_getx(A) && y == point_gety(A)) || (x == point_getx(B) && y == point_gety(B))))
        {
            return 0;
        }
        if((point_gety(A) == point_gety(B) && y == point_gety(A) && _between(x, point_getx(A), point_getx(B))))
        {
            return 0;
        }
        if((_between(y, point_gety(A), point_gety(B)))) // if P inside the vertical range
        {
            // filter out "ray pass vertex" problem by treating the line a little lower
            if(((y == point_gety(A) && point_gety(B) >= point_gety(A)) || (y == point_gety(B) && point_gety(A) >= point_gety(B))))
            {
                goto POINT_IN_POLYGON_CONTINUE;
            }
            // calc cross product `PA X PB`, P lays on left side of AB if c > 0
            coordinate_t c = (point_getx(A) - x) * (point_gety(B) - y) - (point_getx(B) - x) * (point_gety(A) - y);
            if(c == 0)
            {
                return 0;
            }
            if((point_gety(A) < point_gety(B)) == (c > 0))
            {
                inside = !inside;
            }
        }
POINT_IN_POLYGON_CONTINUE:
        i = j;
        j = j + 1;
    }
    return inside ? 1 : -1;
}

static struct vector* _calculate_origins(const struct object* cell, const struct vector* targetarea, const struct vector* excludes)
{
    ucoordinate_t width, height;
    object_width_height_alignmentbox(cell, &width, &height);
    ucoordinate_t xpitch = width;
    ucoordinate_t ypitch = height;

    coordinate_t minx = COORDINATE_MAX;
    coordinate_t maxx = COORDINATE_MIN;
    coordinate_t miny = COORDINATE_MAX;
    coordinate_t maxy = COORDINATE_MIN;
    struct vector_const_iterator* it = vector_const_iterator_create(targetarea);
    while(vector_const_iterator_is_valid(it))
    {
        const point_t* pt = vector_const_iterator_get(it);
        coordinate_t x = point_getx(pt);
        coordinate_t y = point_gety(pt);
        if(x < minx)
        {
            minx = x;
        }
        if(x > maxx)
        {
            maxx = x;
        }
        if(y < miny)
        {
            miny = y;
        }
        if(y > maxy)
        {
            maxy = y;
        }
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);

    struct vector* origins = vector_create(32, point_destroy);
    coordinate_t x = minx + xpitch / 2;
    while(x < maxx)
    {
        coordinate_t y = miny + ypitch / 2;
        while(y < maxy)
        {
            int insert = _is_point_in_polygon(x, y, targetarea) != -1;
            if(excludes)
            {
                struct vector_const_iterator* exclude_it = vector_const_iterator_create(excludes);
                while(vector_const_iterator_is_valid(exclude_it))
                {
                    const struct vector* exclude = vector_const_iterator_get(exclude_it);
                    // FIXME: this needs a proper polygon intersection test
                    if(_is_point_in_polygon(x            , y             , exclude) == 1 ||
                       _is_point_in_polygon(x + width / 2, y             , exclude) == 1 ||
                       _is_point_in_polygon(x - width / 2, y             , exclude) == 1 ||
                       _is_point_in_polygon(x            , y + height / 2, exclude) == 1 ||
                       _is_point_in_polygon(x            , y - height / 2, exclude) == 1 ||
                       _is_point_in_polygon(x + width / 2, y + height / 2, exclude) == 1 ||
                       _is_point_in_polygon(x - width / 2, y + height / 2, exclude) == 1 ||
                       _is_point_in_polygon(x + width / 2, y - height / 2, exclude) == 1 ||
                       _is_point_in_polygon(x - width / 2, y - height / 2, exclude) == 1)
                    {
                        insert = 0;
                    }
                    vector_const_iterator_next(exclude_it);
                }
                vector_const_iterator_destroy(exclude_it);
            }
            if(insert)
            {
                vector_append(origins, point_create(x, y));
            }
            y = y + ypitch;
        }
        x = x + xpitch;
    }
    return origins;
}

struct vector* placement_place_within_boundary(struct object* toplevel, struct object* cell, const char* basename, const struct vector* targetarea, const struct vector* excludes)
{
    struct vector* origins = _calculate_origins(cell, targetarea, excludes);
    struct vector* children = vector_create(vector_size(origins), NULL);
    struct vector_const_iterator* origin_it = vector_const_iterator_create(origins);
    int i = 1;
    while(vector_const_iterator_is_valid(origin_it))
    {
        const point_t* origin = vector_const_iterator_get(origin_it);
        size_t len = strlen(basename) + 1 + util_num_digits(i);
        char* name = malloc(len + 1);
        sprintf(name, "%s_%d", basename, i);
        struct object* child = object_add_child(toplevel, cell, name);
        object_move_point_to_origin(child, origin);
        vector_append(children, child);
        free(name);
        i = i + 1;
        vector_const_iterator_next(origin_it);
    }
    vector_const_iterator_destroy(origin_it);
    vector_destroy(origins);
    return children;
}

void placement_place_within_boundary_merge(struct object* toplevel, struct object* cell, const struct vector* targetarea, const struct vector* excludes)
{
    struct vector* origins = _calculate_origins(cell, targetarea, excludes);
    struct vector_const_iterator* origin_it = vector_const_iterator_create(origins);
    while(vector_const_iterator_is_valid(origin_it))
    {
        const point_t* origin = vector_const_iterator_get(origin_it);
        object_move_to(cell, point_getx(origin), point_gety(origin));
        object_merge_into(toplevel, cell);
        vector_const_iterator_next(origin_it);
    }
    vector_const_iterator_destroy(origin_it);
    vector_destroy(origins);
}

struct object* placement_place_within_rectangular_boundary(struct object* toplevel, struct object* cell, const char* basename, const point_t* targetbl, const point_t* targettr)
{
    coordinate_t xpitch, ypitch;
    object_width_height_alignmentbox(cell, &xpitch, &ypitch);

    coordinate_t fillwidth = point_getx(targettr) - point_getx(targetbl);
    coordinate_t fillheight = point_gety(targettr) - point_gety(targetbl);

    coordinate_t xrep = fillwidth / xpitch;
    coordinate_t yrep = fillheight / ypitch;

    struct object* children = object_add_child_array(toplevel, cell, basename, xrep, yrep, xpitch, ypitch);
    object_translate(children, -(xrep - 1) * xpitch / 2, -(yrep - 1) * ypitch / 2);
    return children;
}

