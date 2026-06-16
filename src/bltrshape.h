#ifndef OPC_BLTRSHAPE_H
#define OPC_BLTRSHAPE_H

#include "lua/lua.h"

#include "point.h"
#include "technology.h"

struct bltrshape;

struct bltrshape* bltrshape_create_xy(coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try, const struct generics* layer, const char* net);
struct bltrshape* bltrshape_create_xy_no_net(coordinate_t blx, coordinate_t bly, coordinate_t trx, coordinate_t try);
struct bltrshape* bltrshape_create(const struct point* bl, const struct point* tr, const struct generics* layer, const char* net);
struct bltrshape* bltrshape_create_no_net(const struct point* bl, const struct point* tr);
struct bltrshape* bltrshape_create_from_table(lua_State* L, int index);
void bltrshape_push_table(lua_State* L, const struct bltrshape* bltrshape);
void bltrshape_destroy(void* v);
void* bltrshape_copy(const void* v); /* const void* v because it is used as copy constructor */
struct point* bltrshape_get_bl(struct bltrshape* bltrshape);
struct point* bltrshape_get_tr(struct bltrshape* bltrshape);
const struct point* bltrshape_get_bl_const(const struct bltrshape* bltrshape);
const struct point* bltrshape_get_tr_const(const struct bltrshape* bltrshape);
const struct generics* bltrshape_get_layer(const struct bltrshape* bltrshape);
int bltrshape_is_layer(const struct bltrshape* bltrshape, const struct generics* layer);
const char* bltrshape_get_net(const struct bltrshape* bltrshape);
int bltrshape_is_net(const struct bltrshape* bltrshape, const char* net);
int bltrshape_equal_nets(const struct bltrshape* bltrshape1, const struct bltrshape* bltrshape2);
int bltrshape_is_intersection(const struct bltrshape* bltrshape1, const struct bltrshape* bltrshape2, int onlyfull);
struct bltrshape* bltrshape_intersection(const struct bltrshape* bltrshape1, const struct bltrshape* bltrshape2, int onlyfull);

#endif /* OPC_BLTRSHAPE_H */
