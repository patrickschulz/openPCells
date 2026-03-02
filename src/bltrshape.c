#include "bltrshape.h"

#include <stdlib.h>
#include <string.h>

#include "util.h"
#include "helpers.h"
#include "lpoint.h"

struct bltrshape {
    struct point* bl;
    struct point* tr;
    const struct generics* layer;
    char* net;
};

struct bltrshape* bltrshape_create_xy(coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try, const struct generics* layer, const char* net)
{
    struct bltrshape* bltrshape = malloc(sizeof(*bltrshape));
    bltrshape->bl = point_create(blx, bly);
    bltrshape->tr = point_create(trx, try);
    bltrshape->layer = layer;
    bltrshape->net = util_strdup(net);
    return bltrshape;
}

struct bltrshape* bltrshape_create_xy_no_net(coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try)
{
    return bltrshape_create_xy(blx, bly, trx, try, NULL, NULL);
}

struct bltrshape* bltrshape_create(const struct point* bl, const struct point* tr, const struct generics* layer, const char* net)
{
    return bltrshape_create_xy(point_getx(bl), point_gety(bl), point_getx(tr), point_gety(tr), layer, net);
}

struct bltrshape* bltrshape_create_no_net(const struct point* bl, const struct point* tr)
{
    return bltrshape_create_xy(point_getx(bl), point_gety(bl), point_getx(tr), point_gety(tr), NULL, NULL);
}

struct bltrshape* bltrshape_create_from_table(lua_State* L, int index)
{
    struct bltrshape* bltrshape = malloc(sizeof(*bltrshape));
    lua_getfield(L, index, "bl");
    struct lpoint* lbl = lpoint_checkpoint(L, -1);
    bltrshape->bl = point_copy(lpoint_get(lbl));
    lua_pop(L, 1);
    lua_getfield(L, index, "tr");
    struct lpoint* ltr = lpoint_checkpoint(L, -1);
    bltrshape->tr = point_copy(lpoint_get(ltr));
    lua_pop(L, 1);
    lua_getfield(L, index, "layer");
    bltrshape->layer = lua_touserdata(L, -1);
    lua_pop(L, 1);
    lua_getfield(L, index, "net");
    const char* net = lua_tostring(L, -1);
    bltrshape->net = util_strdup(net);
    lua_pop(L, 1);
    return bltrshape;
}

void bltrshape_push_table(lua_State* L, struct bltrshape* bltrshape)
{
    lua_newtable(L);
    /* net */
    lua_pushstring(L, bltrshape->net);
    lua_setfield(L, -2, "net");
    /* net */
    lua_pushlightuserdata(L, (void*)bltrshape->layer);
    lua_setfield(L, -2, "layer");
    /* bl */
    lpoint_create_internal_pt(L, bltrshape->bl);
    lua_setfield(L, -2, "bl");
    /* tr */
    lpoint_create_internal_pt(L, bltrshape->tr);
    lua_setfield(L, -2, "tr");
}

void bltrshape_destroy(void* v)
{
    struct bltrshape* bltrshape = v;
    point_destroy(bltrshape->bl);
    point_destroy(bltrshape->tr);
    free(bltrshape->net);
    free(bltrshape);
}

/* const void* v because it is used as copy constructor */
void* bltrshape_copy(const void* v)
{
    const struct bltrshape* bltrshape = v;
    return bltrshape_create(bltrshape->bl, bltrshape->tr, bltrshape->layer, bltrshape->net);
}

struct point* bltrshape_get_bl(struct bltrshape* bltrshape)
{
    return bltrshape->bl;
}

struct point* bltrshape_get_tr(struct bltrshape* bltrshape)
{
    return bltrshape->tr;
}

const struct point* bltrshape_get_bl_const(const struct bltrshape* bltrshape)
{
    return bltrshape->bl;
}

const struct point* bltrshape_get_tr_const(const struct bltrshape* bltrshape)
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

const char* bltrshape_get_net(const struct bltrshape* bltrshape)
{
    return bltrshape->net;
}

int bltrshape_is_net(const struct bltrshape* bltrshape, const char* net)
{
    return strcmp(bltrshape->net, net) == 0;
}

int bltrshape_equal_nets(const struct bltrshape* bltrshape1, const struct bltrshape* bltrshape2)
{
    return strcmp(bltrshape1->net, bltrshape2->net) == 0;
}

int bltrshape_is_intersection(const struct bltrshape* bltrshape1, const struct bltrshape* bltrshape2, int onlyfull)
{
    coordinate_t bl1x = point_getx(bltrshape1->bl);
    coordinate_t bl1y = point_gety(bltrshape1->bl);
    coordinate_t tr1x = point_getx(bltrshape1->tr);
    coordinate_t tr1y = point_gety(bltrshape1->tr);
    coordinate_t bl2x = point_getx(bltrshape2->bl);
    coordinate_t bl2y = point_gety(bltrshape2->bl);
    coordinate_t tr2x = point_getx(bltrshape2->tr);
    coordinate_t tr2y = point_gety(bltrshape2->tr);
    if(onlyfull)
    {
        if(
            ((bl1x <= bl2x) && (tr1x >= tr2x) && (bl2y <= bl1y) && (tr2y >= tr1y)) ||
            ((bl2x <= bl1x) && (tr2x >= tr1x) && (bl1y <= bl2y) && (tr1y >= tr2y))
          )
        {
            return 1;
        }
    }
    else
    {
        coordinate_t xoverlap = MAX2(0, MIN2(tr1x, tr2x) - MAX2(bl1x, bl2x));
        coordinate_t yoverlap = MAX2(0, MIN2(tr1y, tr2y) - MAX2(bl1y, bl2y));
        if((xoverlap > 0) && (yoverlap > 0))
        {
            return 1;
        }
    }
    return 0;
}

struct bltrshape* bltrshape_intersection(const struct bltrshape* bltrshape1, const struct bltrshape* bltrshape2, int onlyfull)
{
    coordinate_t bl1x = point_getx(bltrshape1->bl);
    coordinate_t bl1y = point_gety(bltrshape1->bl);
    coordinate_t tr1x = point_getx(bltrshape1->tr);
    coordinate_t tr1y = point_gety(bltrshape1->tr);
    coordinate_t bl2x = point_getx(bltrshape2->bl);
    coordinate_t bl2y = point_gety(bltrshape2->bl);
    coordinate_t tr2x = point_getx(bltrshape2->tr);
    coordinate_t tr2y = point_gety(bltrshape2->tr);
    coordinate_t blx = MAX2(bl1x, bl2x);
    coordinate_t bly = MAX2(bl1y, bl2y);
    coordinate_t trx = MIN2(tr1x, tr2x);
    coordinate_t try = MIN2(tr1y, tr2y);
    if((trx > blx) && (try > bly))
    {
        int success = 0;
        if(!onlyfull)
        {
            success = 1;
        }
        else // full intersection
        {
            if(
                ((bl1x <= bl2x) && (tr1x >= tr2x) && (bl2y <= bl1y) && (tr2y >= tr1y)) ||
                ((bl2x <= bl1x) && (tr2x >= tr1x) && (bl1y <= bl2y) && (tr1y >= tr2y))
              )
            {
                success = 1;
            }
        }
        if(success)
        {
            return bltrshape_create_xy(blx, bly, trx, try, NULL, NULL);
        }
    }
    return NULL;
}
