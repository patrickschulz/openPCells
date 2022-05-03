#ifndef OPC_SHAPE_H
#define OPC_SHAPE_H

#include <stddef.h>

#include "point.h"
#include "transformationmatrix.h"
#include "generics.h"

enum shapetype
{
    RECTANGLE,
    POLYGON,
    TRIANGULATED_POLYGON,
    PATH,
    CURVE
};

struct curve_segment
{
    enum curve_segment_type {
        LINE,
        ARC
    } type;
};

typedef struct
{
    ucoordinate_t width;
    coordinate_t extension[2];
} path_properties_t;

typedef struct
{
    enum shapetype type;

    point_t** points;
    size_t size;
    size_t capacity;

    generics_t* layer;

    void* properties; // optional
} shape_t;

shape_t* shape_create_rectangle(coordinate_t bl_x, coordinate_t bl_y, coordinate_t tr_x, coordinate_t tr_y);
shape_t* shape_create_polygon(size_t capacity);
shape_t* shape_create_path(size_t capacity, ucoordinate_t width, coordinate_t extstart, coordinate_t extend);
shape_t* shape_create_curve(void);
shape_t* shape_copy(shape_t* shape);
void shape_destroy(shape_t* shape);

void shape_append(shape_t* shape, coordinate_t x, coordinate_t y);

int shape_get_path_width(shape_t* shape, ucoordinate_t* width);
int shape_get_path_extension(shape_t* shape, coordinate_t* start, coordinate_t* end);

int shape_is_empty(shape_t* shape);

// transformations
void shape_translate(shape_t* shape, coordinate_t dx, coordinate_t dy);
void shape_apply_transformation(shape_t* shape, transformationmatrix_t* matrix);
void shape_apply_inverse_transformation(shape_t* shape, transformationmatrix_t* matrix);

coordinate_t shape_get_width(shape_t* shape);
coordinate_t shape_get_height(shape_t* shape);

// curve segments
void shape_curve_add_line_segment(shape_t* shape, point_t* startpt, point_t* endpt);

int shape_get_center(shape_t* shape, coordinate_t* x, coordinate_t* y);

int shape_resize_lrtb(shape_t* shape, coordinate_t left, coordinate_t right, coordinate_t top, coordinate_t bottom);
void shape_resolve_path(shape_t* shape);
void shape_triangulate_polygon(shape_t* shape);
void shape_rasterize_curve(shape_t* shape);

#endif /* OPC_SHAPE_H */
