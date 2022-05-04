#ifndef OPC_SHAPE_H
#define OPC_SHAPE_H

#include <stddef.h>

#include "point.h"
#include "transformationmatrix.h"
#include "generics.h"

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

struct curve_segment {
    enum segment_type {
        LINESEGMENT,
        ARCSEGMENT
    } type;
    union {
        struct {
            point_t* pt;
        };
        struct {
            double startangle;
            double endangle;
            coordinate_t radius;
            int clockwise;
        };
    } data;
};

struct curve {
    point_t* origin;
    struct vector* segments;
    unsigned int grid;
};

typedef struct {
    enum shapetype {
        RECTANGLE,
        POLYGON,
        TRIANGULATED_POLYGON, // re-uses struct polygon
        PATH,
        CURVE
    } type;
    void* content;
    generics_t* layer;
} shape_t;

shape_t* shape_create_rectangle(generics_t* layer, coordinate_t bl_x, coordinate_t bl_y, coordinate_t tr_x, coordinate_t tr_y);
shape_t* shape_create_polygon(generics_t* layer, size_t capacity);
shape_t* shape_create_path(generics_t* layer, size_t capacity, ucoordinate_t width, coordinate_t extstart, coordinate_t extend);
shape_t* shape_create_curve(generics_t* layer, coordinate_t x, coordinate_t y, unsigned int grid);
shape_t* shape_copy(shape_t* shape);
void shape_destroy(shape_t* shape);

void shape_append(shape_t* shape, coordinate_t x, coordinate_t y);

// rectangle access functions
int shape_get_rectangle_points(shape_t* shape, point_t** blp, point_t** trp);

// polygon (including triangulated) access functions
int shape_get_polygon_points(shape_t* shape, struct vector** points);

// path access functions
int shape_get_path_points(shape_t* shape, struct vector** points);
int shape_get_path_width(shape_t* shape, ucoordinate_t* width);
int shape_get_path_extension(shape_t* shape, coordinate_t* start, coordinate_t* end);

int shape_is_empty(shape_t* shape);

// transformations
void shape_translate(shape_t* shape, coordinate_t dx, coordinate_t dy);
void shape_apply_transformation(shape_t* shape, transformationmatrix_t* matrix);
void shape_apply_inverse_transformation(shape_t* shape, transformationmatrix_t* matrix);

coordinate_t shape_get_width(const shape_t* shape);
coordinate_t shape_get_height(const shape_t* shape);
void shape_get_width_height(const shape_t* shape, coordinate_t* width, coordinate_t* height);
void shape_get_minmax_xy(const shape_t* shape, const transformationmatrix_t* trans, coordinate_t* minxp, coordinate_t* minyp, coordinate_t* maxxp, coordinate_t* maxyp);

// curve segments
void shape_curve_add_line_segment(shape_t* shape, point_t* pt);
void shape_curve_add_arc_segment(shape_t* shape, double startangle, double endangle, coordinate_t radius, int clockwise);

int shape_get_center(shape_t* shape, coordinate_t* x, coordinate_t* y);

void shape_resize_lrtb(shape_t* shape, coordinate_t left, coordinate_t right, coordinate_t top, coordinate_t bottom);
void shape_resolve_path(shape_t* shape);
void shape_triangulate_polygon(shape_t* shape);
void shape_rasterize_curve(shape_t* shape);

#endif /* OPC_SHAPE_H */
