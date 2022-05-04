#include "shape.h"

#include <stdlib.h>

#include "graphics.h"
#include "geometry.h"

static shape_t* _create_shape(enum shapetype type, generics_t* layer, size_t capacity)
{
    shape_t* shape = malloc(sizeof(*shape));
    shape->type = type;
    shape->points = vector_create(capacity);
    shape->layer = layer;
    return shape;
}

shape_t* shape_create_rectangle(generics_t* layer, coordinate_t bl_x, coordinate_t bl_y, coordinate_t tr_x, coordinate_t tr_y)
{
    shape_t* shape = _create_shape(RECTANGLE, layer, 2);
    vector_append(shape->points, point_create(bl_x, bl_y));
    vector_append(shape->points, point_create(tr_x, tr_y));
    return shape;
}

shape_t* shape_create_polygon(generics_t* layer, size_t capacity)
{
    shape_t* shape = _create_shape(POLYGON, layer, capacity);
    return shape;
}

shape_t* shape_create_path(generics_t* layer, size_t capacity, ucoordinate_t width, coordinate_t extstart, coordinate_t extend)
{
    shape_t* shape = _create_shape(PATH, layer, capacity);
    path_properties_t* properties = malloc(sizeof(path_properties_t));
    properties->width = width;
    properties->extension[0] = extstart;
    properties->extension[1] = extend;
    shape->properties = properties;
    return shape;
}

shape_t* shape_create_curve(generics_t* layer, point_t* origin)
{
    shape_t* shape = _create_shape(CURVE, layer, 0);
    shape_append(shape, origin->x, origin->y);
    shape->properties = vector_create(8);
    return shape;
}

shape_t* shape_copy(shape_t* self)
{
    shape_t* new;
    if(self->type == RECTANGLE)
    {
        point_t* bl = vector_get(self->points, 0);
        point_t* tr = vector_get(self->points, 1);
        new = shape_create_rectangle(self->layer, bl->x, bl->y, tr->x, tr->y);
    }
    else
    {
        if(self->type == POLYGON)
        {
            new = shape_create_polygon(self->layer, vector_capacity(self->points));
        }
        else // PATH
        {
            path_properties_t* properties = self->properties;
            new = shape_create_path(self->layer, vector_capacity(self->points), properties->width, properties->extension[0], properties->extension[1]);
        }
        for(unsigned int i = 0; i < vector_size(self->points); ++i)
        {
            vector_append(new->points, point_copy(vector_get(self->points, i)));
        }
    }
    return new;
}

void shape_destroy(shape_t* shape)
{
    vector_destroy(shape->points, point_destroy);
    if(shape->type == PATH)
    {
        free(shape->properties);
    }
    if(shape->type == CURVE)
    {
        vector_destroy(shape->properties, free);
    }
    free(shape);
}

point_t* shape_get_point(shape_t* shape, size_t index)
{
    return vector_get(shape->points, index);
}

static void _append_unconditionally(shape_t* shape, coordinate_t x, coordinate_t y)
{
    if(shape->type == RECTANGLE)
    {
        return;
    }
    vector_append(shape->points, point_create(x, y));
}

void shape_append(shape_t* shape, coordinate_t x, coordinate_t y)
{
    // don't append points that are equal as the last one
    if(vector_size(shape->points) > 0)
    {
        point_t* lastpt = vector_get(shape->points, vector_size(shape->points) - 1);
        if((lastpt->x == x) && (lastpt->y == y))
        {
            return;
        }
    }
    _append_unconditionally(shape, x, y);
}

int shape_get_path_width(shape_t* shape, ucoordinate_t* width)
{
    if(shape->type != PATH)
    {
        return 0;
    }
    *width = ((path_properties_t*)shape->properties)->width;
    return 1;
}

int shape_get_path_extension(shape_t* shape, coordinate_t* start, coordinate_t* end)
{
    if(shape->type != PATH)
    {
        return 0;
    }
    *start = ((path_properties_t*)shape->properties)->extension[0];
    *end = ((path_properties_t*)shape->properties)->extension[1];
    return 1;
}

