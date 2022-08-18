#include "shape.h"

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "graphics.h"
#include "geometry.h"

struct rectangle {
    point_t* bl;
    point_t* tr;
};

struct polygon {
    struct vector* points;
};

struct path {
    struct vector* points;
    ucoordinate_t width;
    coordinate_t extension[2];
};

struct shape {
    enum shapetype {
        RECTANGLE,
        POLYGON,
        TRIANGULATED_POLYGON, // re-uses struct polygon
        PATH,
        CURVE
    } type;
    void* content;
    struct generics* layer;
};

static struct shape* _create_shape(enum shapetype type, struct generics* layer)
{
    struct shape* shape = malloc(sizeof(*shape));
    shape->type = type;
    shape->layer = layer;
    return shape;
}

struct shape* shape_create_rectangle(struct generics* layer, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try)
{
    struct shape* shape = _create_shape(RECTANGLE, layer);
    struct rectangle* rectangle = malloc(sizeof(*rectangle));
    rectangle->bl = point_create(blx, bly);
    rectangle->tr = point_create(trx, try);
    shape->content = rectangle;
    return shape;
}

struct shape* shape_create_polygon(struct generics* layer, size_t capacity)
{
    struct shape* shape = _create_shape(POLYGON, layer);
    struct polygon* polygon = malloc(sizeof(*polygon));
    polygon->points = vector_create(capacity);
    shape->content = polygon;
    return shape;
}

struct shape* shape_create_path(struct generics* layer, size_t capacity, ucoordinate_t width, coordinate_t extstart, coordinate_t extend)
{
    struct shape* shape = _create_shape(PATH, layer);
    struct path* path = malloc(sizeof(*path));
    path->points = vector_create(capacity);
    path->width = width;
    path->extension[0] = extstart;
    path->extension[1] = extend;
    shape->content = path;
    return shape;
}

struct shape* shape_create_curve(struct generics* layer, coordinate_t x, coordinate_t y, unsigned int grid, int allow45)
{
    struct shape* shape = _create_shape(CURVE, layer);
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
    struct shape* self = v;
    struct shape* new;
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
        case CURVE:
        {
            struct curve* curve = self->content;
            new = shape_create_curve(self->layer, curve->origin->x, curve->origin->y, curve->grid, curve->allow45);
            for(unsigned int i = 0; i < vector_size(curve->segments); ++i)
            {
                struct curve_segment* segment = vector_get(curve->segments, i);
                struct curve_segment* new_segment = malloc(sizeof(*new_segment));
                new_segment->type = segment->type;
                if(segment->type == LINESEGMENT)
                {
                    new_segment->data.pt = point_copy(segment->data.pt);
                }
                else
                {
                    new_segment->data = segment->data;
                }
            }
            break;
        }
    }
    return new;
}

void shape_destroy(void* v)
{
    struct shape* shape = v;
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

static void _append_unconditionally(struct shape* shape, coordinate_t x, coordinate_t y)
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

void shape_append(struct shape* shape, coordinate_t x, coordinate_t y)
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

const struct hashmap* shape_get_main_layerdata(const struct shape* shape)
{
    return generics_get_first_layer_data(shape->layer);
}

struct generics* shape_get_layer(struct shape* shape)
{
    return shape->layer;
}

int shape_is_rectangle(struct shape* shape)
{
    return shape->type == RECTANGLE;
}

int shape_is_path(struct shape* shape)
{
    return shape->type == PATH;
}

int shape_is_polygon(struct shape* shape)
{
    return shape->type == POLYGON;
}

int shape_is_triangulated_polygon(struct shape* shape)
{
    return shape->type == TRIANGULATED_POLYGON;
}

int shape_is_curve(struct shape* shape)
{
    return shape->type == CURVE;
}

void* shape_get_content(struct shape* shape)
{
    return shape->content;
}

int shape_get_rectangle_points(struct shape* shape, point_t** bl, point_t** tr)
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

int shape_get_polygon_points(struct shape* shape, struct vector** points)
{
    if(shape->type != POLYGON && shape->type != TRIANGULATED_POLYGON)
    {
        return 0;
    }
    struct polygon* polygon = shape->content;
    *points = polygon->points;
    return 1;
}

int shape_get_path_points(struct shape* shape, struct vector** points)
{
    if(shape->type != PATH)
    {
        return 0;
    }
    struct path* path = shape->content;
    *points = path->points;
    return 1;
}

int shape_get_path_width(struct shape* shape, ucoordinate_t* width)
{
    if(shape->type != PATH)
    {
        return 0;
    }
    struct path* path = shape->content;
    *width = path->width;
    return 1;
}

int shape_get_path_extension(struct shape* shape, coordinate_t* start, coordinate_t* end)
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

int shape_get_curve_origin(struct shape* shape, point_t** originp)
{
    if(shape->type != CURVE)
    {
        return 0;
    }
    struct curve* curve = shape->content;
    *originp = curve->origin;
    return 1;
}

int shape_is_empty(struct shape* shape)
{
    return generics_is_empty(shape->layer);
}

void shape_translate(struct shape* shape, coordinate_t dx, coordinate_t dy)
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
        case CURVE:
        {
            struct curve* curve = shape->content;
            point_translate(curve->origin, dx, dy);
            for(unsigned int i = 0; i < vector_size(curve->segments); ++i)
            {
                struct curve_segment* segment = vector_get(curve->segments, i);
                if(segment->type == LINESEGMENT)
                {
                    point_translate(segment->data.pt, dx, dy);
                }
            }
            break;
        }
    }
}

