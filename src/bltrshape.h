#ifndef OPC_BLTRSHAPE_H
#define OPC_BLTRSHAPE_H

#include "point.h"

struct bltrshape;

struct bltrshape* bltrshape_create(const struct point* bl, const struct point* tr);
void bltrshape_destroy(void* v);
void* bltrshape_copy(const void* v); /* const void* v because it is used as copy constructor */
const struct point* bltrshape_get_bl(const struct bltrshape* bltrshape);
const struct point* bltrshape_get_tr(const struct bltrshape* bltrshape);

#endif /* OPC_BLTRSHAPE_H */
