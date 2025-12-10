#include "bltrshape.h"

#include <stdlib.h>

struct bltrshape {
    struct point* bl;
    struct point* tr;
    const struct generics* layer;
};

struct bltrshape* bltrshape_create(const struct point* bl, const struct point* tr, const struct generics* layer)
{
    struct bltrshape* bltrshape = malloc(sizeof(*bltrshape));
    bltrshape->bl = point_copy(bl);
    bltrshape->tr = point_copy(tr);
    bltrshape->layer = layer;
    return bltrshape;
}

struct bltrshape* bltrshape_create_xy(coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try, const struct generics* layer)
{
    struct bltrshape* bltrshape = malloc(sizeof(*bltrshape));
    bltrshape->bl = point_create(blx, bly);
    bltrshape->tr = point_create(trx, try);
    bltrshape->layer = layer;
    return bltrshape;
}

void bltrshape_destroy(void* v)
{
    struct bltrshape* bltrshape = v;
    point_destroy(bltrshape->bl);
    point_destroy(bltrshape->tr);
    free(bltrshape);
}

/* const void* v because it is used as copy constructor */
void* bltrshape_copy(const void* v)
{
    const struct bltrshape* bltrshape = v;
    return bltrshape_create(bltrshape->bl, bltrshape->tr, bltrshape->layer);
}

struct point* bltrshape_get_bl(const struct bltrshape* bltrshape)
{
    return bltrshape->bl;
}

struct point* bltrshape_get_tr(const struct bltrshape* bltrshape)
{
    return bltrshape->tr;
}

const struct generics* bltrshape_get_layer(const struct bltrshape* bltrshape)
{
    return bltrshape->layer;
}

int bltrshape_is_layer(const struct bltrshape* bltrshape, const struct generics* layer)
{
    return bltrshape->layer == layer;
}
