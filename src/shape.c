#include "shape.h"

#include <assert.h>
#include <stdlib.h>
#include <stdio.h>

#include "math.h"
#include "point.h"
#include "graphics.h"
#include "geometry.h"

struct rectangle {
    struct point content [2];
};

// macros, because this simplifies const-correctness
#define _bl(rect) (rect->content + 0)
#define _tr(rect) (rect->content + 1)

struct polygon_shape {
    struct vector* points;
};

struct path {
    struct vector* points;
    ucoordinate_t width;
    coordinate_t extension[2];
};

struct curve_segment {
    enum segment_type {
        LINE_SEGMENT,
        ARC_SEGMENT,
        CUBIC_BEZIER_SEGMENT
    } type;
    union {
        struct {
            struct point* pt;
        };
        struct {
            double startangle;
            double endangle;
            coordinate_t radius;
            int clockwise;
        };
        struct {
            struct point* cpt1;
            struct point* cpt2;
            struct point* endpt;
        };
    };
};

struct curve {
    struct point* origin;
    struct vector* segments;
    unsigned int grid;
    int allow45;
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
    _bl(rectangle)->x = blx;
    _bl(rectangle)->y = bly;
    _tr(rectangle)->x = trx;
    _tr(rectangle)->y = try;
    shape->content = rectangle;
    return shape;
}

struct shape* shape_create_polygon(const struct generics* layer, size_t capacity)
{
    struct shape* shape = _create_shape(POLYGON, layer);
    struct polygon_shape* polygon = malloc(sizeof(*polygon));
    polygon->points = vector_create(capacity, point_destroy);
    shape->content = polygon;
    return shape;
}

struct shape* shape_create_path(const struct generics* layer, size_t capacity, ucoordinate_t width, coordinate_t extstart, coordinate_t extend)
{
    struct shape* shape = _create_shape(PATH, layer);
    struct path* path = malloc(sizeof(*path));
    path->points = vector_create(capacity, point_destroy);
    path->width = width;
    path->extension[0] = extstart;
    path->extension[1] = extend;
    shape->content = path;
    return shape;
}

static void _destroy_segment(void* v)
{
    struct curve_segment* segment = v;
    switch(segment->type)
    {
        case LINE_SEGMENT:
        {
            point_destroy(segment->pt);
            break;
        }
        case ARC_SEGMENT:
        {
            break;
        }
        case CUBIC_BEZIER_SEGMENT:
        {
            point_destroy(segment->cpt1);
            point_destroy(segment->cpt2);
            point_destroy(segment->endpt);
        }
    }
    free(segment);
}

static int _check_grid(const struct point* pt, unsigned int grid)
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

static void _fix_grid(struct point* pt, unsigned int grid)
{
    pt->x = (pt->x / grid) * grid;
    pt->y = (pt->y / grid) * grid;
}

struct shape* shape_create_curve(const struct generics* layer, coordinate_t x, coordinate_t y, unsigned int grid, int allow45)
{
    struct shape* shape = _create_shape(CURVE, layer);
    struct curve* curve = malloc(sizeof(*curve));
    curve->origin = point_create(x, y);
    if(!_check_grid(curve->origin, grid))
    {
        fprintf(stderr, "curve origin (%lld, %lld) is not on grid (%d) and will be corrected to ", curve->origin->x, curve->origin->y, grid);
        _fix_grid(curve->origin, grid);
        fprintf(stderr, "(%lld, %lld)\n", curve->origin->x, curve->origin->y);
    }
    curve->segments = vector_create(8, _destroy_segment);
    curve->grid = grid;
    curve->allow45 = allow45;
    shape->content = curve;
    return shape;
}

static int _collinear(const struct point* pt1, const struct point* pt2, const struct point* pt3)
{
    return (pt1->x * (pt2->y - pt3->y) + pt2->x * (pt3->y - pt1->y) + pt3->x * (pt1->y - pt2->y)) == 0;
}

static void _remove_superfluous_points(struct vector* pts)
{
    size_t index = 0;
    while(index + 2 < vector_size(pts))
    {
        struct point* pt1 = vector_get(pts, index);
        struct point* pt2 = vector_get(pts, index + 1);
        struct point* pt3 = vector_get(pts, index + 2);
        if(_collinear(pt1, pt2, pt3))
        {
            vector_remove(pts, index + 1);
        }
        else
        {
            ++index;
        }
    }
    if(!vector_empty(pts))
    {
        struct point* firstpt = vector_get(pts, 0);
        struct point* lastpt = vector_get(pts, vector_size(pts) - 1);
        if(firstpt->x == lastpt->x && firstpt->y == lastpt->y)
        {
            vector_remove(pts, vector_size(pts) - 1);
        }
    }
}

