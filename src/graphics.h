#ifndef OPC_GRAPHICS_H
#define OPC_GRAPHICS_H

#include <stddef.h>

#include "point.h"
#include "vector.h"

void graphics_raster_line_segment(point_t* startpt, point_t* endpt, unsigned int grid, int allow45, struct vector* result);
void graphics_raster_arc_segment(point_t* firstpt, point_t* centerpt, point_t* lastpt, unsigned int grid, int allow45, struct vector* result);

struct vector* graphics_cubic_bezier(struct vector* curve);

#endif // OPC_GRAPHICS_H
