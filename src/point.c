#include "point.h"

#include <stdlib.h>

point_t* point_create(coordinate_t x, coordinate_t y)
{
    point_t* pt = malloc(sizeof(*pt));
    pt->x = x;
    pt->y = y;
    return pt;
}

void point_destroy(point_t* pt)
{
    free(pt);
}