static int _is_counterclockwise(const struct vector* points)
{
    double sum = 0.0;
    const struct point* pt1 = vector_get_const(points, vector_size(points) - 1);
    for(size_t i = 0; i < vector_size(points); i++)
    {
        const struct point* pt2 = vector_get_const(points, i);
        sum += (pt2->x - pt1->x) * (pt2->y + pt1->y);
        pt1 = pt2;
    }
    return sum < 0.0;
}

static void _check_counterclockwise(struct vector* points)
{
    if(!_is_counterclockwise(points))
    {
        vector_reverse(points);
    }
}

void shape_cleanup(struct shape* shape)
{
    if(shape->type == POLYGON)
    {
        struct polygon_shape* polygon = shape->content;
        _remove_superfluous_points(polygon->points);
        _check_counterclockwise(polygon->points);
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
            new = shape_create_rectangle(self->layer,
                _bl(rectangle)->x,
                _bl(rectangle)->y,
                _tr(rectangle)->x,
                _tr(rectangle)->y
            );
            break;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon_shape* polygon = self->content;
            new = shape_create_polygon(self->layer, vector_capacity(polygon->points));
            struct polygon_shape* np = new->content;
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
            struct curve* new_curve = new->content;
            for(unsigned int i = 0; i < vector_size(curve->segments); ++i)
            {
                struct curve_segment* segment = vector_get(curve->segments, i);
                struct curve_segment* new_segment = malloc(sizeof(*new_segment));
                new_segment->type = segment->type;
                switch(segment->type)
                {
                    case LINE_SEGMENT:
                    {
                        new_segment->pt = point_copy(segment->pt);
                        break;
                    }
                    case ARC_SEGMENT:
                    {
                        new_segment->startangle = segment->startangle;
                        new_segment->endangle = segment->endangle;
                        new_segment->radius = segment->radius;
                        new_segment->clockwise = segment->clockwise;
                        break;
                    }
                    case CUBIC_BEZIER_SEGMENT:
                    {
                        new_segment->cpt1 = point_copy(segment->cpt1);
                        new_segment->cpt2 = point_copy(segment->cpt2);
                        new_segment->endpt = point_copy(segment->endpt);
                    }
                }
                vector_append(new_curve->segments, new_segment);
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
            // nothing to do
            break;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon_shape* polygon = shape->content;
            vector_destroy(polygon->points);
            break;
        }
        case PATH:
        {
            struct path* path = shape->content;
            vector_destroy(path->points);
            break;
        }
        case CURVE:
        {
            struct curve* curve = shape->content;
            point_destroy(curve->origin);
            vector_destroy(curve->segments);
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
        struct polygon_shape* polygon = shape->content;
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

int shape_is_layer(const struct shape* shape, const struct generics* layer)
{
    return shape->layer == layer;
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

int shape_is_malformed(const struct shape* shape)
{
    if(shape_is_rectangle(shape))
    {
        struct rectangle* rectangle = shape->content;
        struct point* bl = _bl(rectangle);
        struct point* tr = _tr(rectangle);
        return (point_getx(bl) == point_getx(tr)) || (point_gety(bl) == point_gety(tr));
    }
    else
    {
        // FIXME: implement malformed checks for other shapes
        return 0;
    }
}

int shape_get_rectangle_points(struct shape* shape, const struct point** bl, const struct point** tr)
{
    if(shape->type != RECTANGLE)
    {
        return 0;
    }
    struct rectangle* rectangle = shape->content;
    *bl = _bl(rectangle);
    *tr = _tr(rectangle);
    return 1;
}

int shape_get_transformed_rectangle_points(const struct shape* shape, const struct transformationmatrix* trans, struct point* bl, struct point* tr)
{
    if(shape->type != RECTANGLE)
    {
        return 0;
    }
    const struct rectangle* rectangle = shape->content;
    *bl = *_bl(rectangle);
    *tr = *_tr(rectangle);
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
    struct polygon_shape* polygon = shape->content;
    *points = polygon->points;
    return 1;
}

int shape_get_transformed_polygon_points(const struct shape* shape, const struct transformationmatrix* trans, struct vector* points)
{
    if(shape->type != POLYGON && shape->type != TRIANGULATED_POLYGON)
    {
        return 0;
    }
    struct polygon_shape* polygon = shape->content;
    struct vector_const_iterator* it = vector_const_iterator_create(polygon->points);
    while(vector_const_iterator_is_valid(it))
    {
        struct point* pt = point_copy(vector_const_iterator_get(it));
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
        struct point* pt = point_copy(vector_const_iterator_get(it));
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

static coordinate_t _fix_to_grid(coordinate_t c, unsigned int grid)
{
    return (c / grid) * grid;
}

int shape_foreach_curve_segments(const struct shape* shape, void* blob, line_segment_handler _line_segment, arc_segment_handler _arc_segment, cubic_bezier_segment_handler _cubic_bezier_segment)
{
    if(shape->type != CURVE)
    {
        return 0;
    }
    struct curve* curve = shape->content;
    struct vector_const_iterator* it = vector_const_iterator_create(curve->segments);
    coordinate_t lastx = curve->origin->x;
    coordinate_t lasty = curve->origin->y;
    unsigned int grid = curve->grid;
    int ret = 1;
    while(vector_const_iterator_is_valid(it))
    {
        const struct curve_segment* segment = vector_const_iterator_get(it);
        switch(segment->type)
        {
            case LINE_SEGMENT:
            {
                ret = _line_segment(segment->pt, blob);
                if(!ret)
                {
                    goto SHAPE_FOREACH_CURVE_SEGMENTS_CLEANUP;
                }
                lastx = segment->pt->x;
                lasty = segment->pt->y;
                break;
            }
            case ARC_SEGMENT:
            {
                ret = _arc_segment(segment->startangle, segment->endangle, segment->radius, segment->clockwise, blob);
                if(!ret)
                {
                    goto SHAPE_FOREACH_CURVE_SEGMENTS_CLEANUP;
                }
                double startcos = cos(segment->startangle * M_PI / 180);
                double startsin = sin(segment->startangle * M_PI / 180);
                double endcos = cos(segment->endangle * M_PI / 180);
                double endsin = sin(segment->endangle * M_PI / 180);
                lastx += _fix_to_grid((endcos - startcos) * segment->radius, grid);
                lasty += _fix_to_grid((endsin - startsin) * segment->radius, grid);
                break;
            }
            case CUBIC_BEZIER_SEGMENT:
            {
                ret = _cubic_bezier_segment(segment->cpt1, segment->cpt2, segment->endpt, blob);
                if(!ret)
                {
                    goto SHAPE_FOREACH_CURVE_SEGMENTS_CLEANUP;
                }
                lastx = segment->endpt->x;
                lasty = segment->endpt->y;
                break;
            }
        }
        vector_const_iterator_next(it);
    }
SHAPE_FOREACH_CURVE_SEGMENTS_CLEANUP:
    vector_const_iterator_destroy(it);
    return ret;
}

int shape_get_curve_origin(const struct shape* shape, const struct point** originp)
{
    if(shape->type != CURVE)
    {
        return 0;
    }
    struct curve* curve = shape->content;
    *originp = curve->origin;
    return 1;
}

int shape_get_transformed_curve_origin(const struct shape* shape, const struct transformationmatrix* trans, struct point* origin)
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

void shape_translate(struct shape* shape, coordinate_t dx, coordinate_t dy)
{
    switch(shape->type)
    {
        case RECTANGLE:
        {
            struct rectangle* rectangle = shape->content;
            point_translate(_bl(rectangle), dx, dy);
            point_translate(_tr(rectangle), dx, dy);
            break;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon_shape* polygon = shape->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                struct point* pt = vector_get(polygon->points, i);
                point_translate(pt, dx, dy);
            }
            break;
        }
        case PATH:
        {
            struct path* path = shape->content;
            for(unsigned int i = 0; i < vector_size(path->points); ++i)
            {
                struct point* pt = vector_get(path->points, i);
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
                switch(segment->type)
                {
                    case LINE_SEGMENT:
                    {
                        point_translate(segment->pt, dx, dy);
                        break;
                    }
                    case CUBIC_BEZIER_SEGMENT:
                    {
                        point_translate(segment->cpt1, dx, dy);
                        point_translate(segment->cpt2, dx, dy);
                        point_translate(segment->endpt, dx, dy);
                        break;
                    }
                    default: // ARC_SEGMENTS don't need to be translated
                        break;
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
        struct point* bl = _bl(rectangle);
        struct point* tr = _tr(rectangle);
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
            transformationmatrix_apply_transformation(trans, _bl(rectangle));
            transformationmatrix_apply_transformation(trans, _tr(rectangle));
            break;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon_shape* polygon = shape->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                struct point* pt = vector_get(polygon->points, i);
                transformationmatrix_apply_transformation(trans, pt);
            }
            break;
        }
        case PATH:
        {
            struct path* path = shape->content;
            for(unsigned int i = 0; i < vector_size(path->points); ++i)
            {
                struct point* pt = vector_get(path->points, i);
                transformationmatrix_apply_transformation(trans, pt);
            }
            break;
        }
        case CURVE:
        {
            // FIXME: this is not correct
            struct curve* curve = shape->content;
            transformationmatrix_apply_transformation(trans, curve->origin);
            for(unsigned int i = 0; i < vector_size(curve->segments); ++i)
            {
                struct curve_segment* segment = vector_get(curve->segments, i);
                switch(segment->type)
                {
                    case LINE_SEGMENT:
                    {
                        transformationmatrix_apply_transformation(trans, segment->pt);
                        break;
                    }
                    case CUBIC_BEZIER_SEGMENT:
                    {
                        transformationmatrix_apply_transformation(trans, segment->cpt1);
                        transformationmatrix_apply_transformation(trans, segment->cpt1);
                        transformationmatrix_apply_transformation(trans, segment->endpt);
                        break;
                    }
                    default: // ARC_SEGMENTS don't need to be translated
                        break;
                }
            }
            break;
        }
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
            transformationmatrix_apply_inverse_transformation(trans, _bl(rectangle));
            transformationmatrix_apply_inverse_transformation(trans, _tr(rectangle));
            break;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon_shape* polygon = shape->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                struct point* pt = vector_get(polygon->points, i);
                transformationmatrix_apply_inverse_transformation(trans, pt);
            }
            break;
        }
        case PATH:
        {
            struct path* path = shape->content;
            for(unsigned int i = 0; i < vector_size(path->points); ++i)
            {
                struct point* pt = vector_get(path->points, i);
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
    shape_get_minmax_xy(shape, &minx, &miny, &maxx, &maxy);
    *widthp = maxx - minx;
    *heightp = maxy - miny;
}

void shape_get_minmax_xy(const struct shape* shape, coordinate_t* minxp, coordinate_t* minyp, coordinate_t* maxxp, coordinate_t* maxyp)
{
    struct point* min = point_create_maximum();
    struct point* max = point_create_minimum();
    switch(shape->type)
    {
        case RECTANGLE:
        {
            struct rectangle* rectangle = shape->content;
            struct point bl = *_bl(rectangle);
            struct point tr = *_tr(rectangle);
            point_update_minimum(&min, &bl);
            point_update_maximum(&max, &tr);
            break;
        }
        case POLYGON:
        case TRIANGULATED_POLYGON:
        {
            struct polygon_shape* polygon = shape->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                struct point* ptr = vector_get(polygon->points, i);
                struct point pt = *ptr;
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
                struct point* ptr = vector_get(path->points, i);
                struct point pt = *ptr;
                point_update_minimum(&min, &pt);
                point_update_maximum(&max, &pt);
            }
            break;
        }
        case CURVE:
        {
            struct shape* polygon = shape_rasterize_curve(shape);
            shape_get_minmax_xy(polygon, &min->x, &min->y, &max->x, &max->y);
            shape_destroy(polygon);
            break;
        }
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
    const struct point* bl = _bl(rectangle);
    const struct point* tr = _tr(rectangle);
    *x = (bl->x + tr->x) / 2;
    *y = (bl->y + tr->y) / 2;
    return 1;
}

void shape_curve_add_line_segment(struct shape* shape, const struct point* pt)
{
    if(shape->type != CURVE)
    {
        return;
    }
    struct curve* curve = shape->content;
    struct curve_segment* segment = malloc(sizeof(*segment));
    segment->type = LINE_SEGMENT;
    segment->pt = point_copy(pt);
    if(!_check_grid(segment->pt, curve->grid))
    {
        fprintf(stderr, "add curve line segment: point (%lld, %lld) is not on grid (%d) and will be corrected to ", segment->pt->x, segment->pt->y, curve->grid);
        _fix_grid(segment->pt, curve->grid);
        fprintf(stderr, "(%lld, %lld)\n", segment->pt->x, segment->pt->y);
        return;
    }
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
    segment->type = ARC_SEGMENT;
    segment->startangle = startangle;
    segment->endangle = endangle;
    segment->radius = radius;
    segment->clockwise = clockwise;
    vector_append(curve->segments, segment);
}

void shape_curve_add_cubic_bezier_segment(struct shape* shape, const struct point* cpt1, const struct point* cpt2, const struct point* endpt)
{
    if(shape->type != CURVE)
    {
        return;
    }
    struct curve* curve = shape->content;
    struct curve_segment* segment = malloc(sizeof(*segment));
    segment->type = CUBIC_BEZIER_SEGMENT;
    segment->cpt1 = point_copy(cpt1);
    if(!_check_grid(segment->cpt1, curve->grid))
    {
        fprintf(stderr, "add curve cubic bezier segment: control point 1 (%lld, %lld) is not on grid (%d) and will be corrected to ", segment->cpt1->x, segment->cpt1->y, curve->grid);
        _fix_grid(segment->cpt1, curve->grid);
        fprintf(stderr, "(%lld, %lld)\n", segment->cpt1->x, segment->cpt1->y);
    }
    segment->cpt2 = point_copy(cpt2);
    if(!_check_grid(segment->cpt2, curve->grid))
    {
        fprintf(stderr, "add curve cubic bezier segment: control point 2 (%lld, %lld) is not on grid (%d) and will be corrected to ", segment->cpt2->x, segment->cpt2->y, curve->grid);
        _fix_grid(segment->cpt2, curve->grid);
        fprintf(stderr, "(%lld, %lld)\n", segment->cpt2->x, segment->cpt2->y);
    }
    segment->endpt = point_copy(endpt);
    if(!_check_grid(segment->endpt, curve->grid))
    {
        fprintf(stderr, "add curve cubic bezier segment: end point (%lld, %lld) is not on grid (%d) and will be corrected to ", segment->endpt->x, segment->endpt->y, curve->grid);
        _fix_grid(segment->endpt, curve->grid);
        fprintf(stderr, "(%lld, %lld)\n", segment->endpt->x, segment->endpt->y);
    }
    vector_append(curve->segments, segment);
}

struct simple_polygon* shape_to_polygon(struct shape* shape)
{
    switch(shape->type)
    {
        case RECTANGLE:
        {
            struct rectangle* rectangle = shape->content;
            struct point* bl = _bl(rectangle);
            struct point* tr = _tr(rectangle);
            struct simple_polygon* simple_polygon = simple_polygon_create();
            simple_polygon_append(simple_polygon, point_create(bl->x, bl->y));
            simple_polygon_append(simple_polygon, point_create(tr->x, bl->y));
            simple_polygon_append(simple_polygon, point_create(tr->x, tr->y));
            simple_polygon_append(simple_polygon, point_create(bl->x, tr->y));
            return simple_polygon;
        }
        case POLYGON:
        {
            struct simple_polygon* simple_polygon = simple_polygon_create();
            struct polygon_shape* polygon = shape->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                simple_polygon_append(simple_polygon, point_copy(vector_get(polygon->points, i)));
            }
            return simple_polygon;
        }
        case PATH:
        {
            struct shape* new = shape_resolve_path(shape);
            struct simple_polygon* simple_polygon = simple_polygon_create();
            struct polygon_shape* polygon = new->content;
            for(unsigned int i = 0; i < vector_size(polygon->points); ++i)
            {
                simple_polygon_append(simple_polygon, point_copy(vector_get(polygon->points, i)));
            }
            return simple_polygon;
        }
    }
    assert(0);
    return NULL;
}

void shape_resolve_path_extensions_inline(struct shape* shape)
{
    if(shape->type != PATH)
    {
        return;
    }
    struct path* path = shape->content;
    struct point* pt_start_1 = vector_get(path->points, 1);
    struct point* pt_start_2 = vector_get(path->points, 0);
    double angle_start = atan2(pt_start_2->y - pt_start_1->y, pt_start_2->x - pt_start_1->x);
    coordinate_t xshift_start = floor(path->extension[0] * cos(angle_start) + 0.5);
    coordinate_t yshift_start = floor(path->extension[0] * sin(angle_start) + 0.5);
    point_translate(pt_start_2, xshift_start, yshift_start);
    struct point* pt_end_1 = vector_get(path->points, vector_size(path->points) - 2);
    struct point* pt_end_2 = vector_get(path->points, vector_size(path->points) - 1);
    double angle_end = atan2(pt_end_2->y - pt_end_1->y, pt_end_2->x - pt_end_1->x);
    coordinate_t xshift_end = floor(path->extension[1] * cos(angle_end) + 0.5);
    coordinate_t yshift_end = floor(path->extension[1] * sin(angle_end) + 0.5);
    point_translate(pt_end_2, xshift_end, yshift_end);
    path->extension[0] = 0;
    path->extension[1] = 0;
}

struct shape* shape_resolve_extensions_path(const struct shape* shape)
{
    if(shape->type != PATH)
    {
        return NULL;
    }
    int miterjoin = 1;
    struct path* path = shape->content;
    struct shape* new = geometry_path_to_polygon(shape->layer, path->points, path->width, miterjoin);
    return new;
}

void shape_resolve_path_inline(struct shape* shape)
{
    if(shape->type != PATH)
    {
        return;
    }
    int miterjoin = 1;
    struct path* path = shape->content;
    struct shape* new = geometry_path_to_polygon(shape->layer, path->points, path->width, miterjoin);
    shape->content = new->content;
    shape->type = new->type;
    vector_destroy(path->points);
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
    struct shape* new = geometry_path_to_polygon(shape->layer, path->points, path->width, miterjoin);
    return new;
}

/*
static void _check_acute_angles(struct vector* points)
{

}
*/

void shape_rasterize_curve_inline(struct shape* shape)
{
    if(shape->type != CURVE)
    {
        return;
    }
    struct vector* rastered_points = vector_create(1024, point_destroy);
    struct curve* curve = shape->content;
    struct vector_const_iterator* it = vector_const_iterator_create(curve->segments);
    struct point* lastpt = point_copy(curve->origin);
    while(vector_const_iterator_is_valid(it))
    {
        const struct curve_segment* segment = vector_const_iterator_get(it);
        switch(segment->type)
        {
            case LINE_SEGMENT:
            {
                graphics_rasterize_line_segment(
                    lastpt, segment->pt,
                    curve->grid, curve->allow45, rastered_points);
                lastpt->x = segment->pt->x;
                lastpt->y = segment->pt->y;
                break;
            }
            case ARC_SEGMENT:
            {
                graphics_rasterize_arc_segment(
                    lastpt,
                    segment->startangle,
                    segment->endangle,
                    segment->radius,
                    segment->clockwise,
                    curve->grid, curve->allow45, rastered_points);
                double startcos = cos(segment->startangle * M_PI / 180);
                double startsin = sin(segment->startangle * M_PI / 180);
                double endcos = cos(segment->endangle * M_PI / 180);
                double endsin = sin(segment->endangle * M_PI / 180);
                lastpt->x = lastpt->x + _fix_to_grid((endcos - startcos) * segment->radius, curve->grid);
                lastpt->y = lastpt->y + _fix_to_grid((endsin - startsin) * segment->radius, curve->grid);
                break;
            }
            case CUBIC_BEZIER_SEGMENT:
            {
                graphics_rasterize_cubic_bezier_segment(
                    lastpt,
                    segment->cpt1,
                    segment->cpt2,
                    segment->endpt,
                    curve->grid, curve->allow45, rastered_points);
                lastpt->x = segment->endpt->x;
                lastpt->y = segment->endpt->y;
                break;
            }
        }
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    point_destroy(lastpt);
    point_destroy(curve->origin);
    vector_destroy(curve->segments);
    free(curve);

    //_check_acute_angles(rastered_points);

    struct polygon_shape* polygon = malloc(sizeof(*polygon));
    polygon->points = rastered_points;
    shape->type = POLYGON;
    shape->content = polygon;

    shape_cleanup(shape);
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
    struct polygon_shape* polygon = shape->content;
    struct vector* result = geometry_triangulate_polygon(polygon->points);
    if(!result)
    {
        fputs("could not triangulate polygon\n", stderr);
        return;
    }
    vector_destroy(polygon->points);
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
    struct vector* result = geometry_triangulate_polygon(((struct polygon_shape*)shape->content)->points);
    ((struct polygon_shape*)shape->content)->points = result;
    new->type = TRIANGULATED_POLYGON;
    return new;
}

