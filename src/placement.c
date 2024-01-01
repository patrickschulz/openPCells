#include "placement.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "util.h"

static int _is_in_targetarea(coordinate_t x, coordinate_t y, coordinate_t width, coordinate_t height, const struct simple_polygon* targetarea)
{
    // FIXME: this needs a proper polygon intersection test
    return (polygon_is_point_in_simple_polygon(targetarea, x            , y             ) == 1) &&
           (polygon_is_point_in_simple_polygon(targetarea, x + width / 2, y             ) >= 0) &&
           (polygon_is_point_in_simple_polygon(targetarea, x - width / 2, y             ) >= 0) &&
           (polygon_is_point_in_simple_polygon(targetarea, x            , y + height / 2) >= 0) &&
           (polygon_is_point_in_simple_polygon(targetarea, x            , y - height / 2) >= 0) &&
           (polygon_is_point_in_simple_polygon(targetarea, x + width / 2, y + height / 2) >= 0) &&
           (polygon_is_point_in_simple_polygon(targetarea, x - width / 2, y + height / 2) >= 0) &&
           (polygon_is_point_in_simple_polygon(targetarea, x + width / 2, y - height / 2) >= 0) &&
           (polygon_is_point_in_simple_polygon(targetarea, x - width / 2, y - height / 2) >= 0);
}

static int _is_in_excludes(coordinate_t x, coordinate_t y, coordinate_t width, coordinate_t height, const struct polygon* excludes)
{
    // FIXME: this needs a proper polygon intersection test
    if(polygon_is_point_in_polygon(excludes, x            , y             ) == 1 ||
       polygon_is_point_in_polygon(excludes, x + width / 2, y             ) == 1 ||
       polygon_is_point_in_polygon(excludes, x - width / 2, y             ) == 1 ||
       polygon_is_point_in_polygon(excludes, x            , y + height / 2) == 1 ||
       polygon_is_point_in_polygon(excludes, x            , y - height / 2) == 1 ||
       polygon_is_point_in_polygon(excludes, x + width / 2, y + height / 2) == 1 ||
       polygon_is_point_in_polygon(excludes, x - width / 2, y + height / 2) == 1 ||
       polygon_is_point_in_polygon(excludes, x + width / 2, y - height / 2) == 1 ||
       polygon_is_point_in_polygon(excludes, x - width / 2, y - height / 2) == 1)
    {
        return 1;
    }
    return 0;
}

static void _get_minmax(const struct simple_polygon* targetarea, coordinate_t* minx, coordinate_t* miny, coordinate_t* maxx, coordinate_t* maxy)
{
    *minx = COORDINATE_MAX;
    *maxx = COORDINATE_MIN;
    *miny = COORDINATE_MAX;
    *maxy = COORDINATE_MIN;
    struct simple_polygon_const_iterator* it = simple_polygon_const_iterator_create(targetarea);
    while(simple_polygon_const_iterator_is_valid(it))
    {
        const point_t* pt = simple_polygon_const_iterator_get(it);
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
        simple_polygon_const_iterator_next(it);
    }
    simple_polygon_const_iterator_destroy(it);
}

