#include "bltrshape.h"

#include <stdlib.h>

struct bltrshape {
    struct point* bl;
    struct point* tr;
};

struct bltrshape* bltrshape_create(const struct point* bl, const struct point* tr)
{
    struct bltrshape* bltrshape = malloc(sizeof(*bltrshape));
    bltrshape->bl = point_copy(bl);
    bltrshape->tr = point_copy(tr);
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
    return bltrshape_create(bltrshape->bl, bltrshape->tr);
}

struct point* bltrshape_get_bl(const struct bltrshape* bltrshape)
{
    return bltrshape->bl;
}

struct point* bltrshape_get_tr(const struct bltrshape* bltrshape)
{
    return bltrshape->tr;
}