static void _correct_rectangle_point_order(struct shape* shape)
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

void shape_apply_transformation(struct shape* shape, struct transformationmatrix* matrix)
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

void shape_apply_inverse_transformation(struct shape* shape, struct transformationmatrix* matrix)
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

coordinate_t shape_get_width(const struct shape* shape)
{
    coordinate_t width, height;
    shape_get_width_height(shape, &width, &height);
    (void) height; // not used
    return width;
}

coordinate_t shape_get_height(const struct shape* shape)
{
    coordinate_t width, height;
    shape_get_width_height(shape, &width, &height);
    (void) width; // not used
    return height;
}

void shape_get_width_height(const struct shape* shape, coordinate_t* widthp, coordinate_t* heightp)
{
    coordinate_t minx, miny, maxx, maxy;
    shape_get_minmax_xy(shape, NULL, &minx, &miny, &maxx, &maxy);
    *widthp = maxx - minx;
    *heightp = maxy - miny;
}

void shape_get_minmax_xy(const struct shape* shape, const struct transformationmatrix* trans, coordinate_t* minxp, coordinate_t* minyp, coordinate_t* maxxp, coordinate_t* maxyp)
{
    point_t* min = point_create_minimum();
    point_t* max = point_create_maximum();
    switch(shape->type)
    {
        case RECTANGLE:
        {
            struct rectangle* rectangle = shape->content;
            point_t bl = *rectangle->bl;
            point_t tr = *rectangle->tr;
            if(trans)
            {
                transformationmatrix_apply_transformation(trans, &bl);
                transformationmatrix_apply_transformation(trans, &tr);
            }
            point_update_minimum(&min, &bl);
            point_update_maximum(&max, &tr);
            break;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon* polygon = shape->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                point_t* ptr = vector_get(polygon->points, i);
                point_t pt = *ptr;
                if(trans)
                {
                    transformationmatrix_apply_transformation(trans, &pt);
                }
                point_update_minimum(&min, &pt);
                point_update_maximum(&max, &pt);
            }
            break;
        }
        case PATH:
        {
            struct path* path = shape->content;
            for(unsigned int i = 0; i < vector_size(path->points); ++i)
            {
                point_t* ptr = vector_get(path->points, i);
                point_t pt = *ptr;
                if(trans)
                {
                    transformationmatrix_apply_transformation(trans, &pt);
                }
                point_update_minimum(&min, &pt);
                point_update_maximum(&max, &pt);
            }
            break;
        }
        //case CURVE: break;
    }
    *minxp = min->x;
    *minyp = min->y;
    *maxxp = max->x;
    *maxyp = max->y;
    point_destroy(min);
    point_destroy(max);
}

int shape_get_center(struct shape* shape, coordinate_t* x, coordinate_t* y)
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

void shape_resize_lrtb(struct shape* shape, coordinate_t left, coordinate_t right, coordinate_t top, coordinate_t bottom)
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

void shape_curve_add_line_segment(struct shape* shape, point_t* pt)
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

void shape_curve_add_arc_segment(struct shape* shape, double startangle, double endangle, coordinate_t radius, int clockwise)
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

void shape_resolve_path(struct shape* shape)
{
    if(shape->type != PATH)
    {
        return;
    }
    int miterjoin = 1;
    struct path* path = shape->content;
    struct shape* new = geometry_path_to_polygon(shape->layer, vector_content(path->points), vector_size(path->points), path->width, miterjoin);
    shape->content = new->content;
    shape->type = new->type;
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

void shape_rasterize_curve(struct shape* shape)
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

void shape_triangulate_polygon(struct shape* shape)
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
