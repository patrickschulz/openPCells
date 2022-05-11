#include "shape.h"

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "graphics.h"
#include "geometry.h"

static shape_t* _create_shape(enum shapetype type, generics_t* layer)
{
    shape_t* shape = malloc(sizeof(*shape));
    shape->type = type;
    shape->layer = layer;
    return shape;
}

shape_t* shape_create_rectangle(generics_t* layer, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try)
{
    shape_t* shape = _create_shape(RECTANGLE, layer);
    struct rectangle* rectangle = malloc(sizeof(*rectangle));
    rectangle->bl = point_create(blx, bly);
    rectangle->tr = point_create(trx, try);
    shape->content = rectangle;
    return shape;
}

shape_t* shape_create_polygon(generics_t* layer, size_t capacity)
{
    shape_t* shape = _create_shape(POLYGON, layer);
    struct polygon* polygon = malloc(sizeof(*polygon));
    polygon->points = vector_create(capacity);
    shape->content = polygon;
    return shape;
}

shape_t* shape_create_path(generics_t* layer, size_t capacity, ucoordinate_t width, coordinate_t extstart, coordinate_t extend)
{
    shape_t* shape = _create_shape(PATH, layer);
    struct path* path = malloc(sizeof(*path));
    path->points = vector_create(capacity);
    path->width = width;
    path->extension[0] = extstart;
    path->extension[1] = extend;
    shape->content = path;
    return shape;
}

shape_t* shape_create_curve(generics_t* layer, coordinate_t x, coordinate_t y, unsigned int grid, int allow45)
{
    shape_t* shape = _create_shape(CURVE, layer);
    struct curve* curve = malloc(sizeof(*curve));
    curve->origin = point_create(x, y);
    curve->segments = vector_create(8);
    curve->grid = grid;
    curve->allow45 = allow45;
    shape->content = curve;
    return shape;
}

void* shape_copy(void* v)
{
    shape_t* self = v;
    shape_t* new;
    switch(self->type)
    {
        case RECTANGLE:
        {
            struct rectangle* rectangle = self->content;
            new = shape_create_rectangle(self->layer, rectangle->bl->x, rectangle->bl->y, rectangle->tr->x, rectangle->tr->y);
            break;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon* polygon = self->content;
            new = shape_create_polygon(self->layer, vector_capacity(polygon->points));
            struct polygon* np = new->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                vector_append(np->points, point_copy(vector_get(polygon->points, i)));
            }
            break;
        }
        case PATH:
        {
            struct path* path = self->content;
            new = shape_create_path(self->layer, vector_capacity(path->points), path->width, path->extension[0], path->extension[1]);
            struct path* np = new->content;
            for(unsigned int i = 0; i < vector_size(path->points); ++i)
            {
                vector_append(np->points, point_copy(vector_get(path->points, i)));
            }
            break;
        }
        //case CURVE: break;
    }
    return new;
}

void shape_destroy(void* v)
{
    shape_t* shape = v;
    switch(shape->type)
    {
        case RECTANGLE:
        {
            struct rectangle* rectangle = shape->content;
            point_destroy(rectangle->bl);
            point_destroy(rectangle->tr);
            break;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon* polygon = shape->content;
            vector_destroy(polygon->points, point_destroy);
            break;
        }
        case PATH:
        {
            struct path* path = shape->content;
            vector_destroy(path->points, point_destroy);
            break;
        }
        case CURVE:
        {
            struct curve* curve = shape->content;
            point_destroy(curve->origin);
            vector_destroy(curve->segments, free);
            break;
        }
    }
    free(shape->content);
    free(shape);
}

static void _append_unconditionally(shape_t* shape, coordinate_t x, coordinate_t y)
{
    if(shape->type == POLYGON)
    {
        struct polygon* polygon = shape->content;
        vector_append(polygon->points, point_create(x, y));
    }
    if(shape->type == PATH)
    {
        struct path* path = shape->content;
        vector_append(path->points, point_create(x, y));
    }
}

