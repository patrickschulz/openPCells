#ifndef OPC_OBJECT_UTIL_H
#define OPC_OBJECT_UTIL_H

#include "point.h"

void objectutil_fix_rectangle_order(struct point* bl, struct point* tr);
void objectutil_fix_rectangle_order_xy(coordinate_t* blx, coordinate_t* bly, coordinate_t* trx, coordinate_t* try);

#endif /* OPC_OBJECT_UTIL_H */
