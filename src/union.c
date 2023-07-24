#include "union.h"

#include <stddef.h>
#include <stdbool.h>

#include "point.h"
#include "shape.h"

enum order
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
};

static enum order rect_order(coordinate_t bl1, coordinate_t tr1, coordinate_t bl2, coordinate_t tr2)
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

struct shape* rectangle_union(struct shape* rect1, struct shape* rect2)
{
    const point_t *bl1;
    const point_t *tr1;
    shape_get_rectangle_points(rect1, &bl1, &tr1);
    const point_t *bl2;
    const point_t *tr2;
    shape_get_rectangle_points(rect2, &bl2, &tr2);
    enum order xorder = rect_order(bl1->x, tr1->x, bl2->x, tr2->x);
    enum order yorder = rect_order(bl1->y, tr1->y, bl2->y, tr2->y);
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
            blx = bl1->x;
            trx = tr2->x;
            break;
        case HALFEQUALLEFTINVERSE:
            blx = bl1->x;
            trx = tr1->x;
            break;
        case HALFEQUALRIGHTREGULAR:
            blx = bl1->x;
            trx = tr1->x;
            break;
        case HALFEQUALRIGHTINVERSE:
            blx = bl2->x;
            trx = tr1->x;
            break;
        case EQUAL:
            blx = bl1->x;
            trx = tr1->x;
            break;
        case OUTER:
            blx = bl1->x;
            trx = tr1->x;
            break;
        case INNER:
            blx = bl2->x;
            trx = tr2->x;
            break;
        case REGULAR:
            blx = bl1->x;
            trx = tr2->x;
            break;
        case INVERSE:
            blx = bl2->x;
            trx = tr1->x;
            break;
        default: // silence warning about not handling NOINTERSECTION, which is handled earlier
            return NULL;
            break;
    }
    switch(yorder)
    {
        case HALFEQUALLEFTREGULAR:
            bly = bl1->y;
            try = tr2->y;
            break;
        case HALFEQUALLEFTINVERSE:
            bly = bl1->y;
            try = tr1->y;
            break;
        case HALFEQUALRIGHTREGULAR:
            bly = bl1->y;
            try = tr1->y;
            break;
        case HALFEQUALRIGHTINVERSE:
            bly = bl2->y;
            try = tr1->y;
            break;
        case EQUAL:
            bly = bl1->y;
            try = tr1->y;
            break;
        case OUTER:
            bly = bl1->y;
            try = tr1->y;
            break;
        case INNER:
            bly = bl2->y;
            try = tr2->y;
            break;
        case REGULAR:
            bly = bl1->y;
            try = tr2->y;
            break;
        case INVERSE:
            bly = bl2->y;
            try = tr1->y;
            break;
        default: // silence warning about not handling NOINTERSECTION, which is handled earlier
            return NULL;
            break;
    }
    struct shape* new = shape_create_rectangle(shape_get_layer(rect1), blx, bly, trx, try);
    return new;
}

size_t union_rectangle_all(struct vector* rectangles)
{
    int i = 0;
    int j = 1;
    while(1)
    {
        //if(i == vector_size(rectangles) - 1 && j == vector_size(rectangles)) break;
        if(i >= (int)vector_size(rectangles) - 1) break;
        struct shape* rect1 = vector_get(rectangles, i);
        struct shape* rect2 = vector_get(rectangles, j);
        struct shape* result = rectangle_union(rect1, rect2);
        if(result)
        {
            vector_set(rectangles, i, result);
            shape_destroy(rect1);
            vector_remove(rectangles, j);
            // restart iteration
            i = 0;
            j = 1;
        }
        else
        {
            ++j;
        }
        if(j > (int)vector_size(rectangles) - 1)
        {
            ++i;
            j = i + 1;
        }
    }
    return vector_size(rectangles);
}

