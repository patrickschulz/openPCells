#ifndef OPC_SHAPE_H
#define OPC_SHAPE_H

#include <stddef.h>

#include "point.h"
#include "transformationmatrix.h"
#include "generics.h"

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
    int allow45;
};

struct shape* shape_create_rectangle(struct generics* layer, coordinate_t bl_x, coordinate_t bl_y, coordinate_t tr_x, coordinate_t tr_y);
struct shape* shape_create_polygon(struct generics* layer, size_t capacity);
struct shape* shape_create_path(struct generics* layer, size_t capacity, ucoordinate_t width, coordinate_t extstart, coordinate_t extend);
struct shape* shape_create_curve(struct generics* layer, coordinate_t x, coordinate_t y, unsigned int grid, int allow45);
void* shape_copy(void* shape);
void shape_destroy(void* shape);

void shape_append(struct shape* shape, coordinate_t x, coordinate_t y);

const struct hashmap* shape_get_main_layerdata(const struct shape*);

struct generics* shape_get_layer(struct shape* shape);

// type checking
int shape_is_rectangle(struct shape* shape);
int shape_is_path(struct shape* shape);
int shape_is_polygon(struct shape* shape);
int shape_is_triangulated_polygon(struct shape* shape);
int shape_is_curve(struct shape* shape);

void* shape_get_content(struct shape* shape);

// rectangle access functions
int shape_get_rectangle_points(struct shape* shape, point_t** blp, point_t** trp);

// polygon (including triangulated) access functions
int shape_get_polygon_points(struct shape* shape, struct vector** points);

// path access functions
int shape_get_path_points(struct shape* shape, struct vector** points);
int shape_get_path_width(struct shape* shape, ucoordinate_t* width);
int shape_get_path_extension(struct shape* shape, coordinate_t* start, coordinate_t* end);

// curve access functions
int shape_get_curve_origin(struct shape* shape, point_t** origin);

int shape_is_empty(struct shape* shape);

// transformations
void shape_translate(struct shape* shape, coordinate_t dx, coordinate_t dy);
void shape_apply_transformation(struct shape* shape, struct transformationmatrix* matrix);
void shape_apply_inverse_transformation(struct shape* shape, struct transformationmatrix* matrix);

coordinate_t shape_get_width(const struct shape* shape);
coordinate_t shape_get_height(const struct shape* shape);
void shape_get_width_height(const struct shape* shape, coordinate_t* width, coordinate_t* height);
void shape_get_minmax_xy(const struct shape* shape, const struct transformationmatrix* trans, coordinate_t* minxp, coordinate_t* minyp, coordinate_t* maxxp, coordinate_t* maxyp);

// curve segments
void shape_curve_add_line_segment(struct shape* shape, point_t* pt);
void shape_curve_add_arc_segment(struct shape* shape, double startangle, double endangle, coordinate_t radius, int clockwise);

int shape_get_center(struct shape* shape, coordinate_t* x, coordinate_t* y);

void shape_resize_lrtb(struct shape* shape, coordinate_t left, coordinate_t right, coordinate_t top, coordinate_t bottom);
void shape_resolve_path(struct shape* shape);
void shape_triangulate_polygon(struct shape* shape);
void shape_rasterize_curve(struct shape* shape);

#endif /* OPC_SHAPE_H */
