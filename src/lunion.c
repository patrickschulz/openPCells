#include <stddef.h>
#include <stdbool.h>

#include "lua/lauxlib.h"

#include "point.h"

typedef coordinate_t lpc;

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

bool rectangle_union(
    lpc bl1x, lpc bl1y, lpc tr1x, lpc tr1y, 
    lpc bl2x, lpc bl2y, lpc tr2x, lpc tr2y, 
    lpc* blx, lpc* bly, lpc* trx, lpc* try
)
{
    order_t xorder = rect_order(bl1x, tr1x, bl2x, tr2x);
    order_t yorder = rect_order(bl1y, tr1y, bl2y, tr2y);
    if(xorder == NOINTERSECTION || yorder == NOINTERSECTION)
    {
        return false;
    }
    if(xorder != EQUAL && yorder != EQUAL) // polygon union, one order has to be EQUAL for rectangle union
    {
        return false;
    }
    switch(xorder)
    {
        case HALFEQUALLEFTREGULAR:
            *blx = bl1x;
            *trx = tr2x;
            break;
        case HALFEQUALLEFTINVERSE:
            *blx = bl1x;
            *trx = tr1x;
            break;
        case HALFEQUALRIGHTREGULAR:
            *blx = bl1x;
            *trx = tr1x;
            break;
        case HALFEQUALRIGHTINVERSE:
            *blx = bl2x;
            *trx = tr1x;
            break;
        case EQUAL:
            *blx = bl1x;
            *trx = tr1x;
            break;
        case OUTER:
            *blx = bl1x;
            *trx = tr1x;
            break;
        case INNER:
            *blx = bl2x;
            *trx = tr2x;
            break;
        case REGULAR:
            *blx = bl1x;
            *trx = tr2x;
            break;
        case INVERSE:
            *blx = bl2x;
            *trx = tr1x;
            break;
        case NOINTERSECTION:
            return false;
            break;
    }
    switch(yorder)
    {
        case HALFEQUALLEFTREGULAR:
            *bly = bl1y;
            *try = tr2y;
            break;
        case HALFEQUALLEFTINVERSE:
            *bly = bl1y;
            *try = tr1y;
            break;
        case HALFEQUALRIGHTREGULAR:
            *bly = bl1y;
            *try = tr1y;
            break;
        case HALFEQUALRIGHTINVERSE:
            *bly = bl2y;
            *try = tr1y;
            break;
        case EQUAL:
            *bly = bl1y;
            *try = tr1y;
            break;
        case OUTER:
            *bly = bl1y;
            *try = tr1y;
            break;
        case INNER:
            *bly = bl2y;
            *try = tr2y;
            break;
        case REGULAR:
            *bly = bl1y;
            *try = tr2y;
            break;
        case INVERSE:
            *bly = bl2y;
            *try = tr1y;
            break;
        case NOINTERSECTION:
            return false;
            break;
    }
    return true;
}

int lrectangle_union(lua_State* L)
{
    lpc blx, bly, trx, try;
    lpc bl1x, bl1y, tr1x, tr1y;
    lpc bl2x, bl2y, tr2x, tr2y;
    bool res = rectangle_union(bl1x, bl1y, tr1x, tr1y, bl2x, bl2y, tr2x, tr2y, &blx, &bly, &trx, &try);
    if(res)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

/*
static void remove_array_element(rectangle_t** array, size_t* num, size_t index)
{
    rectangle_destroy(array[index]);
    for(size_t i = index + 1; i < *num; ++i)
    {
        array[i - 1] = array[i];
    }
    --(*num);
}
*/

/*
size_t rectangle_union_all(rectangle_t** rectangles, size_t num)
{
    size_t i = 0;
    size_t j = 1;
    while(1)
    {
        if(i == num - 1 && j == num) break;
        rectangle_t* rect1 = rectangles[i];
        rectangle_t* rect2 = rectangles[j];
        rectangle_t* result = rectangle_union(rect1, rect2);
        if(result)
        {
            rectangles[i] = result;
            rectangle_destroy(rect1);
            remove_array_element(rectangles, &num, j);
            // restart iteration
            i = 0;
            j = 1;
        }
        else
        {
            ++j;
        }
        if(j > num)
        {
            ++i;
            j = i + 1;
        }
    }
    return num;
}
*/

int open_lunion_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "rectangle", lrectangle_union },
        { NULL,        NULL             }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "union");
    return 0;
}