struct vector* placement_calculate_origins(
    ucoordinate_t width, ucoordinate_t height,
    ucoordinate_t xpitch, ucoordinate_t ypitch,
    coordinate_t xstartshift, coordinate_t ystartshift,
    const struct simple_polygon* targetarea,
    const struct polygon* excludes
)
{
    coordinate_t minx, maxx, miny, maxy;
    _get_minmax(targetarea, &minx, &miny, &maxx, &maxy);

    // calculate x and y shifts (relies on integer mathematics)
    // basically, this calculates the maximum number of placed rectangles
    // and the corresponding required shift to center this amount
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

struct vector* placement_calculate_origins_centered(
    ucoordinate_t width, ucoordinate_t height,
    ucoordinate_t xpitch, ucoordinate_t ypitch,
    coordinate_t xstartshift, coordinate_t ystartshift,
    const struct simple_polygon* targetarea,
    const struct polygon* excludes
)
{
    coordinate_t minx, maxx, miny, maxy;
    _get_minmax(targetarea, &minx, &miny, &maxx, &maxy);

    // calculate x and y shifts (relies on integer mathematics)
    // basically, this calculates the maximum number of placed rectangles
    // and the corresponding required shift to center this amount
    int xshift = ((maxx - minx + xpitch - width) - ((maxx - minx + xpitch - width) / (xpitch)) * xpitch) / 2;
    int yshift = ((maxy - miny + ypitch - height) - ((maxy - miny + ypitch - height) / (ypitch)) * ypitch) / 2;

    struct vector* origins = vector_create(32, point_destroy);
    coordinate_t x = minx + ((xstartshift + xshift) % xpitch) + width / 2;
    while(x <= maxx)
    {
        coordinate_t y = miny + ((ystartshift + yshift) % ypitch) + height / 2;
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
    if(!name)
    {
        return NULL;
    }
    sprintf(name, "%s_%d", basename, i);
    struct object* child = object_add_child(toplevel, cell, name);
    object_move_point_to_origin(child, origin);
    free(name);
    return child;
}

void placement_place_at_origins(struct object* toplevel, struct object* cell, const struct vector* origins, const char* basename, struct vector* children)
{
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
}

struct vector* placement_place_on_grid(struct object* toplevel, struct object* cell, const char* basename, const point_t* basept, coordinate_t xpitch, coordinate_t ypitch, const struct vector* grid)
{
    struct vector* children = vector_create(32, NULL);
    struct vector_const_iterator* yit = vector_const_iterator_create(grid);
    unsigned int counter = 0;
    unsigned int yi = 0;
    while(vector_const_iterator_is_valid(yit))
    {
        const struct vector* yvec = vector_const_iterator_get(yit);
        struct vector_const_iterator* xit = vector_const_iterator_create(yvec);
        unsigned int xi = 0;
        while(vector_const_iterator_is_valid(xit))
        {
            const int* place = vector_const_iterator_get(xit);
            if(*place)
            {
                point_t* origin = point_copy(basept);
                point_translate(origin, xi * xpitch, yi * ypitch);
                struct object* child = _place_child(toplevel, cell, origin, basename, counter);
                point_destroy(origin);
                vector_append(children, child);
                ++counter;
            }
            ++xi;
            vector_const_iterator_next(xit);
        }
        vector_const_iterator_destroy(xit);
        ++yi;
        vector_const_iterator_next(yit);
    }
    vector_const_iterator_destroy(yit);
    return children;
}

struct vector* placement_place_within_boundary(struct object* toplevel, struct object* cell, const char* basename, const struct simple_polygon* targetarea, const struct polygon* excludes)
{
    ucoordinate_t width, height;
    object_width_height_alignmentbox(cell, &width, &height);
    struct vector* origins = placement_calculate_origins(width, height, width, height, width / 2, height / 2, targetarea, excludes);
    struct vector* children = vector_create(vector_size(origins), NULL);
    placement_place_at_origins(toplevel, cell, origins, basename, children);
    vector_destroy(origins);
    return children;
}

void placement_place_within_boundary_merge(struct object* toplevel, struct object* cell, const struct simple_polygon* targetarea, const struct polygon* excludes)
{
    ucoordinate_t width, height;
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
    ucoordinate_t xpitch, ypitch;
    object_width_height_alignmentbox(cell, &xpitch, &ypitch);
    coordinate_t fillwidth = point_getx(targettr) - point_getx(targetbl);
    coordinate_t fillheight = point_gety(targettr) - point_gety(targetbl);
    coordinate_t xrep = fillwidth / xpitch;
    coordinate_t yrep = fillheight / ypitch;
    struct object* children = object_add_child_array(toplevel, cell, basename, xrep, yrep, xpitch, ypitch);
    object_translate(
        children,
        (point_getx(targetbl) + point_getx(targettr)) / 2 - (xrep - 1) * xpitch / 2,
        (point_gety(targetbl) + point_gety(targettr)) / 2 - (yrep - 1) * ypitch / 2
    );
    return children;
}

static int _is_any_of_layers(struct const_vector* layers, struct const_vector* celllayers)
{
    for(size_t i = 0; i < const_vector_size(layers); ++i)
    {
        const struct generics* layer = const_vector_get(layers, i);
        for(size_t j = 0; j < const_vector_size(celllayers); ++j)
        {
            const struct generics* celllayer = const_vector_get(celllayers, j);
            if(layer == celllayer)
            {
                return 1;
            }
        }
    }
    return 0;
}

struct vector* placement_place_within_layer_boundaries(
    struct object* toplevel,
    struct vector* celllookup, // contains entries of struct placement_celllookup*
    const char* basename,
    const struct simple_polygon* targetarea,
    struct vector* layerexcludes // contains entries of struct placement_layerexclude*
)
{
    ucoordinate_t width, height;
    struct vector* children = vector_create(1, NULL);
    for(size_t cellindex = 0; cellindex < vector_size(celllookup); ++cellindex)
    {
        struct placement_celllookup* lookup = vector_get(celllookup, cellindex);
        struct object* cell = lookup->cell;
        struct const_vector* celllayers = lookup->layers;
        object_width_height_alignmentbox(cell, &width, &height);

        ucoordinate_t xpitch = width;
        ucoordinate_t ypitch = height;
        coordinate_t xstartshift = width / 2;
        coordinate_t ystartshift = height / 2;

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
                for(size_t excludeindex = 0; excludeindex < vector_size(layerexcludes); ++excludeindex)
                {
                    struct placement_layerexclude* layerexclude = vector_get(layerexcludes, excludeindex);
                    struct polygon* excludes = layerexclude->excludes;
                    struct const_vector* layers = layerexclude->layers;
                    if(_is_any_of_layers(layers, celllayers))
                    {
                        if(excludes && _is_in_excludes(x, y, width, height, excludes))
                        {
                            insert = 0;
                        }
                    }
                }
                if(insert)
                {
                    vector_append(origins, point_create(x, y));
                }
                y = y + ypitch;
            }
            x = x + xpitch;
        }

        // sub-basename
        size_t len = strlen(basename) + 1 + util_num_digits(cellindex);
        char* subbasename = malloc(len + 1);
        //if(!subname)
        //{
        //    return NULL;
        //}
        sprintf(subbasename, "%s_%zd", basename, cellindex);
        placement_place_at_origins(toplevel, cell, origins, subbasename, children);
        free(subbasename);
        vector_destroy(origins);
    }
    return children;
}