void shape_append(shape_t* shape, coordinate_t x, coordinate_t y)
{
    // don't append points that are equal as the last one
    if(shape->type == POLYGON)
    {
        struct polygon* polygon = shape->content;
        if(vector_size(polygon->points) > 0)
        {
            point_t* lastpt = vector_get(polygon->points, vector_size(polygon->points) - 1);
            if((lastpt->x == x) && (lastpt->y == y))
            {
                return;
            }
        }
    }
    if(shape->type == PATH)
    {
        struct path* path = shape->content;
        if(vector_size(path->points) > 0)
        {
            point_t* lastpt = vector_get(path->points, vector_size(path->points) - 1);
            if((lastpt->x == x) && (lastpt->y == y))
            {
                return;
            }
        }
    }
    _append_unconditionally(shape, x, y);
}

const struct keyvaluearray* shape_get_main_layerdata(const shape_t* shape)
{
    return shape->layer->data[0];
}

int shape_get_rectangle_points(shape_t* shape, point_t** bl, point_t** tr)
{
    if(shape->type != RECTANGLE)
    {
        return 0;
    }
    struct rectangle* rectangle = shape->content;
    *bl = rectangle->bl;
    *tr = rectangle->tr;
    return 1;
}

int shape_get_polygon_points(shape_t* shape, struct vector** points)
{
    if(shape->type != POLYGON && shape->type != TRIANGULATED_POLYGON)
    {
        return 0;
    }
    struct polygon* polygon = shape->content;
    *points = polygon->points;
    return 1;
}

int shape_get_path_points(shape_t* shape, struct vector** points)
{
    if(shape->type != PATH)
    {
        return 0;
    }
    struct path* path = shape->content;
    *points = path->points;
    return 1;
}

int shape_get_path_width(shape_t* shape, ucoordinate_t* width)
{
    if(shape->type != PATH)
    {
        return 0;
    }
    struct path* path = shape->content;
    *width = path->width;
    return 1;
}

int shape_get_path_extension(shape_t* shape, coordinate_t* start, coordinate_t* end)
{
    if(shape->type != PATH)
    {
        return 0;
    }
    struct path* path = shape->content;
    *start = path->extension[0];
    *end = path->extension[1];
    return 1;
}

int shape_get_curve_origin(shape_t* shape, point_t** originp)
{
    if(shape->type != CURVE)
    {
        return 0;
    }
    struct curve* curve = shape->content;
    *originp = curve->origin;
    return 1;
}
int shape_is_empty(shape_t* shape)
{
    return generics_is_empty(shape->layer);
}

void shape_translate(shape_t* shape, coordinate_t dx, coordinate_t dy)
{
    switch(shape->type)
    {
        case RECTANGLE:
        {
            struct rectangle* rectangle = shape->content;
            point_translate(rectangle->bl, dx, dy);
            point_translate(rectangle->tr, dx, dy);
            break;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon* polygon = shape->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                point_t* pt = vector_get(polygon->points, i);
                point_translate(pt, dx, dy);
            }
            break;
        }
        case PATH:
        {
            struct path* path = shape->content;
            for(unsigned int i = 0; i < vector_size(path->points); ++i)
            {
                point_t* pt = vector_get(path->points, i);
                point_translate(pt, dx, dy);
            }
            break;
        }
        //case CURVE: break;
    }
}

static void _correct_rectangle_point_order(shape_t* shape)
{
    if(shape->type == RECTANGLE)
    {
        struct rectangle* rectangle = shape->content;
        // order of points matter, check if bottom left is still bottom left
        point_t* bl = rectangle->bl;
        point_t* tr = rectangle->bl;
        if(bl->x > tr->x)
        {
            coordinate_t tmp = bl->x;
            bl->x = tr->x;
            tr->x = tmp;
        }
        if(bl->y > tr->y)
        {
            coordinate_t tmp = bl->y;
            bl->y = tr->y;
            tr->y = tmp;
        }
    }
}

