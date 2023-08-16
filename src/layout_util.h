#ifndef OPC_LAYOUT_UTIL_H
#define OPC_LAYOUT_UTIL_H

#include "point.h"
#include "vector.h"

int layout_util_is_point_in_polygon(coordinate_t x, coordinate_t y, const struct const_vector* polygon);

#endif /* OPC_LAYOUT_UTIL_H */
