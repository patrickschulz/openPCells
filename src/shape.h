#ifndef OPC_SHAPE_H
#define OPC_SHAPE_H

#include <stddef.h>

#include "point.h"
#include "transformationmatrix.h"
#include "technology.h"

struct curve_segment {
    enum segment_type {
        LINESEGMENT,
        ARCSEGMENT,
        CUBIC_BEZIER
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
        struct {
            point_t* cpt1;
            point_t* cpt2;
            point_t* endpt;
        };
    } data;
};

struct shape;

struct shape* shape_create_rectangle(const struct generics* layer, coordinate_t bl_x, coordinate_t bl_y, coordinate_t tr_x, coordinate_t tr_y);
struct shape* shape_create_polygon(const struct generics* layer, size_t capacity);
struct shape* shape_create_path(const struct generics* layer, size_t capacity, ucoordinate_t width, coordinate_t extstart, coordinate_t extend);
struct shape* shape_create_curve(const struct generics* layer, coordinate_t x, coordinate_t y, unsigned int grid, int allow45);
void shape_cleanup(struct shape* shape);
void* shape_copy(const void* shape);
void shape_destroy(void* shape);

void shape_append(struct shape* shape, coordinate_t x, coordinate_t y);

const struct hashmap* shape_get_main_layerdata(const struct shape*);

const struct generics* shape_get_layer(const struct shape* shape);

// type checking
int shape_is_rectangle(const struct shape* shape);
int shape_is_path(const struct shape* shape);
int shape_is_polygon(const struct shape* shape);
int shape_is_triangulated_polygon(const struct shape* shape);
int shape_is_curve(const struct shape* shape);

const void* shape_get_content(const struct shape* shape);

// rectangle access functions
int shape_get_rectangle_points(struct shape* shape, point_t** blp, point_t** trp);
int shape_get_transformed_rectangle_points(const struct shape* shape, const struct transformationmatrix* trans, point_t* blp, point_t* trp);

// polygon (including triangulated) access functions
int shape_get_polygon_points(struct shape* shape, struct vector** points);
int shape_get_transformed_polygon_points(const struct shape* shape, const struct transformationmatrix* trans, struct vector* points);

// path access functions
int shape_get_path_points(struct shape* shape, struct vector** points);
int shape_get_transformed_path_points(const struct shape* shape, const struct transformationmatrix* trans, struct vector* points);
int shape_get_path_width(const struct shape* shape, ucoordinate_t* width);
int shape_get_path_extension(const struct shape* shape, coordinate_t* start, coordinate_t* end);

// curve access functions
int shape_get_curve_content(const struct shape* shape, point_t** origin, unsigned int* grid, struct vector_const_iterator** it);
int shape_get_curve_origin(const struct shape* shape, point_t** origin);
int shape_get_transformed_curve_origin(const struct shape* shape, const struct transformationmatrix* trans, point_t* origin);

int shape_is_empty(const struct shape* shape);

// transformations
void shape_translate(struct shape* shape, coordinate_t dx, coordinate_t dy);
void shape_apply_transformation(struct shape* shape, const struct transformationmatrix* trans);
void shape_apply_inverse_transformation(struct shape* shape, const struct transformationmatrix* trans);

coordinate_t shape_get_width(const struct shape* shape);
coordinate_t shape_get_height(const struct shape* shape);
void shape_get_width_height(const struct shape* shape, coordinate_t* width, coordinate_t* height);
void shape_get_minmax_xy(const struct shape* shape, const struct transformationmatrix* trans, coordinate_t* minxp, coordinate_t* minyp, coordinate_t* maxxp, coordinate_t* maxyp);

// curve segments
void shape_curve_add_line_segment(struct shape* shape, const point_t* pt);
void shape_curve_add_arc_segment(struct shape* shape, double startangle, double endangle, coordinate_t radius, int clockwise);
void shape_curve_add_cubic_bezier_segment(struct shape* shape, const point_t* cpt1, const point_t* cpt2, const point_t* endpt);

int shape_get_center(const struct shape* shape, coordinate_t* x, coordinate_t* y);

void shape_resize_lrtb(struct shape* shape, coordinate_t left, coordinate_t right, coordinate_t top, coordinate_t bottom);
void shape_resolve_path_inline(struct shape* shape);
struct shape* shape_resolve_path(const struct shape* shape);
void shape_triangulate_polygon_inline(struct shape* shape);
struct shape* shape_triangulate_polygon(const struct shape* shape);
void shape_rasterize_curve_inline(struct shape* shape);
struct shape* shape_rasterize_curve(const struct shape* shape);

#endif /* OPC_SHAPE_H */
