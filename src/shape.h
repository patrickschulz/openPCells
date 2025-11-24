#ifndef OPC_SHAPE_H
#define OPC_SHAPE_H

#include <stddef.h>

#include "point.h"
#include "polygon.h"
#include "technology.h"
#include "transformationmatrix.h"

struct shape;
typedef int (*line_segment_handler)(const struct point*, void*);
typedef int (*arc_segment_handler)(double, double, coordinate_t, int, void*);
typedef int (*cubic_bezier_segment_handler)(const struct point*, const struct point*, const struct point*, void*);

struct shape* shape_create_rectangle(const struct generics* layer, coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try);
struct shape* shape_create_polygon(const struct generics* layer, size_t capacity);
struct shape* shape_create_path(const struct generics* layer, size_t capacity, ucoordinate_t width, coordinate_t extstart, coordinate_t extend);
struct shape* shape_create_curve(const struct generics* layer, coordinate_t x, coordinate_t y, unsigned int grid, int allow45);
void shape_cleanup(struct shape* shape);
void* shape_copy(const void* v);
void shape_destroy(void* v);

void shape_append(struct shape* shape, coordinate_t x, coordinate_t y);

const struct hashmap* shape_get_main_layerdata(const struct shape*);

int shape_is_layer(const struct shape* shape, const struct generics* layer);
const struct generics* shape_get_layer(const struct shape* shape);

// type checking
int shape_is_rectangle(const struct shape* shape);
int shape_is_path(const struct shape* shape);
int shape_is_polygon(const struct shape* shape);
int shape_is_triangulated_polygon(const struct shape* shape);
int shape_is_curve(const struct shape* shape);

int shape_is_malformed(const struct shape* shape);

// rectangle access functions
int shape_get_rectangle_points(struct shape* shape, const struct point** blp, const struct point** trp);
int shape_get_transformed_rectangle_points(const struct shape* shape, const struct transformationmatrix* trans, struct point* blp, struct point* trp);

// polygon (including triangulated) access functions
int shape_get_polygon_points(struct shape* shape, struct vector** points);
int shape_get_transformed_polygon_points(const struct shape* shape, const struct transformationmatrix* trans, struct vector* points);

// path access functions
int shape_get_path_points(struct shape* shape, struct vector** points);
int shape_get_transformed_path_points(const struct shape* shape, const struct transformationmatrix* trans, struct vector* points);
int shape_get_path_width(const struct shape* shape, ucoordinate_t* width);
int shape_get_path_extension(const struct shape* shape, coordinate_t* start, coordinate_t* end);

// curve access functions
int shape_foreach_curve_segments(const struct shape* shape, void* blob, line_segment_handler, arc_segment_handler, cubic_bezier_segment_handler);
int shape_get_curve_origin(const struct shape* shape, const struct point** origin);
int shape_get_transformed_curve_origin(const struct shape* shape, const struct transformationmatrix* trans, struct point* origin);

// transformations
void shape_translate(struct shape* shape, coordinate_t dx, coordinate_t dy);
void shape_apply_transformation(struct shape* shape, const struct transformationmatrix* trans);
void shape_apply_inverse_transformation(struct shape* shape, const struct transformationmatrix* trans);

// width/height
coordinate_t shape_get_width(const struct shape* shape);
coordinate_t shape_get_height(const struct shape* shape);
void shape_get_width_height(const struct shape* shape, coordinate_t* width, coordinate_t* height);
void shape_get_minmax_xy(const struct shape* shape, coordinate_t* minxp, coordinate_t* minyp, coordinate_t* maxxp, coordinate_t* maxyp);

// curve segments
void shape_curve_add_line_segment(struct shape* shape, const struct point* pt);
void shape_curve_add_arc_segment(struct shape* shape, double startangle, double endangle, coordinate_t radius, int clockwise);
void shape_curve_add_cubic_bezier_segment(struct shape* shape, const struct point* cpt1, const struct point* cpt2, const struct point* endpt);

// conversion to polygon (e.g. for layer boundaries)
struct simple_polygon* shape_to_polygon(struct shape* shape);

int shape_get_center(const struct shape* shape, coordinate_t* x, coordinate_t* y);

void shape_resolve_path_extensions_inline(struct shape* shape);
struct shape* shape_resolve_path_extensions(const struct shape* shape);
void shape_resolve_path_inline(struct shape* shape);
struct shape* shape_resolve_path(const struct shape* shape);
void shape_triangulate_polygon_inline(struct shape* shape);
struct shape* shape_triangulate_polygon(const struct shape* shape);
void shape_rasterize_curve_inline(struct shape* shape);
struct shape* shape_rasterize_curve(const struct shape* shape);

#endif /* OPC_SHAPE_H */