void shape_apply_transformation(shape_t* shape, transformationmatrix_t* matrix)
{
    switch(shape->type)
    {
        case RECTANGLE:
        {
            struct rectangle* rectangle = shape->content;
            transformationmatrix_apply_transformation(matrix, rectangle->bl);
            transformationmatrix_apply_transformation(matrix, rectangle->tr);
            break;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon* polygon = shape->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                point_t* pt = vector_get(polygon->points, i);
                transformationmatrix_apply_transformation(matrix, pt);
            }
            break;
        }
        case PATH:
        {
            struct path* path = shape->content;
            for(unsigned int i = 0; i < vector_size(path->points); ++i)
            {
                point_t* pt = vector_get(path->points, i);
                transformationmatrix_apply_transformation(matrix, pt);
            }
            break;
        }
        //case CURVE: break;
    }
    _correct_rectangle_point_order(shape);
}

void shape_apply_inverse_transformation(shape_t* shape, transformationmatrix_t* matrix)
{
    switch(shape->type)
    {
        case RECTANGLE:
        {
            struct rectangle* rectangle = shape->content;
            transformationmatrix_apply_inverse_transformation(matrix, rectangle->bl);
            transformationmatrix_apply_inverse_transformation(matrix, rectangle->tr);
            break;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon* polygon = shape->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                point_t* pt = vector_get(polygon->points, i);
                transformationmatrix_apply_inverse_transformation(matrix, pt);
            }
            break;
        }
        case PATH:
        {
            struct path* path = shape->content;
            for(unsigned int i = 0; i < vector_size(path->points); ++i)
            {
                point_t* pt = vector_get(path->points, i);
                transformationmatrix_apply_inverse_transformation(matrix, pt);
            }
            break;
        }
        //case CURVE: break;
    }
    _correct_rectangle_point_order(shape);
}

#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

coordinate_t shape_get_width(const shape_t* shape)
{
    coordinate_t minx = COORDINATE_MAX;
    coordinate_t maxx = COORDINATE_MIN;
    switch(shape->type)
    {
        case RECTANGLE:
        {
            struct rectangle* rectangle = shape->content;
            return rectangle->tr->x - rectangle->bl->x;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon* polygon = shape->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                point_t* pt = vector_get(polygon->points, i);
                maxx = max(maxx, pt->x);
            }
            break;
        }
        case PATH:
        {
            struct path* path = shape->content;
            for(unsigned int i = 0; i < vector_size(path->points); ++i)
            {
                point_t* pt = vector_get(path->points, i);
                minx = min(minx, pt->x);
                maxx = max(maxx, pt->x);
            }
            break;
        }
        //case CURVE: break;
    }
    return maxx - minx;
}

coordinate_t shape_get_height(const shape_t* shape)
{
    coordinate_t miny = COORDINATE_MAX;
    coordinate_t maxy = COORDINATE_MIN;
    switch(shape->type)
    {
        case RECTANGLE:
        {
            struct rectangle* rectangle = shape->content;
            return rectangle->tr->y - rectangle->bl->y;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon* polygon = shape->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                point_t* pt = vector_get(polygon->points, i);
                miny = min(miny, pt->y);
                maxy = max(maxy, pt->y);
            }
            break;
        }
        case PATH:
        {
            struct path* path = shape->content;
            for(unsigned int i = 0; i < vector_size(path->points); ++i)
            {
                point_t* pt = vector_get(path->points, i);
                miny = min(miny, pt->y);
                maxy = max(maxy, pt->y);
            }
            break;
        }
        //case CURVE: break;
    }
    return maxy - miny;
}

void shape_get_width_height(const shape_t* shape, coordinate_t* width, coordinate_t* height)
{
    coordinate_t minx = COORDINATE_MAX;
    coordinate_t maxx = COORDINATE_MIN;
    coordinate_t miny = COORDINATE_MAX;
    coordinate_t maxy = COORDINATE_MIN;
    switch(shape->type)
    {
        case RECTANGLE:
        {
            struct rectangle* rectangle = shape->content;
            minx = rectangle->bl->x;
            maxx = rectangle->tr->x;
            miny = rectangle->bl->y;
            maxy = rectangle->tr->y;
            break;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon* polygon = shape->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                point_t* pt = vector_get(polygon->points, i);
                minx = min(minx, pt->x);
                maxx = max(maxx, pt->x);
                miny = min(miny, pt->y);
                maxy = max(maxy, pt->y);
            }
            break;
        }
        case PATH:
        {
            struct path* path = shape->content;
            for(unsigned int i = 0; i < vector_size(path->points); ++i)
            {
                point_t* pt = vector_get(path->points, i);
                minx = min(minx, pt->x);
                maxx = max(maxx, pt->x);
                miny = min(miny, pt->y);
                maxy = max(maxy, pt->y);
            }
            break;
        }
        //case CURVE: break;
    }
    *width = maxx - minx;
    *height = maxy - miny;
}

