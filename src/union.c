#include "union.h"

#include <stddef.h>
#include <stdbool.h>

#include "point.h"
#include "shape.h"

typedef enum
{
    NOINTERSECTION,
    REGULAR,
    INVERSE,
    HALFEQUALLEFTREGULAR,
    HALFEQUALLEFTINVERSE,
    HALFEQUALRIGHTREGULAR,
    HALFEQUALRIGHTINVERSE,
    EQUAL,
    OUTER,
    INNER
} order_t;

static order_t rect_order(coordinate_t bl1, coordinate_t tr1, coordinate_t bl2, coordinate_t tr2)
{
    if(bl1  > tr2 || bl2  > tr1) return NOINTERSECTION;
    if(bl1  < bl2 && tr1  > tr2) return OUTER;
    if(bl2  < bl1 && tr2  > tr1) return INNER;
    if(bl1 == bl2 && tr1 == tr2) return EQUAL;
    if(bl1 == bl2 && tr1  < tr2) return HALFEQUALLEFTREGULAR;
    if(bl1 == bl2 && tr1  > tr2) return HALFEQUALLEFTINVERSE;
    if(tr1 == tr2 && bl1  < bl2) return HALFEQUALRIGHTREGULAR;
    if(tr1 == tr2 && bl1  > bl2) return HALFEQUALRIGHTINVERSE;
    if(tr1 >= bl2 && bl1  < bl2) return REGULAR;
    if(tr2 >= bl1 && bl2  < bl1) return INVERSE;
    return NOINTERSECTION;
}

shape_t* rectangle_union(shape_t* rect1, shape_t* rect2)
{
    coordinate_t bl1x = rect1->points[0]->x;
    coordinate_t bl1y = rect1->points[0]->y;
    coordinate_t tr1x = rect1->points[1]->x;
    coordinate_t tr1y = rect1->points[1]->y;
    coordinate_t bl2x = rect2->points[0]->x;
    coordinate_t bl2y = rect2->points[0]->y;
    coordinate_t tr2x = rect2->points[1]->x;
    coordinate_t tr2y = rect2->points[1]->y;
    order_t xorder = rect_order(bl1x, tr1x, bl2x, tr2x);
    order_t yorder = rect_order(bl1y, tr1y, bl2y, tr2y);
    if(xorder == NOINTERSECTION || yorder == NOINTERSECTION)
    {
        return NULL;
    }
    if(xorder != EQUAL && yorder != EQUAL) // polygon union, one order has to be EQUAL for rectangle union
    {
        return NULL;
    }
    coordinate_t blx, bly, trx, try;
    switch(xorder)
    {
        case HALFEQUALLEFTREGULAR:
            blx = bl1x;
            trx = tr2x;
            break;
        case HALFEQUALLEFTINVERSE:
            blx = bl1x;
            trx = tr1x;
            break;
        case HALFEQUALRIGHTREGULAR:
            blx = bl1x;
            trx = tr1x;
            break;
        case HALFEQUALRIGHTINVERSE:
            blx = bl2x;
            trx = tr1x;
            break;
        case EQUAL:
            blx = bl1x;
            trx = tr1x;
            break;
        case OUTER:
            blx = bl1x;
            trx = tr1x;
            break;
        case INNER:
            blx = bl2x;
            trx = tr2x;
            break;
        case REGULAR:
            blx = bl1x;
            trx = tr2x;
            break;
        case INVERSE:
            blx = bl2x;
            trx = tr1x;
            break;
        default: // silence warning about not handling NOINTERSECTION, which is handled earlier
            break;
    }
    switch(yorder)
    {
        case HALFEQUALLEFTREGULAR:
            bly = bl1y;
            try = tr2y;
            break;
        case HALFEQUALLEFTINVERSE:
            bly = bl1y;
            try = tr1y;
            break;
        case HALFEQUALRIGHTREGULAR:
            bly = bl1y;
            try = tr1y;
            break;
        case HALFEQUALRIGHTINVERSE:
            bly = bl2y;
            try = tr1y;
            break;
        case EQUAL:
            bly = bl1y;
            try = tr1y;
            break;
        case OUTER:
            bly = bl1y;
            try = tr1y;
            break;
        case INNER:
            bly = bl2y;
            try = tr2y;
            break;
        case REGULAR:
            bly = bl1y;
            try = tr2y;
            break;
        case INVERSE:
            bly = bl2y;
            try = tr1y;
            break;
        default: // silence warning about not handling NOINTERSECTION, which is handled earlier
            break;
    }
    shape_t* new = shape_create_rectangle(blx, bly, trx, try);
    new->layer = rect1->layer;
    return new;
}

size_t union_rectangle_all(struct vector* rectangles)
{
    int i = 0;
    int j = 1;
    while(1)
    {
        //if(i == vector_size(rectangles) - 1 && j == vector_size(rectangles)) break;
        if(i >= vector_size(rectangles) - 1) break;
        shape_t* rect1 = vector_get(rectangles, i);
        shape_t* rect2 = vector_get(rectangles, j);
        shape_t* result = rectangle_union(rect1, rect2);
        if(result)
        {
            vector_set(rectangles, i, result);
            shape_destroy(rect1);
            vector_remove(rectangles, j, shape_destroy);
            // restart iteration
            i = 0;
            j = 1;
        }
        else
        {
            ++j;
        }
        if(j > vector_size(rectangles) - 1)
        {
            ++i;
            j = i + 1;
        }
    }
    return vector_size(rectangles);
}

