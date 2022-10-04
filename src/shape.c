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
    const struct generics* layer;
};

static struct shape* _create_shape(enum shapetype type, const struct generics* layer)
{
    struct shape* shape = malloc(sizeof(*shape));
    shape->type = type;
    shape->layer = layer;
    return shape;
}

struct shape* shape_create_rectangle(const struct generics* layer, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try)
{
    struct shape* shape = _create_shape(RECTANGLE, layer);
    struct rectangle* rectangle = malloc(sizeof(*rectangle));
    rectangle->bl = point_create(blx, bly);
    rectangle->tr = point_create(trx, try);
    shape->content = rectangle;
    return shape;
}

struct shape* shape_create_polygon(const struct generics* layer, size_t capacity)
{
    struct shape* shape = _create_shape(POLYGON, layer);
    struct polygon* polygon = malloc(sizeof(*polygon));
    polygon->points = vector_create(capacity);
    shape->content = polygon;
    return shape;
}

struct shape* shape_create_path(const struct generics* layer, size_t capacity, ucoordinate_t width, coordinate_t extstart, coordinate_t extend)
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

struct shape* shape_create_curve(const struct generics* layer, coordinate_t x, coordinate_t y, unsigned int grid, int allow45)
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

static void _remove_superfluous_points(struct vector* pts)
{
    for(size_t i = vector_size(pts) - 2; i > 1; --i)
    {
        point_t* pt1 = vector_get(pts, i - 1);
        point_t* pt2 = vector_get(pts, i);
        point_t* pt3 = vector_get(pts, i + 1);
        if(((pt1->x == pt2->x) && (pt1->x == pt3->x)) || ((pt1->y == pt2->y) && (pt1->y == pt3->y)))
        {
            vector_remove(pts, i, point_destroy);
            --i;
        }
    }
}

void shape_cleanup(struct shape* shape)
{
    if(shape->type == POLYGON)
    {
        struct polygon* polygon = shape->content;
        _remove_superfluous_points(polygon->points);
    }
    if(shape->type == PATH)
    {
        struct path* path = shape->content;
        _remove_superfluous_points(path->points);
    }
}

void* shape_copy(const void* v)
{
    const struct shape* self = v;
    struct shape* new = NULL;
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
    _append_unconditionally(shape, x, y);
}

const struct hashmap* shape_get_main_layerdata(const struct shape* shape)
{
    return generics_get_first_layer_data(shape->layer);
}

const struct generics* shape_get_layer(const struct shape* shape)
{
    return shape->layer;
}

int shape_is_rectangle(const struct shape* shape)
{
    return shape->type == RECTANGLE;
}

int shape_is_path(const struct shape* shape)
{
    return shape->type == PATH;
}

int shape_is_polygon(const struct shape* shape)
{
    return shape->type == POLYGON;
}

int shape_is_triangulated_polygon(const struct shape* shape)
{
    return shape->type == TRIANGULATED_POLYGON;
}

int shape_is_curve(const struct shape* shape)
{
    return shape->type == CURVE;
}

const void* shape_get_content(const struct shape* shape)
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

