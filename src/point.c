#include "point.h"

#include <stdlib.h>

point_t* point_create(coordinate_t x, coordinate_t y)
{
    point_t* pt = malloc(sizeof(*pt));
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
    const point_t* pt = v;
    point_t* new = point_create(pt->x, pt->y);
    return new;
}

inline coordinate_t point_getx(const point_t* pt)
{
    return pt->x;
}

inline coordinate_t point_gety(const point_t* pt)
{
    return pt->y;
}

void point_translate(point_t* pt, coordinate_t x, coordinate_t y)
{
    pt->x += x;
    pt->y += y;
}

point_t* point_create_minimum(void)
{
    return point_create(COORDINATE_MIN, COORDINATE_MIN);
}

point_t* point_create_maximum(void)
{
    return point_create(COORDINATE_MAX, COORDINATE_MAX);
}

void point_update_minimum(point_t** min, const point_t* pt)
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

void point_update_maximum(point_t** max, const point_t* pt)
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

coordinate_t point_xdifference(const point_t* pt1, const point_t* pt2)
{
    return pt1->x - pt2->x;
}

coordinate_t point_ydifference(const point_t* pt1, const point_t* pt2)
{
    return pt1->y - pt2->y;
}
