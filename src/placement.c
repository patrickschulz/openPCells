#include "placement.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "layout_util.h"
#include "util.h"

static int _is_in_targetarea(coordinate_t x, coordinate_t y, coordinate_t width, coordinate_t height, const struct const_vector* targetarea)
{
    // FIXME: this needs a proper polygon intersection test
    return (layout_util_is_point_in_polygon(x            , y             , targetarea) == 1) &&
           (layout_util_is_point_in_polygon(x + width / 2, y             , targetarea) >= 0) &&
           (layout_util_is_point_in_polygon(x - width / 2, y             , targetarea) >= 0) &&
           (layout_util_is_point_in_polygon(x            , y + height / 2, targetarea) >= 0) &&
           (layout_util_is_point_in_polygon(x            , y - height / 2, targetarea) >= 0) &&
           (layout_util_is_point_in_polygon(x + width / 2, y + height / 2, targetarea) >= 0) &&
           (layout_util_is_point_in_polygon(x - width / 2, y + height / 2, targetarea) >= 0) &&
           (layout_util_is_point_in_polygon(x + width / 2, y - height / 2, targetarea) >= 0) &&
           (layout_util_is_point_in_polygon(x - width / 2, y - height / 2, targetarea) >= 0);
}

static int _is_in_excludes(coordinate_t x, coordinate_t y, coordinate_t width, coordinate_t height, const struct vector* excludes)
{
    int is_in_exclude = 0;
    struct vector_const_iterator* exclude_it = vector_const_iterator_create(excludes);
    while(vector_const_iterator_is_valid(exclude_it))
    {
        const struct const_vector* exclude = vector_const_iterator_get(exclude_it);
        // FIXME: this needs a proper polygon intersection test
        if(layout_util_is_point_in_polygon(x            , y             , exclude) == 1 ||
                layout_util_is_point_in_polygon(x + width / 2, y             , exclude) == 1 ||
                layout_util_is_point_in_polygon(x - width / 2, y             , exclude) == 1 ||
                layout_util_is_point_in_polygon(x            , y + height / 2, exclude) == 1 ||
                layout_util_is_point_in_polygon(x            , y - height / 2, exclude) == 1 ||
                layout_util_is_point_in_polygon(x + width / 2, y + height / 2, exclude) == 1 ||
                layout_util_is_point_in_polygon(x - width / 2, y + height / 2, exclude) == 1 ||
                layout_util_is_point_in_polygon(x + width / 2, y - height / 2, exclude) == 1 ||
                layout_util_is_point_in_polygon(x - width / 2, y - height / 2, exclude) == 1)
        {
            is_in_exclude = 1;
            break;
        }
        vector_const_iterator_next(exclude_it);
    }
    vector_const_iterator_destroy(exclude_it);
    return is_in_exclude;
}

static void _get_minmax(const struct const_vector* targetarea, coordinate_t* minx, coordinate_t* miny, coordinate_t* maxx, coordinate_t* maxy)
{
    *minx = COORDINATE_MAX;
    *maxx = COORDINATE_MIN;
    *miny = COORDINATE_MAX;
    *maxy = COORDINATE_MIN;
    struct const_vector_iterator* it = const_vector_iterator_create(targetarea);
    while(const_vector_iterator_is_valid(it))
    {
        const point_t* pt = const_vector_iterator_get(it);
        coordinate_t x = point_getx(pt);
        coordinate_t y = point_gety(pt);
        if(x < *minx)
        {
            *minx = x;
        }
        if(x > *maxx)
        {
            *maxx = x;
        }
        if(y < *miny)
        {
            *miny = y;
        }
        if(y > *maxy)
        {
            *maxy = y;
        }
        const_vector_iterator_next(it);
    }
    const_vector_iterator_destroy(it);
}

struct vector* placement_calculate_origins(
    ucoordinate_t width, ucoordinate_t height,
    ucoordinate_t xpitch, ucoordinate_t ypitch,
    coordinate_t xstartshift, coordinate_t ystartshift,
    const struct const_vector* targetarea,
    const struct vector* excludes
)
{
    coordinate_t minx, maxx, miny, maxy;
    _get_minmax(targetarea, &minx, &miny, &maxx, &maxy);

    // calculate x and y shifts (relies on integer mathematics)
    int xshift = ((maxx - minx) - ((maxx - minx) / (xpitch)) * xpitch) / 2;
    int yshift = ((maxy - miny) - ((maxy - miny) / (ypitch)) * ypitch) / 2;

    struct vector* origins = vector_create(32, point_destroy);
    coordinate_t x = minx + ((xstartshift + xshift) % xpitch);
    while(x <= maxx)
    {
        coordinate_t y = miny + ((ystartshift + yshift) % ypitch);
        while(y <= maxy)
        {
            int insert = _is_in_targetarea(x, y, width, height, targetarea);
            if(excludes && _is_in_excludes(x, y, width, height, excludes))
            {
                insert = 0;
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

static struct object* _place_child(struct object* toplevel, struct object* cell, const point_t* origin, const char* basename, int i)
{
    size_t len = strlen(basename) + 1 + util_num_digits(i);
    char* name = malloc(len + 1);
    sprintf(name, "%s_%d", basename, i);
    struct object* child = object_add_child(toplevel, cell, name);
    object_move_point_to_origin(child, origin);
    free(name);
    return child;
}

struct vector* placement_place_within_boundary(struct object* toplevel, struct object* cell, const char* basename, const struct const_vector* targetarea, const struct vector* excludes)
{
    ucoordinate_t width, height;
    object_width_height_alignmentbox(cell, &width, &height);
    struct vector* origins = placement_calculate_origins(width, height, width, height, width / 2, height / 2, targetarea, excludes);
    struct vector* children = vector_create(vector_size(origins), NULL);
    struct vector_const_iterator* origin_it = vector_const_iterator_create(origins);
    int i = 1;
    while(vector_const_iterator_is_valid(origin_it))
    {
        const point_t* origin = vector_const_iterator_get(origin_it);
        struct object* child = _place_child(toplevel, cell, origin, basename, i);
        vector_append(children, child);
        i = i + 1;
        vector_const_iterator_next(origin_it);
    }
    vector_const_iterator_destroy(origin_it);
    vector_destroy(origins);
    return children;
}

void placement_place_within_boundary_merge(struct object* toplevel, struct object* cell, const struct const_vector* targetarea, const struct vector* excludes)
{
    // FIXME: should be ucoordinate
    coordinate_t width, height;
    object_width_height_alignmentbox(cell, &width, &height);
    struct vector* origins = placement_calculate_origins(width, height, width, height, width / 2, height / 2, targetarea, excludes);
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
    // FIXME: should be ucoordinate, but this raises an error with the gcc analyzer regarding signed integer overflow. Not sure why and debugging is tedious
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