int shape_get_transformed_rectangle_points(const struct shape* shape, const struct transformationmatrix* trans, point_t* bl, point_t* tr)
{
    if(shape->type != RECTANGLE)
    {
        return 0;
    }
    const struct rectangle* rectangle = shape->content;
    *bl = *rectangle->bl;
    *tr = *rectangle->tr;
    transformationmatrix_apply_transformation(trans, bl);
    transformationmatrix_apply_transformation(trans, tr);
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

int shape_get_transformed_polygon_points(const struct shape* shape, const struct transformationmatrix* trans, struct vector* points)
{
    if(shape->type != POLYGON && shape->type != TRIANGULATED_POLYGON)
    {
        return 0;
    }
    struct polygon* polygon = shape->content;
    struct vector_const_iterator* it = vector_const_iterator_create(polygon->points);
    while(vector_const_iterator_is_valid(it))
    {
        point_t* pt = point_copy(vector_const_iterator_get(it));
        transformationmatrix_apply_transformation(trans, pt);
        vector_append(points, pt);
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
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

int shape_get_transformed_path_points(const struct shape* shape, const struct transformationmatrix* trans, struct vector* points)
{
    if(shape->type != PATH)
    {
        return 0;
    }
    struct path* path = shape->content;
    struct vector_const_iterator* it = vector_const_iterator_create(path->points);
    while(vector_const_iterator_is_valid(it))
    {
        point_t* pt = point_copy(vector_const_iterator_get(it));
        transformationmatrix_apply_transformation(trans, pt);
        vector_append(points, pt);
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    return 1;
}

int shape_get_path_width(const struct shape* shape, ucoordinate_t* width)
{
    if(shape->type != PATH)
    {
        return 0;
    }
    struct path* path = shape->content;
    *width = path->width;
    return 1;
}

int shape_get_path_extension(const struct shape* shape, coordinate_t* start, coordinate_t* end)
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

int shape_get_transformed_curve_origin(const struct shape* shape, const struct transformationmatrix* trans, point_t* origin)
{
    if(shape->type != CURVE)
    {
        return 0;
    }
    struct curve* curve = shape->content;
    *origin = *curve->origin;
    transformationmatrix_apply_transformation(trans, origin);
    return 1;
}

int shape_is_empty(const struct shape* shape)
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

void shape_apply_transformation(struct shape* shape, const struct transformationmatrix* trans)
{
    switch(shape->type)
    {
        case RECTANGLE:
        {
            struct rectangle* rectangle = shape->content;
            transformationmatrix_apply_transformation(trans, rectangle->bl);
            transformationmatrix_apply_transformation(trans, rectangle->tr);
            break;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon* polygon = shape->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                point_t* pt = vector_get(polygon->points, i);
                transformationmatrix_apply_transformation(trans, pt);
            }
            break;
        }
        case PATH:
        {
            struct path* path = shape->content;
            for(unsigned int i = 0; i < vector_size(path->points); ++i)
            {
                point_t* pt = vector_get(path->points, i);
                transformationmatrix_apply_transformation(trans, pt);
            }
            break;
        }
        //case CURVE: break;
    }
    _correct_rectangle_point_order(shape);
}

void shape_apply_inverse_transformation(struct shape* shape, const struct transformationmatrix* trans)
{
    switch(shape->type)
    {
        case RECTANGLE:
        {
            struct rectangle* rectangle = shape->content;
            transformationmatrix_apply_inverse_transformation(trans, rectangle->bl);
            transformationmatrix_apply_inverse_transformation(trans, rectangle->tr);
            break;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon* polygon = shape->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                point_t* pt = vector_get(polygon->points, i);
                transformationmatrix_apply_inverse_transformation(trans, pt);
            }
            break;
        }
        case PATH:
        {
            struct path* path = shape->content;
            for(unsigned int i = 0; i < vector_size(path->points); ++i)
            {
                point_t* pt = vector_get(path->points, i);
                transformationmatrix_apply_inverse_transformation(trans, pt);
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
    point_t* min = point_create_maximum();
    point_t* max = point_create_minimum();
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

int shape_get_center(const struct shape* shape, coordinate_t* x, coordinate_t* y)
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

static int _check_grid(const point_t* pt, unsigned int grid)
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

void shape_curve_add_line_segment(struct shape* shape, const point_t* pt)
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

void shape_resolve_path_inline(struct shape* shape)
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

struct shape* shape_resolve_path(const struct shape* shape)
{
    if(shape->type != PATH)
    {
        return NULL;
    }
    int miterjoin = 1;
    struct path* path = shape->content;
    struct shape* new = geometry_path_to_polygon(shape->layer, vector_content(path->points), vector_size(path->points), path->width, miterjoin);
    return new;
}

static coordinate_t _fix_to_grid(coordinate_t c, unsigned int grid)
{
    return (c / grid) * grid;
}

void shape_rasterize_curve_inline(struct shape* shape)
{
    if(shape->type != CURVE)
    {
        return;
    }
    // FIXME: add_curve_xxx_segment MUST also specify the type, then we can iterate over the individual segments here!
    struct vector* rastered_points = vector_create(1024);
    struct curve* curve = shape->content;
    struct vector_const_iterator* it = vector_const_iterator_create(curve->segments);
    point_t* lastpt = point_copy(curve->origin);
    while(vector_const_iterator_is_valid(it))
    {
        const struct curve_segment* segment = vector_const_iterator_get(it);
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
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    point_destroy(lastpt);
    point_destroy(curve->origin);
    vector_destroy(curve->segments, free);

    _remove_superfluous_points(rastered_points);

    struct polygon* polygon = malloc(sizeof(*polygon));
    polygon->points = rastered_points;
    shape->type = POLYGON;
    shape->content = polygon;
}

struct shape* shape_rasterize_curve(const struct shape* shape)
{
    if(shape->type != CURVE)
    {
        return NULL;
    }
    struct shape* new = shape_copy(shape);
    shape_rasterize_curve_inline(new);
    return new;
}

void shape_triangulate_polygon_inline(struct shape* shape)
{
    if(shape->type != POLYGON)
    {
        return;
    }
    struct polygon* polygon = shape->content;
    struct vector* result = geometry_triangulate_polygon(polygon->points);
    if(!result)
    {
        fputs("could not triangulate polygon\n", stderr);
        return;
    }
    vector_destroy(polygon->points, point_destroy);
    polygon->points = result;
    shape->type = TRIANGULATED_POLYGON;
}

struct shape* shape_triangulate_polygon(const struct shape* shape)
{
    if(shape->type != POLYGON)
    {
        return NULL;
    }
    struct shape* new = shape_copy(shape);
    struct vector* result = geometry_triangulate_polygon(((struct polygon*)shape->content)->points);
    ((struct polygon*)shape->content)->points = result;
    new->type = TRIANGULATED_POLYGON;
    return new;
}