int shape_is_empty(shape_t* shape)
{
    return shape->layer->size == 0;
}

void shape_translate(shape_t* shape, coordinate_t dx, coordinate_t dy)
{
    for(unsigned int i = 0; i < vector_size(shape->points); ++i)
    {
        point_t* pt = vector_get(shape->points, i);
        point_translate(pt, dx, dy);
    }
}

static void _correct_rectangle_point_order(shape_t* shape)
{
    if(shape->type == RECTANGLE)
    {
        // order of points matter, check if bottom left is still bottom left
        point_t* bl = vector_get(shape->points, 0);
        point_t* tr = vector_get(shape->points, 1);
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
    for(unsigned int i = 0; i < vector_size(shape->points); ++i)
    {
        transformationmatrix_apply_transformation(matrix, vector_get(shape->points, i));
    }
    _correct_rectangle_point_order(shape);
}

void shape_apply_inverse_transformation(shape_t* shape, transformationmatrix_t* matrix)
{
    for(unsigned int i = 0; i < vector_size(shape->points); ++i)
    {
        transformationmatrix_apply_inverse_transformation(matrix, vector_get(shape->points, i));
    }
    _correct_rectangle_point_order(shape);
}

coordinate_t shape_get_width(const shape_t* shape)
{
    coordinate_t minx = COORDINATE_MAX;
    coordinate_t maxx = COORDINATE_MIN;
    for(unsigned int i = 0; i < vector_size(shape->points); ++i)
    {
        point_t* pt = vector_get(shape->points, i);
        if(pt->x < minx)
        {
            minx = pt->x;
        }
        if(pt->x > maxx)
        {
            maxx = pt->x;
        }
    }
    return maxx - minx;
}

coordinate_t shape_get_height(const shape_t* shape)
{
    coordinate_t miny = COORDINATE_MAX;
    coordinate_t maxy = COORDINATE_MIN;
    for(unsigned int i = 0; i < vector_size(shape->points); ++i)
    {
        point_t* pt = vector_get(shape->points, i);
        if(pt->y < miny)
        {
            miny = pt->y;
        }
        if(pt->y > maxy)
        {
            maxy = pt->y;
        }
    }
    return maxy - miny;
}

void shape_get_width_height(const shape_t* shape, coordinate_t* width, coordinate_t* height)
{
    coordinate_t minx = COORDINATE_MAX;
    coordinate_t maxx = COORDINATE_MIN;
    coordinate_t miny = COORDINATE_MAX;
    coordinate_t maxy = COORDINATE_MIN;
    for(unsigned int i = 0; i < vector_size(shape->points); ++i)
    {
        point_t* pt = vector_get(shape->points, i);
        if(pt->x < minx)
        {
            minx = pt->x;
        }
        if(pt->x > maxx)
        {
            maxx = pt->x;
        }
        if(pt->y < miny)
        {
            miny = pt->y;
        }
        if(pt->y > maxy)
        {
            maxy = pt->y;
        }
    }
    *width = maxx - minx;
    *height = maxy - miny;
}

#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

void shape_get_minmax_xy(const shape_t* shape, const transformationmatrix_t* trans, coordinate_t* minxp, coordinate_t* minyp, coordinate_t* maxxp, coordinate_t* maxyp)
{
    coordinate_t minx = COORDINATE_MAX;
    coordinate_t maxx = COORDINATE_MIN;
    coordinate_t miny = COORDINATE_MAX;
    coordinate_t maxy = COORDINATE_MIN;
    switch(shape->type)
    {
        // FIXME: also include paths
        case RECTANGLE:
        case POLYGON:
        case TRIANGULATED_POLYGON:
        case CURVE: // FIXME: this likely overestimates the bounding box of curves
            for(unsigned int i = 0; i < vector_size(shape->points); ++i)
            {
                point_t* pt = vector_get(shape->points, i);
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
    *minxp = minx;
    *minyp = miny;
    *maxxp = maxx;
    *maxyp = maxy;
}

int shape_get_center(shape_t* shape, coordinate_t* x, coordinate_t* y)
{
    if(shape->type != RECTANGLE)
    {
        return 0;
    }
    point_t* bl = vector_get(shape->points, 0);
    point_t* tr = vector_get(shape->points, 1);
    *x = (bl->x + tr->x) / 2;
    *y = (bl->y + tr->y) / 2;
    return 1;
}

int shape_resize_lrtb(shape_t* shape, coordinate_t left, coordinate_t right, coordinate_t top, coordinate_t bottom)
{
    if(shape->type != RECTANGLE)
    {
        return 0;
    }
    point_t* bl = vector_get(shape->points, 0);
    point_t* tr = vector_get(shape->points, 1);
    point_translate(bl, -left, -bottom);
    point_translate(tr, right, top);
    return 0;
}

void shape_curve_add_line_segment(shape_t* shape, point_t* pt)
{
    if(shape->type != CURVE)
    {
        return;
    }
    _append_unconditionally(shape, pt->x, pt->y);
    struct vector* curve_segments = shape->properties;
    struct curve_segment* segment = malloc(sizeof(*segment));
    segment->type = LINE;
    vector_append(curve_segments, segment);
}

void shape_curve_add_arc_segment(shape_t* shape, double startangle, double endangle, coordinate_t radius)
{
    if(shape->type != CURVE)
    {
        return;
    }
    struct vector* curve_segments = shape->properties;
    struct curve_segment* segment = malloc(sizeof(*segment));
    segment->type = ARC;
    segment->properties.arc_startangle = startangle;
    segment->properties.arc_endangle = endangle;
    segment->properties.arc_radius = radius;
    vector_append(curve_segments, segment);
}

void shape_resolve_path(shape_t* shape)
{
    if(shape->type != PATH)
    {
        return;
    }
    int miterjoin = 1;
    path_properties_t* properties = shape->properties;
    shape_t* new = geometry_path_to_polygon(shape->layer, vector_content(shape->points), vector_size(shape->points), properties->width, miterjoin);
    free(shape->properties);
    vector_destroy(shape->points, point_destroy);
    shape->properties = NULL;
    shape->points = new->points;
    shape->type = new->type;
    free(new);
}

void shape_rasterize_curve(shape_t* shape)
{
    if(shape->type != CURVE)
    {
        return;
    }
    // FIXME: add_curve_xxx_segment MUST also specify the type, then we can iterate over the individual segments here!
    struct vector* rastered_points = vector_create(1024);
    size_t ptidx = 0;
    struct vector_iterator* it = vector_iterator_create(shape->properties);
    while(vector_iterator_is_valid(it))
    {
        struct curve_segment* segment = vector_iterator_get(it);
        switch(segment->type)
        {
            case LINE:
                graphics_raster_line_segment(
                    vector_get(shape->points, ptidx),
                    vector_get(shape->points, ptidx + 1),
                    100, 1, rastered_points);
                ptidx += 1;
                break;
            case ARC:
                // FIXME
                graphics_raster_arc_segment(
                    vector_get(shape->points, ptidx), 
                    segment->properties.arc_startangle,
                    segment->properties.arc_endangle,
                    segment->properties.arc_radius,
                    100, 1, rastered_points);
                ptidx += 1;
                break;
        }
        vector_iterator_next(it);
    }
    vector_iterator_destroy(it);
    // properties and the old points have to be destroyed here
    vector_destroy(shape->points, point_destroy);
    vector_destroy(shape->properties, free);
    shape->type = POLYGON;
    shape->points = rastered_points;
}

void shape_triangulate_polygon(shape_t* shape)
{
    if(shape->type != POLYGON)
    {
        return;
    }
    struct vector* result = geometry_triangulate_polygon(shape->points);
    vector_destroy(shape->points, point_destroy);
    shape->points = result;
    shape->type = TRIANGULATED_POLYGON;
}
