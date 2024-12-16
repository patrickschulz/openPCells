#ifndef OPC_GRAPHICS_H
#define OPC_GRAPHICS_H

#include <stddef.h>

#include "point.h"
#include "vector.h"

void graphics_rasterize_line_segment(const struct point* startpt, const struct point* endpt, unsigned int grid, int allow45, struct vector* result);
void graphics_rasterize_arc_segment(struct point* startpt, double startangle, double endangle, coordinate_t radius, int clockwise, unsigned int grid, int allow45, struct vector* result);
void graphics_rasterize_cubic_bezier_segment(const struct point* startpt, const struct point* cpt1, const struct point* cpt2, const struct point* endpt, unsigned int grid, int allow45, struct vector* result);

struct vector* graphics_cubic_bezier(const struct const_vector* curve);

#endif // OPC_GRAPHICS_H