void shape_get_minmax_xy(const shape_t* shape, const transformationmatrix_t* trans, coordinate_t* minxp, coordinate_t* minyp, coordinate_t* maxxp, coordinate_t* maxyp)
{
    coordinate_t minx = COORDINATE_MAX;
    coordinate_t maxx = COORDINATE_MIN;
    coordinate_t miny = COORDINATE_MAX;
    coordinate_t maxy = COORDINATE_MIN;
    switch(shape->type)
    {
        case RECTANGLE:
        {
            struct rectangle* rectangle = shape->content;
            minx = rectangle->bl->x;
            maxx = rectangle->tr->x;
            miny = rectangle->bl->y;
            maxy = rectangle->tr->y;
            transformationmatrix_apply_transformation_xy(trans, &minx, &miny);
            transformationmatrix_apply_transformation_xy(trans, &maxx, &maxy);
            break;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon* polygon = shape->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                point_t* pt = vector_get(polygon->points, i);
                coordinate_t x = pt->x;
                coordinate_t y = pt->y;
                transformationmatrix_apply_transformation_xy(trans, &x, &y);
                minx = min(minx, x);
                maxx = max(maxx, x);
                miny = min(miny, y);
                maxy = max(maxy, y);
            }
            break;
        }
        case PATH:
        {
            struct path* path = shape->content;
            for(unsigned int i = 0; i < vector_size(path->points); ++i)
            {
                point_t* pt = vector_get(path->points, i);
                coordinate_t x = pt->x;
                coordinate_t y = pt->y;
                transformationmatrix_apply_transformation_xy(trans, &x, &y);
                minx = min(minx, x);
                maxx = max(maxx, x);
                miny = min(miny, y);
                maxy = max(maxy, y);
            }
            break;
        }
        //case CURVE: break;
    }
    *minxp = minx;
    *minyp = miny;
    *maxxp = maxx;
    *maxyp = maxy;
}

int shape_get_center(shape_t* shape, coordinate_t* x, coordinate_t* y)
{
    if(shape->type != RECTANGLE) // FIXME: support other types
    {
        return 0;
    }
    struct rectangle* rectangle = shape->content;
    point_t* bl = rectangle->bl;
    point_t* tr = rectangle->tr;
    *x = (bl->x + tr->x) / 2;
    *y = (bl->y + tr->y) / 2;
    return 1;
}

void shape_resize_lrtb(shape_t* shape, coordinate_t left, coordinate_t right, coordinate_t top, coordinate_t bottom)
{
    if(shape->type != RECTANGLE) // FIXME: support other types
    {
        return;
    }
    struct rectangle* rectangle = shape->content;
    point_t* bl = rectangle->bl;
    point_t* tr = rectangle->tr;
    point_translate(bl, -left, -bottom);
    point_translate(tr, right, top);
}

static int _check_grid(point_t* pt, unsigned int grid)
{
    if((pt->x % grid) != 0)
    {
        return 0;
    }
    if((pt->y % grid) != 0)
    {
        return 0;
    }
    return 1;
}

void shape_curve_add_line_segment(shape_t* shape, point_t* pt)
{
    if(shape->type != CURVE)
    {
        return;
    }
    struct curve* curve = shape->content;
    if(!_check_grid(pt, curve->grid))
    {
        fprintf(stderr, "add curve line segment: point (%lld, %lld) is not on grid (%d)\n", pt->x, pt->y, curve->grid);
        return;
    }
    struct curve_segment* segment = malloc(sizeof(*segment));
    segment->type = LINESEGMENT;
    segment->data.pt = point_copy(pt);
    vector_append(curve->segments, segment);
}

