#include "point.h"

#include <stdlib.h>

struct point* point_create(coordinate_t x, coordinate_t y)
{
    struct point* pt = malloc(sizeof(*pt));
    pt->x = x;
    pt->y = y;
    return pt;
}

void point_destroy(void* pt)
{
    free(pt);
}

void* point_copy(const void* v)
{
    const struct point* pt = v;
    struct point* new = point_create(pt->x, pt->y);
    return new;
}

inline coordinate_t point_getx(const struct point* pt)
{
    return pt->x;
}

inline coordinate_t point_gety(const struct point* pt)
{
    return pt->y;
}

void point_translate(struct point* pt, coordinate_t x, coordinate_t y)
{
    pt->x += x;
    pt->y += y;
}

struct point* point_create_minimum(void)
{
    return point_create(COORDINATE_MIN, COORDINATE_MIN);
}

struct point* point_create_maximum(void)
{
    return point_create(COORDINATE_MAX, COORDINATE_MAX);
}

void point_update_minimum(struct point** min, const struct point* pt)
{
    if(pt->x < (*min)->x)
    {
        (*min)->x = pt->x;
    }
    if(pt->y < (*min)->y)
    {
        (*min)->y = pt->y;
    }
}

void point_update_maximum(struct point** max, const struct point* pt)
{
    if(pt->x > (*max)->x)
    {
        (*max)->x = pt->x;
    }
    if(pt->y > (*max)->y)
    {
        (*max)->y = pt->y;
    }
}

coordinate_t point_xdifference(const struct point* pt1, const struct point* pt2)
{
    return pt1->x - pt2->x;
}

coordinate_t point_ydifference(const struct point* pt1, const struct point* pt2)
{
    return pt1->y - pt2->y;
}
