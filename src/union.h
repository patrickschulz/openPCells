#ifndef OPC_UNION_H
#define OPC_UNION_H

#include "point.h"
#include "vector.h"

int rectangle_union(coordinate_t blx1, coordinate_t bly1, coordinate_t trx1, coordinate_t try1, coordinate_t blx2, coordinate_t bly2, coordinate_t trx2, coordinate_t try2, coordinate_t* blx, coordinate_t* bly, coordinate_t* trx, coordinate_t* try);
size_t union_rectangle_all(struct vector* rectangles);

#endif // OPC_UNION_H