void shape_curve_add_arc_segment(shape_t* shape, double startangle, double endangle, coordinate_t radius, int clockwise)
{
    if(shape->type != CURVE)
    {
        return;
    }
    struct curve* curve = shape->content;
    struct curve_segment* segment = malloc(sizeof(*segment));
    segment->type = ARCSEGMENT;
    segment->data.startangle = startangle;
    segment->data.endangle = endangle;
    segment->data.radius = radius;
    segment->data.clockwise = clockwise;
    vector_append(curve->segments, segment);
}

void shape_resolve_path(shape_t* shape)
{
    if(shape->type != PATH)
    {
        return;
    }
    int miterjoin = 1;
    struct path* path = shape->content;
    shape_t* new = geometry_path_to_polygon(shape->layer, vector_content(path->points), vector_size(path->points), path->width, miterjoin);
    shape->content = new->content;
    shape->type = POLYGON;
    vector_destroy(path->points, point_destroy);
    free(path);
    free(new);
}

static coordinate_t _fix_to_grid(coordinate_t c, unsigned int grid)
{
    return (c / grid) * grid;
}

static void _remove_superfluous_points(struct vector* pts)
{
    for(size_t i = vector_size(pts) - 1; i > 0; --i)
    {
        point_t* this = vector_get(pts, i);
        point_t* that = vector_get(pts, i - 1);
        if(this->x == that->x && this->y == that->y)
        {
            vector_remove(pts, i, point_destroy);
        }
    }
}

void shape_rasterize_curve(shape_t* shape)
{
    if(shape->type != CURVE)
    {
        return;
    }
    // FIXME: add_curve_xxx_segment MUST also specify the type, then we can iterate over the individual segments here!
    struct vector* rastered_points = vector_create(1024);
    struct curve* curve = shape->content;
    struct vector_iterator* it = vector_iterator_create(curve->segments);
    point_t* lastpt = point_copy(curve->origin);
    while(vector_iterator_is_valid(it))
    {
        struct curve_segment* segment = vector_iterator_get(it);
        switch(segment->type)
        {
            case LINESEGMENT:
            {
                graphics_raster_line_segment(
                    lastpt, segment->data.pt,
                    curve->grid, curve->allow45, rastered_points);
                lastpt->x = segment->data.pt->x;
                lastpt->y = segment->data.pt->y;
                break;
            }
            case ARCSEGMENT:
            {
                graphics_raster_arc_segment(
                    lastpt,
                    segment->data.startangle,
                    segment->data.endangle,
                    segment->data.radius,
                    segment->data.clockwise,
                    curve->grid, curve->allow45, rastered_points);
                double startcos = cos(segment->data.startangle * M_PI / 180);
                double startsin = sin(segment->data.startangle * M_PI / 180);
                double endcos = cos(segment->data.endangle * M_PI / 180);
                double endsin = sin(segment->data.endangle * M_PI / 180);
                lastpt->x = lastpt->x + _fix_to_grid((endcos - startcos) * segment->data.radius, curve->grid);
                lastpt->y = lastpt->y + _fix_to_grid((endsin - startsin) * segment->data.radius, curve->grid);
                break;
            }
        }
        vector_iterator_next(it);
    }
    point_destroy(lastpt);
    vector_iterator_destroy(it);
    point_destroy(curve->origin);
    vector_destroy(curve->segments, free);

    _remove_superfluous_points(rastered_points);

    struct polygon* polygon = malloc(sizeof(*polygon));
    polygon->points = rastered_points;
    shape->type = POLYGON;
    shape->content = polygon;
}

void shape_triangulate_polygon(shape_t* shape)
{
    if(shape->type != POLYGON)
    {
        return;
    }
    struct polygon* polygon = shape->content;
    struct vector* result = geometry_triangulate_polygon(polygon->points);
    vector_destroy(polygon->points, point_destroy);
    polygon->points = result;
    shape->type = TRIANGULATED_POLYGON;
}
