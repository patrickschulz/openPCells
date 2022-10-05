#ifndef OPC_GRAPHICS_H
#define OPC_GRAPHICS_H

#include <stddef.h>

#include "point.h"
#include "vector.h"

void graphics_raster_line_segment(point_t* startpt, point_t* endpt, unsigned int grid, int allow45, struct vector* result);
void graphics_raster_arc_segment(point_t* startpt, double startangle, double endangle, coordinate_t radius, int clockwise, unsigned int grid, int allow45, struct vector* result);
void graphics_raster_cubic_bezier_segment(const point_t* startpt, const point_t* cpt1, const point_t* cpt2, const point_t* endpt, unsigned int grid, int allow45, struct vector* result);

struct vector* graphics_cubic_bezier(const struct const_vector* curve);

#endif // OPC_GRAPHICS_H
