#ifndef OPC_OBJECT_IMPLEMENTATION
#error "This header must only be included in the implementation files of the object module. It is not intended for external use."
#endif

#ifndef OPC_OBJECT_UTIL_H
#define OPC_OBJECT_UTIL_H

#include "point.h"
#include "transformationmatrix.h"

void objectutil_fix_rectangle_order(struct point* bl, struct point* tr);
void objectutil_fix_rectangle_order_xy(coordinate_t* blx, coordinate_t* bly, coordinate_t* trx, coordinate_t* try);
void objectutil_transform_to_global_coordinates_xy(const struct transformationmatrix* trans, coordinate_t* x, coordinate_t* y);
void objectutil_transform_to_global_coordinates_pt(const struct transformationmatrix* trans, struct point* pt);
void objectutil_transform_to_local_coordinates_xy(const struct transformationmatrix* trans, coordinate_t* x, coordinate_t* y);
void objectutil_transform_to_local_coordinates_pt(const struct transformationmatrix* trans, struct point* pt);

#endif /* OPC_OBJECT_UTIL_H */
