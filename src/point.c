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

point_t* point_copy(point_t* pt)
{
    point_t* new = point_create(pt->x, pt->y);
    return new;
}

void point_translate(point_t* pt, coordinate_t x, coordinate_t y)
{
    pt->x += x;
    pt->y += y;
}
