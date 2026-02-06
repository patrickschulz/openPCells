#ifndef OPC_BLTRSHAPE_H
#define OPC_BLTRSHAPE_H

#include "point.h"
#include "technology.h"

struct bltrshape;

struct bltrshape* bltrshape_create(const struct point* bl, const struct point* tr, const struct generics* layer);
struct bltrshape* bltrshape_create_xy(coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try, const struct generics* layer);
void bltrshape_destroy(void* v);
void* bltrshape_copy(const void* v); /* const void* v because it is used as copy constructor */
struct point* bltrshape_get_bl(struct bltrshape* bltrshape);
struct point* bltrshape_get_tr(struct bltrshape* bltrshape);
const struct point* bltrshape_get_bl_const(const struct bltrshape* bltrshape);
const struct point* bltrshape_get_tr_const(const struct bltrshape* bltrshape);
const struct generics* bltrshape_get_layer(const struct bltrshape* bltrshape);
int bltrshape_is_layer(const struct bltrshape* bltrshape, const struct generics* layer);

#endif /* OPC_BLTRSHAPE_H */
